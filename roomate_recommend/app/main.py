from fastapi import FastAPI
from routes_checklist import router as checklist_router
from routes_recommend import router as recommend_router

app = FastAPI()

app.include_router(checklist_router, prefix="/checklist")
app.include_router(recommend_router)
