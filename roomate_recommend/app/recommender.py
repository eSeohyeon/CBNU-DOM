import torch
import pandas as pd
from firebase_admin import firestore

def compute_recommendations(user_id: str, dormitory: str, df_selected=None):
    """
    Flutter에서 Firestore에 저장한 체크리스트 기반 추천
    latent vector 없이 feature별 similarity + penalty 적용
    """
    def parse_multi_choice(x):
        if isinstance(x, list):
            return x
        if isinstance(x, str):
            return [i.strip() for i in x.split(",") if i.strip()]
        return []

    def parse_time(val):
        if isinstance(val, int):
            return [val]
        if isinstance(val, str):
            parts = val.replace("시", "").split(",")
            return [int(p.strip()) for p in parts if p.strip().isdigit()]
        if isinstance(val, list):
            result = []
            for v in val:
                if isinstance(v, int):
                    result.append(v)
                elif isinstance(v, str):
                    parts = v.replace("시", "").split(",")
                    result.extend([int(p.strip()) for p in parts if p.strip().isdigit()])
            return result
        return []

    def circular_time_diff(x, y):
        diff = abs(x - y) % 12
        return min(diff, 12 - diff)

    def jaccard_with_circular_time_bonus(a, b):
        set_a = set(parse_time(a))
        set_b = set(parse_time(b))
        if set_a == set_b:
            return 1.0
        inter = len(set_a & set_b)
        union = len(set_a | set_b)
        jaccard = inter / union if union > 0 else 0
        partial = 0
        count = 0
        for x in set_a:
            for y in set_b:
                diff = circular_time_diff(x, y)
                if diff == 1:
                    partial += 0.8
                    count += 1
                elif diff == 2:
                    partial += 0.5
                    count += 1
        if count > 0:
            partial /= count
            sim = 0.7 * jaccard + 0.3 * partial
        else:
            sim = jaccard
        return min(1.0, sim)

    # 1. DataFrame 준비
    if df_selected is None:
        from firebase_client import get_checklists_by_dormitory
        df_selected = get_checklists_by_dormitory(dormitory)

    if df_selected.empty or len(df_selected) < 5:
        return {"status": "unavailable", "message": "추천 기능은 30명 이상일 때만 활성화됩니다."}

    if "uid" not in df_selected.columns:
        df_selected["uid"] = df_selected.index.astype(str)
    df_selected["uid"] = df_selected["uid"].astype(str).str.strip()
    df_selected.set_index("uid", inplace=True)

    # 2. 체크리스트 풀기
    df_features = pd.json_normalize(df_selected["checklist"])
    expected_cols = [
        "생활패턴.취침시간","생활패턴.기상시간","생활패턴.샤워시각",
        "생활습관.청소","생활습관.잠버릇","생활습관.소리","생활습관.흡연여부",
        "성향.더위","성향.추위","성향.잠귀","성향.실내통화","성향.친구초대",
        "성향.실내취식","성향.벌레"
    ]
    for col in expected_cols:
        if col not in df_features.columns:
            df_features[col] = [[] for _ in range(len(df_features))]
        df_features[col] = df_features[col].apply(parse_multi_choice)

    columns_fit = [
        "취침시간","기상시간","샤워시각","청소","잠버릇","더위","추위",
        "소리","흡연여부","잠귀","실내통화","친구초대","실내취식","벌레"
    ]
    rename_map = {k: v for k, v in zip(expected_cols, columns_fit)}
    df_features_renamed = df_features.rename(columns=rename_map)

    # 3. 본인 row
    if user_id not in df_selected.index:
        return {"status": "unavailable", "message": "본인 체크리스트가 없습니다."}
    user_index = df_selected.index.get_loc(user_id)
    user_row = df_features_renamed.iloc[user_index]

    # 4. 점수 계산
    scores = []
    feature_sims_list = []

    for idx in range(len(df_selected)):
        if idx == user_index:
            scores.append(-1.0)
            feature_sims_list.append({})
            continue

        candidate_row = df_features_renamed.iloc[idx]

        feature_sims = {}
        sim_total = 0
        weight_total = 0

        for col in columns_fit:
            # 기존처럼 점수 계산용 feature
            if col in ["취침시간","기상시간"]:
                sim = jaccard_with_circular_time_bonus(parse_time(user_row[col]), parse_time(candidate_row[col]))
                sim_total += sim
                weight_total += 1
            elif col not in ["샤워시각","잠귀","잠버릇","벌레"]:
                set_a = set(user_row[col])
                set_b = set(candidate_row[col])
                sim = len(set_a & set_b)/len(set_a | set_b) if len(set_a | set_b) > 0 else 0
                sim_total += sim
                weight_total += 1
            # 샤워시각, 잠귀, 잠버릇, 벌레는 점수 계산에 제외
            # 하지만 similarity_scores에는 넣기
            if col == "샤워시각":
                user_times = set(parse_multi_choice(user_row[col]))
                cand_times = set(parse_multi_choice(candidate_row[col]))
                fixed_times = {"아침", "저녁"}
                sim_showertime = len(user_times & cand_times & fixed_times) / len((user_times | cand_times) & fixed_times) if len((user_times | cand_times) & fixed_times) > 0 else 0
                feature_sims[col] = sim_showertime
            elif col in ["잠귀","잠버릇","벌레"]:
                set_a = set(parse_multi_choice(user_row[col]))
                set_b = set(parse_multi_choice(candidate_row[col]))
                sim_other = len(set_a & set_b)/len(set_a | set_b) if len(set_a | set_b) > 0 else 0
                feature_sims[col] = sim_other
            else:
                feature_sims[col] = sim


        # penalty 적용
        # 샤워시간
        user_times = set(parse_multi_choice(user_row['샤워시각']))
        cand_times = set(parse_multi_choice(candidate_row['샤워시각']))
        fixed_times = {"아침", "저녁"}
        overlap_count = len(user_times & cand_times & fixed_times)
        total_fixed_count = len((user_times | cand_times) & fixed_times)
        penalty_shower = 0.3 * (overlap_count / total_fixed_count) if total_fixed_count>0 else 0

        # 잠귀 + 잠버릇
        user_ear = set(parse_multi_choice(user_row['잠귀']))
        cand_ear = set(parse_multi_choice(candidate_row['잠귀']))
        user_sleep = set(parse_multi_choice(user_row['잠버릇']))
        cand_sleep = set(parse_multi_choice(candidate_row['잠버릇']))
        bright_overlap = sum(1 for u in user_ear if u=='밝음' for c in cand_sleep if c!='없음')
        bright_overlap += sum(1 for c in cand_ear if c=='밝음' for u in user_sleep if u!='없음')
        max_penalty = 0.5
        total_possible = max(len(user_ear)*len(cand_sleep), len(cand_ear)*len(user_sleep))
        penalty_sleep = max_penalty * (bright_overlap/total_possible) if total_possible>0 else 0

        # 벌레
        user_bug = set(parse_multi_choice(user_row['벌레']))
        cand_bug = set(parse_multi_choice(candidate_row['벌레']))
        bad_eggs = {'극혐','못잡음'}
        overlap_bad = len(user_bug & cand_bug & bad_eggs)
        total_bad_possible = min(len(user_bug & bad_eggs), len(cand_bug & bad_eggs))
        penalty_bug = 0.5 * (overlap_bad/total_bad_possible) if total_bad_possible>0 else 0

        total_score = sim_total/weight_total - (penalty_shower + penalty_sleep + penalty_bug)
        total_score = max(total_score, 0)  # 음수 방지
        scores.append(total_score)
        feature_sims_list.append(feature_sims)

    # 5. 상위 후보 추출
    valid_scores = [s if s>0 else -float('inf') for s in scores]  # 본인 및 0점 제외
    scores_tensor = torch.tensor(valid_scores)
    top_n = min(10, len(scores))
    top_indices = torch.topk(scores_tensor, top_n).indices.tolist()

    # 6. Firestore 조회 + 결과
    db = firestore.client()
    results = []
    for rank, idx in enumerate(top_indices, 1):
        candidate_id = df_selected.index[idx]
        candidate_row = df_features_renamed.iloc[idx]

        user_data = {}
        user_ref = db.collection("users").document(candidate_id)
        user_doc = user_ref.get()
        if user_doc.exists:
            user_data = user_doc.to_dict()

        feature_sims = feature_sims_list[idx]
        top_features = [f[0] for f in sorted(feature_sims.items(), key=lambda x: -x[1])[:5]]
        score = round(float(scores[idx])*100,1)

        results.append({
            "rank": rank,
            "candidate_id": candidate_id,
            "score": score,
            "top_features": top_features,
            "similarity_scores": feature_sims,
            "full_info": {
                "user_id": candidate_id,
                "nickname": user_data.get("nickname",""),
                "department": user_data.get("department",""),
                "birthYear": user_data.get("birthYear",""),
                "enrollYear": user_data.get("enrollYear",""),
                "checklist": df_selected.loc[candidate_id]['checklist']
            }
        })

    return {"status":"success","recommendations":results}
