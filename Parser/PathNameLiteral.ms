/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
パス名リテラルのパーサ。
*/
struct PathNameLiteralStruct (
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
  private fn pathNameLiteral = (
    this.pc.Join (
      this.pc.Sequence #(
        this.pc.Char "$",
        this.pc.Option (this.path())
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn path = (
    this.pc.Sequence #(
      this.pc.Option (this.objectset()),
      this.pc.Option (this.pc.Char "/"),
      this.pc.Option (this.levels()),
      this.level()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn levels = (
    this.pc.Join (
      this.pc.Sequence #(
        this.level(),
        this.pc.Many (
          this.pc.Sequence #(
            this.pc.Choice #(
              this.pc.Char "/",
              this.pc.Token "..."
            ),
            /* this.pc.Char "/", */
            this.level()
          )
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn level = (
    this.pc.Join (
      this.pc.Choice #(
        this.pc.Sequence #(
          this.pc.Char "'",
          this.pc.Many (
            this.pc.Choice #(
              this.pc.AndAlso #(
                this.pc.IsNot (this.pc.Char "'"),
                this.pc.AnyChar()
              ),
              this.pc.Token "\\*",
              this.pc.Token "\\?",
              this.pc.Token "\\\\"
            )
          ),
          this.pc.Expect (this.pc.Char "'") expected:"'"
        ),
        this.pc.Many (
          this.pc.Choice #(
            this.alphanumeric(),
            this.pc.Char "_*?\\"
          )
        ),
        this.pc.Token "..."
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn objectset = (
    this.pc.Choice #(
      this.pc.Token "cameras",
      this.pc.Token "geometry",
      this.pc.Token "helpers",
      this.pc.Token "lights",
      this.pc.Token "objects",
      this.pc.Token "selection",
      this.pc.Token "shapes",
      this.pc.Token "spacewarps",
      this.pc.Token "systems"
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn alphanumeric = (
    this.pc.Choice #(this.letter(), this.digit())
  ),

  /*-
  @returns <Struct>
  */
  private fn digit = (
    this.pc.Digit()
  ),

  /*-
  @returns <Struct>
  */
  private fn letter = (
    this.pc.Alphabet()
  ),

  /*- @returns <Name> */
  public fn StructName = #PathNameLiteralStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%PathNameLiteralStruct\n" indent to:out
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
    local pathUtility = ::PathUtilityStruct (getSourceFileName())
    this.pc = ::ParserCombinatorStruct()
    this.parser = this.pathNameLiteral()
  )
)
