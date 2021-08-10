from starlette.status import (
    HTTP_200_OK,
    HTTP_401_UNAUTHORIZED,
    HTTP_402_PAYMENT_REQUIRED,
)
from starlette.testclient import TestClient
from .test_enterprise import create_enterprise

from .test_auth import get_random_logged_user


def test_me_path_success(client: TestClient):
    r_user = get_random_logged_user(client)
    r_user = client.get("/user/me", cookies=client.cookies.get_dict())
    assert r_user.status_code == HTTP_200_OK


def test_me_path_failure(client: TestClient):
    r_user = client.get("/user/me", cookies=client.cookies.get_dict())
    assert r_user.status_code == HTTP_401_UNAUTHORIZED


def set_fav_enterprise(client: TestClient,
                       fav_enterprise,
    ):
    response = client.patch(
        "/preferred_enterprise",
        json={"fav_enterprise": fav_enterprise},
        cookies=client.cookies.get_dict(),
    )
    return response


def test_set_fav_enterprise(client: TestClient):
    _ = get_random_logged_user(client)
    enterprise = create_enterprise(client)
    r = set_fav_enterprise(client, fav_enterprise=enterprise.json().id)
    assert r.status_code == HTTP_200_OK

    #TODO: test na faile
    #TODO: wyjebać śmieci z gita
    #TODO: napisać get na enterprise
    #TODO: sprawdzić, czy reszta testów się nie wywala
    #TODO: migracje dopisać
