/* rollout_def */
rollout varname "description" (
  Spinner spn "caption" range:[0, 100, 1] type:#Integer scale:1 pos:[5, 5]
  Button btn "caption" width:150 height:18 pos:[5, 25]

  on spn Changed arg1 arg2 do (
    expr
  )
  on btn Pressed do expr
)
