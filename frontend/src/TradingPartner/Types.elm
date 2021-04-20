module TradingPartner.Types exposing (..)

import RemoteData exposing (WebData)


type alias TradingPartnerNew =
    { name : String
    , nipNumber : String
    , adress : String
    }


type alias TradingPartner =
    { id : Int
    , nipNumber : String
    , name : String
    , adress : String
    }


type NipValidity
    = Valid
    | Invalid
    | TooShort


type TradingPartnerMsg
    = AddPartner
    | UpdateForm TradingPartnerNew
    | GotNewPartnerResult (WebData TradingPartner)
    | GotPartnersList (WebData (List TradingPartner))


