def test_add_trading_partner_failing_empty_json(client):
    response = client.post("/api/trading_partner/", json={})
    assert response.status_code == 422


def test_add_trading_partner_failing_wrong_nip(client):
    response = client.post(
        "/api/trading_partner/", json={"nip_number": "5", "name": "", "adress": ""}
    )
    assert response.status_code == 422
    assert response.json()["detail"][0]["msg"] == "Nip must have exactly 10 characters."


def test_add_trading_partner_success(client):
    response = client.post(
        "/api/trading_partner/",
        json={"nip_number": "0000000000", "name": "", "adress": ""},
    )
    assert response.status_code == 200


def test_trading_partner_create_and_fetch(client):
    data_to_save = {"nip_number": "0000000000", "name": "", "adress": ""}

    _ = client.post(
        "/api/trading_partner/",
        json={"nip_number": "0000000000", "name": "", "adress": ""},
    )
    response = client.get(
        "/api/trading_partner/",
    )
    assert response.status_code == 200
    assert response.json()[0]["nip_number"] == data_to_save["nip_number"]
