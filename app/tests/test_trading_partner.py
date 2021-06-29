from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_401_UNAUTHORIZED,
    HTTP_422_UNPROCESSABLE_ENTITY,
)
from starlette.testclient import TestClient

from .auth_utils import get_random_user_header


def test_add_trading_partner_failing_unauthorized(client: TestClient):
    response = client.post("/api/trading_partner", json={})
    assert response.status_code == HTTP_401_UNAUTHORIZED


def test_add_trading_partner_failing_wrong_payload(client: TestClient):
    header = get_random_user_header(client)
    response = client.post(
        "/api/trading_partner",
        json={"nip_number": "5", "name": "", "adress": ""},
        headers=header,
    )
    assert response.status_code == HTTP_422_UNPROCESSABLE_ENTITY


def test_add_trading_partner_ok(client: TestClient):
    header = get_random_user_header(client)
    r_create_enterprise = client.post(
        "/api/enterprise",
        headers=header,
        json={"name": "somename", "nip_number": "0623601757", "address": "adres1"},
    )
    response = client.post(
        "/api/trading_partner",
        json={
            "nip_number": "0623601757",
            "name": "abaca",
            "address": "gdagaga",
            "enterprise": r_create_enterprise.json(),
        },
        headers=header,
    )
    assert response.status_code == HTTP_201_CREATED


def test_add_trading_partner_failing_wrong_nip(client: TestClient):
    header = get_random_user_header(client)
    r_create_enterprise = client.post(
        "/api/enterprise",
        headers=header,
        json={"name": "somename", "nip_number": "0623601757", "address": "adres1"},
    )
    response = client.post(
        "/api/trading_partner",
        json={
            "nip_number": "14341",
            "name": "",
            "adress": "",
            "enterprise": r_create_enterprise.json()["id"],
        },
        headers=header,
    )
    assert response.status_code == HTTP_422_UNPROCESSABLE_ENTITY
