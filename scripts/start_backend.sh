set -e

/wait
alembic upgrade head
uvicorn app.main:app --reload --host 0.0.0.0 --port=5000
