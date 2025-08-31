from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime, timezone
from firebase_client import db                # Firebase Firestore 접근
from model_handler import rule_based_classify, DLModelHandler, get_answer

router = APIRouter()

# DL 모델 핸들러 초기화
dl_model = DLModelHandler(model_dir="../models/kobert_model_0.95")  # 모델 경로

class QuestionRequest(BaseModel):
    question: str
    user_id: str  # 사용자 ID

@router.get("/")
def root():
    return {"message": "Dormitory Chatbot API is running."}

@router.post("/get_answer")
def get_answer_api(request: QuestionRequest):
    question = request.question
    user_id = request.user_id

    # 1. Rule-based 분류
    label = rule_based_classify(question)

    # 2. DL 모델 fallback
    if label is None:
        label = dl_model.predict(question)

    # 3. 답변 결정
    if label is None:
        answer = "죄송합니다, 답변을 찾을 수 없습니다."
    else:
        answer = get_answer(label)

    # 4. Firestore에 로그 저장
    try:
        doc_ref = db.collection("chatbot_logs").document()
        doc_ref.set({
            "user_id": user_id,
            "question": question,
            "answer": answer,
            "timestamp": datetime.now(timezone.utc) 
        })
    except Exception as e:
        print(f"Firestore 저장 오류: {e}")

    return {"answer": answer}
