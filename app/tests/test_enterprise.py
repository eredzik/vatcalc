from starlette.status import HTTP_200_OK, HTTP_201_CREATED, HTTP_401_UNAUTHORIZED
from starlette.testclient import TestClient

from .auth_utils import get_random_user_header


def test_enterprise_add(client: TestClient):
    r = client.post(
        "/api/enterprise1",
        json={"name": "somename"},
        headers=get_random_user_header(client),
    )
    assert r.status_code == HTTP_201_CREATED


def test_enterprise_add_unauthorized(client: TestClient):
    r = client.post(
        "/api/enterprise1",
        json={"name": "somename"},
    )
    assert r.status_code == HTTP_401_UNAUTHORIZED


def test_enterprise_get_for_user(client: TestClient):
    header = get_random_user_header(client)
    r = client.post(
        "/api/enterprise1",
        json={"name": "somename"},
        headers=header,
    )
    r2 = client.get(
        "/api/enterprise1",
        headers=header,
    )
    assert r2.status_code == HTTP_200_OK
    assert r2.json() == [{"name": "somename", "enterprise_id": r.json()['id'], "role": "ADMIN"}]
