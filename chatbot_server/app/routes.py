from fastapi import FastAPI, Query, APIRouter
from pydantic import BaseModel
from model_handler import rule_based_classify, DLModelHandler, get_answer

router = APIRouter() # app 두 개 있어서 수정한 부분

# DL 모델 핸들러 초기화
dl_model = DLModelHandler(model_dir="../models/kobert_model_0.95") # 모델 경로 때문에 수정한 부분

class QuestionRequest(BaseModel):
    question: str

@router.get("/") # 수정
def root():
    return {"message": "Dormitory Q&A API is running."}

@router.post("/get_answer") # 수정
def get_answer_api(request: QuestionRequest):
    question = request.question

    # 1. Rule-based 우선 적용
    label = rule_based_classify(question)

    # 2. Rule-based에서 못 찾으면 DL 모델로 예측
    if label is None:
        label = dl_model.predict(question)

    # 3. 둘 다 없으면 기본 안내 메시지
    if label is None:
        return {"answer": "죄송합니다, 답변을 찾을 수 없습니다."}

    # 4. Label에 맞는 답변 반환
    answer = get_answer(label)
    return {"answer": answer}
