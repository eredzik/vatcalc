module Auth exposing (User, beforeProtectedInit)

import ElmSpa.Page as ElmSpa
import Gen.Route as Route
import Request exposing (Request)
import Shared
import User


type alias User =
    User.User


beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route.Route
beforeProtectedInit shared request =
    case shared.user of
        Just user ->
            case user.favEnterpriseId of
                Just _ ->
                    ElmSpa.Provide user

                Nothing ->
                    case request.route of
                        Route.Home_ ->
                            ElmSpa.Provide user

                        Route.Enterprises ->
                            ElmSpa.Provide user

                        Route.Invoices ->
                            ElmSpa.RedirectTo Route.Enterprises

                        Route.Login ->
                            ElmSpa.RedirectTo Route.Home_

                        Route.NotFound ->
                            ElmSpa.Provide user

                        Route.Partners ->
                            ElmSpa.RedirectTo Route.Enterprises

                        Route.Register ->
                            ElmSpa.RedirectTo Route.Home_

                        Route.Enterprises__Add ->
                            ElmSpa.Provide user

                        Route.Enterprises__Id_ _ ->
                            ElmSpa.Provide user

                        Route.Partners__Add ->
                            ElmSpa.RedirectTo Route.Enterprises

        Nothing ->
            ElmSpa.RedirectTo Route.Login
