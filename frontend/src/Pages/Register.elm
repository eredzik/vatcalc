module Pages.Register exposing (Model, Msg, page)

import Api.Data exposing (Data(..))
import Api.User
import Effect exposing (Effect)
import ElmSpa.Page exposing (Protected(..))
import Gen.Route as Route
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events
import Page
import Request exposing (Request)
import Shared
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


type RegisteredState
    = SuccesfulRegister
    | Registering


type alias Model =
    { registered : RegisteredState
    , username : String
    , email : String
    , password : String
    , errors : List String
    }


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( { registered = Registering
      , username = ""
      , email = ""
      , password = ""
      , errors = []
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | AttemptedSignUp
    | GotUser (Data String)


type Field
    = Username
    | Email
    | Password


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Updated Username username ->
            ( { model | username = username }
            , Effect.none
            )

        Updated Email email ->
            ( { model | email = email }
            , Effect.none
            )

        Updated Password password ->
            ( { model | password = password }
            , Effect.none
            )

        AttemptedSignUp ->
            ( model
            , Effect.fromCmd <|
                Api.User.registration
                    { user =
                        { username = model.username
                        , email = model.email
                        , password = model.password
                        }
                    , onResponse = GotUser
                    }
            )

        GotUser id ->
            case id of
                NotAsked ->
                    ( model, Effect.none )

                Loading ->
                    ( model, Effect.none )

                Failure errors ->
                    ( { model | errors = errors }, Effect.none )

                Success _ ->
                    ( { model | registered = SuccesfulRegister }, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    case model.registered of
        SuccesfulRegister ->
            viewAfterRegister model

        Registering ->
            viewRegister model


viewRegister : Model -> View Msg
viewRegister model =
    { title = "Sign up"
    , body =
        [ div []
            [ h1 [] [ text "Rejestracja!" ]
            , p []
                [ a [ Attr.href (Route.toHref Route.Login) ]
                    [ text "Masz konto? Zaloguj się tutaj." ]
                ]
            , ul [] <|
                List.map
                    (\stringOfError -> li [] [ text stringOfError ])
                    model.errors
            , form [ Events.onSubmit AttemptedSignUp ]
                [ viewField
                    { label = "Login"
                    , type_ = "text"
                    , value = model.username
                    , onInput = Updated Username
                    }
                , viewField
                    { label = "Email"
                    , type_ = "email"
                    , value = model.email
                    , onInput = Updated Email
                    }
                , viewField
                    { label = "Hasło"
                    , type_ = "password"
                    , value = model.password
                    , onInput = Updated Password
                    }
                , button
                    []
                    [ text "Zarejestruj" ]
                ]
            ]
        ]
    }


type alias FormField msg =
    { label : String
    , type_ : String
    , value : String
    , onInput : String -> msg
    }


viewField : FormField msg -> Html msg
viewField options =
    fieldset []
        [ label [] [ text (options.label ++ ": ") ]
        , input
            [ Attr.placeholder options.label
            , Attr.type_ options.type_
            , Attr.value options.value
            , Events.onInput options.onInput
            ]
            []
        ]


viewAfterRegister : Model -> View Msg
viewAfterRegister _ =
    { title = "Sign up"
    , body =
        [ text "Zarejestrowałeś się! Zaloguj się "
        , a
            [ Attr.href <| Route.toHref Route.Login
            ]
            [ text "tutaj" ]
        ]
    }
