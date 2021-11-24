/* plugin_def */
plugin Geometry varname name:"string" extends:varname (
  parameters param rollout:rlt (
    varname type:#Float subAnim:true ui:spn
  )

  rollout rlt "description" (
    Spinner spn "caption" range:[-10.0, 10.0, 0.0] type:#Float scale:1.0

    on spn Changed arg1 arg2 do expr
  )

  on Load do expr
)
