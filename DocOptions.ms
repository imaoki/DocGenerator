/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
ドキュメントのHTMLファイル化に必要なプロパティを格納する構造体。
*/
struct DocOptionsStruct (
  /*- @prop <String> 検索の基点になるディレクトリの絶対パスまたは相対パス。既定値は`@"..\"`。 */
  public BasePath = @"..\",
  /*- @prop <String> 更新日に使用する[日時書式指定文字列](https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/custom-date-and-time-format-strings)。既定値は`"yyyy-MM-dd"`。 */
  public DateFormat = "yyyy-MM-dd",
  /*- @prop <String> 自動リンクに使用する.NET APIブラウザのベースURL。既定値は`"https://docs.microsoft.com/ja-jp/dotnet/api/"`。 */
  public DotNetApiBaseUrl = "https://docs.microsoft.com/ja-jp/dotnet/api/",
  /*- @prop <String> 自動リンクに使用する.NET APIブラウザのバージョン。既定値は`"netframework-4.8"`。 */
  public DotNetApiVersion = "netframework-4.8",
  /*- @prop <BooleanClass> UTF-8エンコーディングのBOMの有無。既定値は`false`。 */
  public EncodingBom = false,
  /*- @prop <String> スクリプトファイルのエンコーディングの名前。既定値は`"utf-8"` */
  public EncodingName = "utf-8",
  /*- @prop <String> HTMLファイル名のセパレータ。既定値は`"-"`。 */
  public FileNameSeparator = "-",
  /*- @prop <String> HTMLファイルの保存先ディレクトリ名。既定値は`"Document"`。 */
  public SaveDirectoryName = "Document",
  /*- @prop <BooleanClass> */
  public ShowError = false,
  /*- @prop <String> 全体のタイトル。既定値は`"mxsdoc"`。 */
  public SiteTitle = "mxsdoc",
  /*- @prop <String> インデックスページのURL。既定値は`"index.html"`。 */
  public SiteUrl = "index.html",
  /*- @prop <String> テンプレートHTMLファイルの絶対パスまたは相対パス。既定値は`@"Template\default-template.html"`。 */
  public TemplatePath = @".\Template\default-template.html",

  /*- @returns <Name> */
  public fn StructName = #DocOptionsStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DocOptionsStruct\n" indent to:out
    format "%  BasePath:@\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.basePath) to:out
    format "%  DateFormat:\"%\"\n" indent this.DateFormat to:out
    format "%  DotNetApiBaseUrl:\"%\"\n" indent this.DotNetApiBaseUrl to:out
    format "%  DotNetApiVersion:\"%\"\n" indent this.DotNetApiVersion to:out
    format "%  EncodingBom:%\n" indent this.EncodingBom to:out
    format "%  EncodingName:\"%\"\n" indent this.EncodingName to:out
    format "%  FileNameSeparator:\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.FileNameSeparator) to:out
    format "%  SaveDirectoryName:\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.SaveDirectoryName) to:out
    format "%  ShowError:%\n" indent this.ShowError to:out
    format "%  SiteTitle:\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.SiteTitle) to:out
    format "%  SiteUrl:\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.SiteUrl) to:out
    format "%  TemplatePath:\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.TemplatePath) to:out
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

  on Create do ()
)
