import os
import secrets
import warnings
from typing import Generator

import alembic
import pytest
from alembic.config import Config
from databases import Database
from fastapi import FastAPI
from fastapi.testclient import TestClient


# Apply migrations at beginning and end of testing session
@pytest.fixture(scope="function")
def apply_migrations():
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    os.environ["TESTING"] = "1"
    os.environ["JWT_SECRET"] = secrets.token_urlsafe(32)
    os.environ["CORS_ALLOWED_ORIGINS"] = "localhost"

    config = Config("alembic.ini")
    alembic.command.upgrade(config, "head")  # type: ignore
    yield
    alembic.command.downgrade(config, "base")  # type: ignore


# Create a new application for testing
@pytest.fixture
def app(apply_migrations: None) -> FastAPI:

    from ..main import get_app

    return get_app()


# Grab a reference to our database when needed
@pytest.fixture
def db(app: FastAPI) -> Database:
    return app.state._db


# Make requests in our tests
@pytest.fixture
def client(app: FastAPI) -> Generator[TestClient, None, None]:
    with (TestClient(app)) as client:
        yield client
