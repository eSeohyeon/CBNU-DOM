import firebase_admin
from firebase_admin import credentials, firestore
import os
import pandas as pd


# ---------------- Firebase 초기화 ----------------
SERVICE_ACCOUNT_PATH = os.path.join(
    os.path.dirname(__file__), "cbnu-dom-firebase-adminsdk-fbsvc-0a520b5d90.json"
)

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

db = firestore.client()

def save_checklist(user_id: str, dormitory: str, checklist: list):
    """
    user_id 기준으로 체크리스트 저장 (새 문서)
    """
    doc_ref = db.collection("checklists").document(user_id)
    if doc_ref.get().exists:
        raise ValueError("체크리스트는 이미 존재합니다.")
    
    doc_ref.set({
        "dormitory": dormitory,
        "checklist": checklist
    })
    return True

def update_checklist(user_id: str, dormitory: str, checklist: list):
    """
    기존 체크리스트 수정
    """
    doc_ref = db.collection("checklists").document(user_id)
    if not doc_ref.get().exists:
        raise ValueError("체크리스트가 존재하지 않습니다.")
    
    doc_ref.update({
        "dormitory": dormitory,
        "checklist": checklist
    })
    return True

def get_checklist(user_id: str):
    """
    user_id 기준 체크리스트 조회
    """
    doc = db.collection("checklists").document(user_id).get()
    if doc.exists:
        return doc.to_dict()
    return None


def get_checklists_by_dormitory(dormitory: str):
    docs = db.collection("checklists").stream()  # 전체 체크리스트 불러오기
    users = []

    for doc in docs:
        data = doc.to_dict()
        user_id = doc.id
        checklist = data.get("checklist", {})

        # checklist가 dict인지 확인하고 '취미/기타' 안 '생활관' 가져오기
        dorm = ""
        if isinstance(checklist, dict) and "취미/기타" in checklist:
            dorm = checklist["취미/기타"].get("생활관", "")

        if dorm == dormitory:  # 동일 생활관만 선택
            users.append({
                "user_id": user_id,
                "dormitory": dorm,
                "checklist": checklist
            })

    df = pd.DataFrame(users)
    if not df.empty:
        df.set_index("user_id", inplace=True)
    else:
        df = pd.DataFrame(columns=["dormitory", "checklist"])
    return df
