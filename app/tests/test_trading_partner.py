from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_401_UNAUTHORIZED,
    HTTP_409_CONFLICT,
    HTTP_422_UNPROCESSABLE_ENTITY,
)
from starlette.testclient import TestClient

from .test_auth import get_random_logged_user
from .test_enterprise import create_enterprise


def create_trading_partner(
    client: TestClient,
    enterprise,
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
            "enterprise_id": enterprise.json()["id"],
        },
        cookies=client.cookies.get_dict(),
    )
    return response_partner


def test_add_trading_partner_failing_unauthorized(client: TestClient):
    response = client.post("/api/trading_partner", json={})
    assert response.status_code == HTTP_401_UNAUTHORIZED


def test_add_trading_partner_failing_wrong_payload(client: TestClient):
    header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    response = create_trading_partner(
        client, enterprise=enterprise, nip_number="notnumber"
    )
    assert response.status_code == HTTP_422_UNPROCESSABLE_ENTITY


def test_add_trading_partner_ok(client: TestClient):
    header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    trading_partner = create_trading_partner(
        client, enterprise, "0623601757", "somename", "someadress"
    )
    assert trading_partner.status_code == HTTP_201_CREATED


def test_add_trading_partner_duplicate(client: TestClient):
    user = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    trading_partner = create_trading_partner(client, enterprise)
    assert trading_partner.status_code == HTTP_201_CREATED
    trading_partner1 = create_trading_partner(client, enterprise)
    assert trading_partner1.status_code == HTTP_409_CONFLICT


def test_add_trading_partner_unauthenticated(client: TestClient):
    user1 = get_random_logged_user(client)
    enterprise1 = create_enterprise(client)
    user = get_random_logged_user(client)
    trading_partner = create_trading_partner(client, enterprise1)
    assert trading_partner.status_code == HTTP_401_UNAUTHORIZED


def test_add_trading_partner_multiple(client: TestClient):
    user1 = get_random_logged_user(client)
    enterprise1 = create_enterprise(client)
    trading_partner = create_trading_partner(
        client, enterprise1, nip_number="0000000000"
    )
    assert trading_partner.status_code == HTTP_201_CREATED
    trading_partner2 = create_trading_partner(
        client, enterprise1, nip_number="4645037591"
    )
    assert trading_partner2.status_code == HTTP_201_CREATED
    enterprise_id=enterprise1.json()['id']
    query=f"/api/trading_partner?page=1&enterprise_id={enterprise_id}"
    trading_partners = client.get(
        query,
        cookies=client.cookies.get_dict(),
    )
    assert trading_partners.status_code == HTTP_200_OK
    assert len(trading_partners.json()) == 2
