module SiteState.Types exposing (..)

import Browser
import Browser.Navigation
import Route exposing (fromUrl)
import Url


type alias Token =
    String


type LoggedStatus
    = Logged Token
    | Visitor


type alias SiteStateModel =
    { loggedStatus : LoggedStatus
    }


init : SiteStateModel
init =
    { loggedStatus = Visitor
    }
