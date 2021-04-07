# from sqlalchemy import create_engine
# from sqlalchemy.ext.declarative import declarative_base
# from sqlalchemy.orm import scoped_session, sessionmaker
import os

POSTGRES_SERVER = os.environ.get("POSTGRES_SERVER")
POSTGRES_PORT = os.environ.get("POSTGRES_PORT")
POSTGRES_USER = os.environ.get("POSTGRES_USER")
POSTGRES_PASSWORD = os.environ.get("POSTGRES_PASSWORD")
POSTGRES_DB = os.environ.get("POSTGRES_DB")

DB_URL = "postgres://{}:{}@{}:{}/{}".format(
    POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_SERVER, POSTGRES_PORT, POSTGRES_DB
)
# DB_URL = "sqlite://sql_app.db"
# POSTGRES_DATABASE_URL = "postgres://postgres:password@localhost:5432/db_name"
print(DB_URL)
TORTOISE_ORM = {
    "connections": {"default": DB_URL},
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
# engine = create_engine(
#     SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
# )
# SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
# Base = declarative_base()
# db_session = scoped_session(SessionLocal)

# Base.query = db_session.query_property()
