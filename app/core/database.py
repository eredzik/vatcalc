import databases
import sqlalchemy

from .config import settings

database = databases.Database(str(settings.DATABASE_URL))
metadata = sqlalchemy.MetaData()
