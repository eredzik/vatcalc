import os
import sys
from logging.config import fileConfig

from sqlalchemy import create_engine

from alembic import context

# add app folder to system path (alternative is running it from parent folder with python -m ...)
myPath = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, myPath + "/../../")

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config  # type: ignore

# Interpret the config file for Python logging.
# This line sets up loggers basically.
fileConfig(config.config_file_name)

# add your model's MetaData object here (the one used in ormar)
# for 'autogenerate' support
from app.models import metadata

target_metadata = metadata

from app.core.config import settings

# set your url here or import from settings
# note that by default url is in saved sqlachemy.url variable in alembic.ini file
URL = str(settings.SQLALCHEMY_DATABASE_URI)


def run_migrations_offline():
    """Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well.  By skipping the Engine creation
    we don't even need a DBAPI to be available.

    Calls to context.execute() here emit the given string to the
    script output.

    """
    context.configure(  # type: ignore
        url=URL,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        # if you use UUID field set also this param
        # the prefix has to match sqlalchemy import name in alembic
        # that can be set by sqlalchemy_module_prefix option (default 'sa.')
        user_module_prefix="sa.",
    )

    with context.begin_transaction():  # type: ignore
        context.run_migrations()  # type: ignore


def run_migrations_online():
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine
    and associate a connection with the context.

    """
    connectable = create_engine(URL)

    with connectable.connect() as connection:
        context.configure(  # type: ignore
            connection=connection,
            target_metadata=target_metadata,
            # if you use UUID field set also this param
            # the prefix has to match sqlalchemy import name in alembic
            # that can be set by sqlalchemy_module_prefix option (default 'sa.')
            user_module_prefix="sa.",
        )

        with context.begin_transaction():  # type: ignore
            context.run_migrations()  # type: ignore


if context.is_offline_mode():  # type: ignore
    run_migrations_offline()
else:
    run_migrations_online()
