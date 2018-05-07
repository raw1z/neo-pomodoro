module Pomodoro exposing (main)

import Html exposing (..)
import Html.Attributes exposing (class)


type alias Id =
    Int


type alias Task =
    { id : Id
    , description : String
    , done : Bool
    }


type alias Model =
    { tasks : List Task
    }


initialModel : Model
initialModel =
    { tasks = []
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


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewHeader
        ]


type Msg
    = SaveTask


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveTask ->
            ( model, Cmd.none )


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
