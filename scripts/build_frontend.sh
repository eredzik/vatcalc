cd frontend;
js="../static/main.js"
sass "style.sass" "../static/style.css"
elm make src/Main.elm --output=$js --optimize
minimized="../static/main.min.js"
uglifyjs $js -o $minimized