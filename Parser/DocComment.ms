/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
ドキュメントコメントのパーサ。
*/
struct DocCommentStruct (
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
    this.pc.Partial this.astNode #DocComment (
      this.pc.Flatten (
        this.pc.Sequence #(
          this.whitespace(),
          this.pc.Skip (this.start()),
          this.whitespace(),
          this.pc.Option (this.text()),
          this.pc.Option (this.tags()),
          this.whitespace(),
          this.pc.Skip (this.pc.Expect (this.end()) expected:"*/")
        )
      ) depth:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tags = (
    this.pc.Flatten (
      this.pc.Many (
        this.pc.Sequence #(
          this.whitespace(),
          this.tag()
        )
      )
    ) depth:1
  ),

  /*-
  @returns <Struct>
  */
  private fn tag = (
    this.pc.Partial this.astNode #Tag (
      this.pc.Choice #(
        this.paramTag(),
        this.propTag(),
        this.returnsTag(),
        this.varTag(),
        this.remarksTag()
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn paramTag = (
    this.pc.Sequence #(
      this.tagTypeParam(),
      this.whitespace(),
      this.pc.Expect (this.paramName()) expected:"<param_name>",
      this.whitespace(),
      this.pc.Expect (this.classForm()) expected:"<class_form>",
      this.whitespace(),
      this.pc.Option (this.text())
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn propTag = (
    this.pc.Sequence #(
      this.tagTypeProp(),
      this.whitespace(),
      this.pc.Expect (this.classForm()) expected:"<class_form>",
      this.whitespace(),
      this.pc.Option (this.text())
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn returnsTag = (
    this.pc.Sequence #(
      this.tagTypeReturns(),
      this.whitespace(),
      this.pc.Expect (this.classForm()) expected:"<class_form>",
      this.whitespace(),
      this.pc.Option (this.text())
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn varTag = (
    this.pc.Sequence #(
      this.tagTypeVar(),
      this.whitespace(),
      this.pc.Expect (this.classForm()) expected:"<class_form>",
      this.whitespace(),
      this.pc.Option (this.text())
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn remarksTag = (
    this.pc.Sequence #(
      this.tagTypeRemarks(),
      this.whitespace(),
      this.pc.Option (this.text())
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn paramName = (
    this.pc.Partial this.astNode #ParamName (
      this.pc.Sequence #(
        this.varName(),
        this.pc.Option (this.pc.Char ":")
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn classForm = (
    this.pc.Partial this.astNode #ClassForm (
      this.pc.Flatten (
        this.pc.Sequence #(
          this.pc.Skip (this.pc.Char "<"),
          this.pc.Expect (
            this.pc.List (this.classDecl()) (this.pc.Char "|")
          ) expected:"1 or more <class_decl>",
          this.pc.Skip (this.pc.Expect (this.pc.Char ">") expected:">")
        )
      ) depth:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn classDecl = (
    this.pc.Choice #(
      this.constructorDef(),
      this.accessorDef(),
      this.classDef(),
      this.className()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn constructorDef = (
    this.pc.Partial this.astNode #ConstructorDef (
      this.pc.Flatten (
        this.pc.Sequence #(
          this.varName(),
          this.pc.Flatten (
            this.pc.Many (
              this.pc.Sequence #(
                this.whitespace(),
                this.pc.Choice #(
                  this.positionalParameter(),
                  this.keywordParameter()
                )
              )
            ) minCount:1
          ) depth:1
        )
      ) depth:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn accessorDef = (
    this.pc.Partial this.astNode #AccessorDef (
      this.pc.Flatten (
        this.pc.Sequence #(
          this.varName(),
          this.pc.Skip (this.pc.Char "["),
          this.pc.Expect (this.pc.Delay this.classForm) expected:"<class_form>",
          this.pc.Skip (this.pc.Expect (this.pc.Char "]") expected:"]")
        )
      ) depth:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn classDef = (
    this.pc.Partial this.astNode #ClassDef (
      this.pc.Sequence #(
        this.varName(),
        this.pc.Skip (this.pc.Char ":"),
        this.pc.Expect (this.className()) expected:"<class_name>"
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn className = (
    this.pc.Partial this.astNode #ClassName (
      this.pc.List (this.varName()) (this.pc.Char ".")
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn positionalParameter = (
    this.pc.Partial this.astNode #PositionalParameter (
      this.pc.Delay this.classForm
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn keywordParameter = (
    this.pc.Partial this.astNode #KeywordParameter (
      this.pc.Flatten (
        this.pc.Sequence #(
          this.varName(),
          this.pc.Skip (this.pc.Char ":"),
          this.pc.Expect (this.pc.Delay this.classForm) expected:"<class_form>"
        )
      ) depth:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn varName = (
    this.pc.Partial this.astNode #VarName (
      this.pc.Sequence #(
        this.pc.Option (this.pc.Char "&"),
        this.pc.Choice #(
          this.identifier(),
          this.quotedName()
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn text = (
    this.pc.Partial this.astNode #Text (
      this.pc.Map (
        this.pc.Join (
          this.pc.Many (
            this.pc.AndAlso #(
              this.pc.IsNot (
                this.pc.Choice #(
                  this.tagType(),
                  this.end()
                )
              ),
              this.pc.AnyChar()
            )
          )
        )
      ) this.trimText
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tagType = (
    this.pc.Choice #(
      this.tagTypeParam(),
      this.tagTypeProp(),
      this.tagTypeRemarks(),
      this.tagTypeReturns(),
      this.tagTypeVar()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tagTypeParam = (
    this.pc.Partial this.astNode #TagType (
      this.pc.Map (
        this.pc.Join (
          this.pc.Sequence #(this.tagTypeSymbol(), this.pc.Token "param")
        )
      ) this.asName
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tagTypeProp = (
    this.pc.Partial this.astNode #TagType (
      this.pc.Map (
        this.pc.Join (
          this.pc.Sequence #(this.tagTypeSymbol(), this.pc.Token "prop")
        )
      ) this.asName
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tagTypeRemarks = (
    this.pc.Partial this.astNode #TagType (
      this.pc.Map (
        this.pc.Join (
          this.pc.Sequence #(this.tagTypeSymbol(), this.pc.Token "remarks")
        )
      ) this.asName
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tagTypeReturns = (
    this.pc.Partial this.astNode #TagType (
      this.pc.Map (
        this.pc.Join (
          this.pc.Sequence #(this.tagTypeSymbol(), this.pc.Token "returns")
        )
      ) this.asName
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tagTypeVar = (
    this.pc.Partial this.astNode #TagType (
      this.pc.Map (
        this.pc.Join (
          this.pc.Sequence #(this.tagTypeSymbol(), this.pc.Token "var")
        )
      ) this.asName
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tagTypeSymbol = (
    this.pc.Skip (this.pc.Char "@")
  ),

  /*-
  @returns <Struct>
  */
  private fn start = (
    this.pc.Token "/*-"
  ),

  /*-
  @returns <Struct>
  */
  private fn end = (
    this.pc.Token "*/"
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
          this.space(),
          this.newLine()
        )
      )
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
  @param result <Any|Struct:FailureStruct>
  @returns <Struct:AstNodeStruct|Struct:FailureStruct>
  */
  private fn asName result = (
    if classOf result == String then (
      result as Name
    )
    else (
      ::FailureStruct()
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

  /*-
  @param result <String|Struct:FailureStruct>
  @returns <String|Struct:FailureStruct>
  */
  private fn trimText result = (
    if classOf result == String then (
      result = ::stringUtility.Trim result
      if result.Count == 0 then (
        ::NotCollectStruct()
      )
      else (
        result
      )
    )
    else (
      ::FailureStruct()
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #DocCommentStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DocCommentStruct\n" indent to:out
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
    this.parser = this.program()
  )
)
