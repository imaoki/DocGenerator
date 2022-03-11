/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  -- clearListener()

  local nowTime = (DotNetClass "System.DateTime").Now.ToString "HH:mm:ss"
  local sw = DotNetObject "System.Diagnostics.Stopwatch"

  local currentFile = getSourceFileName()
  local pathUtility = ::std.PathUtilityStruct currentFile

  local actual
  local expected
  local testDef
  local testObj

  format "[run %]@\"%\"\n" nowTime currentFile
  /* Setup Start ------------------------------------------------------------ */
  local destinationFiles
  local expectedCodes
  local currentDir = pathUtility.GetDirectoryName currentFile
  local dataDir = pathUtility.GetFullPath @".\Data"
  local indexFile = pathUtility.GetFullPath @".\TestDoc\index.html"
  local templatePath = pathUtility.GetFullPath @".\Data\test-template.html"
  local testDocDir = pathUtility.GetFullPath @".\TestDoc"

  fileIn (pathUtility.GetFullPath @"..\definitionPool.ms")
  local optionsDef = ::docGeneratorDefinitionPool[@"DocOptions.ms"]

  local options = optionsDef \
      BasePath:@".\Test" \
      SaveDirectoryName:"TestDoc" \
      ShowError:false \
      TemplatePath:templatePath

  testDef = fileIn (pathUtility.GetFullPath @"..\DocGenerator.ms")
  testObj = testDef options
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* FromFile */
  destinationFiles = #(pathUtility.GetFullPath @".\TestDoc\data-filea.html")
  expectedCodes = #(
    "mxsdoc\nindex.html\nFileA.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileA</p>\n"
  )
  -- 変換
  testObj.FromFile (pathUtility.GetFullPath @".\Data\FileA.ms")
  -- ファイルの存在を確認
  actual = ::TestValueStruct (::std.FileUtility.FileExists destinationFiles[1])
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイルの内容を確認
  actual = ::TestValueStruct (::std.FileUtility.ReadAllText destinationFiles[1])
  expected = ::TestValueStruct expectedCodes[1]
  assert (actual.Equals expected == true)
  -- データ削除
  ::std.FileUtility.DeleteDirectory testDocDir

  /* FromDirectory */
  -- 対象ディレクトリのファイルのみ
  destinationFiles = #(
    pathUtility.GetFullPath @".\TestDoc\data-filea.html",
    pathUtility.GetFullPath @".\TestDoc\data-fileb.html",
    pathUtility.GetFullPath @".\TestDoc\data-filec.html"
  )
  expectedCodes = #(
    "mxsdoc\nindex.html\nFileA.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileA</p>\n",
    "mxsdoc\nindex.html\nFileB.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileB</p>\n",
    "mxsdoc\nindex.html\nFileC.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileC</p>\n"
  )
  -- 変換
  testObj.FromDirectory dataDir
  -- ファイルの存在を確認
  for file in destinationFiles do (
    actual = ::TestValueStruct (::std.FileUtility.FileExists file)
    expected = ::TestValueStruct true
    assert (actual.Equals expected == true)
  )
  -- ファイルの内容を確認
  for i = 1 to destinationFiles.Count do (
    actual = ::TestValueStruct (::std.FileUtility.ReadAllText destinationFiles[i])
    expected = ::TestValueStruct expectedCodes[i]
    assert (actual.Equals expected == true)
  )
  -- データ削除
  ::std.FileUtility.DeleteDirectory testDocDir
  -- サブディレクトリのファイルも全て
  destinationFiles = #(
    pathUtility.GetFullPath @".\TestDoc\data-_dira-filed.html",
    pathUtility.GetFullPath @".\TestDoc\data-dirb-filee.html",
    pathUtility.GetFullPath @".\TestDoc\data-dirb-filef.html",
    pathUtility.GetFullPath @".\TestDoc\data-dirc-_fileg.html",
    pathUtility.GetFullPath @".\TestDoc\data-filea.html",
    pathUtility.GetFullPath @".\TestDoc\data-fileb.html",
    pathUtility.GetFullPath @".\TestDoc\data-filec.html"
  )
  expectedCodes = #(
    "mxsdoc\nindex.html\nFileD.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileD</p>\n",
    "mxsdoc\nindex.html\nFileE.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileE</p>\n",
    "mxsdoc\nindex.html\nFileF.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileF</p>\n",
    "mxsdoc\nindex.html\n_FileG.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileG</p>\n",
    "mxsdoc\nindex.html\nFileA.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileA</p>\n",
    "mxsdoc\nindex.html\nFileB.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileB</p>\n",
    "mxsdoc\nindex.html\nFileC.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileC</p>\n"
  )
  -- 変換
  testObj.FromDirectory dataDir recursive:true
  -- ファイルの存在を確認
  for file in destinationFiles do (
    actual = ::TestValueStruct (::std.FileUtility.FileExists file)
    expected = ::TestValueStruct true
    assert (actual.Equals expected == true)
  )
  -- ファイルの内容を確認
  for i = 1 to destinationFiles.Count do (
    actual = ::TestValueStruct (::std.FileUtility.ReadAllText destinationFiles[i])
    expected = ::TestValueStruct expectedCodes[i]
    assert (actual.Equals expected == true)
  )
  -- データ削除
  ::std.FileUtility.DeleteDirectory testDocDir
  -- 単一パターンでファイルを除外
  destinationFiles = #(
    pathUtility.GetFullPath @".\TestDoc\data-dirb-filee.html",
    pathUtility.GetFullPath @".\TestDoc\data-dirb-filef.html",
    pathUtility.GetFullPath @".\TestDoc\data-filea.html",
    pathUtility.GetFullPath @".\TestDoc\data-fileb.html",
    pathUtility.GetFullPath @".\TestDoc\data-filec.html"
  )
  expectedCodes = #(
    "mxsdoc\nindex.html\nFileE.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileE</p>\n",
    "mxsdoc\nindex.html\nFileF.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileF</p>\n",
    "mxsdoc\nindex.html\nFileA.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileA</p>\n",
    "mxsdoc\nindex.html\nFileB.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileB</p>\n",
    "mxsdoc\nindex.html\nFileC.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileC</p>\n"
  )
  -- 変換
  testObj.FromDirectory dataDir recursive:true ignore:@"*\_*"
  -- ファイルの存在を確認
  for file in destinationFiles do (
    actual = ::TestValueStruct (::std.FileUtility.FileExists file)
    expected = ::TestValueStruct true
    assert (actual.Equals expected == true)
  )
  -- ファイルの内容を確認
  for i = 1 to destinationFiles.Count do (
    actual = ::TestValueStruct (::std.FileUtility.ReadAllText destinationFiles[i])
    expected = ::TestValueStruct expectedCodes[i]
    assert (actual.Equals expected == true)
  )
  -- データ削除
  ::std.FileUtility.DeleteDirectory testDocDir
  -- 複数パターンでファイルを除外
  destinationFiles = #(
    pathUtility.GetFullPath @".\TestDoc\data-dirb-filee.html",
    pathUtility.GetFullPath @".\TestDoc\data-dirb-filef.html",
    pathUtility.GetFullPath @".\TestDoc\data-fileb.html",
    pathUtility.GetFullPath @".\TestDoc\data-filec.html"
  )
  expectedCodes = #(
    "mxsdoc\nindex.html\nFileE.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileE</p>\n",
    "mxsdoc\nindex.html\nFileF.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileF</p>\n",
    "mxsdoc\nindex.html\nFileB.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileB</p>\n",
    "mxsdoc\nindex.html\nFileC.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileC</p>\n"
  )
  -- 変換
  testObj.FromDirectory dataDir recursive:true ignore:#(@"*\_*", "*A.ms")
  -- ファイルの存在を確認
  for file in destinationFiles do (
    actual = ::TestValueStruct (::std.FileUtility.FileExists file)
    expected = ::TestValueStruct true
    assert (actual.Equals expected == true)
  )
  -- ファイルの内容を確認
  for i = 1 to destinationFiles.Count do (
    actual = ::TestValueStruct (::std.FileUtility.ReadAllText destinationFiles[i])
    expected = ::TestValueStruct expectedCodes[i]
    assert (actual.Equals expected == true)
  )
  -- データ削除
  ::std.FileUtility.DeleteDirectory testDocDir
  -- 除外の例外パターンを指定
  destinationFiles = #(
    pathUtility.GetFullPath @".\TestDoc\data-dirb-filee.html",
    pathUtility.GetFullPath @".\TestDoc\data-dirb-filef.html",
    pathUtility.GetFullPath @".\TestDoc\data-dirc-_fileg.html",
    pathUtility.GetFullPath @".\TestDoc\data-filea.html",
    pathUtility.GetFullPath @".\TestDoc\data-fileb.html",
    pathUtility.GetFullPath @".\TestDoc\data-filec.html"
  )
  expectedCodes = #(
    "mxsdoc\nindex.html\nFileE.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileE</p>\n",
    "mxsdoc\nindex.html\nFileF.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileF</p>\n",
    "mxsdoc\nindex.html\n_FileG.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileG</p>\n",
    "mxsdoc\nindex.html\nFileA.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileA</p>\n",
    "mxsdoc\nindex.html\nFileB.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileB</p>\n",
    "mxsdoc\nindex.html\nFileC.ms\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<p>FileC</p>\n"
  )
  -- 変換
  testObj.FromDirectory dataDir recursive:true ignore:@"*\_*" exception:@"*\_FileG.ms"
  -- ファイルの存在を確認
  for file in destinationFiles do (
    actual = ::TestValueStruct (::std.FileUtility.FileExists file)
    expected = ::TestValueStruct true
    assert (actual.Equals expected == true)
  )
  -- ファイルの内容を確認
  for i = 1 to destinationFiles.Count do (
    actual = ::TestValueStruct (::std.FileUtility.ReadAllText destinationFiles[i])
    expected = ::TestValueStruct expectedCodes[i]
    assert (actual.Equals expected == true)
  )
  -- データ削除
  ::std.FileUtility.DeleteDirectory testDocDir

  /* IndexFromDirectory */
  -- 対象ディレクトリのファイルのみ
  testObj.IndexFromDirectory dataDir
  -- ファイルの存在を確認
  actual = ::TestValueStruct (::std.FileUtility.FileExists indexFile)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイルの内容を確認
  actual = ::TestValueStruct (::std.FileUtility.ReadAllText indexFile)
  expected = ::TestValueStruct "mxsdoc\nindex.html\nIndex\n\n<ul>\n<li><p>Data</p><ul>\n<li><p><a href=\"data-filea.html\">FileA.ms</a></p></li>\n<li><p><a href=\"data-fileb.html\">FileB.ms</a></p></li>\n<li><p><a href=\"data-filec.html\">FileC.ms</a></p></li>\n</ul></li>\n</ul>\n"
  assert (actual.Equals expected == true)
  -- データ削除
  ::std.FileUtility.DeleteDirectory testDocDir
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
