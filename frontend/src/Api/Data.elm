module Api.Data exposing
    ( Data(..)
    , expectJson
    , toMaybe
    )

import Http
import Json.Decode as Json


type Data value
    = NotAsked
    | Failure (List String)
    | Success value


toMaybe : Data value -> Maybe value
toMaybe data =
    case data of
        Success value ->
            Just value

        _ ->
            Nothing


expectJson : (Data value -> msg) -> Json.Decoder value -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse (fromResult >> toMsg) <|
        \response ->
            case response of
                Http.BadUrl_ _ ->
                    Err [ "Bad URL" ]

                Http.Timeout_ ->
                    Err [ "Request timeout" ]

                Http.NetworkError_ ->
                    Err [ "Connection issues" ]

                Http.BadStatus_ _ body ->
                    case Json.decodeString errorDecoder body of
                        Ok errors ->
                            Err [ errors ]

                        Err _ ->
                            Err [ "Bad status code" ]

                Http.GoodStatus_ _ body ->
                    case Json.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err [ Json.errorToString err ]


errorDecoder : Json.Decoder String
errorDecoder =
    Json.oneOf [ existingErrorDecoder, formErrorsDecoder ]


existingErrorDecoder : Json.Decoder String
existingErrorDecoder =
    Json.field "detail" Json.string


formErrorsDecoder : Json.Decoder String
formErrorsDecoder =
    Json.field "detail"
        (Json.index 0
            (Json.field "type" Json.string)
        )


fromResult : Result (List String) value -> Data value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err reasons ->
            Failure reasons
