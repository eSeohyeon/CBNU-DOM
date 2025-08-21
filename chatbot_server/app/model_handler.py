import pandas as pd
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import pickle

# ------------------------------
# 1. 답변 엑셀 불러오기
# ------------------------------
answers_df = pd.read_excel("answers.xlsx")  # 1열: Label, 2열: Answer
answers_dict = dict(zip(answers_df.iloc[:,0], answers_df.iloc[:,1]))

# ------------------------------
# 2. Rule-based 분류
# ------------------------------
def normalize(text):
    return text.replace(" ", "").lower()

def rule_based_classify(question: str) -> str:
    normalized_question = normalize(question)

    rules = {
        ("와이파이", "공유기", "랜선", "와파", "네트워크", "wifi", "인터넷"): "인터넷_연결방법",
        ("헬스장", "체단실"): "헬스장_이용안내",
        ("키분실", "카드분실"): "키_분실안내",
        "RC": "RC_안내",
        ("중도입주", "중도입사"): "중도_입주안내",
        "외박": "외박_규정안내",
        ("택배", "우편", "등기", "소포"): "택배_관련사항",
        "통금": "통금_규정안내",
        "추가모집": "추가_모집안내",
        ("청주기숙사", "청주긱사"): "입사_청주시학생",
        ("중도퇴소", "중도퇴실", "중도퇴거"): "중도_퇴소",
        ("기숙사확인", "긱사확인", "호실배정"): "확인_방법",
        "환불": "환불_방법",
        ("세탁", "빨래", "세제", "섬유유연제"): "세탁_안내",
        "커트라인": "커트라인_확인",
        "벌점": "벌점_안내",
        "계절": "계절학기",
        ("담배", "흡연"): "흡연_사항",
        "ATM": "ATM_위치안내",
        ("주류", "소주", "맥주"): "주류_규정안내",
        "스터디룸": "스터디룸",
        ("게임", "셧다운", "vpn"): "게임"
    }

    for keywords, label in rules.items():
        if isinstance(keywords, tuple):
            if any(normalize(keyword) in normalized_question for keyword in keywords):
                return label
        else:
            if normalize(keywords) in normalized_question:
                return label

    return None

# ------------------------------
# 3. 딥러닝 모델 로드
# ------------------------------
class DLModelHandler:
    def __init__(self, model_dir="kobert_model_0.95"):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = AutoModelForSequenceClassification.from_pretrained(model_dir)
        self.tokenizer = AutoTokenizer.from_pretrained(model_dir, use_fast=False)
        self.model.to(self.device)
        self.model.eval()

        # Label Encoder
        with open(f"{model_dir}/label_encoder.pkl", "rb") as f:
            self.le = pickle.load(f)

    def predict(self, question: str) -> str:
        inputs = self.tokenizer(question, 
                                return_tensors="pt", 
                                padding="max_length", 
                                truncation=True, 
                                max_length=64)
        inputs = {k:v.to(self.device) for k,v in inputs.items()}
        with torch.no_grad():
            outputs = self.model(**inputs)
            pred = torch.argmax(outputs.logits, dim=1).item()
        label = self.le.inverse_transform([pred])[0]
        return label

# ------------------------------
# 4. 답변 가져오기
# ------------------------------
def get_answer(label: str) -> str:
    return answers_dict.get(label, "죄송합니다, 답변을 찾을 수 없습니다.")