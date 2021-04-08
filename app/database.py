import os

try:
    DATABASE_URL = os.environ["DATABASE_URL"]
except:
    raise Exception("DATABASE_URL is not configured")


TORTOISE_ORM = {
    "connections": {"default": DATABASE_URL},
    "apps": {
        "models": {
            "models": [
                "app.trading_partner.models",
                "app.user.models",
                "app.invoice.models",
                "aerich.models",
            ],
            "default_connection": "default",
        },
    },
}

print(f"GETTING CONFIG: {TORTOISE_ORM}")
