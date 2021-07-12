module Auth exposing (User, beforeProtectedInit)

import ElmSpa.Page as ElmSpa
import Gen.Route as Route exposing (Route)
import Request exposing (Request)
import Shared


type alias User =
    Shared.User


beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route
beforeProtectedInit shared req =
    case shared.user of
        Just user ->
            ElmSpa.Provide user

        Nothing ->
            ElmSpa.RedirectTo Route.Login
