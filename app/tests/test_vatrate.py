from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_401_UNAUTHORIZED,
    HTTP_409_CONFLICT,
)
from starlette.testclient import TestClient

from .auth_utils import create_random_enterprise, get_random_user_header


def create_vat_rate(
    client: TestClient, user_header, enterprise_id, vat_rate=0.23, comment="test1"
):
    response_partner = client.post(
        "/api/vatrate",
        json={
            "vat_rate": vat_rate,
            "comment": comment,
            "enterprise": enterprise_id,
        },
        headers=user_header,
    )
    return response_partner



def test_failing_add_vatrate(client: TestClient):
    user_header = get_random_user_header(client)
    user2 = get_random_user_header(client)
    enterprise2 = create_random_enterprise(client, user2)
    r = client.post(
        "/api/vatrate",
        headers=user_header,
        json={"vat_rate": 0.1, "comment": "test2", "enterprise": enterprise2},
    )
    assert r.status_code == HTTP_401_UNAUTHORIZED


def test_correct_add_vatrate(client: TestClient):
    user_header = get_random_user_header(client)
    enterprise_id = create_random_enterprise(client, user_header)
    r = client.post(
        "/api/vatrate",
        headers=user_header,
        json={"vat_rate": 0.1, "comment": "test2", "enterprise": enterprise_id},
    )
    assert r.status_code == HTTP_201_CREATED


def test_create_only_one_vatrate(client: TestClient):
    user_header = get_random_user_header(client)
    enterprise = create_random_enterprise(client, user_header)
    r = client.post(
        "/api/vatrate",
        headers=user_header,
        json={"vat_rate": 0.1, "comment": "test2", "enterprise": enterprise},
    )
    assert r.status_code == HTTP_201_CREATED
    r = client.post(
        "/api/vatrate",
        headers=user_header,
        json={"vat_rate": 0.1, "comment": "test2", "enterprise": enterprise},
    )
    assert r.status_code == HTTP_409_CONFLICT
    r_get = client.get(
        "/api/vatrate",
        headers=user_header,
        params={"page": 1, "enterprise_id": enterprise["id"]},
    )
    assert r_get.status_code == HTTP_200_OK
    assert len(r_get.json()) == 1


def test_create_multiple_vat_rates(client: TestClient):
    user_header = get_random_user_header(client)
    enterprise = create_random_enterprise(client, user_header)
    vatrate = create_vat_rate(client, user_header, enterprise, vat_rate=0.23)
    assert vatrate.status_code == HTTP_201_CREATED
    vatrate2 = create_vat_rate(client, user_header, enterprise, vat_rate=0.22)
    assert vatrate2.status_code == HTTP_201_CREATED
    r_get = client.get(
        "/api/vatrate",
        headers=user_header,
        params={"page": 1, "enterprise_id": enterprise["id"]},
    )
    assert r_get.status_code == HTTP_200_OK
    assert len(r_get.json()) == 2