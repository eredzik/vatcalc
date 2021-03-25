pipenv run uvicorn backend.app.main:app --port 8026 &
cd frontend;
sleep 1;
npx elm-graphql http://localhost:8026/ --output src --base Backend
sleep 1;
kill $!
elm make src/Main.elm --output=build/main.js