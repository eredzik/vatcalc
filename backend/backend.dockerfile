FROM python:3.8

WORKDIR /usr/src/app/
COPY Pipfile .
RUN pip install pipenv
RUN pipenv install

COPY app app

CMD [ "pipenv", "run", "uvicorn", "app.main:app", "--reload", "--host", "0.0.0.0"]

