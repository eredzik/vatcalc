'use strict';

// import 'bootstrap/dist/css/bootstrap.min.css';
import './style.scss';
var Elm = require('./Main.elm').Elm
console.log(localStorage.getItem('storage'))
var app = Elm.Main.init({
    flags: JSON.parse(localStorage.getItem('storage'))
})

// Ports go here
// https://guide.elm-lang.org/interop/ports.html
app.ports.save_.subscribe(storage => {
    localStorage.setItem('storage', JSON.stringify(storage))
    // app.ports.load_.send(storage)
})