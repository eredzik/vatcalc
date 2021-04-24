module Main.Types exposing (..)

import Browser
import Browser.Navigation
import Invoice.API
import Invoice.Types
import LogIn.Types
import Platform.Cmd
import Register.Types
import Route exposing (Route(..), fromUrl)
import SiteState.Types
import TradingPartner.API
import TradingPartner.Types
import Url


type Msg
    = TradingPartnerMsg TradingPartner.Types.TradingPartnerMsg
    | InvoiceMsg Invoice.Types.InvoiceMsg
    | LogInMsg LogIn.Types.LogInMsg
    | UrlRequest Browser.UrlRequest
    | UrlChange Url.Url
    | RegisterMsg Register.Types.RegisterMsg


type alias Model =
    { key : Browser.Navigation.Key
    , route : Route.Route
    , siteState : SiteState.Types.SiteStateModel
    , tradingPartners : TradingPartner.Types.TradingPartnerModel
    , invoices : Invoice.Types.InvoiceModel
    , logInModel : LogIn.Types.LogInModel
    , registerModel : Register.Types.RegisterModel
    }


init : {} -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , route = fromUrl url
      , siteState = SiteState.Types.init
      , tradingPartners = TradingPartner.Types.init
      , invoices = Invoice.Types.init
      , logInModel = LogIn.Types.init
      , registerModel = Register.Types.init
      }
    , Platform.Cmd.batch
        [ Cmd.map TradingPartnerMsg TradingPartner.API.fetchAllPartners
        , Cmd.map InvoiceMsg Invoice.API.fetchAllInvoices
        ]
    )
