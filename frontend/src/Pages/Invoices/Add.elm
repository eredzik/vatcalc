module Pages.Invoices.Add exposing (Model, Msg, page)

import Api
import Api.Data exposing (EnterpriseCreateResponse, InvoicePositionInput, InvoiceType)
import Api.Request.Enterprise
import Api.Time exposing (Posix)
import Components.Form exposing (Field, FormField(..), validateWith, viewForm)
import Components.Validate.Nip exposing (NipValidationResult(..), validateNip)
import Date exposing (Date)
import DatePicker exposing (DateEvent(..))
import ElmSpa.Page exposing (Protected(..))
import Gen.Route
import Html.Styled
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
    { invoiceType : Maybe InvoiceType
    , tradingPartnerId : Maybe Int
    , invoiceDate : Maybe Date
    , datepicker : DatePicker.DatePicker
    , invoiceBusinessId : Maybe String
    , invoicepositions : List InvoicePositionInput
    }


init : ( Model, Cmd Msg )
init =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init
    in
    ( Model
        Nothing
        Nothing
        Nothing
        datePicker
        Nothing
        []
    , Cmd.map ToDatePicker datePickerFx
    )



-- UPDATE


type Field
    = NipNumber
    | Address


type Msg
    = UpdatedField Field String
    | DeactivatedField Field
    | Submitted
    | Received (Result Http.Error EnterpriseCreateResponse)
    | ToDatePicker DatePicker.Msg


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        UpdatedField fieldname val ->
            ( model, Cmd.none )

        DeactivatedField fieldname ->
            ( model, Cmd.none )

        Submitted ->
            ( model, Cmd.none )

        Received response ->
            ( model, Cmd.none )

        ToDatePicker subMsg ->
            let
                ( newDatePicker, dateEvent ) =
                    DatePicker.update DatePicker.defaultSettings subMsg model.datepicker

                newDate =
                    case dateEvent of
                        Picked changedDate ->
                            Just changedDate

                        _ ->
                            model.invoiceDate
            in
            ( { model
                | invoiceDate = newDate
                , datepicker = newDatePicker
              }
            , Cmd.none
            )


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
            []
            ( "Dodaj"
            , List.any (\a -> List.isEmpty a |> not)
                []
            )
            ""
            Submitted
        , DatePicker.view model.invoiceDate DatePicker.defaultSettings model.datepicker
            |> Html.Styled.fromUnstyled
            |> Html.Styled.map ToDatePicker
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
