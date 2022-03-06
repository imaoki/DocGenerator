/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ドキュメントのパスを生成する。
@remarks
ベースパスから見た相対パスが生成されるパスのファイル名になる。

| ベースパス   | 変換対象                         | 生成されるパス                            |
| ------------ | -------------------------------- | ----------------------------------------- |
| `C:\Foo\Bar` | `C:\Foo\Bar\Hoge\Piyo\script.ms` | `C:\Foo\Bar\Document\hoge-piyo-script.ms` |
| `C:\Foo`     | `C:\Foo\Bar\Hoge\Piyo\script.ms` | `C:\Foo\Document\bar-hoge-piyo-script.ms` |
*/
struct DocPathMakerStruct (
  /*- @prop <Struct:DocOptionsStruct> 既定値は`undefined`。未指定の場合は既定値で作成される。 */
  public Options,

  /*- @prop <Struct:PathUtilityStruct> */
  private pathUtility,
  /*- @prop <DotNetClass:System.Uri> */
  private uriClass = DotNetClass "System.Uri",

  /*-
  ディレクトリ内のスクリプトファイルのパスから変換後のHTMLファイルのパスを作成する。
  @param dir <String> ディレクトリの絶対パス。
  @param recursive: <BooleanClass> 全てのサブディレクトリから検索する場合は`true`、現在のディレクトリからのみ検索する場合は`false`。既定値は`false`。
  @param ignore: <String|Array[<String>]> 結果から除外するパスのパターン。既定値は`unsupplied`。
  リテラル文字とワイルドカード文字の組み合わせ。大文字と小文字を区別しない。
  @param exception: <String|Array[<String>]> `ignore`に一致しても除外しない例外パターン。既定値は`unsupplied`。
  @returns <Array[<DataPair Source:<String> Destination:<String>>]>
  */
  public fn FromDirectory dir recursive:false ignore: exception: = (
    if classOf ignore == String do (
      ignore = #(ignore)
    )
    if classOf exception == String do (
      exception = #(exception)
    )
    dir = this.trimEndBackslash dir
    local files = ::std.FileUtility.GetFiles dir "*.ms" recursive:recursive
    for file in files collect (
      local shouldCollect = true
      if classOf ignore == Array do (
        shouldCollect = not this.matchPatterns file ignore
        if not shouldCollect and classOf exception == Array do (
          shouldCollect = this.matchPatterns file exception
        )
      )
      if shouldCollect then (
        this.FromFile file
      )
      else (
        dontCollect
      )
    )
  ),

  /*-
  スクリプトファイルのパスから変換後のHTMLファイルのパスを作成する。
  @param file <String> ファイルの絶対パス。
  @returns <DataPair Source:<String> Destination:<String>>
  */
  public fn FromFile file = (
    local absBasePath = this.GetAbsoluteBasePath()
    -- ベース側は末尾が区切り文字でなければならない
    local baseUri = DotNetObject this.uriClass (absBasePath + @"\")
    local destUri = DotNetObject this.uriClass file
    local relativeUri = baseUri.MakeRelativeUri destUri
    local relativePath = relativeUri.ToString()
    relativePath = substituteString relativePath "/" this.Options.FileNameSeparator
    local destinationPath = absBasePath \
        + @"\" + this.Options.SaveDirectoryName \
        + @"\" + (toLower relativePath)
    destinationPath = this.pathUtility.ChangeExtension destinationPath "html"
    DataPair Source:file Destination:destinationPath
  ),

  /*-
  `Options.BasePath`を絶対パスで取得する。
  @returns <String>
  */
  public fn GetAbsoluteBasePath = (
    this.trimEndBackslash (this.pathUtility.GetFullPath this.Options.BasePath)
  ),

  /*-
  `Options.SiteUrl`を絶対パスで取得する。
  @returns <String>
  */
  public fn GetAbsoluteIndexPath = (
    this.GetAbsoluteBasePath() \
        + @"\" + this.Options.SaveDirectoryName \
        + @"\" + this.Options.SiteUrl
  ),

  /*-
  `Options.TemplatePath`を絶対パスで取得する。
  @returns <String>
  */
  public fn GetAbsoluteTemplatePath = (
    this.pathUtility.GetFullPath this.Options.TemplatePath
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
  @param input <String>
  @param patterns <Array[<String>]>
  @returns <BooleanClass>
  */
  private fn matchPatterns input patterns = (
    local isMatch = false
    for pattern in patterns while not isMatch do (
      isMatch = matchPattern input pattern:pattern ignoreCase:true
    )
    isMatch
  ),

  /*-
  末尾のバックスラッシュを除去する。
  @param input <String>
  @returns <String>
  */
  private fn trimEndBackslash input = (
    if matchPattern input pattern:@"*\" then (
      ::std.StringUtility.TrimEnd input @"\"
    )
    else (
      input
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #DocPathMakerStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DocPathMakerStruct\n" indent to:out
    format "%  Options:\n" indent to:out
    this.Options.Dump indent:(indent + "    ") out:out
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
  )
)
