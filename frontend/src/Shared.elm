module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Api
import Api.Data
import Api.Request.Authentication
import Api.Request.User
import Components.Navbar
import Css
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Http
import Json.Decode as Decode
import Request exposing (Request)
import Storage
import User exposing (User)
import Utils.Route
import View exposing (View)



-- INIT


type alias Flags =
    Decode.Value


type alias Model =
    { user : Maybe User
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ flags =
    let
        user =
            Storage.fromJson flags |> .user

        cmds =
            case user of
                Just _ ->
                    Api.Request.User.getUserDataUserMeGet
                        |> Api.send GotUserData

                Nothing ->
                    Cmd.none
    in
    ( { user = user
      }
    , cmds
    )



-- UPDATE


type Msg
    = ClickedSignOut
    | SignedInUser
    | GotUserData (Result Http.Error Api.Data.CurrentUserResponse)
    | LoggedOut (Result Http.Error ())
    | SelectedFavouriteEnterprise (Maybe Int)


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        SignedInUser ->
            ( model
            , Api.Request.User.getUserDataUserMeGet
                |> Api.send GotUserData
            )

        ClickedSignOut ->
            ( { model | user = Nothing }
            , Api.Request.Authentication.logoutLogoutPost |> Api.send LoggedOut
            )

        LoggedOut _ ->
            ( model
            , Cmd.batch [ Storage.saveToLocalStorage { user = Nothing } ]
            )

        GotUserData userResponse ->
            case userResponse of
                Ok userData ->
                    ( { model | user = Just userData }
                    , Storage.saveToLocalStorage { user = Just userData }
                    )

                Err _ ->
                    ( { model | user = Nothing }
                    , Storage.saveToLocalStorage { user = Nothing }
                    )

        SelectedFavouriteEnterprise enterprise_id ->
            case model.user of
                Just user ->
                    let
                        new_user =
                            user
                                |> (\z -> { z | favEnterpriseId = enterprise_id })
                    in
                    ( { model | user = Just new_user }
                    , Storage.saveToLocalStorage { user = Just new_user }
                    )

                Nothing ->
                    ( model, Cmd.none )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none



-- VIEW


view :
    Request
    -> { page : View msg, toMsg : Msg -> msg }
    -> Model
    -> View msg
view req { page, toMsg } model =
    { title =
        if String.isEmpty page.title then
            "VatCalc"

        else
            page.title ++ " | VatCalc"
    , body =
        [ div
            [ Attr.css [ Css.margin <| Css.px 0 ] ]
            [ Components.Navbar.view
                { isLoggedIn =
                    case model.user of
                        Just _ ->
                            True

                        Nothing ->
                            False
                , currentRoute = Utils.Route.fromUrl req.url
                , onSignOut = toMsg ClickedSignOut
                }
            , div
                [ Attr.class "page" ]
                page.body
            ]
        ]
    }
