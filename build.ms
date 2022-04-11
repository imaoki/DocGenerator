/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  /* 初期化 */
  local mp = ::MxsPackStruct (getSourceFileName())
  /* 出力先ディレクトリ削除 */
  -- mp.DeleteDirectory @".\Distribution"

  /* コード切り出し */
  local definitionPoolCode = mp.ClipFile @".\definitionPool.ms" 1 1007
  local DocGeneratorCode = mp.ClipFile @".\DocGenerator.ms" 1 -1

  local DocDependentTableCode = mp.ClipFile @".\DocDependentTable.ms" 85 -1
  local DocOptionsCode = mp.ClipFile @".\DocOptions.ms" 106 -1
  local DocPathMakerCode = mp.ClipFile @".\DocPathMaker.ms" 497 -1
  local DocRenderCode = mp.ClipFile @".\DocRender.ms" 835 -1

  local DocCode = mp.ClipFile @".\Parser\Doc.ms" 83 -1
  local DocCommentCode = mp.ClipFile @".\Parser\DocComment.ms" 87 -1
  local DocDependentCode = mp.ClipFile @".\Parser\DocDependent.ms" 84 -1
  local PathNameLiteralCode = mp.ClipFile @".\Parser\PathNameLiteral.ms" 84 -1
  local StringLiteralCode = mp.ClipFile @".\Parser\StringLiteral.ms" 84 -1

  /* コード置換 */
  local code = mp.ReplaceText definitionPoolCode 985 23 DocCode
  code = mp.ReplaceText code 847 32 DocDependentCode
  code = mp.ReplaceText code 713 33 StringLiteralCode
  code = mp.ReplaceText code 618 35 PathNameLiteralCode
  code = mp.ReplaceText code 526 30 DocCommentCode
  code = mp.ReplaceText code 435 22 DocRenderCode
  code = mp.ReplaceText code 361 25 DocPathMakerCode
  code = mp.ReplaceText code 266 23 DocOptionsCode
  code = mp.ReplaceText code 186 30 DocDependentTableCode
  code = mp.ClipText code 64 -1
  code = mp.ReplaceText DocGeneratorCode 1481 27 code

  /* インストールコード追加 */
  -- code = mp.AppendText code "::DocGeneratorStruct.Install()\n::DocGeneratorStruct\n"
  /* インストーラーオプション削除 */
  -- code = mp.RemoveInstallerOption code
  /* バンドルファイルを保存 */
  mp.WriteAllText @".\Distribution\DocGenerator.bundle.ms" code
  /* 最小化ファイルを保存 */
  code = mp.Minify code
  mp.WriteAllText @".\Distribution\DocGenerator.min.ms" code
  /* ファイルコピー */
  mp.CopyDirectory @".\DocGenerator.Template" @".\Distribution\DocGenerator.Template"
  ok
)
