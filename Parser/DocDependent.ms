/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
依存情報を調べるパーサ。
*/
struct DocDependentStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*- @prop <Struct:PathNameLiteralStruct> */
  private pathNameLiteralParser,
  /*- @prop <Struct:StringLiteralStruct> */
  private stringLiteralParser,

  /*-
  @returns <Struct>
  */
  public fn GetParser = (
    this.parser
  ),

  /*-
  @param input <String>
  @returns <Struct:AstNodeStruct|Struct:NotCollectStruct> 成功した場合はパース結果、失敗した場合は`NotCollectStruct`を返す。
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
  private fn program = (
    this.pc.Partial this.astNode #DocDependent (
      this.rootGlobal()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn rootGlobal = (
    this.pc.Flatten (
      this.pc.Many (
        this.pc.Sequence #(
          this.pc.Option (this.rootDelimiter()),
          this.pc.Choice #(
            this.structDecl(),
            this.globalVarDecl(),
            this.globalVarName(),
            this.exprSeq()
          )
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn nonRootGlobal = (
    this.pc.Flatten (
      this.pc.Many (
        this.pc.Sequence #(
          this.pc.Option (this.nonRootDelimiter()),
          this.pc.Choice #(
            this.globalVarDecl(),
            this.globalVarName(),
            this.exprSeq()
          )
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn exprSeq = (
    this.pc.Flatten (
      this.pc.Sequence #(
        this.pc.Skip (this.pc.Char "("),
        this.pc.Option (
          this.pc.Delay this.nonRootGlobal
        ),
        this.pc.Option (this.nonRootDelimiter()),
        this.pc.Expect (this.pc.Skip (this.pc.Char ")")) expected:")"
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn rootDelimiter = (
    this.pc.Skip (
      this.pc.Many (
        this.pc.Choice #(
          this.delimitedLiteral(),
          this.pc.AndAlso #(
            this.pc.IsNot (
              this.pc.Choice #(
                this.structStart(),
                this.globalStart(),
                this.globalSymbol(),
                this.pc.Char "(",
                this.pc.Char ")"
              )
            ),
            this.pc.AnyChar()
          )
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn nonRootDelimiter = (
    this.pc.Skip (
      this.pc.Many (
        this.pc.Choice #(
          this.delimitedLiteral(),
          this.pc.AndAlso #(
            this.pc.IsNot (
              this.pc.Choice #(
                this.globalStart(),
                this.globalSymbol(),
                this.pc.Char "(",
                this.pc.Char ")"
              )
            ),
            this.pc.AnyChar()
          )
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn delimitedLiteral = (
    this.pc.Choice #(
      this.pathNameLiteral(),
      this.blockComment(),
      this.singleLineComment(),
      this.stringLiteral()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn structDecl = (
    this.pc.Partial this.astNode #StructDecl (
      this.pc.ItemAt (
        this.pc.Sequence #(
          this.pc.Skip (this.structStart()),
          this.whitespace(),
          this.varName()
        )
      ) -1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn globalVarDecl = (
    this.pc.Partial this.astNode #GlobalVarDecl (
      this.pc.ItemAt (
        this.pc.Sequence #(
          this.pc.Skip (this.globalStart()),
          this.whitespace(),
          this.varName()
        )
      ) -1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn structStart = (
    this.pc.ItemAt (
      this.pc.Sequence #(
        this.pc.Skip (this.pc.Boundary()),
        this.pc.Token "struct",
        this.pc.Skip (this.pc.Boundary())
      )
    ) -1
  ),

  /*-
  @returns <Struct>
  */
  private fn globalStart = (
    this.pc.ItemAt (
      this.pc.Sequence #(
        this.pc.Skip (this.pc.Boundary()),
        this.pc.Token "global",
        this.pc.Skip (this.pc.Boundary())
      )
    ) -1
  ),

  /*-
  @returns <Struct>
  */
  private fn globalVarName = (
    this.pc.Partial this.astNode #GlobalVarName (
      this.pc.Join (
        this.pc.Sequence #(
          this.pc.Skip (this.globalSymbol()),
          this.pc.Choice #(
            this.pc.Sequence #(
              this.keyword(),
              this.identifier()
            ),
            this.pc.AndAlso #(
              this.pc.IsNot (this.keyword()),
              this.identifier()
            ),
            this.quotedName()
          )
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn varName = (
    this.pc.Partial this.astNode #VarName (
      this.pc.Join (
        this.pc.Sequence #(
          this.pc.Skip (this.pc.Option (this.globalSymbol())),
          this.pc.Choice #(
            this.pc.Sequence #(
              this.keyword(),
              this.identifier()
            ),
            this.pc.AndAlso #(
              this.pc.IsNot (this.keyword()),
              this.identifier()
            ),
            this.quotedName()
          )
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn globalSymbol = (
    this.pc.Token "::"
  ),

  /*-
  @returns <Struct>
  */
  private fn blockComment = (
    this.pc.Sequence #(
      this.pc.Token "/*",
      this.pc.Many (
        this.pc.AndAlso #(
          this.pc.IsNot (this.pc.Token "*/"),
          this.pc.AnyChar()
        )
      ),
      this.pc.Expect (this.pc.Token "*/") expected:"*/"
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn singleLineComment = (
    this.pc.Sequence #(
      this.pc.Token "--",
      this.pc.Many (
        this.pc.AndAlso #(
          this.pc.IsNot (this.newLine()),
          this.pc.AnyChar()
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn stringLiteral = (
    this.stringLiteralParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn pathNameLiteral = (
    this.pathNameLiteralParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn identifier = (
    this.pc.Join (
      this.pc.Sequence #(
        this.pc.Choice #(
          this.letter(),
          this.pc.Char "_"
        ),
        this.pc.Many (
          this.pc.Choice #(
            this.alphanumeric(),
            this.pc.Char "_"
          )
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn quotedName = (
    this.pc.Join (
      this.pc.Sequence #(
        this.pc.Char "'",
        this.pc.Many (
          this.pc.AndAlso #(
            this.pc.IsNot (this.pc.Char "'"),
            this.pc.AnyChar()
          )
        ),
        this.pc.Expect (this.pc.Char "'") expected:"'"
      )
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

  /*-
  @returns <Struct>
  */
  private fn whitespace = (
    this.pc.Skip (
      this.pc.Many (
        this.pc.Choice #(
          this.continuation(),
          this.space(),
          this.newLine()
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn continuation = (
    this.pc.Sequence #(
      this.pc.Char "\\",
      this.pc.Many (this.space),
      this.newLine()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn space = (
    this.pc.Char " \t"
  ),

  /*-
  @returns <Struct>
  */
  private fn newLine = (
    this.pc.Char "\n"
  ),

  /*-
  @returns <Struct>
  */
  private fn keyword = (
    this.pc.Choice #(
      this.pc.Token "about",
      this.pc.Token "and",
      this.pc.Token "animate",
      this.pc.Token "as",
      this.pc.Token "at",
      this.pc.Token "attributes",
      this.pc.Token "by",
      this.pc.Token "case",
      this.pc.Token "catch",
      this.pc.Token "collect",
      this.pc.Token "continue",
      this.pc.Token "coordsys",
      this.pc.Token "do",
      this.pc.Token "else",
      this.pc.Token "exit",
      this.pc.Token "fn",
      this.pc.Token "for",
      this.pc.Token "from",
      this.pc.Token "function",
      this.pc.Token "global",
      this.pc.Token "if",
      this.pc.Token "in",
      this.pc.Token "local",
      this.pc.Token "macroscript",
      this.pc.Token "mapped",
      this.pc.Token "max",
      this.pc.Token "not",
      this.pc.Token "of",
      this.pc.Token "off",
      this.pc.Token "on",
      this.pc.Token "or",
      this.pc.Token "parameters",
      this.pc.Token "persistent",
      this.pc.Token "plugin",
      this.pc.Token "private",
      this.pc.Token "public",
      this.pc.Token "rcmenu",
      this.pc.Token "return",
      this.pc.Token "rollout",
      this.pc.Token "set",
      this.pc.Token "struct",
      this.pc.Token "then",
      this.pc.Token "throw",
      this.pc.Token "to",
      this.pc.Token "tool",
      this.pc.Token "try",
      this.pc.Token "undo",
      this.pc.Token "utility",
      this.pc.Token "when",
      this.pc.Token "where",
      this.pc.Token "while",
      this.pc.Token "with"
    )
  ),

  /*-
  パース結果をAstNode化する。
  @param type <Name>
  @param result <Any|Struct:FailureStruct>
  @returns <Struct:AstNodeStruct|Struct:FailureStruct>
  */
  private fn astNode type result = (
    case classOf result of (
      (::FailureStruct): result
      (::NotCollectStruct): result
      default: (
        if classOf result == Array and result.Count == 0 then (
          ::NotCollectStruct()
        )
        else (
          ::AstNodeStruct Type:type Value:result
        )
      )
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #DocDependentStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DocDependentStruct\n" indent to:out
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
    this.pathNameLiteralParser = (fileIn "PathNameLiteral.ms") ShowError:this.ShowError
    this.stringLiteralParser = (fileIn "StringLiteral.ms") ShowError:this.ShowError
    this.parser = this.program()
  )
)
