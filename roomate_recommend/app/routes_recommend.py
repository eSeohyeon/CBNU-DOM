from fastapi import APIRouter, HTTPException, Body
import pandas as pd
import torch

from autoencoder import load_model
from recommender import compute_recommendations
from firebase_client import db, get_checklist, get_checklists_by_dormitory

router = APIRouter()

# ---------------- 모델 로딩 (서버 시작 시 한 번만) ----------------
model = load_model()

# ---------------- 체크리스트 유효성 함수 ----------------
def valid_checklist(x):
    if isinstance(x, list):
        return any(isinstance(i, dict) and len(i) > 0 for i in x)
    if isinstance(x, dict):
        return len(x) > 0
    return False

# ---------------- 추천 API ----------------
@router.post("/recommend")
def recommend(
    user_id: str = Body(..., embed=True),
    method: str = Body("ai", embed=True),
    filters: dict = Body(None, embed=True)
):
    # 1 Firestore users 컬렉션에서 사용자 존재 확인
    user_doc_ref = db.collection("users").document(user_id)
    if not user_doc_ref.get().exists:
        raise HTTPException(status_code=404, detail="존재하지 않는 사용자입니다.")

    # 2 checklists 컬렉션에서 체크리스트 + 생활관 조회
    user_checklist_doc = get_checklist(user_id)
    if not user_checklist_doc:
        raise HTTPException(status_code=400, detail="사용자 체크리스트가 존재하지 않습니다.")

    checklist = user_checklist_doc.get("checklist", {})

    # '취미/기타' key 존재 여부 확인 후 '생활관' 가져오기
    dormitory = ""
    if "취미/기타" in checklist and isinstance(checklist["취미/기타"], dict):
        dormitory = checklist["취미/기타"].get("생활관", "")

    if not dormitory or not checklist:
        raise HTTPException(status_code=400, detail="체크리스트 또는 생활관 정보가 누락되었습니다.")



    # 3 동일 생활관 체크리스트 불러오기
    df_selected = get_checklists_by_dormitory(dormitory)
    if df_selected is None or len(df_selected) < 1:
        raise HTTPException(status_code=400, detail="추천 대상자가 존재하지 않습니다.")

    # UID 컬럼이 없다면 index를 UID로 설정
    if "uid" not in df_selected.columns:
        df_selected["uid"] = df_selected.index.astype(str)
    df_selected["uid"] = df_selected["uid"].astype(str).str.strip()

    # 4 본인 제거
    # df_selected = df_selected[df_selected["uid"] != str(user_id).strip()]

    # 5 체크리스트 없는 사용자 제거
    df_selected = df_selected[df_selected["checklist"].apply(valid_checklist)]

    if len(df_selected) == 0:
        raise HTTPException(status_code=400, detail="유효한 추천 대상자가 없습니다.")

    # ---------------- 추천 방식 분기 ----------------
    if method == "ai":
        if len(df_selected) < 5:
            raise HTTPException(status_code=400, detail="해당 생활관 인원이 30명 미만이라 AI 추천이 불가합니다.")

        # AI 추천 점수 계산
        recommendations = compute_recommendations(user_id, dormitory, df_selected=df_selected)

        # Firestore UID 기준으로 반환, 본인/체크리스트 없는 사용자 제거
        formatted = []
        for rec in recommendations.get("recommendations", []):
            candidate_id = rec.get("candidate_id") or rec.get("user_id")
            if not candidate_id or candidate_id == user_id:
                continue
            full_info = rec.get("full_info", {})
            if not valid_checklist(full_info.get("checklist")):
                continue
            # === checklist 구조 정리 ===
            checklist = full_info.get("checklist", {})
            full_info["checklist"] = checklist

            formatted.append({
                "candidate_id": candidate_id,
                "score": rec.get("score", 0.0),
                "top_features": rec.get("top_features", []),
                "similarity_scores": rec.get("similarity_scores", {}),
                "full_info": full_info,
            })

        return {"status" : "success", "recommendations": formatted}

    elif method == "filter":
        if not filters:
            raise HTTPException(status_code=400, detail="필터 조건이 필요합니다.")

        df_filtered = df_selected.copy()

        # 필터 적용
        for key, value in filters.items():
            if key not in df_filtered.columns:
                continue
            if isinstance(value, list):
                df_filtered = df_filtered[df_filtered[key].isin(value)]
            else:
                df_filtered = df_filtered[df_filtered[key] == value]

        # 체크리스트 없는 사용자 제거
        df_filtered = df_filtered[df_filtered["checklist"].apply(valid_checklist)]

        if df_filtered.empty:
            return {"recommendations": []}

        # 결과 생성
        results = []
        for _, row in df_filtered.iterrows():
            results.append({
                "user_id": row["uid"],
                "checklist": row["checklist"],
            })

        return {"recommendations": results}

    else:
        raise HTTPException(status_code=400, detail="잘못된 추천 방식입니다. ('ai' 또는 'filter')")
