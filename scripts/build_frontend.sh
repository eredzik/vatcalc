cd frontend;
js="../static/main.js"
elm make src/Main.elm --output=$js --optimize
minimized="../static/main.min.js"
uglifyjs $js -o $minimized