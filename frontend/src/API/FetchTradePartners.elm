module API.FetchTradePartners exposing (getAllPartners)

import API.GraphQL exposing (makeGraphQLQuery)
import API.Objects exposing (TradePartner)
import Backend.Object
import Backend.Object.TradingPartner as TradingPartner
import Backend.Query as Query
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, map4, with)


partnersSelection : SelectionSet TradePartner Backend.Object.TradingPartner
partnersSelection =
    map4 TradePartner
        TradingPartner.nipNumber
        TradingPartner.name
        TradingPartner.adress
        TradingPartner.uuid


getAllPartners : SelectionSet (List TradePartner) RootQuery
getAllPartners =
    Query.allPartners partnersSelection
