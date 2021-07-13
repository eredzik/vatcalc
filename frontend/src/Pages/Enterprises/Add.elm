module Pages.Enterprises.Add exposing (Model, Msg, page)

import Api
import Api.Data exposing (EnterpriseCreateResponse)
import Api.Request.Enterprise
import Components.Form exposing (Field, viewForm)
import Components.Validator exposing (NipValidationResult(..), validateNip)
import Html.Styled.Attributes as Attr
import Http
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.protected.element
        (\_ ->
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { name : String
    , nameError : List String
    , nipNumber : String
    , nipNumberError : List String
    , address : String
    , addressError : List String
    }


type Field
    = Name
    | NipNumber
    | Address


init : ( Model, Cmd Msg )
init =
    ( Model "" [] "" [] "" [], Cmd.none )



-- UPDATE


type Msg
    = UpdatedField Field String
    | DeactivatedField Field
    | Submitted
    | Received (Result Http.Error EnterpriseCreateResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdatedField fieldname val ->
            case fieldname of
                Name ->
                    ( { model | name = val }, Cmd.none )

                NipNumber ->
                    ( { model | nipNumber = val }, Cmd.none )

                Address ->
                    ( { model | address = val }, Cmd.none )

        DeactivatedField fieldname ->
            case fieldname of
                Name ->
                    if String.isEmpty model.name then
                        ( { model | nameError = [ "Nazwa firmy nie może być pusta" ] }, Cmd.none )

                    else
                        ( { model | nameError = [] }, Cmd.none )

                NipNumber ->
                    let
                        validationResult =
                            case validateNip model.nipNumber of
                                InvalidNipLength ->
                                    [ "Nip musi mieć równo 10 znaków." ]

                                InvalidNipControlNumber ->
                                    [ "Niepoprawny numer nip - błąd walidacji cyfry kontrolnej." ]

                                InvalidNipSymbols ->
                                    [ "Numer nip powinien składać się tylko z cyfr" ]

                                CorrectNipNumber ->
                                    []
                    in
                    ( { model | nipNumberError = validationResult }, Cmd.none )

                Address ->
                    if String.isEmpty model.address then
                        ( { model | addressError = [ "Adres firmy nie może być pusty" ] }, Cmd.none )

                    else
                        ( { model | addressError = [] }, Cmd.none )

        Submitted ->
            ( model
            , Api.Request.Enterprise.createEnterpriseEnterprisePost
                { nipNumber = model.nipNumber
                , name = model.name
                , address = model.address
                }
                |> Api.send Received
            )

        Received _ ->
            ( model, Cmd.none )



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
              , value = model.name
              , onInput = \val -> UpdatedField Name val
              , onBlur = DeactivatedField Name
              , errorList = model.nameError
              , otherAttrsInput = []
              }
            , { label = "Numer NIP"
              , type_ = "string"
              , value = model.nipNumber
              , onInput = \val -> UpdatedField NipNumber val
              , onBlur = DeactivatedField NipNumber
              , errorList = model.nipNumberError
              , otherAttrsInput = [ Attr.maxlength 10 ]
              }
            , { label = "Adres"
              , type_ = "string"
              , value = model.address
              , onInput = \val -> UpdatedField Address val
              , onBlur = DeactivatedField Address
              , errorList = model.addressError
              , otherAttrsInput = []
              }
            ]
            ( "Dodaj", List.any (\a -> List.isEmpty a |> not) [ model.addressError, model.nameError, model.nipNumberError ] )
            Submitted
        ]
    }
