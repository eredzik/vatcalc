module API.FetchTradePartners exposing (getAllPartners, partnersSelection)

import API.Objects exposing (TradePartner)
import Backend.Object
import Backend.Object.TradingPartner as TradingPartner
import Backend.Query as Query
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, map4)


partnersSelection : SelectionSet TradePartner Backend.Object.TradingPartner
partnersSelection =
    map4 TradePartner
        TradingPartner.uuid
        TradingPartner.nipNumber
        TradingPartner.name
        TradingPartner.adress


getAllPartners : SelectionSet (List TradePartner) RootQuery
getAllPartners =
    Query.allPartners partnersSelection
