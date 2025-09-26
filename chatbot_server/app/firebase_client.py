import firebase_admin
from firebase_admin import credentials, firestore
import os

# 서비스 계정 키 경로
SERVICE_ACCOUNT_PATH = os.path.join(
    os.path.dirname(__file__), "cbnu-dom-firebase-adminsdk-fbsvc-0a520b5d90.json"
)

try:
    # 이미 초기화된 앱이 있으면 가져오기
    app = firebase_admin.get_app()
except ValueError:
    # 없으면 새로 초기화
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    app = firebase_admin.initialize_app(cred)


# Firestore 클라이언트
db = firestore.client()