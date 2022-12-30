module Main exposing (init, main, update, view)

-- TODO: Implement actual API.
-- TODO: Make loading / error page for initial load / submit.
-- TODO: ismanager check.

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Dict
import Time
import Array
import Http

import Browser.Navigation as Nav
import Url exposing (Url)

import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col

import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Form.Radio as Radio

import Markdown.Render
import Markdown.Option

import QS

-- Local packages:
import Config exposing (..)
import Api


-- MAIN

main =
  Browser.application
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    , onUrlChange = ChangedUrl
    , onUrlRequest = ClickedLink
    }

-- MODEL


type alias Model =
  { wizard : Wizard
  , pageIndex : Int
  , scores : Dict.Dict String ResultKind
  , navbarState : Navbar.State
  , url : Url.Url
  , key : Nav.Key
  , feedbackFor : String
  , feedbackUID : String
  , time : Time.Posix
  }


-- TODO: move to util.
getQueryParam : Url -> String -> String
getQueryParam url key =
    let
        maybeVal = QS.get key
                <| QS.parse QS.config
                <| Maybe.withDefault "" url.query
    in
        case maybeVal of
            Just oneOrMany ->
                case oneOrMany of
                    QS.One val ->
                        val
                    _ ->
                        ""
            Nothing ->
                ""


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
   let
      (navbarState, navbarCmd ) =
        Navbar.initialState NavbarMsg
    in
    ({ wizard = configuredWizard
     , pageIndex = Maybe.withDefault 0 <| String.toInt <| getQueryParam url "page"
     , scores = Dict.empty
     , navbarState = navbarState
     , url = url
     , key = key
     -- TODO: This needs proper error handling. If url does not contain those fields, all is lost.
     , feedbackFor = getQueryParam url "feedbackFor"
     , feedbackUID = getQueryParam url "feedbackUID"
     , time = Time.millisToPosix 0
     }, navbarCmd )



-- UPDATE


type Msg
  = Submit
  | Next
  | Prev
  | Score String ResultKind
  | ChangedUrl Url
  | ClickedLink Browser.UrlRequest
  | NavbarMsg Navbar.State
  | MarkdownMsg Markdown.Render.MarkdownMsg -- when user clicks something in the markdown.
  | Tick Time.Posix
  | UploadResult (Result Http.Error Api.ApiErr)


-- TODO: move to util.
replaceQueryParam : Url.Url -> String -> String -> Url.Url
replaceQueryParam url key value =
    let
        oldQueryParams = QS.parse QS.config (Maybe.withDefault "" url.query)
        newQueryParams = QS.set key (QS.One value ) oldQueryParams
    in
        { url | query = Just <| String.dropLeft 1 <| QS.serialize QS.config newQueryParams }


reportFromModel : Model -> Api.Report
reportFromModel model =
    { unixStampMs = Time.posixToMillis model.time
    , feedbackFor = model.feedbackFor
    , feedbackUID = model.feedbackUID
    , results = model.scores
    }


allRequiredFieldsSet : Model -> Bool
allRequiredFieldsSet model =
    List.all identity
        (List.map
            (\page ->
                List.all
                    (\question -> Dict.member question.text model.scores)
                    (List.filter .required page.questions)
            )
            model.wizard.pages
        )

updatePageIndex : Model -> Int -> (Model, Cmd msg)
updatePageIndex model inc =
    let
        nPages = List.length model.wizard.pages
        newIndex = model.pageIndex+inc
        newIndexClamped = if newIndex > (nPages + 1) then
            nPages + 1
          else if newIndex < 0 then
            0
          else
            newIndex

        newUrl = replaceQueryParam model.url "page" (String.fromInt newIndexClamped)
    in
        ({ model | pageIndex = newIndexClamped }
        , Nav.pushUrl model.key (Url.toString (Debug.log "url" newUrl))
        )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Next ->
        updatePageIndex model 1

    Prev ->
        updatePageIndex model -1

    Submit ->
        (model, Api.doUpload (reportFromModel model) UploadResult)

    Score text result ->
        ({ model | scores = Dict.insert text result model.scores }, Cmd.none)

    ChangedUrl url ->
        ( { model | url = url }, Cmd.none)

    UploadResult result ->
        case result of
            Ok apiErr ->
                (model, Cmd.none)
            Err _ ->
                (model, Cmd.none)

    ClickedLink request ->
        -- NOTE: This is only here to not reload on clicking internal URLs, if any.
        case request of
            -- User clicked on link inside application:
            Browser.Internal url ->
              ( model, Nav.pushUrl model.key (Url.toString url) )

            -- User clicked on external link:
            Browser.External href ->
              ( model, Nav.load href )

    MarkdownMsg _ ->
        ( model, Cmd.none)

    NavbarMsg state ->
        ( { model | navbarState = state }, Cmd.none )

    Tick newTime ->
      ( { model | time = newTime }
      , Cmd.none
      )



-- VIEW

viewIntro : Model -> Html Msg
viewIntro model =
    Grid.container []
        [ Grid.row
            [ Row.centerSm ]
            [ Grid.col
                [ Col.sm8 ]
                [ h1 [] [ text "Intro" ] ]
            ]
        , Grid.row
            [ Row.centerSm ]
            [ Grid.col
                [ Col.sm8 ]
                [ Markdown.Render.toHtml Markdown.Option.Standard model.wizard.intro |>
                    Html.map MarkdownMsg
                ]
            ]
        ]

