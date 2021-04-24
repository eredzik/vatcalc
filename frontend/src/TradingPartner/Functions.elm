module TradingPartner.Functions exposing (..)

-- import Backend.Object.Invoice exposing (partner)

import Html exposing (..)
import RemoteData
import String
import TableBuilder.TableBuilder exposing (buildTable)
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


view : TradingPartnerModel -> Html msg
view model =
    case model.tradePartners of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success trade_partners ->
            let
                listrows row =
                    [ String.fromInt row.id, row.nipNumber, row.name, row.adress ]
            in
            buildTable
                [ "ID", "Numer NIP", "Nazwa kontrahenta", "Adres kontrahenta" ]
                (List.map listrows trade_partners)

        RemoteData.Failure _ ->
            text "download failed"
