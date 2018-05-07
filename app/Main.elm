module Pomodoro exposing (main)

import Html exposing (..)
import Html.Attributes exposing (autofocus, class, disabled, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)


type alias Id =
    Int


type alias Task =
    { id : Id
    , description : String
    , done : Bool
    }


type alias Model =
    { tasks : List Task
    , newTask : String
    }


initialModel : Model
initialModel =
    { tasks = []
    , newTask = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


viewHeader : Html Msg
viewHeader =
    nav [ class "header" ]
        [ div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-12" ]
                    [ h1 [ class "display-4" ]
                        [ text "Pomodoro" ]
                    ]
                ]
            ]
        ]


viewNewTask : Model -> Html Msg
viewNewTask model =
    div [ class "new-task" ]
        [ form [ class "d-flex", onSubmit SaveTask ]
            [ input
                [ type_ "text"
                , class "flex-fill"
                , placeholder "Add a task..."
                , value model.newTask
                , autofocus True
                , onInput UpdateTask
                ]
                []
            , button
                [ disabled (String.isEmpty model.newTask)
                , class "btn btn-dark"
                ]
                [ text "Add" ]
            ]
        ]


viewTaskActions : Task -> Html Msg
viewTaskActions task =
    div [ class "actions" ]
        [ button [ class "btn btn-dark" ] [ text "Done" ]
        , button [ class "btn btn-dark" ] [ text "Remove" ]
        ]


viewTask : Task -> Html Msg
viewTask task =
    li [ class "task d-flex" ]
        [ div [ class "desc flex-fill" ] [ text task.description ]
        , viewTaskActions task
        ]


viewTaskList : List Task -> Html Msg
viewTaskList tasks =
    ul [ class "tasks" ] (List.map viewTask tasks)


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewHeader
        , viewTaskList model.tasks
        , viewNewTask model
        ]


type Msg
    = SaveTask
    | UpdateTask String


addNewTask : Model -> Model
addNewTask model =
    let
        task =
            Task (List.length model.tasks) model.newTask False

        newTasks =
            model.tasks ++ [ task ]
    in
        { model | tasks = newTasks, newTask = "" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveTask ->
            ( addNewTask model, Cmd.none )

        UpdateTask description ->
            ( { model | newTask = description }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
