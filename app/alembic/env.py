import os
import sys
from logging.config import fileConfig

from sqlalchemy import create_engine, engine_from_config, pool

import alembic  # type: ignore

# add app folder to system path (alternative is running it from parent folder with python -m ...)
myPath = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, myPath + "/../../")

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = alembic.context.config  # type: ignore

# Interpret the config file for Python logging.
# This line sets up loggers basically.
fileConfig(config.config_file_name)

from app.core.config import settings

# add your model's MetaData object here (the one used in ormar)
# for 'autogenerate' support
from app.models import metadata

# set your url here or import from settings
# note that by default url is in saved sqlachemy.url variable in alembic.ini file
DATABASE_URL = str(settings.DATABASE_URL)


def run_migrations_online() -> None:
    """
    Run migrations in 'online' mode
    """
    DB_URL = f"{DATABASE_URL}_test" if os.environ.get("TESTING") else str(DATABASE_URL)
    POSTGRES_DB = DB_URL.split("/")[-1]
    # handle testing config for migrations
    if os.environ.get("TESTING"):
        # connect to primary db
        default_engine = create_engine(str(DATABASE_URL), isolation_level="AUTOCOMMIT")
        # drop testing db if it exists and create a fresh one
        with default_engine.connect() as default_conn:
            default_conn.execute(f"DROP DATABASE IF EXISTS {POSTGRES_DB}")
            default_conn.execute(f"CREATE DATABASE {POSTGRES_DB}")
    connectable = config.attributes.get("connection", None)
    config.set_main_option("sqlalchemy.url", DB_URL)
    if connectable is None:
        connectable = engine_from_config(
            config.get_section(config.config_ini_section),
            prefix="sqlalchemy.",
            poolclass=pool.NullPool,
        )

    with connectable.connect() as connection:
        alembic.context.configure(connection=connection, target_metadata=metadata)  # type: ignore
        with alembic.context.begin_transaction():  # type: ignore
            alembic.context.run_migrations()  # type: ignore


def run_migrations_offline() -> None:
    """
    Run migrations in 'offline' mode.
    """
    if os.environ.get("TESTING"):
        raise Exception(
            "Database error: Running testing migrations offline currently not permitted."
        )
    alembic.context.configure(url=str(DATABASE_URL))  # type: ignore
    with alembic.context.begin_transaction():  # type: ignore
        alembic.context.run_migrations()  # type: ignore


if alembic.context.is_offline_mode():  # type: ignore
    run_migrations_offline()
else:
    run_migrations_online()
