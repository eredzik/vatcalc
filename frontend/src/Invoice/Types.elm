module Invoice.Types exposing (..)

import RemoteData exposing (WebData)
import TradingPartner.Types


type InvoiceType
    = Received
    | Issued


type alias Invoice =
    { id : Int
    , invoiceId : String
    , date : String
    , invoiceType : InvoiceType
    , positions : List InvoicePosition
    , partner : TradingPartner.Types.TradingPartner
    }


type InvoiceMsg
    = GotAllInvoices (WebData (List Invoice))


type alias InvoicePosition =
    { id : Int
    , name : String
    , vatRate : Float
    , numItems : Float
    , priceNet : Float
    }


type alias InvoiceModel =
    { allInvoices : WebData (List Invoice)
    }
