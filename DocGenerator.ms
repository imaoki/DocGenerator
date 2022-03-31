/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  local hasMetRequirements
  fn hasMetRequirements = (
    isStruct ::std \
        and isProperty ::std #StructName \
        and classOf ::std.StructName == MAXScriptFunction \
        and ::std.StructName() == #StandardStruct \
    and isStructDef ::ParserCombinatorStruct \
        and isProperty ::ParserCombinatorStruct #StructName \
        and classOf ::ParserCombinatorStruct.StructName == MAXScriptFunction \
        and ::ParserCombinatorStruct.StructName() == #ParserCombinatorStruct \
    and isStructDef ::MarkdownStruct \
        and isProperty ::MarkdownStruct #StructName \
        and classOf ::MarkdownStruct.StructName == MAXScriptFunction \
        and ::MarkdownStruct.StructName() == #MarkdownStruct
  )
  if not hasMetRequirements() do (
    local fileClass = DotNetClass "System.IO.File"
    local pathClass = DotNetClass "System.IO.Path"
    local currentDir = pathClass.GetDirectoryName (getSourceFileName())
    local standardFile = currentDir + @"\Standard.min.ms"
    local parserCombinatorFile = currentDir + @"\ParserCombinator.min.ms"
    local markdownFile = currentDir + @"\Markdown.min.ms"
    if fileClass.Exists standardFile do fileIn standardFile
    if fileClass.Exists parserCombinatorFile do fileIn parserCombinatorFile
    if fileClass.Exists markdownFile do fileIn markdownFile
  )
  if not hasMetRequirements() do (
    format "[error]Requirement not met.\n"
  )
  ok
)
fileIn @"definitionPool.ms"
/*-
スクリプトファイル内のドキュメントコメントを基にHTMLファイルを生成する。
*/
struct DocGeneratorStruct (
  /*- @prop <Struct:DocOptionsStruct> 既定値は`undefined`。未指定の場合は既定値で作成される。 */
  public Options,

  /*- @prop <Struct:DocDependentStruct> */
  private docDependentParser,
  /*- @prop <Struct:DocDependentTableStruct> */
  private docDependentTable,
  /*- @prop <Struct:DocStruct> */
  private docParser,
  /*- @prop <Struct:DocRenderStruct> */
  private docRender,
  /*- @prop <Struct:DocPathMakerStruct> */
  private pathMaker,
  /*- @prop <Struct:PathUtilityStruct> */
  private pathUtility,

  /*
  public fn FromDirectory dir recursive:false ignore: exception: = (),
  public fn FromFile file = (),
  public fn IndexFromDirectory dir recursive:false ignore: exception: = (),

  private fn compareFileName a b = (),
  private fn convertFile path = (),
  private fn dumpPathTree pathTree indent = (),
  private fn extractDependent path = (),
  private fn isDocOptions obj = (),
  private fn makePathTree parentPath paths = (),
  private fn pathTreeToHtml pathTree = (),
  */

  /*-
  ディレクトリ内のスクリプトファイルを変換する。
  @param dir <String> ディレクトリの絶対パス。
  @param recursive: <BooleanClass> 全てのサブディレクトリから検索する場合は`true`、現在のディレクトリからのみ検索する場合は`false`。既定値は`false`。
  @param ignore: <String|Array[<String>]> 結果から除外するパスのパターン。既定値は`unsupplied`。
  リテラル文字とワイルドカード文字の組み合わせ。大文字と小文字を区別しない。
  @param exception: <String|Array[<String>]> `ignore`に一致しても除外しない例外パターン。既定値は`unsupplied`。
  @returns <OkClass>
  */
  public fn FromDirectory dir recursive:false ignore: exception: = (
    this.docDependentTable.Initialize()
    local paths = this.pathMaker.FromDirectory \
        dir recursive:recursive ignore:ignore exception:exception
    for path in paths do (
      this.extractDependent path
    )
    for path in paths do (
      this.convertFile path
    )
    ok
  ),

  /*-
  スクリプトファイルを変換する。
  @param file <String> ファイルの絶対パス。
  @returns <OkClass>
  @remarks 依存情報の解析は指定したファイルのみで行われるため正しく抽出できない。
  */
  public fn FromFile file = (
    this.docDependentTable.Initialize()
    local path = this.pathMaker.FromFile file
    this.extractDependent path
    this.convertFile path
    ok
  ),

  /*-
  ディレクトリ内のスクリプトファイルからインデックスページを生成する。
  @param dir <String> ディレクトリの絶対パス。
  @param recursive: <BooleanClass> 全てのサブディレクトリから検索する場合は`true`、現在のディレクトリからのみ検索する場合は`false`。既定値は`false`。
  @param ignore: <String|Array[<String>]> 結果から除外するパスのパターン。既定値は`unsupplied`。
  リテラル文字とワイルドカード文字の組み合わせ。大文字と小文字を区別しない。
  @param exception: <String|Array[<String>]> `ignore`に一致しても除外しない例外パターン。既定値は`unsupplied`。
  @returns <OkClass>
  @remarks HTMLファイルの書き込みは常にUTF-8Nで行う。
  */
  public fn IndexFromDirectory dir recursive:false ignore: exception: = (
    local absBasePath = this.pathMaker.GetAbsoluteBasePath()
    local paths = this.pathMaker.FromDirectory \
        dir recursive:recursive ignore:ignore exception:exception
    local pathTree = this.makePathTree absBasePath paths
    -- this.dumpPathTree pathTree ""
    local html = this.pathTreeToHtml pathTree
    local content = this.docRender.RenderIndex html
    local indexPath = this.pathMaker.GetAbsoluteIndexPath()
    local destDirPath = this.pathUtility.GetDirectoryName indexPath
    if not ::std.FileUtility.DirectoryExists destDirPath do (
      ::std.FileUtility.CreateDirectory destDirPath
    )
    if ::std.FileUtility.DirectoryExists destDirPath do (
      ::std.FileUtility.WriteAllText indexPath content
    )
    ok
  ),

  /*-
  @param path <DataPair Source:<String> Destination:<String>>
  @returns <OkClass>
  @remarks HTMLファイルの書き込みは常にUTF-8Nで行う。
  */
  private fn convertFile path = (
    local code = ::std.FileUtility.ReadAllText path.Source \
        encoding:this.Options.EncodingName bom:this.Options.EncodingBom
    local docTitle = this.pathUtility.GetFileName path.Source
    local astNode = this.docParser.Parse code
    local dependent = this.docDependentTable.GetDependent path
    local content = this.docRender.Render \
        astNode \
        docTitle:docTitle \
        dependent:dependent
    local destDirPath = this.pathUtility.GetDirectoryName path.Destination
    if not ::std.FileUtility.DirectoryExists destDirPath do (
      ::std.FileUtility.CreateDirectory destDirPath
    )
    if ::std.FileUtility.DirectoryExists destDirPath do (
      ::std.FileUtility.WriteAllText path.Destination content
    )
    ok
  ),

  /*-
  ディレクトリが前、ファイルが後になるように並べ替える。
  @param a <Any>
  @param b <Any>
  @returns <Integer>
  */
  private fn compareFileName a b = (
    local aWeight = (this.pathUtility.HasExtension a.Name) as Integer
    local bWeight = (this.pathUtility.HasExtension b.Name) as Integer
    case of (
      (aWeight < bWeight): -1
      (aWeight > bWeight): 1
      default: ::std.Comparer.CompareName a b
    )
  ),

  /*-
  パスの階層構造をリスナーに出力する。デバッグ用。
  @param pathTree <Array[<DataPair Name:<String> Value:<Array[<Any>]|DataPair Source:<String> Destination:<String>>>]>
  @param indent <String>
  @returns <OkClass>
  */
  private fn dumpPathTree pathTree indent = (
    for path in pathTree do (
      if classOf path.Value == Array then (
        format "%%\n" indent path.Name
        this.dumpPathTree path.Value (indent + "  ")
      )
      else (
        local fileName = this.pathUtility.GetFileName path.Value.Destination
        format "%% - %\n" indent path.Name fileName
      )
    )
    ok
  ),

  /*-
  依存情報を抽出する。
  @param path <DataPair Source:<String> Destination:<String>>
  @returns <OkClass>
  */
  private fn extractDependent path = (
    local code = ::std.FileUtility.ReadAllText path.Source \
        encoding:this.Options.EncodingName bom:this.Options.EncodingBom
    local astNode = this.docDependentParser.Parse code
    this.docDependentTable.AddDependent astNode path
    ok
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
  パスの配列からディレクトリやファイルの階層構造を構築する。
  @param parentPath <String> 親ディレクトリのパス。
  @param paths <Array[<DataPair Source:<String> Destination:<String>>]>
  @returns <Array[<DataPair Name:<String> Value:<Array[<Any>]|DataPair Source:<String> Destination:<String>>>]>
  @remarks 終端（ファイル）の`Value`には子階層の配列ではなくファイルのパス情報が格納される。
  */
  private fn makePathTree parentPath paths = (
    local fileNames = #()
    local subPaths = #()
    for path in paths do (
      local lowPath = substituteString path.Source parentPath ""
      local components = ::std.StringUtility.Split lowPath @"\"
      if components.Count > 0 do (
        local firstComponent = components[1]
        deleteItem components 1
        local index = findItem fileNames firstComponent
        if index == 0 then (
          append fileNames firstComponent
          append subPaths (DataPair Name:firstComponent Value:#(path))
          index = subPaths.Count
        )
        else (
          append subPaths[index].Value path
        )
      )
    )
    if paths.Count == 1 and subPaths.Count == 0 then (
      -- パスの終端に達した場合はファイル情報を返す。
      paths[1]
    )
    else (
      qsort subPaths this.compareFileName
      for subPath in subPaths do (
        local nextParentPath = parentPath + @"\" + subPath.Name
        subPath.Value = this.makePathTree nextParentPath subPath.Value
      )
      subPaths
    )
  ),

  /*-
  パスの階層構造からリスト要素のHTMLコードを生成する。
  @param pathTree <Array[<DataPair Name:<String> Value:<Array[<Any>]|DataPair Source:<String> Destination:<String>>>]>
  @returns <String>
  */
  private fn pathTreeToHtml pathTree = (
    local html = StringStream ""
    format "<ul>\n" to:html
    for path in pathTree do (
      if classOf path.Value == Array then (
        format "<li><p>%</p>%</li>\n" path.Name (this.pathTreeToHtml path.Value) to:html
      )
      else (
        format "<li><p><a href=\"%\">%</a></p></li>\n" \
            (this.pathUtility.GetFileName path.Value.Destination) path.Name to:html
      )
    )
    format "</ul>" to:html
    html as String
  ),

  /*- @prop <String> バージョン番号。メジャー、マイナー、パッチの順。 */
  private version = "1.1.2",

  /*- @returns <Name> */
  public fn StructName = #DocGeneratorStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DocGeneratorStruct\n" indent to:out
    format "%  pathMaker:\n" indent to:out
    this.pathMaker.Dump indent:(indent + "    ") out:out
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

  /*-
  @returns <String>
  */
  public fn GetVersion = (
    this.version
  ),

  on Create do (
    if not this.isDocOptions this.Options do (
      this.Options = (::docGeneratorDefinitionPool[@"DocOptions.ms"])()
    )
    this.docDependentParser = (::docGeneratorDefinitionPool[@"Parser\DocDependent.ms"]) ShowError:this.Options.ShowError
    this.docDependentTable = (::docGeneratorDefinitionPool[@"DocDependentTable.ms"])()
    this.docParser = (::docGeneratorDefinitionPool[@"Parser\Doc.ms"]) ShowError:this.Options.ShowError
    this.docRender = (::docGeneratorDefinitionPool[@"DocRender.ms"]) this.Options
    this.pathMaker = (::docGeneratorDefinitionPool[@"DocPathMaker.ms"]) this.Options
    this.pathUtility = ::std.PathUtilityStruct (getSourceFileName())
  )
)
