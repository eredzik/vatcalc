module Pages.Home_ exposing (Model, Msg, page)

import Api.Article exposing (Article)
import Api.Article.Filters as Filters
import Api.Article.Tag exposing (Tag)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Html.Styled as Html exposing (..)
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.element
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { listing : Data Api.Article.Listing
    , page : Int
    , tags : Data (List Tag)
    , activeTab : Tab
    }


type Tab
    = FeedFor User
    | Global
    | TagFilter Tag


init : Shared.Model -> ( Model, Cmd Msg )
init shared =
    let
        activeTab : Tab
        activeTab =
            shared.user
                |> Maybe.map FeedFor
                |> Maybe.withDefault Global

        model : Model
        model =
            { listing = Api.Data.Loading
            , page = 1
            , tags = Api.Data.Loading
            , activeTab = activeTab
            }
    in
    ( model
    , Cmd.batch
        [ fetchArticlesForTab shared model
        , Api.Article.Tag.list { onResponse = GotTags }
        ]
    )


fetchArticlesForTab :
    Shared.Model
    ->
        { model
            | page : Int
            , activeTab : Tab
        }
    -> Cmd Msg
fetchArticlesForTab shared model =
    case model.activeTab of
        Global ->
            Api.Article.list
                { filters = Filters.create
                , page = model.page
                , token = Maybe.map .token shared.user
                , onResponse = GotArticles
                }

        FeedFor user ->
            Api.Article.feed
                { token = user.token
                , page = model.page
                , onResponse = GotArticles
                }

        TagFilter tag ->
            Api.Article.list
                { filters =
                    Filters.create
                        |> Filters.withTag tag
                , page = model.page
                , token = Maybe.map .token shared.user
                , onResponse = GotArticles
                }



-- UPDATE


type Msg
    = GotArticles (Data Api.Article.Listing)
    | GotTags (Data (List Tag))
    | SelectedTab Tab
    | ClickedFavorite User Article
    | ClickedUnfavorite User Article
    | ClickedPage Int
    | UpdatedArticle (Data Article)


update : Shared.Model -> Msg -> Model -> ( Model, Cmd Msg )
update shared msg model =
    case msg of
        GotArticles listing ->
            ( { model | listing = listing }
            , Cmd.none
            )

        GotTags tags ->
            ( { model | tags = tags }
            , Cmd.none
            )

        SelectedTab tab ->
            let
                newModel : Model
                newModel =
                    { model
                        | activeTab = tab
                        , listing = Api.Data.Loading
                        , page = 1
                    }
            in
            ( newModel
            , fetchArticlesForTab shared newModel
            )

        ClickedFavorite user article ->
            ( model
            , Api.Article.favorite
                { token = user.token
                , slug = article.slug
                , onResponse = UpdatedArticle
                }
            )

        ClickedUnfavorite user article ->
            ( model
            , Api.Article.unfavorite
                { token = user.token
                , slug = article.slug
                , onResponse = UpdatedArticle
                }
            )

        ClickedPage page_ ->
            let
                newModel : Model
                newModel =
                    { model
                        | listing = Api.Data.Loading
                        , page = page_
                    }
            in
            ( newModel
            , fetchArticlesForTab shared newModel
            )

        UpdatedArticle (Api.Data.Success article) ->
            ( { model
                | listing =
                    Api.Data.map (Api.Article.updateArticle article)
                        model.listing
              }
            , Cmd.none
            )

        UpdatedArticle _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view _ _ =
    { title = ""
    , body =
        [ text "Strona glowna" ]
    }
