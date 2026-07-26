"""EsperFlow backend entry point.

    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.config import settings
from app.firebase import get_app
from app.routers import blood_requests, health

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
)
logger = logging.getLogger("esperflow")


@asynccontextmanager
async def lifespan(_: FastAPI):
    # Fail loudly at boot rather than on the first user's submit.
    try:
        app_instance = get_app()
        logger.info("Firebase Admin ready for project %s", app_instance.project_id)
    except Exception:  # noqa: BLE001 - the server still serves /health while you fix creds
        logger.exception(
            "Firebase Admin could not start. /api endpoints will fail until "
            "credentials are configured (see backend/README.md)."
        )
    yield


app = FastAPI(
    title="EsperFlow API",
    description=(
        "Trusted sender for EsperFlow blood requests: stores a request in "
        "Firestore and pushes it to every registered user via Firebase Cloud "
        "Messaging."
    ),
    version=__version__,
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(blood_requests.router)


@app.get("/", tags=["health"])
def root() -> dict:
    return {
        "service": "EsperFlow API",
        "version": __version__,
        "docs": "/docs",
    }
