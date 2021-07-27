module Components.Form exposing (Field, FormField(..), validateWith, viewField, viewForm)

import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Events


type alias Field msg =
    { label : String
    , type_ : String
    , value : String
    , errorList : List String
    , onInput : String -> msg
    , onBlur : msg
    , otherAttrsInput : List (Attribute msg)
    }


type FormField
    = Valid String
    | Invalid String (List String)
    | ToBeValidated String


validateWith : (String -> FormField) -> FormField -> FormField
validateWith func fieldToValidate =
    case fieldToValidate of
        ToBeValidated str ->
            func str

        Invalid a b ->
            Invalid a b

        Valid a ->
            Valid a


viewField : Field msg -> Html msg
viewField options =
    div []
        [ label [ Attr.class "form-label" ] [ text (options.label ++ ": ") ]
        , input
            ([ Attr.class "form-control form-control-lg"
             , Attr.placeholder options.label
             , Attr.type_ options.type_
             , Attr.value options.value
             , Events.onInput options.onInput
             , Events.onBlur options.onBlur
             , Attr.classList
                [ ( "is-valid", List.isEmpty options.errorList )
                , ( "is-invalid", List.isEmpty options.errorList |> not )
                ]
             ]
                ++ options.otherAttrsInput
            )
            []
        , div
            [ Attr.classList
                [ ( "valid-feedback", List.isEmpty options.errorList )
                , ( "invalid-feedback", List.isEmpty options.errorList |> not )
                ]
            ]
            (List.map text options.errorList)
        ]


viewForm :
    List (Field msg)
    -> ( String, Bool )
    -> String
    -> msg
    -> Html msg
viewForm fields ( button_label, buttonDisabled ) errorFeedback onSubmitMsg =
    form [ Events.onSubmit onSubmitMsg, Attr.class "needs-validation" ] <|
        List.map viewField fields
            ++ [ div [ Attr.class "is-valid" ] [ text errorFeedback ]
               , button [ Attr.disabled buttonDisabled ] [ text button_label ]
               ]
