module Components.SimpleTable exposing (bootstapTable, createTable, simpleBootstrapTable)

import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr


type alias Column =
    List String


type alias Table =
    { headers :
        List
            { name : String
            , isKey : Bool
            }
    , rows : List Column
    }


tableHeader : Table -> Html msg -> Html msg
tableHeader tab content =
    table (List.map Attr.class [ "table", "table-striped" ])
        [ thead []
            [ tr []
                (List.map
                    (\column ->
                        th
                            [ Attr.scope "col" ]
                            [ text column.name ]
                    )
                    tab.headers
                )
            ]
        , content
        ]


bootstapTable : Table -> Html msg
bootstapTable table_input =
    let
        show_row is_key row_value =
            if is_key then
                th [ Attr.scope "row" ] [ text row_value ]

            else
                td [] [ text row_value ]
    in
    tableHeader table_input
        (tbody []
            (List.map
                (\row ->
                    tr [] <|
                        List.map2
                            (\column_attrs row_value -> show_row column_attrs.isKey row_value)
                            table_input.headers
                            row
                )
                table_input.rows
            )
        )


createTable : List ( String, Bool, a -> String ) -> List a -> Table
createTable options data =
    let
        func_list =
            List.map (\( _, _, func ) -> func) options
    in
    { headers =
        List.map (\( name, isKey, _ ) -> { name = name, isKey = isKey }) options
    , rows = List.map (\row -> List.map (\a -> a row) func_list) data
    }


simpleBootstrapTable : List ( String, Bool, a -> String ) -> List a -> Html msg
simpleBootstrapTable options data =
    createTable options data |> bootstapTable
