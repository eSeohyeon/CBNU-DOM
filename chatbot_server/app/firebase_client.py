import firebase_admin
from firebase_admin import credentials, firestore
import os

# 서비스 계정 키 경로
SERVICE_ACCOUNT_PATH = os.path.join(
    os.path.dirname(__file__), "app/cbnu-dom-firebase-adminsdk-fbsvc-0a520b5d90.json"
)

# Firebase 초기화 (중복 초기화 방지)
if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

# Firestore 클라이언트
db = firestore.client()