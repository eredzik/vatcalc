frontend/src/Main.elm:
	sh scripts/build_frontend.sh

clean :
	rm frontend/main.js

alembic-revision:
	docker-compose run backend alembic revision --autogenerate -m "$(COMMENT)"