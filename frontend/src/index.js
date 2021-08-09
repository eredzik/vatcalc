'use strict';

// import 'bootstrap/dist/css/bootstrap.min.css';
import './style.scss';
var Elm = require('./Main.elm').Elm
var app = Elm.Main.init()

// Ports go here
// https://guide.elm-lang.org/interop/ports.html
// app.ports.outgoing.subscribe(({ tag, data }) => {
//     switch (tag) {
//         case 'saveUser':
//             return localStorage.setItem('user', JSON.stringify(data))
//         case 'clearUser':
//             return localStorage.removeItem('user')
//         default:
//             return console.warn(`Unrecognized Port`, tag)
//     }
// })