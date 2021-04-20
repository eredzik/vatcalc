module Main.Types exposing (..)

import Browser
import Invoice.Types exposing (..)
import TradingPartner.Types
import Url


type LoggedStatus
    = Logged
    | Visitor


type Msg
    = UrlRequest Browser.UrlRequest
    | UrlChange Url.Url
    | TradingPartnerMsg TradingPartner.Types.TradingPartnerMsg
    | InvoiceMsg Invoice.Types.InvoiceMsg
    | Form FormMsg


type FormMsg
    = EmailUpdate String
    | PasswordUpdate String
    | SubmitForm
