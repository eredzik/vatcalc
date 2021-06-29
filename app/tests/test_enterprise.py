from starlette.status import HTTP_200_OK, HTTP_201_CREATED, HTTP_401_UNAUTHORIZED
from starlette.testclient import TestClient

from .auth_utils import get_random_user_header, create_random_enterprise


def test_enterprise_add(client: TestClient):
    r = create_random_enterprise(client, get_random_user_header(client))
    assert r is not None
    r2 = create_random_enterprise(client, get_random_user_header(client))
    assert r2 is not None


def test_enterprise_add_unauthorized(client: TestClient):
    r = client.post(
        "/api/enterprise",
        json={"name": "somename", "nip_number": "0623601757", "address": "adres1"},
    )
    assert r.status_code == HTTP_401_UNAUTHORIZED


def test_enterprise_get_for_user(client: TestClient):
    header = get_random_user_header(client)
    r = client.post(
        "/api/enterprise",
        json={"name": "somename", "nip_number": "0623601757", "address": "adres1"},
        headers=header,
    )
    r2 = client.get(
        "/api/enterprise",
        headers=header,
    )
    assert r2.status_code == HTTP_200_OK
    assert r2.json() == [{"name": "somename", "enterprise_id": r.json()['id'], "role": "ADMIN"}]
