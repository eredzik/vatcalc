set -e

/wait
cd app
alembic upgrade head
cd ..
uvicorn app.main:app --reload --host 0.0.0.0 --port=5000
