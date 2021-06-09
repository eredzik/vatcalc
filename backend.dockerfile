FROM python:3.8

WORKDIR /usr/src/backend/
COPY Pipfile .
COPY Pipfile.lock .
RUN pip install --no-cache-dir pipenv && \
    pipenv install --system --ignore-pipfile --deploy --clear --dev

ENV WAIT_VERSION 2.7.2
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait
RUN chmod +x /wait
ENV PYTHONPATH="/usr/src/backend/app:${PYTHONPATH}"

CMD pipenv run sh /usr/src/backend/scripts/start_backend.sh

