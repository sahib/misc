module Api exposing (Report, ApiErr, encodeReport, encodeReportAsText, doExists, doUpload)

import Json.Encode as E
import Json.Decode as D

import Dict
import Http

-- Local imports:
import Config exposing (..)


encodeResult : ResultKind -> E.Value
encodeResult result =
    case result of
        RangeResult num ->
            E.object
                [ ("type", E.string "range" )
                , ("value", E.int num)
                ]
        TextResult text ->
            E.object
                [ ("type", E.string "text" )
                , ("value", E.string text )
                ]

encodeResults : Dict.Dict String ResultKind -> E.Value
encodeResults results =
    E.dict identity encodeResult results


type alias Report =
    { unixStampMs : Int
    , feedbackFor : String
    , feedbackUID : String
    , results : Dict.Dict String ResultKind
    }

encodeReport : Report -> E.Value
encodeReport report =
    E.object
      [ ("unix_stamp_ms", E.int report.unixStampMs )
      , ("feedback_for", E.string report.feedbackFor )
      , ("feedback_uid", E.string report.feedbackUID )
      , ("results", encodeResults report.results )
      ]


-- TODO: remove when no longer needed.
encodeReportAsText : Report -> String
encodeReportAsText report =
    E.encode 4 <| encodeReport report

decodeExistsResponse : D.Decoder Bool
decodeExistsResponse =
    D.field "exists" D.bool

doExists : String -> (Result Http.Error Bool -> msg) -> Cmd msg
doExists uid toMsg =
    Http.get
    { url = "/api/exists"
    , expect = Http.expectJson toMsg decodeExistsResponse
    }


type alias ApiErr =
    { success : Bool
    , message : String
    }


decodeApiErr : D.Decoder ApiErr
decodeApiErr =
    D.map2 ApiErr
        (D.field "success" D.bool)
        (D.oneOf [D.field "message" D.string, D.null ""])


doUpload : Report -> (Result Http.Error ApiErr -> msg) -> Cmd msg
doUpload report toMsg =
    Http.post
    { url = "/api/upload"
    , body = Http.jsonBody <| encodeReport report
    , expect = Http.expectJson toMsg decodeApiErr
    }
