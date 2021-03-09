module DecoderTradePartners exposing (TradePartner, TradePartnerNew, partnersDecoder, partnersEncoder)

import Json.Decode exposing (Decoder, field, int, string)
import Json.Encode as Encode


type alias TradePartner =
    { nip_number : String
    , name : String
    , adress : String
    , id : Int
    }


partnersDecoder : Decoder TradePartner
partnersDecoder =
    Json.Decode.map4 TradePartner
        (field "nip_number" string)
        (field "name" string)
        (field "adress" string)
        (field "id" int)


type alias TradePartnerNew =
    { nip_number : String
    , name : String
    , adress : String
    }


partnersEncoder : TradePartnerNew -> Encode.Value
partnersEncoder trade_partner =
    Encode.object
        [ ( "nip_number", Encode.string trade_partner.nip_number )
        , ( "name", Encode.string trade_partner.name )
        , ( "adress", Encode.string trade_partner.adress )
        ]
