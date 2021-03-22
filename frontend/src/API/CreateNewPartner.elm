module API.CreateNewPartner exposing (..)

import API.FetchTradePartners exposing (partnersSelection)
import API.Objects exposing (TradePartner, TradePartnerNew, TradePartnerResponse)
import Backend.Mutation as Mutation
import Backend.Object
import Backend.Object.CreateTradingPartner
import Backend.Object.TradingPartner
import Graphql.Operation exposing (RootMutation)
import Graphql.OptionalArgument
import Graphql.SelectionSet exposing (SelectionSet, map2, map4)



-- CreateTradingPartner -> SelectionSet (Maybe decodesTo)


createNewPartner :
    TradePartnerNew
    -> SelectionSet (Maybe TradePartnerResponse) RootMutation
createNewPartner trade_partner =
    Mutation.createTradingPartner
        (createNewPartnerOptionalArgs
            trade_partner.adress
        )
        (Mutation.CreateTradingPartnerRequiredArguments trade_partner.name trade_partner.nip_number)
        partnersSelection


partnersSelection : SelectionSet TradePartnerResponse Backend.Object.CreateTradingPartner
partnersSelection =
    map2 TradePartnerResponse
        Backend.Object.CreateTradingPartner.ok
        (Backend.Object.CreateTradingPartner.tradingPartner
            (map4
                TradePartner
                Backend.Object.TradingPartner.uuid
                Backend.Object.TradingPartner.nipNumber
                Backend.Object.TradingPartner.name
                Backend.Object.TradingPartner.adress
            )
        )


createNewPartnerOptionalArgs : String -> Mutation.CreateTradingPartnerOptionalArguments -> Mutation.CreateTradingPartnerOptionalArguments
createNewPartnerOptionalArgs adress =
    \args ->
        { args
            | adress = Graphql.OptionalArgument.Present adress
        }
