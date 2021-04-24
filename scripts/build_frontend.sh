cd frontend;
js="../static/main.js"
sass "style.sass" "../static/style.css"
#--optimize
elm make src/Main.elm --output=$js  --debug
minimized="../static/main.min.js"
uglifyjs $js -o $minimized