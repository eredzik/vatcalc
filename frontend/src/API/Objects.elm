module API.Objects exposing (TradePartner, TradePartnerNew, TradePartnerResponse)


type alias TradePartner =
    { id : Int
    , nip_number : Maybe String
    , name : Maybe String
    , adress : Maybe String
    }


type alias TradePartnerNew =
    { nip_number : String
    , name : String
    , adress : String
    }


type alias TradePartnerResponse =
    { ok : Maybe Bool
    , trade_partner : Maybe TradePartner
    }
