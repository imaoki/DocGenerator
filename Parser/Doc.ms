/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ドキュメントのパーサ。
*/
struct DocStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*- @prop <Struct:DocCommentStruct> */
  private docCommentParser,
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
  @returns <Struct:AstNodeStruct|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
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
    this.pc.Partial this.astNode #Document (
      this.pc.Flatten (
        this.pc.Sequence #(
          this.docDelimiter(),
          this.pc.Option (this.docs())
        )
      ) depth:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn docs = (
    this.pc.Flatten (
      this.pc.Many (
        this.pc.Sequence #(
          this.doc(),
          this.docDelimiter()
        )
      ) minCount:1
    ) depth:1
  ),

  /*-
  @returns <Struct>
  */
  private fn doc = (
    this.pc.Choice #(
      this.simpleDoc(),
      this.docSeq()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn simpleDoc = (
    this.pc.Partial this.astNode #SimpleDoc (
      this.pc.Sequence #(
        this.docComment(),
        this.keywordDelimiter(),
        this.pc.Option (this.keywords()),
        this.pc.Expect (this.varName()) expected:"<var_name>"
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn docSeq = (
    this.pc.Partial this.astNode #DocSeq (
      this.pc.Flatten (
        this.pc.Sequence #(
          this.pc.Skip (this.pc.Char "("),
          this.docDelimiter(),
          this.pc.Option (
            this.pc.Delay this.docs
          ),
          this.pc.Expect (this.pc.Skip (this.pc.Char ")")) expected:")"
        )
      ) depth:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn keywords = (
    this.pc.Partial this.astNode #Keywords (
      this.pc.Flatten (
        this.pc.Many (
          this.pc.Partial this.astNode #Keyword (
            this.pc.Join (
              this.pc.Sequence #(
                this.pc.Lookahead #(
                  this.keyword(),
                  this.pc.IsNot (this.identifier())
                ),
                this.keywordDelimiter()
              )
            )
          )
        ) minCount:1
      ) depth:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn docDelimiter = (
    this.pc.Skip (
      this.pc.Many (
        this.pc.Choice #(
          this.delimitedLiteral(),
          this.pc.AndAlso #(
            this.pc.IsNot (
              this.pc.Choice #(
                this.docCommentStart(),
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
  private fn keywordDelimiter = (
    this.pc.Skip (
      this.pc.Many (
        this.pc.Choice #(
          this.delimitedLiteral(),
          this.pc.AndAlso #(
            this.pc.IsNot (
              this.pc.Choice #(
                this.keyword(),
                this.varName()
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
      this.delimitedComment(),
      this.singleLineComment(),
      this.stringLiteral()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn varName = (
    this.pc.Partial this.astNode #VarName (
      this.pc.Join (
        this.pc.Sequence #(
          this.pc.Option (this.pc.Token "::"),
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
  private fn docComment = (
    this.docCommentParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn delimitedComment = (
    this.pc.Sequence #(
      this.pc.Lookahead #(
        this.pc.Token "/*",
        this.pc.IsNot (this.pc.Char "-")
      ),
      this.pc.Many (
        this.pc.AndAlso #(
          this.pc.IsNot (this.docCommentEnd()),
          this.pc.AnyChar()
        )
      ),
      this.pc.Expect (this.docCommentEnd()) expected:"*/"
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
  private fn docCommentStart = (
    this.pc.Token "/*-"
  ),

  /*-
  @returns <Struct>
  */
  private fn docCommentEnd = (
    this.pc.Token "*/"
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
  @remarks 先頭の文字列が重複しているトークンは長い方を前に記述すること。

  誤
  :   ```maxscript
      "at",
      "attributes"
      ```

  正
  :   ```maxscript
      "attributes",
      "at"
      ```
  */
  private fn keyword = (
    this.pc.Choice #(
      this.pc.Token "about",
      this.pc.Token "and",
      this.pc.Token "animate",
      this.pc.Token "as",
      this.pc.Token "attributes",
      this.pc.Token "at",
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
      this.pc.Token "off",
      this.pc.Token "of",
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
      this.pc.Token "tool",
      this.pc.Token "to",
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
  public fn StructName = #DocStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DocStruct\n" indent to:out
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
    this.docCommentParser = (fileIn @"DocComment.ms") ShowError:this.ShowError
    this.pathNameLiteralParser = (fileIn @"PathNameLiteral.ms") ShowError:this.ShowError
    this.stringLiteralParser = (fileIn @"StringLiteral.ms") ShowError:this.ShowError
    this.parser = this.program()
  )
)
