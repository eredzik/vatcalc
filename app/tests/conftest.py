import os
import warnings

import alembic
import pytest
from alembic.config import Config
from databases import Database
from fastapi import FastAPI
from fastapi.testclient import TestClient


# Apply migrations at beginning and end of testing session
@pytest.fixture(scope="session")
def apply_migrations():
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    os.environ["TESTING"] = "1"
    config = Config("alembic.ini")
    alembic.command.upgrade(config, "head")  # type: ignore
    yield
    alembic.command.downgrade(config, "base")  # type: ignore


# Create a new application for testing
@pytest.fixture
def app(apply_migrations: None) -> FastAPI:
    from ..main import app

    print("ABC")
    return app


# Grab a reference to our database when needed
@pytest.fixture
def db(app: FastAPI) -> Database:
    return app.state._db


# Make requests in our tests
@pytest.fixture
def client(app: FastAPI) -> TestClient:
    with (TestClient(app)) as client:
        yield client
