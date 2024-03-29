/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
依存情報を格納する構造体。
*/
struct DocDependentTableStruct (
  /*-
  @prop <Dictionary <String> <Array[<DataPair Source:<String> Destination:<String>>]>>
  定義しているファイルをグローバル変数毎にまとめた辞書。
  キーがグローバル変数名、値が定義しているファイルパスの配列。
  */
  private declarationTable,
  /*-
  @prop <Dictionary <String> <Array[<String>]>>
  依存しているグローバル変数をファイル毎に格納した辞書。
  キーがファイルパス、値がグローバル変数名の配列。
  */
  private dependentTable,

  /*
  public fn AddDependent astNode path = (),
  public fn GetDependent path = (),
  public fn Initialize = (),

  private fn isAstNode obj = (),
  */

  /*-
  構文木の内容をそれぞれのテーブルに振り分ける。
  @param astNode <Struct:AstNodeStruct|Struct:NotCollectStruct>
  @param path <DataPair Source:<String> Destination:<String>>
  @returns <OkClass>
  */
  public fn AddDependent astNode path = (
    if this.isAstNode astNode and astNode.Type == #DocDependent do (
      for n in astNode.Value where this.isAstNode n do (
        if n.Type == #GlobalVarName then (
          local key = path.Source
          if not hasDictValue this.dependentTable key do (
            this.dependentTable[key] = #()
          )
          appendIfUnique this.dependentTable[key] n.Value
        )
        else (
          local key = n.Value.Value
          if not hasDictValue this.declarationTable key do (
            this.declarationTable[key] = #()
          )
          appendIfUnique this.declarationTable[key] path
        )
      )
      for key in this.declarationTable.Keys do (
        qsort this.declarationTable[key] ::std.Comparer.CompareProperty propName:#Source
      )
      for key in this.dependentTable.Keys do (
        qsort this.dependentTable[key] ::std.Comparer.CompareStringLogical
      )
    )
    ok
  ),

  /*-
  指定されたパスの依存情報を取得する。
  @param path <DataPair Source:<String> Destination:<String>>
  @returns <DataPair VarName:<Array[<String>]> Path:<Array[<Array[<DataPair Source:<String> Destination:<String>>]>]>>
  */
  public fn GetDependent path = (
    local dependent = DataPair VarName:#() Path:#()
    local key = path.Source
    if hasDictValue this.dependentTable key do (
      dependent.VarName = deepCopy this.dependentTable[key]
      dependent.Path = for key in dependent.VarName collect (
        if hasDictValue this.declarationTable key then (
          deepCopy this.declarationTable[key]
        )
        else (
          #()
        )
      )
    )
    dependent
  ),

  /*-
  @returns <OkClass>
  */
  public fn Initialize = (
    this.declarationTable = Dictionary #String
    this.dependentTable = Dictionary #String
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isAstNode obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #AstNodeStruct
  ),

  /*- @returns <Name> */
  public fn StructName = #DocDependentTableStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DocDependentTableStruct\n" indent to:out

    format "%  declarationTable:%\n" indent this.declarationTable.Count to:out
    for key in this.declarationTable.Keys do (
      local v = this.declarationTable[key]
      format "%    [\"%\"]:%\n" indent key v.Count to:out
      for i = 1 to v.Count do (
        format "%      [%]:\n" indent i to:out
        format "%             Source:@\"%\"\n" indent (::std.StringUtility.EscapeBackslash v[i].Source) to:out
        format "%        Destination:@\"%\"\n" indent (::std.StringUtility.EscapeBackslash v[i].Destination) to:out
      )
    )

    format "%  dependentTable:%\n" indent this.dependentTable.Count to:out
    for key in this.dependentTable.Keys do (
      local v = this.dependentTable[key]
      format "%    [\"%\"]:%\n" \
          indent (::std.StringUtility.EscapeBackslash key) v.Count to:out
      for i = 1 to v.Count do (
        format "%      [%]:@\"%\"\n" indent i v[i] to:out
      )
    )
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  @remarks 大文字と小文字を区別する。
  */
  public fn Equals obj = (
    local isEqualStructName = isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == this.StructName()

    local isEqualProperties = true

    isEqualStructName and isEqualProperties
  ),

  on Create do (
    this.Initialize()
  )
)
