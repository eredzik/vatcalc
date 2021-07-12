module Example exposing (..)

import Expect
import Test exposing (..)


suite : Test
suite =
    test "Abc"
        (\_ ->
            Expect.equal
                1
                1
        )



--     test "User gets decoded"
--         (\_ ->
--             let
--                 input =
--                     "{\"email\":\"a@b.c\",\"token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiZGZkNzYwZDUtNmRmYy00NjM5LWExZGYtNmNjYmEyZDM0YmI3IiwiYXVkIjoiZmFzdGFwaS11c2VyczphdXRoIiwiZXhwIjoxNjI0Njk3NTg1fQ.b5oUd7N7fHlLgY7XGTQmmeJxSA3cYQ5UHxo-1RlPHqw\"}"
--                 decodedOutput =
--                     Json.decodeString Api.User.decoder input
--             in
--             Expect.equal
--                 (Ok
--                     (Api.User.User
--                         "a@b.c"
--                         (Token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiZGZkNzYwZDUtNmRmYy00NjM5LWExZGYtNmNjYmEyZDM0YmI3IiwiYXVkIjoiZmFzdGFwaS11c2VyczphdXRoIiwiZXhwIjoxNjI0Njk3NTg1fQ.b5oUd7N7fHlLgY7XGTQmmeJxSA3cYQ5UHxo-1RlPHqw")
--                         Nothing
--                     )
--                 )
--                 decodedOutput
--         )
