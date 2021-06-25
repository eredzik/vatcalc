module Auth exposing (User, beforeProtectedInit)

import Api.Token exposing (Token(..))
import Api.User
import ElmSpa.Page as ElmSpa
import Gen.Route as Route exposing (Route(..))
import Request exposing (Request)
import Shared


type alias User =
    Api.User.User


beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route
beforeProtectedInit shared req =
    case shared.user of
        Just user ->
            case req.route of
                Register ->
                    ElmSpa.RedirectTo Route.Home_

                Login ->
                    ElmSpa.RedirectTo Route.Home_

                _ ->
                    ElmSpa.Provide user

        Nothing ->
            case req.route of
                Register ->
                    Api.User.User "" (Token "") |> ElmSpa.Provide

                Login ->
                    Api.User.User "" (Token "") |> ElmSpa.Provide

                _ ->
                    ElmSpa.RedirectTo Route.Login
