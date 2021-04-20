module TableBuilder.TableBuilder exposing (..)

import Html exposing (..)


buildTable : List String -> List (List String) -> Html msg
buildTable listHeaders listRowsData =
    let
        datarow_to_row row =
            tr [] (List.map split_rows row)

        split_rows value =
            td [] [ text value ]

        header_to_row_header value =
            th [] [ text value ]
    in
    table []
        [ thead []
            (List.map
                header_to_row_header
                listHeaders
            )
        , tbody [] (List.map datarow_to_row listRowsData)
        ]
