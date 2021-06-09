from fastapi.testclient import TestClient
from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_400_BAD_REQUEST,
    HTTP_422_UNPROCESSABLE_ENTITY,
)

from .auth_utils import (
    get_random_email,
    get_random_logged_user_token,
    login_sample_user,
    register_sample_user,
)


def test_register_user(client: TestClient):

    r = register_sample_user(client, get_random_email(), "corrrectlongpassword")
    assert r.status_code == HTTP_201_CREATED


def test_register_wrong_email(client: TestClient):
    r = register_sample_user(client, "notaemail", "corrrectlongpassword")
    assert r.status_code == HTTP_422_UNPROCESSABLE_ENTITY


def test_login_user(client: TestClient):
    email = get_random_email()
    password = "corrrectlongpassword"
    r = register_sample_user(client, email, password)
    r2 = login_sample_user(client, email, password)
    assert r2.status_code == HTTP_200_OK
    assert r2.json()["access_token"] != None


def test_get_random_token(client: TestClient):
    assert get_random_logged_user_token(client) is not None


def test_login_user_not_existing(client: TestClient):
    email = get_random_email()
    password = "corrrectlongpassword"
    r = login_sample_user(client, email, password)
    assert r.status_code == HTTP_400_BAD_REQUEST
    assert r.json()["detail"] == "LOGIN_BAD_CREDENTIALS"
