module Pages.Login exposing (Model, Msg, page)

import Api.Data exposing (Data(..))
import Api.Token exposing (Token(..))
import Api.User exposing (User)
import Components.UserForm
import Effect exposing (Effect)
import Gen.Route as Route
import Page
import Request exposing (Request)
import Shared
import Utils.Route
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.protected.advanced
        (\_ ->
            { init = init shared
            , update = update req
            , subscriptions = subscriptions
            , view = view
            }
        )



-- INIT


type alias Model =
    { user : Data User
    , email : String
    , password : String
    }


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( Model
        Api.Data.NotAsked
        ""
        ""
    , Effect.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | AttemptedSignIn
    | GotToken (Data String)


type Field
    = Email
    | Password


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
    case msg of
        Updated Email email ->
            ( { model | email = email }
            , Effect.none
            )

        Updated Password password ->
            ( { model | password = password }
            , Effect.none
            )

        AttemptedSignIn ->
            ( model
            , Effect.fromCmd <|
                Api.User.authentication
                    { user =
                        { email = model.email
                        , password = model.password
                        }
                    , onResponse = GotToken
                    }
            )

        GotToken token ->
            case Api.Data.toMaybe token of
                Just token_ ->
                    let
                        user =
                            { email = model.email
                            , token = Token token_
                            , selectedEnterprise = Nothing
                            }
                    in
                    ( { model | user = Success user }
                    , Effect.batch
                        [ Effect.fromCmd (Utils.Route.navigate req.key Route.Home_)
                        , Effect.fromShared (Shared.SignedInUser user)
                        ]
                    )

                Nothing ->
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
            { user = model.user
            , label = "Sign in"
            , onFormSubmit = AttemptedSignIn
            , alternateLink = { label = "Need an account?", route = Route.Register }
            , fields =
                [ { label = "Email"
                  , type_ = "email"
                  , value = model.email
                  , onInput = Updated Email
                  }
                , { label = "Password"
                  , type_ = "password"
                  , value = model.password
                  , onInput = Updated Password
                  }
                ]
            }
        ]
    }
