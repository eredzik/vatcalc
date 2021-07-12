from starlette.status import (
    HTTP_200_OK,
    HTTP_401_UNAUTHORIZED,
    HTTP_402_PAYMENT_REQUIRED,
)
from starlette.testclient import TestClient

from .test_auth import get_random_logged_user


def test_me_path_success(client: TestClient):
    r_user = get_random_logged_user(client)
    r_user = client.get("/api/user/me", cookies=client.cookies.get_dict())
    assert r_user.status_code == HTTP_200_OK


def test_me_path_failure(client: TestClient):
    r_user = client.get("/api/user/me", cookies=client.cookies.get_dict())
    assert r_user.status_code == HTTP_401_UNAUTHORIZED
