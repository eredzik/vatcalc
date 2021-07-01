'use strict';

import 'bootstrap/dist/css/bootstrap.min.css';

var Elm = require('./Main.elm').Elm
var flags =
{
    user: JSON.parse(localStorage.getItem('user')) || null,
    api_endpoint: process.env.API_SERVER
}

console.log(flags)

var app = Elm.Main.init({ flags: flags })

// Ports go here
// https://guide.elm-lang.org/interop/ports.html
app.ports.outgoing.subscribe(({ tag, data }) => {
    switch (tag) {
        case 'saveUser':
            return localStorage.setItem('user', JSON.stringify(data))
        case 'clearUser':
            return localStorage.removeItem('user')
        default:
            return console.warn(`Unrecognized Port`, tag)
    }
})