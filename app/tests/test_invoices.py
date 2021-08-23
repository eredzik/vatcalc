from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_401_UNAUTHORIZED,
    HTTP_409_CONFLICT,
)
from starlette.testclient import TestClient

from .test_auth import get_random_logged_user
from .test_enterprise import create_enterprise
from .test_trading_partner import create_trading_partner
from .test_vatrate import create_vat_rate


def create_invoice_no_vatrate(client: TestClient, enterprise, trading_partner):
    return client.post(
        "/invoice",
        cookies=client.cookies.get_dict(),
        json={
            "invoice_type": "INBOUND",
            "invoice_date": "2021-06-29",
            "trading_partner_id": trading_partner.json()["id"],
            "enterprise_id": enterprise.json()["id"],
            "invoice_business_id": "string",
            "invoicepositions": [
                {
                    "name": "string",
                    "vat_rate_id": 0,
                    "num_items": 0,
                    "price_net": 0,
                }
            ],
        },
    )

def create_invoice_vatrate(client: TestClient, enterprise, trading_partner, vat_rate):
    return client.post(
        "/invoice",
        cookies=client.cookies.get_dict(),
        json={
            "invoice_type": "INBOUND",
            "invoice_date": "2021-06-29",
            "trading_partner_id": trading_partner.json()["id"],
            "enterprise_id": enterprise.json()["id"],
            "invoice_business_id": "string",
            "invoicepositions": [
                {
                    "name": "string",
                    "vat_rate_id": vat_rate.json()["id"],
                    "num_items": 0,
                    "price_net": 0,
                },
                {
                    "name": "string",
                    "vat_rate_id": vat_rate.json()["id"],
                    "num_items": 0,
                    "price_net": 0,
                },
            ],
        },
    )


def test_add_invoice_failing_unauthorized(client: TestClient):
    response = client.post("/invoice", json={})
    assert response.status_code == HTTP_401_UNAUTHORIZED


def test_nonexistant_vat_rate(client: TestClient):
    user_header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r_trading_partner = create_trading_partner(client, enterprise)
    assert r_trading_partner.status_code == HTTP_201_CREATED
    r_invoice = create_invoice_no_vatrate(client, enterprise, r_trading_partner)
    assert r_invoice.status_code == HTTP_409_CONFLICT


def test_nonexistant_partner(client: TestClient):
    user_header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r_trading_partner = create_trading_partner(client, enterprise)
    user_header1 = get_random_logged_user(client)
    enterprise1 = create_enterprise(client)
    vat_rate1 = create_vat_rate(client, enterprise1)

    assert r_trading_partner.status_code == HTTP_201_CREATED
    r_invoice = create_invoice_vatrate(client, enterprise, r_trading_partner, vat_rate1)
    assert r_invoice.status_code == HTTP_401_UNAUTHORIZED


def test_nonexistant_vatrate(client: TestClient):
    user1 = get_random_logged_user(client)
    enterprise1 = create_enterprise(client)
    vat_rate1 = create_vat_rate(client, enterprise1)

    user = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r_trading_partner = create_trading_partner(client, enterprise)

    assert r_trading_partner.status_code == HTTP_201_CREATED
    r_invoice = create_invoice_vatrate(client, enterprise, r_trading_partner, vat_rate1)
    assert r_invoice.status_code == HTTP_409_CONFLICT


def test_not_enough_permissions(client: TestClient):
    user_header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r_trading_partner = create_trading_partner(client, enterprise)
    user_header1 = get_random_logged_user(client)
    enterprise1 = create_enterprise(client)
    vat_rate1 = create_vat_rate(client, enterprise1)

    assert r_trading_partner.status_code == HTTP_201_CREATED
    r_invoice = create_invoice_vatrate(client, enterprise, r_trading_partner, vat_rate1)
    assert r_invoice.status_code == HTTP_401_UNAUTHORIZED


def test_bad_invoice_type(client: TestClient):
    pass  # TODO: Implement


def test_add_invoice_vatrate_success(client: TestClient):
    user_header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r_trading_partner = create_trading_partner(client, enterprise)
    assert r_trading_partner.status_code == HTTP_201_CREATED
    vat_rate = create_vat_rate(client, enterprise)
    r_invoice = create_invoice_vatrate(client, enterprise, r_trading_partner, vat_rate)
    assert r_invoice.status_code == HTTP_201_CREATED
    r_invoice_get = client.get(
        "/invoice",
        cookies=user_header.cookies.get_dict(),
        params={"page": 1, "enterprise_id": enterprise.json()["id"]},
    )
    assert r_invoice_get.status_code == HTTP_200_OK
    assert len(r_invoice_get.json()) == 1
    assert len(r_invoice_get.json()[0]["invoicepositions"]) == 2


def test_get_invoice_no_permissions(client: TestClient):
    user_header = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    user_header1 = get_random_logged_user(client)
    r_invoice_get = client.get(
        "/invoice",
        cookies=user_header1.cookies.get_dict(),
        params={"page": 1, "enterprise_id": enterprise.json()["id"]},
    )
    assert r_invoice_get.status_code == HTTP_401_UNAUTHORIZED

def test_delete_invoice(client: TestClient):
    user_header = get_random_logged_user(client)
    r_enterprise = create_enterprise(client)
    r_trading_partner = create_trading_partner(client, r_enterprise)
    assert r_trading_partner.status_code == HTTP_201_CREATED
    r_vat_rate = create_vat_rate(client, r_enterprise)
    r_invoice = create_invoice_vatrate(client, r_enterprise, r_trading_partner, r_vat_rate)
    r_invoice_delete = client.delete(
        f"/invoice/{r_invoice.json()['id']}",
        cookies=client.cookies.get_dict())
    assert r_invoice_delete.status_code == HTTP_200_OK

def test_update_invoice(client: TestClient):
    user_header = get_random_logged_user(client)
    r_enterprise = create_enterprise(client)
    r_trading_partner = create_trading_partner(client, r_enterprise)
    assert r_trading_partner.status_code == HTTP_201_CREATED
    r_vat_rate = create_vat_rate(client, r_enterprise)
    r_invoice = create_invoice_vatrate(client, r_enterprise, r_trading_partner, r_vat_rate)
    r_update = client.patch(
        f"/invoice/{r_invoice.json()['id']}",
        cookies=client.cookies.get_dict(),
        json={"invoice_date": "2137-06-29"})
    assert r_update.status_code == HTTP_200_OK