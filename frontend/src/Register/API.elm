module Register.API exposing (..)

import Http exposing (Error(..), Expect, expectStringResponse)
import Json.Decode as JD
import Json.Encode as JE
import Register.Types exposing (RegisterModel, RegisterMsg(..), RegisterResponse(..))
import Route exposing (Route(..))
import String exposing (String)


expectJson : (Result Http.Error a -> msg) -> a -> a -> JD.Decoder a -> Expect msg
expectJson toMsg okValue existsValue decoderError =
    expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata body ->
                    if metadata.statusCode == 422 then
                        case JD.decodeString decoderError body of
                            Ok value ->
                                Ok value

                            Err err ->
                                Err (BadBody (JD.errorToString err))

                    else if metadata.statusCode == 400 then
                        Ok existsValue

                    else
                        Err (Http.BadStatus metadata.statusCode)

                Http.GoodStatus_ metadata body ->
                    Ok okValue


register : RegisterModel -> Cmd RegisterMsg
register model =
    let
        body =
            JE.object
                [ ( "email", JE.string model.email )
                , ( "password", JE.string model.password )
                ]
    in
    Http.post
        { url = "/api/auth/register"
        , body = Http.jsonBody body
        , expect = expectJson GotRegisterResult Success EmailExists errorDecoder
        }


errorDecoder : JD.Decoder RegisterResponse
errorDecoder =
    JD.at [ "detail" ]
        (JD.index 0 (JD.at [ "type" ] JD.string))
        |> JD.andThen
            (\str ->
                if str == "value_error.email" then
                    JD.succeed EmailValidationError

                else
                    JD.succeed UnknownError
            )
