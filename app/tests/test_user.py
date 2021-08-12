from starlette.status import *
from starlette.testclient import TestClient

from .test_auth import get_random_logged_user
from .test_enterprise import create_enterprise


def test_me_path_success(client: TestClient):
    r_user = get_random_logged_user(client)
    r_user = client.get("/user/me", cookies=client.cookies.get_dict())
    assert r_user.status_code == HTTP_200_OK


def test_me_path_failure(client: TestClient):
    r_user = client.get("/user/me", cookies=client.cookies.get_dict())
    assert r_user.status_code == HTTP_401_UNAUTHORIZED


def set_fav_enterprise(
    client: TestClient,
    fav_enterprise="123",
):
    response = client.patch(
        f"/user/me/preferred_enterprise?fav_enterprise={fav_enterprise}",
        cookies=client.cookies.get_dict(),
    )
    return response


def test_set_fav_enterprise(client: TestClient):
    user = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r = set_fav_enterprise(client, fav_enterprise=enterprise.json()["id"])
    assert r.status_code == HTTP_200_OK


def test_set_fav_enterprise_unauthorised(client: TestClient, fav_enterprise="123"):
    r = client.patch(
        "/user/me/preferred_enterprise", json={"fav_enterprise": fav_enterprise}
    )
    assert r.status_code == HTTP_401_UNAUTHORIZED


def test_get_fav_enterprise(client: TestClient):
    user = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r = set_fav_enterprise(client, fav_enterprise=enterprise.json()["id"])
    r2 = client.get("/user/me/preferred_enterprise", cookies=user.cookies.get_dict())
    assert r2.status_code == HTTP_200_OK


def test_no_fav_enterprise(client: TestClient):
    _ = get_random_logged_user(client)
    r = client.get("/user/me/preferred_enterprise", cookies=client.cookies.get_dict())
    assert r.status_code == HTTP_404_NOT_FOUND
    assert r.json() == {"detail": "Not found favorite enterprise."}
