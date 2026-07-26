"""Runtime configuration, loaded from environment variables / .env."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    # HTTP server
    host: str = "0.0.0.0"
    port: int = 8000
    reload: bool = False
    cors_origins: str = "*"

    # When set, every /api request must carry a matching "x-api-key" header.
    api_key: str | None = None

    # Firebase Admin
    firebase_project_id: str = "esperflow-1b828"
    firebase_service_account_path: str | None = "./serviceAccountKey.json"
    firebase_service_account_json: str | None = None

    # Firestore collections (must match the Flutter app)
    donors_collection: str = "donors"
    blood_requests_collection: str = "bloodRequests"

    # Broadcast behaviour
    notify_only_active_donors: bool = False

    @property
    def cors_origin_list(self) -> list[str]:
        raw = (self.cors_origins or "*").strip()
        if raw == "*":
            return ["*"]
        return [origin.strip() for origin in raw.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
