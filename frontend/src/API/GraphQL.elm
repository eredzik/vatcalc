module API.GraphQL exposing (makeGraphQLMutation, makeGraphQLQuery)

import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet)


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


makeGraphQLMutation :
    SelectionSet decodesTo RootMutation
    -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg)
    -> Cmd msg
makeGraphQLMutation mutation decodesTo =
    mutation
        |> Graphql.Http.mutationRequest graphql_url
        |> Graphql.Http.send decodesTo
