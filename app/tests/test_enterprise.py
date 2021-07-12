from starlette.status import (HTTP_200_OK, HTTP_201_CREATED,
                              HTTP_401_UNAUTHORIZED)
from starlette.testclient import TestClient

from .test_auth import get_random_logged_user


def create_enterprise(
    client: TestClient,
    name="somename",
    nip_number="0623601757",
    address="address1",
):
    response = client.post(
        "/enterprise",
        json={"name": name, "nip_number": nip_number, "address": address},
        cookies=client.cookies.get_dict(),
    )
    assert response.status_code == HTTP_201_CREATED
    return response


def test_enterprise_add(client: TestClient):
    user = get_random_logged_user(client)
    r = create_enterprise(client)
    assert r is not None
    r2 = create_enterprise(client)
    assert r2 is not None


def test_enterprise_add_unauthorized(client: TestClient):
    r = client.post(
        "/enterprise",
        json={"name": "somename", "nip_number": "0623601757", "address": "adres1"},
    )
    assert r.status_code == HTTP_401_UNAUTHORIZED


def test_enterprise_get_for_user(client: TestClient):
    user_response = get_random_logged_user(client)
    r = create_enterprise(client)
    r2 = client.get(
        "/enterprise?page=1", cookies=client.cookies.get_dict()
    )
    assert r2.status_code == HTTP_200_OK
    assert r2.json() == [
        {
            "name": "somename",
            "enterprise_id": r.json()["id"],
            "role": "ADMIN",
            "nip_number": "0623601757",
            "address": "address1",
        }
    ]
