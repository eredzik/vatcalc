import os
from typing import Dict

try:
    DATABASE_URL = os.environ["DATABASE_URL"]
except:
    raise Exception("DATABASE_URL is not configured")

if DATABASE_URL.split(":")[0] == "sqlite":
    GENERATE_SCHEMA = True
else:
    GENERATE_SCHEMA = False

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
