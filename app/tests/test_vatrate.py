from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_401_UNAUTHORIZED,
    HTTP_409_CONFLICT,
)
from starlette.testclient import TestClient

from .test_auth import get_random_logged_user
from .test_enterprise import create_enterprise


def create_vat_rate(client: TestClient, enterprise, vat_rate=0.23, comment="test1"):
    response_partner = client.post(
        "/api/vatrate",
        json={
            "vat_rate": vat_rate,
            "comment": comment,
            "enterprise_id": enterprise.json()["id"],
        },
        cookies=client.cookies.get_dict(),
    )
    return response_partner


def test_unauthorized_add_vatrate(client: TestClient):
    user = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    user1 = get_random_logged_user(client)
    r = create_vat_rate(client, enterprise)
    assert r.status_code == HTTP_401_UNAUTHORIZED


def test_correct_add_vatrate(client: TestClient):
    user_header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r = create_vat_rate(client, enterprise)

    assert r.status_code == HTTP_201_CREATED


def test_create_only_one_vatrate(client: TestClient):
    user_header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r = create_vat_rate(client, enterprise)
    assert r.status_code == HTTP_201_CREATED
    r = create_vat_rate(client, enterprise)
    assert r.status_code == HTTP_409_CONFLICT
    r_get = client.get(
        "/api/vatrate",
        cookies=client.cookies.get_dict(),
        params={"page": 1, "enterprise_id": enterprise.json()["id"]},
    )
    assert r_get.status_code == HTTP_200_OK
    assert len(r_get.json()) == 1


def test_create_multiple_vat_rates(client: TestClient):
    user_header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    vatrate = create_vat_rate(client, enterprise, vat_rate=0.23)
    assert vatrate.status_code == HTTP_201_CREATED
    vatrate2 = create_vat_rate(client, enterprise, vat_rate=0.22)
    assert vatrate2.status_code == HTTP_201_CREATED
    r_get = client.get(
        "/api/vatrate",
        cookies=client.cookies.get_dict(),
        params={"page": 1, "enterprise_id": enterprise.json()["id"]},
    )
    assert r_get.status_code == HTTP_200_OK
    assert len(r_get.json()) == 2
