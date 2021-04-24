module LogIn.Functions exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import LogIn.Types exposing (LogInData, LogInDataModel(..), LogInModel, LogInMsg(..))
import Validate exposing (Validator)


logInValidator : Validator ( LogInDataModel, String ) LogInData
logInValidator =
    Validate.firstError
        [ Validate.ifBlank .password ( Password, "Proszę wpisać hasło." )
        , Validate.ifBlank .email ( Email, "Proszę wpisać email" )
        , Validate.ifInvalidEmail .email (\_ -> ( Email, "Proszę wpisać poprawny email" ))
        ]


formField : (String -> msg) -> String -> String -> String -> Html msg
formField m name t p =
    label [ class "form-label" ]
        [ text name
        , input
            [ type_ t
            , placeholder p
            , onInput m
            ]
            []
        ]


view : LogInModel -> Html LogInMsg
view _ =
    div []
        [ form []
            [ formField EmailUpdate "e-mail" "text" "E-mail"
            , formField PasswordUpdate "hasło" "password" "Hasło"
            , button [ onClick SubmitForm ] [ text "Zaloguj" ]
            ]
        ]


update : LogInMsg -> LogInModel -> ( LogInModel, Cmd LogInMsg )
update msg model =
    case msg of
        EmailUpdate value ->
            let
                logform =
                    model.logInData

                new_logform =
                    { logform | email = value }
            in
            ( { model | logInData = new_logform }, Cmd.none )

        PasswordUpdate value ->
            let
                logform =
                    model.logInData

                new_logform =
                    { logform | password = value }
            in
            ( { model | logInData = new_logform }, Cmd.none )

        SubmitForm ->
            let
                validation_result =
                    Validate.validate logInValidator model.logInData
            in
            case validation_result of
                Ok _ ->
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )
