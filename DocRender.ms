/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
ドキュメントの構文木をHTMLコードに変換する。
@remarks
テンプレートHTML内で使用可能な変数は以下の通り。

| 変数          | 説明                                                                     |
| ------------- | ------------------------------------------------------------------------ |
| `site.title`  | 全体のタイトル。                                                         |
| `site.url`    | インデックスページのURL。                                                |
| `doc.title`   | ドキュメントのタイトル。                                                 |
| `doc.toc`     | 目次。                                                                   |
| `doc.update`  | ドキュメントの更新日時。書式は`Options.DateFormat`プロパティで指定する。 |
| `doc.content` | ドキュメント本文。                                                       |

変数は`{{{変数}}}`のように波括弧で括って使用する。
*/
struct DocRenderStruct (
  /*- @prop <Struct:DocOptionsStruct> 既定値は`undefined`。未指定の場合は既定値で作成される。 */
  public Options,

  /*- @prop <String> テンプレートHTMLコード。 */
  private template = "",
  /*- @prop <StringStream> TOC生成用の一時変数。 */
  private toc,

  /*- @prop <String> テンプレートHTMLが使用できない場合に使用する既定のテンプレートHTMLコード。 */
  private defaultTemplate = "<!doctype html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n<title>{{{site.title}}}</title>\n</head>\n<body>\n<h1><a href=\"{{{site.url}}}\">{{{site.title}}}</a></h1>\n<h2>{{{doc.title}}}</h2>\n{{{doc.toc}}}\n{{{doc.content}}}\n</body>\n</html>\n",
  /*- @prop <Struct:PathUtilityStruct> */
  private pathUtility,
  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> `(?<=\n) +`に一致する正規表現オブジェクト。 */
  private spaceRegex,
  /*- @prop <DotNetClass:System.Uri> */
  private uriClass = DotNetClass "System.Uri",

  /*-
  構文木からHTMLコードを生成する。
  @param astNode <Struct:AstNodeStruct> パース結果の構文木。
  @param docTitle: <String> ドキュメントのタイトル。既定値は`"Untitled"`。
  @param dependent: <DataPair VarName:<Array[<String>]> Path:<Array[<Array[<DataPair Source:<String> Destination:<String>>]>]>> `DocDependentTableStruct`から取得した依存情報。既定値は`unsupplied`。
  @returns <String> HTMLコード。
  @remarks 依存情報を含める場合は`dependent`を指定する。
  */
  public fn Render astNode docTitle:"Untitled" dependent: = (
    this.template = this.readTemplate()
    this.toc = StringStream ""
    local docContent = StringStream ""
    format "%" (this.dependentToHtml dependent) to:docContent
    format "%" (
      ::std.StringUtility.Trim (this.docToHtml astNode 3 dependent)
    ) to:docContent
    docContent = docContent as String
    this.toc = this.toc as String

    local html = copy this.template
    html = substituteString html "{{{site.title}}}" (this.sanitize this.Options.SiteTitle)
    html = substituteString html "{{{site.url}}}" (this.sanitize this.Options.SiteUrl)
    html = substituteString html "{{{doc.title}}}" (this.sanitize docTitle)
    html = substituteString html "{{{doc.toc}}}" this.toc
    html = substituteString html "{{{doc.update}}}" (this.generateNowDate())
    html = substituteString html "{{{doc.content}}}" docContent
    html
  ),

  /*-
  インデックスページ用のHTMLコードを生成する。
  @param docContent <String> 各ドキュメントへのアンカーで更生されたHTMLコード。
  @returns <String> HTMLコード。
  */
  public fn RenderIndex docContent = (
    this.template = this.readTemplate()
    local html = copy this.template
    html = substituteString html "{{{site.title}}}" (this.sanitize this.Options.SiteTitle)
    html = substituteString html "{{{site.url}}}" (this.sanitize this.Options.SiteUrl)
    html = substituteString html "{{{doc.title}}}" "Index"
    html = substituteString html "{{{doc.toc}}}" ""
    html = substituteString html "{{{doc.update}}}" (this.generateNowDate())
    html = substituteString html "{{{doc.content}}}" docContent
    html
  ),

  /*-
  テキストのインデントを指定したインデントに置き換える。
  @param input <String>
  @param indent: <String> 最終的なインデント。既定値は`"  "`。
  @returns <String>
  */
  private fn adjustIndent input indent:"  " = (
    local indentCount = 0
    local indentValue = undefined
    local lines = ::std.StringUtility.Split input "\n" removeEmpty:false
    for s in lines do (
      local space = (this.spaceRegex.Match s).Value
      local spaceCount = space.Count
      if spaceCount > 0 do (
        if indentValue == undefined or spaceCount < indentCount do (
          indentCount = spaceCount
          indentValue = space
        )
      )
    )
    if classOf indentValue == String then (
      local result = ""
      local lineCount = lines.Count
      for i = 1 to lineCount do (
        local s = lines[i]
        local delimiter = if i == lineCount then "" else "\n"
        local fromIndex = findString s indentValue
        if classOf fromIndex == Integer then (
          result += (replace s fromIndex indentCount indent) + delimiter
        )
        else (
          result += s + delimiter
        )
      )
      result
    )
    else (
      input
    )
  ),

  /*-
  @param dependent <DataPair VarName:<Array[<String>]> Path:<Array[<Array[<DataPair Source:<String> Destination:<String>>]>]>|UnsuppliedClass>
  @returns <String>
  */
  private fn dependentToHtml dependent = (
    local out = StringStream ""
    if this.isValidDependent dependent do (
      local absBasePath = this.pathUtility.GetFullPath this.Options.BasePath
      format "<dl><dt>依存</dt><dd><ul>\n" to:out
      for i = 1 to dependent.VarName.Count do (
        format "<li>" to:out
        local varName = this.sanitize dependent.VarName[i]
        local path = dependent.Path[i]
        if path.Count == 1 then (
          local url = this.pathUtility.GetFileName path[1].Destination
          format "<code><a href=\"%\">%</a></code>" url varName to:out
        )
        else (
          format "<code>%</code><ul>\n" varName to:out
          for i = 1 to path.Count do (
            local url = this.pathUtility.GetFileName path[i].Destination
            local fileName = substituteString path[i].Source absBasePath ""
            fileName = this.sanitize fileName
            format "<li><a href=\"%\">%</a></li>\n" url fileName to:out
          )
          format "</ul>" to:out
        )
        format "</li>\n" to:out
      )
      format "</ul></dd></dl>\n" to:out
    )
    out as String
  ),

  /*-
  @param n <Struct:AstNodeStruct>
  @param dependent <DataPair VarName:<Array[<String>]> Path:<Array[<Array[<DataPair Source:<String> Destination:<String>>]>]>> `DocDependentTableStruct`から取得した依存情報。
  @returns <String>
  */
  private fn docCommentToHtml n dependent = (
    local out = StringStream ""
    if this.isAstNode n do (
      case n.Type of (
        (#AccessorDef): (
          for v in n.Value do (
            local isClssForm = v.Type == #ClassForm
            if isClssForm do format "[" to:out
            format "%" (this.docCommentToHtml v dependent) to:out
            if isClssForm do format "]" to:out
          )
        )
        (#ClassDef): (
          local dotNetClassKeys = #(
            "dotnetclass",
            "dotnetcontrol",
            "dotnetobject"
          )
          local isDotNetClassDef = false
          for v in n.Value do (
            local html = this.docCommentToHtml v dependent
            if v.Type == #VarName do (
              isDotNetClassDef = findItem dotNetClassKeys (toLower html)
            )
            if v.Type == #ClassName do format ":" to:out
            if isDotNetClassDef and v.Type == #ClassName then (
              local url = copy this.Options.DotNetApiBaseUrl
              url += toLower html
              url += "?view=" + this.Options.DotNetApiVersion
              format "<a href=\"%\">%</a>" url html to:out
            )
            else (
              format "%" html to:out
            )
          )
        )
        (#ClassForm): (
          format "&lt;" to:out
          local html = for v in n.Value collect (
            this.docCommentToHtml v dependent
          )
          html = ::std.StringUtility.Join html separator:"|"
          format "%" html to:out
          format "&gt;" to:out
        )
        (#ClassName): (
          local html = for v in n.Value collect (
            this.docCommentToHtml v dependent
          )
          html = ::std.StringUtility.Join html separator:"."
          format "%" html to:out
        )
        (#ConstructorDef): (
          for v in n.Value do (
            if v.Type != #VarName do format "&nbsp;" to:out
            format "%" (this.docCommentToHtml v dependent) to:out
          )
        )
        (#DocComment): (
          for v in n.Value do (
            format "%" (this.docCommentToHtml v dependent) to:out
          )
        )
        (#KeywordParameter): (
          for v in n.Value do (
            if v.Type == #ClassForm do format ":" to:out
            format "%" (this.docCommentToHtml v dependent) to:out
          )
        )
        (#ParamName): (
          for v in n.Value do (
            if this.isAstNode v then (
              format "%" (this.docCommentToHtml v dependent) to:out
            )
            else (
              format "%" (this.sanitize v) to:out
            )
          )
        )
        (#PositionalParameter): (
          format "%" (this.docCommentToHtml n.Value dependent) to:out
        )
        (#Tag): (
          format "<dl>\n" to:out
          for v in n.Value do (
            case v.Type of (
              (#TagType): format "<dt>" to:out
              (#Text): format "<dd>" to:out
              default: format "<dd><code>" to:out
            )
            format "%" (this.docCommentToHtml v dependent) to:out
            case v.Type of (
              (#TagType): format "</dt>\n" to:out
              (#Text): format "</dd>\n" to:out
              default: format "</code></dd>\n" to:out
            )
          )
          format "</dl>\n" to:out
        )
        (#TagType): (
          local html = case n.Value of (
            (#Param): "パラメータ"
            (#Prop): "プロパティ"
            (#Remarks): "補足"
            (#Returns): "戻り値"
            (#Var): "変数"
            default: "タグ"
          )
          format "%" html to:out
        )
        (#Text): (
          local markdownText = this.adjustIndent n.Value
          if this.markdownDefines() then (
            format "%" (::markdown.ToHtml markdownText) to:out
          )
          else (
            format "<pre class=\"markdown\"><code class=\"language-markdown\">" to:out
            format "%" (this.sanitize markdownText) to:out
            format "</code></pre>\n" to:out
          )
        )
        (#VarName): (
          local absBasePath = this.pathUtility.GetFullPath this.Options.BasePath
          for v in n.Value do (
            local varNameIndex = 0
            if this.isValidDependent dependent do (
              varNameIndex = findItem dependent.VarName v
              if varNameIndex > 0 do (
                if dependent.Path[varNameIndex].Count != 1 do (
                  -- パスが複数ある場合はリンクしない
                  varNameIndex = 0
                )
              )
            )
            if varNameIndex == 0 then (
              format "%" (this.sanitize v) to:out
            )
            else (
              local varName = this.sanitize dependent.VarName[varNameIndex]
              local path = dependent.Path[varNameIndex]
              local url = this.pathUtility.GetFileName path[1].Destination
              format "<a href=\"%\">%</a>" url varName to:out
            )
          )
        )
        default: ()
      )
    )
    out as String
  ),

  /*-
  @param n <Struct:AstNodeStruct>
  @param h <Integer> 現在のヘッダレベル。
  @param dependent <DataPair VarName:<Array[<String>]> Path:<Array[<Array[<DataPair Source:<String> Destination:<String>>]>]>> `DocDependentTableStruct`から取得した依存情報。
  @returns <String>
  */
  private fn docToHtml n h dependent = (
    local out = StringStream ""
    if this.isAstNode n do (
      case n.Type of (
        (#DocSeq): (
          format "<li>" to:toc
          for i = 1 to n.Value.Count do (
            this.writeTocBorderTag n i
            format "%" (this.docToHtml n.Value[i] (h + 1) dependent) to:out
            this.writeTocEndTag n i
          )
          format "</li>" to:toc
        )
        (#Document): (
          format "<div class=\"table-of-contents\"><ul><li>" to:toc
          for i = 1 to n.Value.Count do (
            this.writeTocBorderTag n i
            format "%" (this.docToHtml n.Value[i] h dependent) to:out
            this.writeTocEndTag n i
          )
          format "</li></ul></div>" to:toc
        )
        (#SimpleDoc): (
          local headerText = ""
          if n.Value[2].Type == #Keywords do (
            local keywordsNode = n.Value[2]
            for i = 1 to keywordsNode.Value.Count do (
              local delimiter = if i == 1 then "" else " "
              headerText += delimiter + keywordsNode.Value[i].Value
            )
          )
          local childCount = n.Value.Count
          local varNameDelimiter = if childCount == 2 then "" else " "
          local varNameText = n.Value[childCount].Value
          headerText += varNameDelimiter + varNameText
          local headerId = this.uriClass.EscapeUriString (toLower varNameText)
          format "<a href=\"#%\">%</a>" headerId (this.sanitize varNameText) to:toc
          format "<h% id=\"%\">%</h%>\n" h headerId (this.sanitize headerText) h to:out
          format "%" (this.docCommentToHtml n.Value[1] dependent) to:out
        )
        default: ()
      )
    )
    out as String
  ),

  /*-
  現在の日付を取得する。
  @returns <String>
  */
  private fn generateNowDate = (
    (DotNetClass "System.DateTime").Now.ToString this.Options.DateFormat
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

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isDocOptions obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #DocOptionsStruct
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidDependent obj = (
    classOf obj == DataPair \
        and isProperty obj #VarName \
        and isProperty obj #Path \
        and classOf obj.VarName == Array \
        and classOf obj.Path == Array \
        and obj.VarName.Count > 0 \
        and obj.VarName.Count == obj.Path.Count
  ),

  /*-
  グローバル変数`::markdown`が定義されているかどうかを判定する。
  @returns <BooleanClass>
  */
  private fn markdownDefines = (
    GlobalVars.IsGlobal "markdown" \
        and isStruct ::markdown \
        and isProperty ::markdown #StructName \
        and classOf ::markdown.StructName == MAXScriptFunction \
        and ::markdown.StructName() == #MarkdownStruct
  ),

  /*-
  テンプレートHTMLファイルの内容を読み込んで`template`に割り当てる。
  @returns <String>
  @remarks ファイルが読み込めなかった場合や内容が空の場合は`defaultTemplate`の内容を返す。
  */
  private fn readTemplate = (
    local code = ::std.FileUtility.ReadAllText (
      this.pathUtility.GetFullPath this.Options.TemplatePath
    )
    if classOf code == String and code.Count > 0 then (
      code
    )
    else (
      copy this.defaultTemplate
    )
  ),

  /*-
  `&`、`"`、`<`、`>`、` `を文字実体参照に置換する。
  @param input <String>
  @returns <String>
  */
  private fn sanitize input = (
    substituteString (
      substituteString (
        substituteString (
          substituteString (
            substituteString input "&" "&amp;"
          ) "\"" "&quot;"
        ) "<" "&lt;"
      ) ">" "&gt;"
    ) " " "&nbsp;"
  ),

  /*-
  @param n <Struct:AstNodeStruct>
  @param i <Integer>
  @returns <OkClass>
  */
  private fn writeTocBorderTag n i = (
    local curType = n.Value[i].Type
    if i == 1 then (
      if curType == #DocSeq do (
        format "<ul>" to:this.toc
      )
    )
    else (
      local preType = n.Value[i - 1].Type
      case preType of (
        (#DocSeq): (
          case curType of (
            (#DocSeq): format "</ul><ul>" to:this.toc
            (#SimpleDoc): format "</ul></li><li>" to:this.toc
            default: ()
          )
        )
        (#SimpleDoc): (
          case curType of (
            (#DocSeq): format "<ul>" to:this.toc
            (#SimpleDoc): format "</li><li>" to:this.toc
            default: ()
          )
        )
        default: ()
      )
    )
    ok
  ),

  /*-
  @param n <Struct:AstNodeStruct>
  @param i <Integer>
  @returns <OkClass>
  */
  private fn writeTocEndTag n i = (
    if i == n.Value.Count and n.Value[i].Type == #DocSeq do (
      format "</ul>" to:this.toc
    )
    ok
  ),

  /*- @returns <Name> */
  public fn StructName = #DocRenderStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DocRenderStruct\n" indent to:out
    format "%  Options:\n" indent to:out
    this.Options.Dump indent:(indent + "    ") out:out
    format "%  defaultTemplate:\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.defaultTemplate) to:out
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
    if not this.isDocOptions this.Options do (
      this.Options = (fileIn "DocOptions.ms")()
    )
    this.pathUtility = ::std.PathUtilityStruct (getSourceFileName())
    this.spaceRegex = ::std.StringUtility.CreateRegex "^ +"
  )
)
