module Register.Functions exposing (..)

import Browser.Navigation
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as JD
import Register.API exposing (register)
import Register.Types exposing (RegisterModel, RegisterMsg(..), RegisterResponse(..))
import RemoteData exposing (RemoteData(..))
import Route exposing (href)


update : RegisterMsg -> RegisterModel -> Browser.Navigation.Key -> ( RegisterModel, Cmd RegisterMsg )
update msg model key =
    case msg of
        EmailInput input ->
            ( { model | email = input }, Cmd.none )

        PasswordInput input ->
            ( { model | password = input }, Cmd.none )

        PasswordRepeatedInput input ->
            ( { model | password_repeated = input }, Cmd.none )

        PasswordInputValidation ->
            let
                password_error =
                    if String.length model.password < 8 && (String.length model.password > 0) then
                        "Hasło jest za krótkie"

                    else
                        ""
            in
            ( { model | password_error = password_error, password_repeated_error = "" }, Cmd.none )

        EmailValidation ->
            let
                email_error =
                    if String.contains "@" model.email then
                        ""

                    else
                        "Wpisz poprawny email"
            in
            ( { model | email_error = email_error }, Cmd.none )

        PasswordRepeatedValidation ->
            let
                password_repeated_error =
                    if model.password == model.password_repeated then
                        ""

                    else
                        "Hasła się różnią"
            in
            ( { model | password_repeated_error = password_repeated_error }, Cmd.none )

        Submit ->
            ( model, register model )

        GotRegisterResult result ->
            case result of
                Ok data ->
                    case data of
                        Register.Types.Success ->
                            ( model, Route.replaceUrl key Route.Index )

                        _ ->
                            ( { model | postRegistrationResponse = data }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


anyErrors : RegisterModel -> Bool
anyErrors model =
    if
        (String.length model.email_error > 0)
            || (String.length model.password_error > 0)
            || (String.length model.password_repeated_error > 0)
    then
        True

    else
        False


viewPostRegistrationScreen : Html RegisterMsg
viewPostRegistrationScreen =
    div []
        [ text "Zarejestrowałeś się pomyślnie! Przejdź"
        , div [ href Route.LogIn ] [ text "tutaj" ]
        , text "by się zalogować."
        ]


view : RegisterModel -> Html RegisterMsg
view model =
    case model.postRegistrationResponse of
        Register.Types.NotAsked ->
            viewRegisterScreen model ""

        Register.Types.Success ->
            viewPostRegistrationScreen

        EmailExists ->
            viewRegisterScreen model "Konto o takim emailu istnieje"

        EmailValidationError ->
            viewRegisterScreen model "Konto o takim emailu istnieje"

        UnknownError ->
            viewRegisterScreen model "Błąd przy komunikacji z serwerem"


viewRegisterScreen : RegisterModel -> String -> Html RegisterMsg
viewRegisterScreen model information =
    div []
        [ h1 [] [ text "Rejestracja" ]
        , div []
            [ form []
                [ div []
                    [ text information
                    , div []
                        [ label []
                            [ text "E-mail"
                            , input
                                [ Attr.type_ "text"
                                , Attr.placeholder "Wpisz email"
                                , Events.onInput EmailInput
                                , Events.onBlur EmailValidation
                                ]
                                []
                            ]
                        , div [ Attr.class "error-email" ] [ text model.email_error ]
                        ]
                    , div []
                        [ label []
                            [ text "Hasło"
                            , input
                                [ Attr.type_ "password"
                                , Attr.placeholder "Hasło"
                                , Events.onInput PasswordInput
                                , Events.onBlur PasswordInputValidation
                                ]
                                []
                            ]
                        , div [ Attr.class "error-password" ] [ text model.password_error ]
                        ]
                    , div []
                        [ label []
                            [ text "Powtórz hasło"
                            , input
                                [ Attr.type_ "password"
                                , Attr.placeholder "Powtórz hasło"
                                , Events.onInput PasswordRepeatedInput
                                , Events.onBlur PasswordRepeatedValidation
                                ]
                                []
                            ]
                        , div [ Attr.class "error-password-repeated" ] [ text model.password_repeated_error ]
                        ]
                    ]
                , button
                    [ Attr.disabled (anyErrors model), Events.onClick Submit, Attr.type_ "button" ]
                    [ text "Zarejestruj" ]
                ]
            ]
        ]
