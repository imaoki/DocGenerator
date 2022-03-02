/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
文字列リテラルのパーサ。
*/
struct StringLiteralStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*-
  @returns <Struct>
  */
  public fn GetParser = (
    this.parser
  ),

  /*-
  @param input <String>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse input = (
    local context = this.pc.Context input
    local result = this.parser.Parse context
    if this.ShowError do context.PrintError result
    result
  ),

  /*-
  @returns <Struct>
  */
  private fn stringLiteral = (
    this.pc.Join (
      this.pc.Choice #(
        this.pc.Sequence #(
          this.pc.Token "@\"",
          this.pc.Many (
            this.pc.AndAlso #(
              this.pc.IsNot (this.pc.Char "\""),
              this.pc.AnyChar()
            )
          ),
          this.pc.Expect (this.pc.Char "\"") expected:"\""
        ),
        this.pc.Sequence #(
          this.pc.Char "\"",
          this.pc.Many (
            this.pc.Choice #(
              this.escapeSeq(),
              this.pc.AndAlso #(
                this.pc.IsNot (this.pc.Char "\""),
                this.pc.AnyChar()
              )
            )
          ),
          this.pc.Expect (this.pc.Char "\"") expected:"\""
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn escapeSeq = (
    this.pc.Choice #(
      this.pc.Token "\\\"",
      this.pc.Token "\\n",
      this.pc.Token "\\r",
      this.pc.Token "\\t",
      this.pc.Token "\\*",
      this.pc.Token "\\?",
      this.pc.Token "\\\\",
      this.pc.Token "\\%",
      this.pc.Sequence #(
        this.pc.Char "\\x",
        this.hexDigits()
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn hexDigits = (
    this.pc.Many (this.hexDigit()) minCount:1
  ),

  /*-
  @returns <Struct>
  */
  private fn hexDigit = (
    this.pc.Char "abcdefABCDEF0123456789"
  ),

  /*- @returns <Name> */
  public fn StructName = #StringLiteralStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%StringLiteralStruct\n" indent to:out
    format "%  ShowError:%\n" indent this.ShowError to:out
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
    local pathUtility = ::std.PathUtilityStruct (getSourceFileName())
    this.pc = ::ParserCombinatorStruct()
    this.parser = this.stringLiteral()
  )
)
