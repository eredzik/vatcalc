module API.Objects exposing (TradePartner)


type alias TradePartner =
    { id : Int
    , nip_number : Maybe String
    , name : Maybe String
    , adress : Maybe String
    }
