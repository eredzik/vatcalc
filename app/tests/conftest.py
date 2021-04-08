import os
from typing import Generator

import pytest
from fastapi.testclient import TestClient
from tortoise.contrib.test import finalizer, initializer

# Set db to inmemory sqlite
os.environ["DATABASE_URL"] = "sqlite://:memory:"
# Set JWT_SECRET to some random value
os.environ["JWT_SECRET"] = "abc"

from ..database import TORTOISE_ORM
from ..main import app


@pytest.fixture(scope="module")
@pytest.mark.filterwarnings("@coroutine")
def client() -> Generator:
    models = TORTOISE_ORM.get("apps").get("models").get("models")  # type: ignore
    initializer(models)
    with TestClient(app) as c:
        yield c
    finalizer()
