from starlette.status import HTTP_201_CREATED, HTTP_401_UNAUTHORIZED, HTTP_409_CONFLICT
from starlette.testclient import TestClient

from .auth_utils import create_random_enterprise, get_random_user_header


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
