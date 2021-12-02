from fastapi.testclient import TestClient

from .test_auth import get_random_logged_user


def test_query_by_nip_failing(client: TestClient):
    _ = get_random_logged_user(client)
    response = client.get(
        "/regon_api/nip_number/0000000000", cookies=client.cookies.get_dict()
    )
    assert response.status_code == 200
    assert response.json()['error_code'] == '4'


def test_query_by_nip_success(client: TestClient):
    _ = get_random_logged_user(client)
    response = client.get(
        "/regon_api/nip_number/5252344078", cookies=client.cookies.get_dict()
    )
    assert response.status_code == 200
    assert response.json()["nip"] == "5252344078"
