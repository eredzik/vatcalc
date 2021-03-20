module Navbar exposing (..)

import Bootstrap.Navbar
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Route
import Task


type Msg
    = NavbarMsg Bootstrap.Navbar.State


type Tab
    = TradePartnersTab
    | InvoicesTab


type alias Model =
    { state : Bootstrap.Navbar.State
    , activeTab : Tab
    }


init : ( Model, Cmd Msg )
init =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg

        model =
            { state = navbarState
            , activeTab = TradePartnersTab
            }
    in
    ( model
    , navbarCmd
    )


view : Model -> Html Msg
view model =
    let
        active route =
            Bootstrap.Navbar.itemLinkActive [ Route.href route ]

        inactive route =
            Bootstrap.Navbar.itemLink [ Route.href route ]

        tabs =
            case model.activeTab of
                TradePartnersTab ->
                    [ active Route.TradePartner [ Html.text "Kontrahenci" ]
                    , inactive Route.Invoices [ Html.text "Faktury" ]
                    ]

                InvoicesTab ->
                    [ inactive Route.TradePartner [ Html.text "Kontrahenci" ]
                    , active Route.Invoices [ Html.text "Faktury" ]
                    ]
    in
    Bootstrap.Navbar.config NavbarMsg
        |> Bootstrap.Navbar.withAnimation
        |> Bootstrap.Navbar.brand [ Html.Attributes.href "#" ] [ Html.text "VatCalc" ]
        |> Bootstrap.Navbar.items tabs
        |> Bootstrap.Navbar.view model.state


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavbarMsg state ->
            ( { model | state = state }, Cmd.none )
