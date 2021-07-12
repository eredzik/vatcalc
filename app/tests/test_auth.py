import random
import string

from fastapi.testclient import TestClient
from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_204_NO_CONTENT,
    HTTP_400_BAD_REQUEST,
    HTTP_401_UNAUTHORIZED,
    HTTP_422_UNPROCESSABLE_ENTITY,
)


# Utility functions
def login_sample_user(client: TestClient, email: str, password: str):
    response = client.post(
        "/api/login",
        data={"username": email, "password": password},
    )
    return response


def register_sample_user(cl: TestClient, email: str, password: str):
    response = cl.post(
        "/api/register", data={"username": email, "email": email, "password": password}
    )
    return response


def get_random_email():
    return (
        "".join(random.choice(string.ascii_letters) for x in range(10)) + "@domain.pl"
    )


def get_random_logged_user(client: TestClient):
    email = get_random_email()
    password = "somelongpassword"
    r = register_sample_user(client, email, password)
    r2 = login_sample_user(client, email, password)
    return r2


# Tests


def test_register(client: TestClient):
    r = register_sample_user(client, get_random_email(), "somepass")
    assert r.status_code == HTTP_201_CREATED


def test_login_not_registered(client: TestClient):
    r = login_sample_user(client, get_random_email(), "somepass")
    assert r.status_code == HTTP_401_UNAUTHORIZED


def test_login_succesful(client: TestClient):
    email = get_random_email()
    passw = "somepass"
    r = register_sample_user(client, email, passw)
    assert r.cookies.get("session") is None
    assert client.cookies.get("session") is None
    assert r.status_code == HTTP_201_CREATED
    login_response = login_sample_user(client, email, passw)
    assert login_response.status_code == HTTP_204_NO_CONTENT
    assert login_response.cookies.get("session") is not None
    assert client.cookies.get("session") is not None


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
    assert r2.status_code == HTTP_204_NO_CONTENT


def test_login_user_not_existing(client: TestClient):
    email = get_random_email()
    password = "corrrectlongpassword"
    r = login_sample_user(client, email, password)
    assert r.status_code == HTTP_401_UNAUTHORIZED
