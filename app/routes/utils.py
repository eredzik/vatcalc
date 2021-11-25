from typing import List

from fastapi.responses import JSONResponse
from pydantic.main import BaseModel
from starlette.status import HTTP_401_UNAUTHORIZED, HTTP_409_CONFLICT, HTTP_204_NO_CONTENT, HTTP_403_FORBIDDEN

from .. import models


async def verify_enterprise_permissions(
    user, enterprise, required_permissions: List[models.UserEnterpriseRoles]
):
    permissions = await models.UserEnterprise.objects.get_or_none(
        user_id=user.id, enterprise_id=enterprise
    )
    if permissions is None:
        return JSONResponse(
            status_code=HTTP_401_UNAUTHORIZED,
            content={"message": "Unauthorized"},
        )
    elif permissions.role not in (r.value for r in required_permissions):
        return JSONResponse(
            status_code=HTTP_401_UNAUTHORIZED, content={"message": "Unauthorized"}
        )
    else:
        return True

async def verify_granting_permissions(
    user, enterprise, role, required_permissions: List[models.UserEnterpriseRoles]
):
    permissions = await models.UserEnterprise.objects.get_or_none(
        user_id=user.id, enterprise_id=enterprise
    )
    if permissions is None:
        return JSONResponse(
            status_code=HTTP_401_UNAUTHORIZED,
            content={"message": "Unauthorized"},
        )
    elif permissions.role not in (r.value for r in required_permissions):
        return JSONResponse(
            status_code=HTTP_401_UNAUTHORIZED, content={"message": "Unauthorized"}
        )
    elif permissions.role == "EDITOR" and role == "VIEWER":
        return JSONResponse(status_code=HTTP_403_FORBIDDEN, content={"message": "Forbidden"})
    elif permissions.role == "ADMIN" and role == "VIEWER":
        return True
    elif permissions.role == "ADMIN" and role == "ADMIN":
        return True



def get_verify_enterprise_permissions_responses():
    return {
        HTTP_401_UNAUTHORIZED: {"model": Message},
        HTTP_409_CONFLICT: {"model": Message},
    }


class Message(BaseModel):
    detail: str
