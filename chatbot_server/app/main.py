from fastapi import FastAPI
from routes import router
from firebase_client import db

app = FastAPI(title="Dormitory Chatbot API")

# Firebase 초기화
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# Firestore 클라이언트 생성
db = firestore.client()

# 라우터 등록
app.include_router(router)