from starlette.status import (
    HTTP_200_OK,
    HTTP_401_UNAUTHORIZED,
    HTTP_404_NOT_FOUND,
)
from starlette.testclient import TestClient

from .test_auth import get_random_logged_user
from .test_enterprise import create_enterprise


def set_fav_enterprise(
    client: TestClient,
    enterprise_id="123",
):
    response = client.patch(
        f"/user/me/preferred_enterprise?enterprise_id={enterprise_id}",
        cookies=client.cookies.get_dict(),
    )
    return response


def get_user_me(client: TestClient):
    return client.get("/user/me", cookies=client.cookies.get_dict())


def test_me_path_success(client: TestClient):
    _ = get_random_logged_user(client)
    r_user_me = get_user_me(client)
    assert r_user_me.status_code == HTTP_200_OK


def test_me_path_failure(client: TestClient):
    r_user = get_user_me(client)
    assert r_user.status_code == HTTP_401_UNAUTHORIZED


def test_set_fav_enterprise(client: TestClient):
    _ = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    assert get_user_me(client).json()["fav_enterprise_id"] is None
    r = set_fav_enterprise(client, enterprise_id=enterprise.json()["id"])
    assert r.status_code == HTTP_200_OK
    assert (
        get_user_me(client).json()["fav_enterprise_id"]
        == enterprise.json()["id"]
    )


def test_set_fav_enterprise_unauthorised(
    client: TestClient, fav_enterprise="123"
):
    r = client.patch(
        "/user/me/preferred_enterprise",
        json={"fav_enterprise": fav_enterprise},
    )
    assert r.status_code == HTTP_401_UNAUTHORIZED


def test_get_fav_enterprise(client: TestClient):
    user = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    _ = set_fav_enterprise(client, enterprise_id=enterprise.json()["id"])
    r2 = client.get(
        "/user/me/preferred_enterprise", cookies=user.cookies.get_dict()
    )
    assert r2.status_code == HTTP_200_OK


def test_no_fav_enterprise(client: TestClient):
    _ = get_random_logged_user(client)
    r = client.get(
        "/user/me/preferred_enterprise", cookies=client.cookies.get_dict()
    )
    assert r.status_code == HTTP_404_NOT_FOUND
    assert r.json() == {"detail": "Not found favorite enterprise."}
