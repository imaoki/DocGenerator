/* struct_def */
struct varname (member, member)

struct varname (
  member,
  member
)

struct varname (
  public varname,

  private varname = expr,

  public fn varname arg = expr,

  public fn varname = (
    expr3
  ),


  private on Clone do expr,

  private on Create do (
    expr
  )
)

struct varname extends:varname (
  public varname,

  private mapped fn varname arg1 arg2:#(expr) &arg3: = (
    expr
  ),

  private on Create do ()
)
