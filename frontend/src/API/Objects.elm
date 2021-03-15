module API.Objects exposing (TradePartner)

import Backend.Scalar exposing (Id)


type alias TradePartner =
    { nip_number : Maybe String
    , name : Maybe String
    , adress : Maybe String
    , id : Id
    }
