module API.Objects exposing (Invoice, InvoicePosition, TradePartner, TradePartnerNew, TradePartnerResponse)

import Backend.Enum.InvoiceType
import Backend.Enum.VatRates
import Backend.Scalar


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


type alias Invoice =
    { uuid : Int
    , invoice_id : String
    , invoice_date : Backend.Scalar.Date
    , invoice_type : Backend.Enum.InvoiceType.InvoiceType
    , partner : TradePartner
    , invoiceposition : List InvoicePosition
    }


type alias InvoicePosition =
    { uuid : Int
    , name : Maybe String
    , vat_rate : Backend.Enum.VatRates.VatRates
    , num_items : Float
    , price_net : Float
    }
