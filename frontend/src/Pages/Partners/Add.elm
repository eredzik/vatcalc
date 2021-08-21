module Pages.Partners.Add exposing (Model, Msg, page)

import Api
import Api.Data
import Api.Request.TradingPartner
import Components.Form exposing (viewForm)
import Components.Validate.Nip
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Http
import Page
import Request exposing (Request)
import Shared
import User
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.element
        (\user ->
            { init = init
            , update = update user
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { name : String
    , nameErrors : List String
    , nipNumber : String
    , nipNumberErrors : List String
    , address : String
    , addressErrors : List String
    , responseError : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [] "" [] "" [] ""
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdatedField Field String
    | DeactivatedField Field
    | Submitted
    | ReceivedResponse (Result Http.Error Api.Data.TradingPartnerResponse)


type Field
    = Name
    | NipNumber
    | Address


update : User.User -> Msg -> Model -> ( Model, Cmd Msg )
update user msg model =
    case msg of
        UpdatedField field str ->
            case field of
                Name ->
                    ( { model | name = str, nameErrors = [] }, Cmd.none )

                NipNumber ->
                    ( { model
                        | nipNumber =
                            case String.toInt str of
                                Just _ ->
                                    str

                                Nothing ->
                                    model.nipNumber
                        , nipNumberErrors = []
                      }
                    , Cmd.none
                    )

                Address ->
                    ( { model | address = str, addressErrors = [] }, Cmd.none )

        DeactivatedField field ->
            case field of
                Name ->
                    ( { model
                        | nameErrors =
                            if String.isEmpty model.name then
                                "Nazwa nie może być pusta" :: model.nameErrors

                            else
                                []
                      }
                    , Cmd.none
                    )

                NipNumber ->
                    ( { model | nipNumberErrors = Components.Validate.Nip.validateToErrorList model.nipNumber }, Cmd.none )

                Address ->
                    ( { model
                        | addressErrors =
                            if String.isEmpty model.address then
                                "Adres nie może być pusty" :: model.addressErrors

                            else
                                []
                      }
                    , Cmd.none
                    )

        Submitted ->
            ( model
            , Api.Request.TradingPartner.addTradingPartnerTradingPartnerPost
                { nipNumber = model.nipNumber
                , name = model.name
                , address = model.address
                , enterpriseId = user.favEnterpriseId |> Maybe.withDefault -1
                }
                |> Api.send ReceivedResponse
            )

        ReceivedResponse _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Dodaj partnera"
    , body =
        [ viewForm
            [ { label = "Numer NIP"
              , type_ = "string"
              , value = model.nipNumber
              , onInput = \val -> UpdatedField NipNumber val
              , onBlur = DeactivatedField NipNumber
              , errorList = model.nipNumberErrors
              , otherAttrsInput = [ Attr.maxlength 10, Attr.class "nip-input-field" ]
              }
            , { label = "Nazwa firmy"
              , type_ = "string"
              , value = model.name
              , onInput = \val -> UpdatedField Name val
              , onBlur = DeactivatedField Name
              , errorList = model.nameErrors
              , otherAttrsInput = []
              }
            , { label = "Adres firmy"
              , type_ = "string"
              , value = model.address
              , onInput = \val -> UpdatedField Address val
              , onBlur = DeactivatedField Address
              , errorList = model.addressErrors
              , otherAttrsInput = []
              }
            ]
            ( "Dodaj"
            , List.any (\a -> List.isEmpty a |> not)
                []
            )
            model.responseError
            Submitted
        ]
    }
