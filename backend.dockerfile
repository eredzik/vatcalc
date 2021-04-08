FROM python:3.8-slim

WORKDIR /usr/src/backend/
COPY Pipfile .
COPY Pipfile.lock .
RUN pip install --no-cache-dir pipenv && \
    pipenv install --system --ignore-pipfile --deploy --clear

ENV WAIT_VERSION 2.7.2
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait
RUN chmod +x /wait

CMD /wait && aerich upgrade && uvicorn app.main:app --reload --host 0.0.0.0 --port 5000

