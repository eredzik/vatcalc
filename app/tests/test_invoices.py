def test_add_invoice_failing(client):
    response = client.post("/api/invoice/", json={})
    assert response.status_code == 422


def test_add_invoice_vatrate_success(client):
    response_vatrate = client.post(
        "/api/vat_rate/", json={"vat_rate": 0.23, "comment": "string"}
    )
    assert response_vatrate.status_code == 200
    response_partner = client.post(
        "/api/trading_partner/",
        json={"nip_number": "0000000000", "name": "", "adress": ""},
    )
    assert response_partner.status_code == 200
    response = client.post(
        "/api/invoice/",
        json={
            "invoice_id": "string",
            "invoice_date": "2021-04-08",
            "invoice_type": "IN",
            "trading_partner_id": 1,
            "invoice_positions_in": [
                {
                    "name": "szajs",
                    "vat_rate_id": 1,
                    "num_items": 5,
                    "price_net": 1,
                },
                {
                    "name": "szajs2",
                    "vat_rate_id": 1,
                    "num_items": 3,
                    "price_net": 2,
                },
            ],
        },
    )
    assert response.status_code == 200
    response_get_invoice = client.get("/api/invoice/")
    assert response_get_invoice.status_code == 200
    assert len(response_get_invoice.json()) > 0
