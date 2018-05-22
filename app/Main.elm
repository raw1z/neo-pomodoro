module Pomodoro exposing (main)

import Html exposing (..)
import Html.Attributes exposing (autofocus, class, disabled, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Time exposing (Time, second)


type alias Id =
    Int


type alias Task =
    { id : Id
    , description : String
    , done : Bool
    }


type TimerStatus
    = Work Int
    | Pause Int
    | LongPause


type alias Timer =
    { task : Task
    , elapsedTime : Int
    , timeout : Int
    , status : TimerStatus
    , statusCount : Int
    }


type alias Model =
    { tasks : List Task
    , newTask : String
    , timer : Maybe Timer
    }


workTimeout : Int
workTimeout =
    1200


pauseTimeout : Int
pauseTimeout =
    300


longPauseTimeout : Int
longPauseTimeout =
    1200


initialModel : Model
initialModel =
    { tasks = []
    , newTask = ""
    , timer = Nothing
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
                    [ h1 [] [ text "Pomodoro" ]
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
                [ text "+" ]
            ]
        ]


viewTaskActions : Task -> Html Msg
viewTaskActions task =
    div [ class "actions" ]
        [ button
            [ class "btn btn-dark"
            , onClick (RemoveTask task)
            ]
            [ text "-" ]
        ]


viewTask : Task -> Html Msg
viewTask task =
    li [ class "task d-flex" ]
        [ div
            [ class "desc flex-fill"
            , onClick (UpdateTimer task)
            ]
            [ text task.description ]
        , viewTaskActions task
        ]


viewTaskList : List Task -> Html Msg
viewTaskList tasks =
    ul [ class "tasks" ] (List.map viewTask tasks)


formatMinutesOrSeconds : Int -> String
formatMinutesOrSeconds value =
    String.padLeft 2 '0' (toString value)


viewTimerTimeout : Timer -> Html Msg
viewTimerTimeout timer =
    let
        minutes =
            timer.timeout // 60

        seconds =
            timer.timeout - (minutes * 60)
    in
        h1 [ class "display-1 timeout" ]
            [ text (formatMinutesOrSeconds minutes)
            , text ":"
            , text (formatMinutesOrSeconds seconds)
            ]


viewTimerClassNames : Timer -> String
viewTimerClassNames timer =
    case timer.status of
        Work _ ->
            "timer timer-work"

        _ ->
            "timer timer-pause"


viewTimer : Maybe Timer -> Html Msg
viewTimer timer =
    case timer of
        Just timer ->
            div [ class (viewTimerClassNames timer) ]
                [ viewTimerTimeout timer
                , div [ class "task-description" ]
                    [ text timer.task.description ]
                ]

        Nothing ->
            div [] []


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewHeader
        , viewTimer model.timer
        , viewTaskList model.tasks
        , viewNewTask model
        ]


type Msg
    = SaveTask
    | UpdateTask String
    | RemoveTask Task
    | UpdateTimer Task
    | Tick Time


addNewTask : Model -> Model
addNewTask model =
    let
        task =
            Task ((List.length model.tasks) + 1) model.newTask False

        newTasks =
            model.tasks ++ [ task ]
    in
        { model | tasks = newTasks, newTask = "" }


removeTask : Model -> Task -> Model
removeTask model taskToRemove =
    let
        isNotRemovable task =
            task.id /= taskToRemove.id
    in
        { model | tasks = List.filter isNotRemovable model.tasks }


createTimer : Task -> Timer
createTimer task =
    Timer task 0 workTimeout (Work 1) 1


updateExistingTimer : Timer -> Task -> Timer
updateExistingTimer timer task =
    case timer.status of
        Pause count ->
            { timer
                | status = Work (count + 1)
                , timeout = workTimeout
                , task = task
            }

        LongPause ->
            { timer
                | status = (Work 1)
                , timeout = workTimeout
                , task = task
            }

        _ ->
            timer


updateTimer : Model -> Task -> Model
updateTimer model task =
    let
        newTimer =
            case model.timer of
                Nothing ->
                    createTimer task

                Just timer ->
                    updateExistingTimer timer task
    in
        { model | timer = Just newTimer }


shiftTimer : Timer -> Maybe Timer
shiftTimer timer =
    case timer.status of
        Work 4 ->
            Just { timer | status = LongPause, timeout = longPauseTimeout }

        Work count ->
            Just { timer | status = (Pause count), timeout = pauseTimeout }

        _ ->
            Just timer


decreaseTimer : Timer -> Maybe Timer
decreaseTimer timer =
    case timer.timeout of
        0 ->
            shiftTimer timer

        _ ->
            Just { timer | timeout = timer.timeout - 1 }


updateTimerAtTick : Model -> Model
updateTimerAtTick model =
    case model.timer of
        Nothing ->
            model

        Just currentTimer ->
            { model | timer = (decreaseTimer currentTimer) }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveTask ->
            ( addNewTask model, Cmd.none )

        UpdateTask description ->
            ( { model | newTask = description }
            , Cmd.none
            )

        RemoveTask task ->
            ( (removeTask model task), Cmd.none )

        UpdateTimer task ->
            ( updateTimer model task, Cmd.none )

        Tick _ ->
            ( updateTimerAtTick model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every second Tick


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
