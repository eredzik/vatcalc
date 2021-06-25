module Pages.Partners exposing (Model, Msg, page)

import Api.TradingPartner exposing (TradingPartner)
import Components.SimpleTable exposing (simpleBootstrapTable)
import Effect exposing (Effect)
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


type alias Model =
    { partners : List TradingPartner
    }


type Msg
    = Placeholder


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( { partners = [ TradingPartner "abb" "" "" "" ]
      }
    , Effect.none
    )


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.protected.advanced
        (\_ ->
            { init = init shared
            , update = update req
            , subscriptions = \_ -> Sub.none
            , view = view shared
            }
        )


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update _ _ model =
    ( model, Effect.none )


view : Shared.Model -> Model -> View Msg
view _ model =
    View
        "Partners"
        [ simpleBootstrapTable
            [ ( "ID", True, .id )
            , ( "Numer NIP", False, .nip_number )
            ]
            model.partners
        ]
