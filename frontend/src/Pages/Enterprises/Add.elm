module Pages.Enterprises.Add exposing (Model, Msg, page)

import Api
import Api.Data exposing (EnterpriseCreateResponse)
import Api.Request.Enterprise
import Components.Form exposing (Field, FormField(..), validateWith, viewForm)
import Components.Validate.Nip exposing (NipValidationResult(..), validateNip)
import ElmSpa.Page exposing (Protected(..))
import Gen.Route
import Html.Styled.Attributes as Attr
import Http exposing (Error(..))
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ req =
    Page.protected.element
        (\_ ->
            { init = init
            , update = update req
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { name : FormField
    , nipNumber : FormField
    , address : FormField
    , responseError : Maybe String
    }


type Field
    = Name
    | NipNumber
    | Address


init : ( Model, Cmd Msg )
init =
    ( Model
        (ToBeValidated "")
        (ToBeValidated "")
        (ToBeValidated "")
        Nothing
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdatedField Field String
    | DeactivatedField Field
    | Submitted
    | Received (Result Http.Error EnterpriseCreateResponse)


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        UpdatedField fieldname val ->
            case fieldname of
                Name ->
                    ( { model | name = ToBeValidated val }, Cmd.none )

                NipNumber ->
                    ( { model | nipNumber = ToBeValidated val }, Cmd.none )

                Address ->
                    ( { model | address = ToBeValidated val }, Cmd.none )

        DeactivatedField fieldname ->
            case fieldname of
                Name ->
                    ( { model | name = model.name |> validateWith nameValidator }, Cmd.none )

                NipNumber ->
                    ( { model | nipNumber = model.nipNumber |> validateWith nipValidator }, Cmd.none )

                Address ->
                    ( { model | address = model.address |> validateWith nameValidator }, Cmd.none )

        Submitted ->
            ( model
            , Api.Request.Enterprise.createEnterpriseEnterprisePost
                { nipNumber = getValue model.nipNumber
                , name = getValue model.name
                , address = getValue model.address
                }
                |> Api.send Received
            )

        Received response ->
            case response of
                Ok _ ->
                    ( model, Request.pushRoute Gen.Route.Enterprises req )

                Err error ->
                    ( { model | responseError = Just (apiErrorToStr error) }, Cmd.none )


nameValidator : String -> FormField
nameValidator name =
    if String.isEmpty name then
        Invalid name [ "Nazwa firmy nie może być pusta" ]

    else
        Valid name


nipValidator : String -> FormField
nipValidator nip =
    case validateNip nip of
        InvalidNipLength ->
            Invalid nip [ "Nip musi mieć równo 10 znaków." ]

        InvalidNipControlNumber ->
            Invalid nip [ "Niepoprawny numer nip - błąd walidacji cyfry kontrolnej." ]

        InvalidNipSymbols ->
            Invalid nip [ "Numer nip powinien składać się tylko z cyfr" ]

        CorrectNipNumber ->
            Valid nip


apiErrorToStr : Http.Error -> String
apiErrorToStr err =
    case err of
        BadUrl _ ->
            "Nie można skomunikować się z serwerem. Spróbuj ponownie. [BADURL]"

        Timeout ->
            "Nie można skomunikować się z serwerem. Spróbuj ponownie. [TIMEOUT]"

        NetworkError ->
            "Nie można skomunikować się z serwerem. Spróbuj ponownie. [NETWORKERROR]"

        BadStatus status ->
            if status == 409 then
                "Firma o podanym nipie już istnieje."

            else
                "Nie można skomunikować się z serwerem. Spróbuj ponownie. [BADSTATUS]"

        BadBody _ ->
            "Nie można skomunikować się z serwerem. Spróbuj ponownie. [BADBODY]"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Dodaj firmę"
    , body =
        [ viewForm
            [ { label = "Nazwa firmy"
              , type_ = "string"
              , value = getValue model.name
              , onInput = \val -> UpdatedField Name val
              , onBlur = DeactivatedField Name
              , errorList = getErrors model.name
              , otherAttrsInput = []
              }
            , { label = "Numer NIP"
              , type_ = "string"
              , value = getValue model.nipNumber
              , onInput = \val -> UpdatedField NipNumber val
              , onBlur = DeactivatedField NipNumber
              , errorList = getErrors model.nipNumber
              , otherAttrsInput = [ Attr.maxlength 10 ]
              }
            , { label = "Adres"
              , type_ = "string"
              , value = getValue model.address
              , onInput = \val -> UpdatedField Address val
              , onBlur = DeactivatedField Address
              , errorList = getErrors model.address
              , otherAttrsInput = []
              }
            ]
            ( "Dodaj"
            , List.any (\a -> List.isEmpty a |> not)
                [ getErrors model.address
                , getErrors model.name
                , getErrors model.nipNumber
                ]
            )
            (model.responseError |> Maybe.withDefault "")
            Submitted
        ]
    }


getErrors : FormField -> List String
getErrors field =
    case field of
        Invalid _ errors ->
            errors

        _ ->
            []


getValue : FormField -> String
getValue field =
    case field of
        Valid str ->
            str

        Invalid str _ ->
            str

        ToBeValidated str ->
            str
