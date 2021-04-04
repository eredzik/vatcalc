FROM python:3.8-slim

WORKDIR /usr/src/backend/
COPY Pipfile .
COPY Pipfile.lock .
RUN pip install --no-cache-dir pipenv && \
    pipenv install --system --ignore-pipfile --deploy --clear


CMD ["uvicorn",  "app.main:app", "--reload", "--host", "0.0.0.0", "--port", "5000"]

