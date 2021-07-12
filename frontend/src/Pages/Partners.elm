module Pages.Partners exposing (Model, Msg, page)

import Api.Data exposing (TradingPartnerResponse)
import Components.SimpleTable exposing (simpleBootstrapTable)
import Effect exposing (Effect)
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


type alias Model =
    { partners : List TradingPartnerResponse
    }


type Msg
    = Placeholder


init : Shared.Model -> ( Model, Effect Msg )
init _ =
    ( { partners = []
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
            [ ( "ID", True, .id >> String.fromInt )
            , ( "Numer NIP", False, .nipNumber )
            ]
            model.partners
        ]
