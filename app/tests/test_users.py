from fastapi.testclient import TestClient
from starlette.status import (
    HTTP_200_OK,
    HTTP_201_CREATED,
    HTTP_400_BAD_REQUEST,
    HTTP_422_UNPROCESSABLE_ENTITY,
)

from .test_auth import (
    get_random_email,
    get_random_logged_user,
    login_sample_user,
    register_sample_user,
)
