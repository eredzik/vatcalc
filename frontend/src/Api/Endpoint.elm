module Api.Endpoint exposing (..)


type Endpoint
    = Login
    | Register
    | Invoice
    | TradingPartner
    | Enterprise


type ApiPath
    = ApiPath String


endpointToString : Endpoint -> ApiPath -> String
endpointToString endpoint apipathEncapsulated =
    let
        apiPath =
            case apipathEncapsulated of
                ApiPath api ->
                    api
    in
    case endpoint of
        Login ->
            apiPath ++ "/api/auth/login"

        Register ->
            apiPath ++ "/api/auth/register"

        Invoice ->
            apiPath ++ "api/invoice"

        TradingPartner ->
            apiPath ++ "api/trading_partner"

        Enterprise ->
            apiPath ++ "api/enterprise"
