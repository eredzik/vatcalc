import random
import string

from fastapi.testclient import TestClient


def register_sample_user(cl: TestClient, email: str, password: str):
    response = cl.post(
        "/api/auth/register", json={"email": email, "password": password}
    )
    return response


def login_sample_user(client: TestClient, email: str, password: str):
    response = client.post(
        "/api/auth/login",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        data={"username": email, "password": password},
    )
    return response


def get_random_email():
    return (
        "".join(random.choice(string.ascii_letters) for x in range(10)) + "@domain.pl"
    )


def get_random_logged_user_token(client: TestClient):
    email = get_random_email()
    password = "somelongpassword"
    r = register_sample_user(client, email, password)
    r2 = login_sample_user(client, email, password)
    return r2.json()['access_token']

def get_random_user_header(client: TestClient):
    token = get_random_logged_user_token(client)
    return {"Authorization": "Bearer " + token}