-- TODO: Display submit button here.
viewOutro : Model -> Html Msg
viewOutro model =
    Grid.container []
        [ Grid.row
            [ Row.centerSm ]
            [ Grid.col
                [ Col.sm8 ]
                [ h1 [] [ text "Outro" ] ]
            ]
        , Grid.row
            [ Row.centerSm ]
            [ Grid.col
                [ Col.sm8 ]
                [ text model.wizard.outro ]
            ]
        , Grid.row
            [ Row.centerSm ]
            [ Grid.col
                [ Col.sm8 ]
                [ Button.button
                    [ Button.primary
                    , Button.onClick Submit
                    , Button.disabled (allRequiredFieldsSet model)
                    ]
                    [ i [ class "fas fa-solid fa-check" ] []
                    , text "Submit" ]
                ]
            ]
        ]

-- getRangeResultInt gets the current score of a range result.
-- Returns -1 on error.
getRangeResultInt: Model -> String -> Int
getRangeResultInt model key =
    let
        maybeResult = Dict.get key model.scores
    in
    case maybeResult of
        Just result ->
            case result of
                RangeResult num ->
                    num
                _ ->
                    -1
        Nothing ->
            -1


viewQuestionRange : Model -> Question -> Int -> Html Msg
viewQuestionRange model question range =
    let
        -- Figure out the current score that was set and default to -1 if none yet.
        currentRadioIdx = getRangeResultInt model question.text
    in
    Grid.row
      [ Row.centerSm ]
      [ Grid.col
          [ Col.sm1 ]
          [ img [ src "/images/flamingo.svg", id "failmongo" ] [] ]
      , Grid.col
          [ Col.sm10 ]
          (List.map
            (\idx ->
                Radio.radio
                    [ Radio.id "question-range-radio"
                    , Radio.checked (currentRadioIdx == idx)
                    , Radio.onClick (Score question.text <| RangeResult idx)
                    , Radio.inline
                    ]
                    (String.fromInt idx)
            )
            (List.range 1 range)
          )
      , Grid.col
          [ Col.sm1 ]
          [ img [ src "/images/penguin.svg", id "penguin" ] [] ]
      ]

viewQuestionText : Model -> Question -> Int -> Html Msg
viewQuestionText _ question nRows =
    Grid.row
      [ Row.centerSm ]
      [ Grid.col
          [ Col.sm12 ]
          [
            Textarea.textarea
            [ Textarea.id <| question.text ++ "-textarea"
            , Textarea.rows nRows
            , Textarea.onInput (\text -> Score question.text <| TextResult text)
            ]
          ]
      ]


viewQuestionInput : Model -> Question -> Html Msg
viewQuestionInput model question =
    case question.kind of
        Range range ->
            viewQuestionRange model question range
        Text nRows ->
            viewQuestionText model question nRows



viewQuestion : Model -> Question -> List (Html Msg)
viewQuestion model question =
    [ Grid.row
        [ Row.centerSm ]
        [ Grid.col
            [ Col.sm12 ]
            [ h3 [] [ text question.text ] ]
        ]
    , Grid.row
        [ Row.leftSm ]
        [ Grid.col
            [ Col.sm12 ]
            [ text question.description ]
        ]
    , viewQuestionInput model question
    ]

viewPage : Model -> Page -> Html Msg
viewPage model page =
    Grid.container []
        ((Grid.row
            [ Row.centerSm ]
            [ Grid.col
                [ Col.sm8 ]
                [ h1 [] [ text page.title ] ]
            ]
        ) :: List.map
          (\question -> Grid.row
            [ Row.centerSm, Row.attrs [ class "question-row" ] ]
            [ Grid.col
                [ Col.sm8 ]
                (viewQuestion model question)
            ]
          )
          page.questions
        )


viewNavbar : Model -> Html Msg
viewNavbar model =
    Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.brand [ href "#" ]
            [ img [ src "/bastelbude.png", id "bastelbuden-logo" ] []
            , text <| "365° Feedback for " ++ model.feedbackFor
            ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#" ]
                [ Button.button
                    [ Button.primary
                    , Button.onClick Prev
                    , Button.disabled (model.pageIndex == 0)
                    ]
                    [ text "Prev" ]
                ]
            , Navbar.itemLink [ href "#" ]
                [ Button.button
                    [ Button.primary
                    , Button.onClick Next
                    , Button.disabled (model.pageIndex == List.length model.wizard.pages + 1)
                    ]
                    [ text "Next" ]
                ]
            ]
        |> Navbar.view model.navbarState


viewCurrentPage : Model -> Html Msg
viewCurrentPage model =
  let
    -- NOTE: Page index starts at 1.
    lastPageIndex = 1 + List.length model.wizard.pages
  in
  if model.pageIndex == 0 then
    viewIntro model
  else if model.pageIndex == lastPageIndex then
    viewOutro model
  else
    let
        currentPage = Array.get (model.pageIndex - 1) <|
            Array.fromList model.wizard.pages
    in
    case currentPage of
        Just page ->
            viewPage model page
        Nothing ->
            span [] [ text "You somehow reached a non-existing page" ]


view : Model -> Browser.Document Msg
view model =
  { title = "365° Feedback for " ++ model.feedbackFor
  , body =
    [ viewNavbar model
    , viewCurrentPage model
    , pre [] [text <| Api.encodeReportAsText <| reportFromModel model ]
    ]
  }

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
      [ Navbar.subscriptions model.navbarState NavbarMsg
      , Time.every 1000 Tick
      ]
