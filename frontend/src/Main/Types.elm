module Main.Types exposing (..)

import Browser
import Browser.Navigation
import Invoice.Types exposing (..)
import TradingPartner.Types
import Url


type LoggedStatus
    = Logged
    | Visitor


type alias Model =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , tradingPartners : TradingPartner.Types.TradingPartnerModel
    , invoices : Invoice.Types.InvoiceModel
    , loggedStatus : LoggedStatus
    }


type alias Flags =
    {}


type Msg
    = UrlRequest Browser.UrlRequest
    | UrlChange Url.Url
    | TradingPartnerMsg TradingPartner.Types.TradingPartnerMsg
    | InvoiceMsg Invoice.Types.InvoiceMsg
