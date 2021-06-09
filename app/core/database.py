import logging
import os

import databases
import sqlalchemy

from .config import settings

DB_URL = (
    f"{settings.DATABASE_URL}_test"
    if os.environ.get("TESTING")
    else str(settings.DATABASE_URL)
)
database = databases.Database(DB_URL)
metadata = sqlalchemy.MetaData()
