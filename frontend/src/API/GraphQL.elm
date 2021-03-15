module API.GraphQL exposing (makeGraphQLQuery)

import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, map4, with)


graphql_url : String
graphql_url =
    "http://localhost:8000/"


makeGraphQLQuery :
    SelectionSet decodesTo RootQuery
    -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg)
    -> Cmd msg
makeGraphQLQuery query decodesTo =
    query
        |> Graphql.Http.queryRequest graphql_url
        |> Graphql.Http.send decodesTo
