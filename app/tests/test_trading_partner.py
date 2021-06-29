from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_401_UNAUTHORIZED,
    HTTP_409_CONFLICT,
    HTTP_422_UNPROCESSABLE_ENTITY,
)
from starlette.testclient import TestClient

from .auth_utils import create_random_enterprise, get_random_user_header


def create_trading_partner(
    client: TestClient,
    user_header,
    enterprise_id,
    nip_number="0000000000",
    name="name",
    address="address",
):
    response_partner = client.post(
        "/api/trading_partner",
        json={
            "nip_number": nip_number,
            "name": name,
            "address": address,
            "enterprise": enterprise_id,
        },
        headers=user_header,
    )
    return response_partner


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


def test_add_trading_partner_duplicate(client: TestClient):
    user = get_random_user_header(client)
    enterprise = create_random_enterprise(client, user)
    trading_partner = create_trading_partner(client, user, enterprise)
    assert trading_partner.status_code == HTTP_201_CREATED
    trading_partner1 = create_trading_partner(client, user, enterprise)
    assert trading_partner1.status_code == HTTP_409_CONFLICT


def test_add_trading_partner_unauthenticated(client: TestClient):
    user = get_random_user_header(client)
    user1 = get_random_user_header(client)
    enterprise1 = create_random_enterprise(client, user1)
    trading_partner = create_trading_partner(client, user, enterprise1)
    assert trading_partner.status_code == HTTP_401_UNAUTHORIZED
