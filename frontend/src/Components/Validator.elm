module Components.Validator exposing (NipValidationResult(..), validateNip)


type NipValidationResult
    = InvalidNipLength
    | InvalidNipControlNumber
    | InvalidNipSymbols
    | CorrectNipNumber


validateNip : String -> NipValidationResult
validateNip nipNumber =
    if String.length nipNumber /= 10 then
        InvalidNipLength

    else
        let
            listOfMaybeNums =
                String.toList nipNumber |> List.map String.fromChar |> List.map String.toInt

            listOfNums =
                List.map
                    (\maybeNum ->
                        case maybeNum of
                            Just num ->
                                num

                            Nothing ->
                                99
                    )
                    listOfMaybeNums
        in
        if List.any (\n -> n == 99) listOfNums then
            InvalidNipSymbols

        else if
            listOfNums
                |> List.take 9
                |> List.map2 (*) [ 6, 5, 7, 2, 3, 4, 5, 6, 7 ]
                |> List.sum
                |> modBy 11
                |> (==) (listOfNums |> List.drop 9 |> List.take 1 |> List.sum)
        then
            CorrectNipNumber

        else
            InvalidNipControlNumber



-- [ 6, 5, 7, 2, 3, 4, 5, 6, 7 ]
