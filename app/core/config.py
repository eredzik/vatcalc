import secrets
from typing import Any, Dict, List, Optional, Union
from pydantic import BaseSettings, PostgresDsn, validator
from pydantic.networks import AnyUrl


class Settings(BaseSettings):
    ACCESS_TOKEN_EXPIRE_SECONDS: int = 60 * 60 * 24 * 7  # 7 days
    JWT_SECRET: str
    # CORS_ALLOWED_ORIGINS: str

    POSTGRES_SERVER: Optional[str]
    POSTGRES_USER: Optional[str]
    POSTGRES_PASSWORD: Optional[str]
    POSTGRES_DB: Optional[str]
    DATABASE_URL: Optional[PostgresDsn] = None
    SOAP_ENDPOINT: str
    SOAP_KEY: str
    AWS_ACCESS_KEY_ID: str
    AWS_SECRET_ACCESS_KEY: str

    @validator("DATABASE_URL", pre=True)
    def assemble_db_connection(cls, v: Optional[str], values: Dict[str, Any]) -> Any:
        if isinstance(v, str):
            return v
        return PostgresDsn.build(
            scheme="postgresql",
            user=values.get("POSTGRES_USER"),
            password=values.get("POSTGRES_PASSWORD"),
            host=values.get("POSTGRES_SERVER", ""),
            path=f"/{values.get('POSTGRES_DB') or ''}",
        )


settings = Settings()
