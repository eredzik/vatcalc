module TradingPartner.Functions exposing (..)

-- import Backend.Object.Invoice exposing (partner)

import Element
import Html exposing (..)
import RemoteData
import String
import TradingPartner.API
import TradingPartner.Types exposing (..)


validateNIP : String -> NipValidity
validateNIP nip =
    let
        get_val number =
            String.slice number (number + 1) nip |> String.toInt |> Maybe.withDefault 0

        nipValid =
            if String.length nip == 10 then
                if
                    (get_val 0
                        * 6
                        + get_val 1
                        * 5
                        + get_val 2
                        * 7
                        + get_val 3
                        * 2
                        + get_val 4
                        * 3
                        + get_val 5
                        * 4
                        + get_val 6
                        * 5
                        + get_val 7
                        * 6
                        + get_val 8
                        * 7
                        |> modBy
                            11
                    )
                        == get_val 9
                then
                    Valid

                else
                    Invalid

            else
                TooShort
    in
    nipValid


init : TradingPartnerModel
init =
    { newTradePartner =
        { name = ""
        , nipNumber = ""
        , adress = ""
        }
    , tradePartners = RemoteData.Loading
    }


update : TradingPartnerMsg -> TradingPartnerModel -> ( TradingPartnerModel, Cmd TradingPartnerMsg )
update msg model =
    case msg of
        GotPartnersList response ->
            ( { model | tradePartners = response }, Cmd.none )

        AddPartner ->
            ( model, TradingPartner.API.addNewPartner model.newTradePartner )

        UpdateForm partnerData ->
            ( { model | newTradePartner = partnerData }, Cmd.none )

        GotNewPartnerResult _ ->
            ( model, TradingPartner.API.fetchAllPartners )



-- VIEW


view : TradingPartnerModel -> Element.Element msg
view model =
    case model.tradePartners of
        RemoteData.NotAsked ->
            Element.text ""

        RemoteData.Loading ->
            Element.text "Loading..."

        RemoteData.Success trade_partners ->
            Element.table []
                { data = trade_partners
                , columns =
                    [ { header = Element.text "t1"
                      , width = Element.fill
                      , view = \partner -> Element.text (String.fromInt partner.id)
                      }
                    , { header = Element.text "t1"
                      , width = Element.fill
                      , view = \partner -> Element.text partner.nipNumber
                      }
                    , { header = Element.text "t2"
                      , width = Element.fill
                      , view = \partner -> Element.text partner.name
                      }
                    , { header = Element.text "t1"
                      , width = Element.fill
                      , view = \partner -> Element.text partner.adress
                      }
                    ]
                }

        RemoteData.Failure _ ->
            Element.text "download failed"
