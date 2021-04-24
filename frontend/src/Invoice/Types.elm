module Invoice.Types exposing (..)

import RemoteData exposing (WebData)
import TradingPartner.Types


type InvoiceType
    = Received
    | Issued
    | NotChosen


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


type alias NewInvoice =
    { invoiceId : String
    , date : String
    , invoiceType : InvoiceType
    , positions : List NewInvoicePosition
    , partnerId : String
    }


type alias NewInvoicePosition =
    { name : String
    , vatRate : Float
    , numItems : Float
    , priceNet : Float
    }


type alias InvoiceModel =
    { allInvoices : WebData (List Invoice)
    , newInvoice : NewInvoice
    }


init : InvoiceModel
init =
    { allInvoices = RemoteData.Loading
    , newInvoice =
        { invoiceId = ""
        , date = ""
        , invoiceType = NotChosen
        , positions = []
        , partnerId = ""
        }
    }
