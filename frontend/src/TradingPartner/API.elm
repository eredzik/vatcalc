module TradingPartner.API exposing (..)

import Http
import Json.Decode as JD
import Json.Encode as JE
import RemoteData
import TradingPartner.Types exposing (..)


partnerDecoder : JD.Decoder TradingPartner
partnerDecoder =
    JD.map4 TradingPartner
        (JD.at [ "id" ] JD.int)
        (JD.at [ "nip_number" ] JD.string)
        (JD.at [ "name" ] JD.string)
        (JD.at [ "adress" ] JD.string)


partnersDecoder : JD.Decoder (List TradingPartner)
partnersDecoder =
    JD.list partnerDecoder


fetchAllPartners : Cmd TradingPartnerMsg
fetchAllPartners =
    Http.get
        { url = "/api/tradingpartner"
        , expect = Http.expectJson (RemoteData.fromResult >> GotPartnersList) partnersDecoder
        }


addNewPartner : TradingPartnerNew -> Cmd TradingPartnerMsg
addNewPartner partner_data =
    let
        body =
            JE.object
                [ ( "name", JE.string partner_data.name )
                , ( "nip_number", JE.string partner_data.name )
                , ( "adress", JE.string partner_data.adress )
                ]
    in
    Http.post
        { url = "/api/tradingpartner"
        , body = Http.jsonBody body
        , expect = Http.expectJson (RemoteData.fromResult >> GotNewPartnerResult) partnerDecoder
        }
