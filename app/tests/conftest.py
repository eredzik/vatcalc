import os
from typing import Generator

import pytest
import sqlalchemy
from fastapi.testclient import TestClient

os.environ["JWT_SECRET"] = "abc"
import sqlalchemy as sa
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from ..database import Base, get_db
from ..main import app

SQLALCHEMY_DB_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DB_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():

    try:
        db: Session = TestingSessionLocal()
        yield db
    finally:
        db.close()  # type: ignore


@pytest.fixture(scope="module")
def client() -> Generator:

    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
