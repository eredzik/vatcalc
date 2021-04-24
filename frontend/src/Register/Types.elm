module Register.Types exposing (..)

import Http exposing (Error)
import RemoteData exposing (RemoteData(..), WebData)
import Route exposing (Route(..))


type RegisterMsg
    = EmailInput String
    | PasswordInput String
    | PasswordRepeatedInput String
    | PasswordInputValidation
    | PasswordRepeatedValidation
    | EmailValidation
    | Submit
    | GotRegisterResult (Result Error RegisterResponse)


type RegisterResponse
    = Success
    | EmailExists
    | EmailValidationError
    | UnknownError
    | NotAsked


type alias RegisterModel =
    { postRegistrationResponse : RegisterResponse
    , email : String
    , email_error : String
    , password : String
    , password_error : String
    , password_repeated : String
    , password_repeated_error : String
    }


init : RegisterModel
init =
    { postRegistrationResponse = NotAsked
    , email = ""
    , email_error = ""
    , password = ""
    , password_error = ""
    , password_repeated = ""
    , password_repeated_error = ""
    }
