module Pages.Login exposing (Model, Msg, page)

-- import Api.xxData exposing (Data(..))
-- import Api.Endpoint exposing (ApiPath)
-- import Api.Token exposing (Token(..))
-- import Api.User exposing (User)

import Api
import Api.Request.Authentication
import Components.UserForm
import Effect exposing (Effect)
import Gen.Route as Route
import Http
import Page
import Request exposing (Request)
import Shared
import Utils.Route
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared
        , update = update req
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { username : String
    , password : String
    }


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( Model
        ""
        ""
    , Effect.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | AttemptedSignIn
    | LoggedIn (Result Http.Error ())
    | DeactivatedField Field


type Field
    = Username
    | Password


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
    case msg of
        Updated Username username ->
            ( { model | username = username }
            , Effect.none
            )

        DeactivatedField Username ->
            ( model, Effect.none )

        Updated Password password ->
            ( { model | password = password }
            , Effect.none
            )

        DeactivatedField Password ->
            ( model, Effect.none )

        AttemptedSignIn ->
            ( model
            , Effect.fromCmd
                (Api.Request.Authentication.loginUserLoginPost
                    { username = model.username
                    , password = model.password
                    }
                    |> Api.send LoggedIn
                )
            )

        LoggedIn response ->
            case response of
                Ok () ->
                    ( model
                    , Effect.batch
                        [ Effect.fromCmd (Utils.Route.navigate req.key Route.Home_)
                        , Effect.fromShared Shared.SignedInUser
                        ]
                    )

                Err err ->
                    ( model
                    , Effect.none
                    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in"
    , body =
        [ Components.UserForm.view
            { label = "Sign in"
            , onFormSubmit = AttemptedSignIn
            , alternateLink = { label = "Need an account?", route = Route.Register }
            , fields =
                [ { label = "username"
                  , type_ = "username"
                  , value = model.username
                  , onInput = Updated Username
                  , onBlur = DeactivatedField Username
                  }
                , { label = "Password"
                  , type_ = "password"
                  , value = model.password
                  , onInput = Updated Password
                  , onBlur = DeactivatedField Password
                  }
                ]
            }
        ]
    }
