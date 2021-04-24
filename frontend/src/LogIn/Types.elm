module LogIn.Types exposing (..)


type LogInDataModel
    = Email
    | Password


type alias LogInData =
    { email : String
    , password : String
    }


type alias LogInModel =
    { logInData : LogInData
    }


type LogInMsg
    = EmailUpdate String
    | PasswordUpdate String
    | SubmitForm


init : LogInModel
init =
    { logInData =
        { email = ""
        , password = ""
        }
    }
