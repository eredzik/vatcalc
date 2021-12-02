from pydantic.main import BaseModel


class Message(BaseModel):
    detail: str

async def verify_granting_permissions(
    user, enterprise
):
    permissions = await models.UserEnterprise.objects.get_or_none(
        user_id=user.id, enterprise_id=enterprise
    )
    if permissions is None:
        return JSONResponse(
            status_code=HTTP_401_UNAUTHORIZED,
            content={"message": "Unauthorized"},
        )
    elif permissions.role != "ADMIN":
        return JSONResponse(
            status_code=HTTP_403_FORBIDDEN, content={"message": "Forbidden"})
    else:
        return True
