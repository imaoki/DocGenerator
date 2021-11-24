/* rcmenu_def */
rcmenu varname (
  SubMenu varname "label" (
    MenuItem varname "label" checked:false enabled:true
    Separator varname
  )

  on varname Picked do expr
)
