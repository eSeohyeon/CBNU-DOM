from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict
from firebase_client import update_checklist, save_checklist, get_checklist

router = APIRouter()

# ---------------- Pydantic 모델 ----------------
class ChecklistInput(BaseModel):
    user_id: str
    dormitory: str
    checklist: List[Dict[str, Dict[str, str]]]

# ---------------- 체크리스트 제출 API ----------------
@router.post("/checklist")
def submit_checklist(data: ChecklistInput):
    if get_checklist(data.user_id):
        raise HTTPException(status_code=400, detail="체크리스트는 이미 제출되었습니다.")
    
    save_checklist(data.user_id, data.dormitory, data.checklist)
    return {"message": "체크리스트가 성공적으로 저장되었습니다.", "user_id": data.user_id}

@router.put("/checklist/update")
def update_checklist_api(data: ChecklistInput):
    if not get_checklist(data.user_id):
        raise HTTPException(status_code=404, detail="존재하지 않는 체크리스트입니다.")
    
    update_checklist(data.user_id, data.dormitory, data.checklist)
    return {"message": "체크리스트가 성공적으로 수정되었습니다.", "user_id": data.user_id}
