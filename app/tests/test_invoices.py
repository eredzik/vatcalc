from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_401_UNAUTHORIZED,
    HTTP_409_CONFLICT,
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


def test_add_invoice_failing_unauthorized(client: TestClient):
    response = client.post("/api/invoice", json={})
    assert response.status_code == HTTP_401_UNAUTHORIZED


def test_nonexistant_vat_rate(client: TestClient):
    user_header = get_random_user_header(client)
    enterprise = create_random_enterprise(client, user_header)
    r_trading_partner = create_trading_partner(client, user_header, enterprise)
    assert r_trading_partner.status_code == HTTP_201_CREATED
    r_invoice = client.post(
        "/api/invoice",
        headers=user_header,
        json={
            "invoice_type": "INBOUND",
            "invoice_date": "2021-06-29",
            "trading_partner": r_trading_partner.json(),
            "invoice_id": "string",
            "invoicepositions": [
                {
                    "name": "string",
                    "vat_rate": {"vat_rate": 0, "id": 0, "comment": "string"},
                    "num_items": 0,
                    "price_net": 0,
                },
                {
                    "name": "string",
                    "vat_rate": {"vat_rate": 3, "id": 0, "comment": "string"},
                    "num_items": 0,
                    "price_net": 0,
                },
            ],
        },
    )
    assert r_invoice.status_code == HTTP_409_CONFLICT


def test_nonexistant_partner(client: TestClient):
    pass  # TODO: Implement


def test_bad_invoice_type(client: TestClient):
    pass  # TODO: Implement


def test_add_invoice_vatrate_success(client: TestClient):
    user_header = get_random_user_header(client)
    enterprise = create_random_enterprise(client, user_header)
    r_trading_partner = create_trading_partner(client, user_header, enterprise)
    assert r_trading_partner.status_code == HTTP_201_CREATED
    vat_rate = create_vat_rate(client, user_header, enterprise)
    r_invoice = client.post(
        "/api/invoice",
        headers=user_header,
        json={
            "invoice_type": "INBOUND",
            "invoice_date": "2021-06-29",
            "trading_partner": r_trading_partner.json(),
            "invoice_id": "string",
            "invoicepositions": [
                {
                    "name": "string",
                    "vat_rate": vat_rate.json(),
                    "num_items": 0,
                    "price_net": 0,
                },
                {
                    "name": "string",
                    "vat_rate": vat_rate.json(),
                    "num_items": 0,
                    "price_net": 0,
                },
            ],
        },
    )
    assert r_invoice.status_code == HTTP_201_CREATED
    r_invoice_get = client.get(
        "/api/invoice",
        headers=user_header,
        params={"page": 1, "enterprise_id": enterprise["id"]},
    )
    assert r_invoice_get.status_code == HTTP_200_OK
    assert len(r_invoice_get.json()) == 1
