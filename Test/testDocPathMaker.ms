/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
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
  local currentDir = pathUtility.GetDirectoryName currentFile
  local dataDir = pathUtility.GetFullPath @".\Data"
  local docGeneratorDir = pathUtility.GetDirectoryName currentDir
  local scriptDir = pathUtility.GetDirectoryName docGeneratorDir
  local maxDir = pathUtility.GetDirectoryName scriptDir

  local defaultTemplateFile = pathUtility.GetFullPath @"..\Resource\default-template.html"
  local indexFile = pathUtility.GetFullPath @"..\..\Document\index.html"

  local optionsDef = fileIn (pathUtility.GetFullPath @"..\DocOptions.ms")

  testDef = fileIn (pathUtility.GetFullPath @"..\DocPathMaker.ms")
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* FromFile */
  -- DocGeneratorディレクトリ
  testObj = testDef()
  -- このファイル
  actual = ::TestValueStruct (testObj.FromFile currentFile)
  -- actual.Dump()
  expected = ::TestValueStruct (
    DataPair Source:currentFile Destination:(
      scriptDir + @"\Document\docgenerator-test-testdocpathmaker.html"
    )
  )
  assert (actual.Equals expected == true)
  -- Dataディレクトリ
  testObj = testDef (optionsDef BasePath:dataDir)
  -- このファイル
  actual = ::TestValueStruct (testObj.FromFile currentFile)
  -- actual.Dump()
  expected = ::TestValueStruct (
    DataPair Source:currentFile Destination:(
      dataDir + @"\Document\..-testdocpathmaker.html"
    )
  )
  assert (actual.Equals expected == true)

  /* FromDirectory */
  -- DocGeneratorディレクトリ
  testObj = testDef()
  -- 対象ディレクトリのファイルのみ
  actual = ::TestValueStruct (testObj.FromDirectory dataDir)
  -- actual.Dump()
  expected = ::TestValueStruct #(
    DataPair Source:(dataDir + @"\FileA.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filea.html"
    ),
    DataPair Source:(dataDir + @"\FileB.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-fileb.html"
    ),
    DataPair Source:(dataDir + @"\FileC.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filec.html"
    )
  )
  assert (actual.Equals expected == true)
  -- サブディレクトリのファイルも全て
  actual = ::TestValueStruct (testObj.FromDirectory dataDir recursive:true)
  -- actual.Dump()
  expected = ::TestValueStruct #(
    DataPair Source:(dataDir + @"\_DirA\FileD.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-_dira-filed.html"
    ),
    DataPair Source:(dataDir + @"\DirB\FileE.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirb-filee.html"
    ),
    DataPair Source:(dataDir + @"\DirB\FileF.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirb-filef.html"
    ),
    DataPair Source:(dataDir + @"\DirC\_FileG.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirc-_fileg.html"
    ),
    DataPair Source:(dataDir + @"\FileA.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filea.html"
    ),
    DataPair Source:(dataDir + @"\FileB.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-fileb.html"
    ),
    DataPair Source:(dataDir + @"\FileC.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filec.html"
    )
  )
  assert (actual.Equals expected == true)
  -- 単一パターンでファイルを除外
  actual = ::TestValueStruct (
    testObj.FromDirectory dataDir recursive:true ignore:@"*\_*"
  )
  -- actual.Dump()
  expected = ::TestValueStruct #(
    DataPair Source:(dataDir + @"\DirB\FileE.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirb-filee.html"
    ),
    DataPair Source:(dataDir + @"\DirB\FileF.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirb-filef.html"
    ),
    DataPair Source:(dataDir + @"\FileA.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filea.html"
    ),
    DataPair Source:(dataDir + @"\FileB.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-fileb.html"
    ),
    DataPair Source:(dataDir + @"\FileC.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filec.html"
    )
  )
  assert (actual.Equals expected == true)
  -- 複数パターンでファイルを除外
  actual = ::TestValueStruct (
    testObj.FromDirectory dataDir recursive:true ignore:#(
      @"*\_*",
      "*A.ms"
    )
  )
  -- actual.Dump()
  expected = ::TestValueStruct #(
    DataPair Source:(dataDir + @"\DirB\FileE.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirb-filee.html"
    ),
    DataPair Source:(dataDir + @"\DirB\FileF.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirb-filef.html"
    ),
    DataPair Source:(dataDir + @"\FileB.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-fileb.html"
    ),
    DataPair Source:(dataDir + @"\FileC.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filec.html"
    )
  )
  assert (actual.Equals expected == true)
  -- 除外の例外パターンを指定
  actual = ::TestValueStruct (
    testObj.FromDirectory dataDir recursive:true ignore:@"*\_*" exception:@"*\_FileG.ms"
  )
  -- actual.Dump()
  expected = ::TestValueStruct #(
    DataPair Source:(dataDir + @"\DirB\FileE.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirb-filee.html"
    ),
    DataPair Source:(dataDir + @"\DirB\FileF.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirb-filef.html"
    ),
    DataPair Source:(dataDir + @"\DirC\_FileG.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-dirc-_fileg.html"
    ),
    DataPair Source:(dataDir + @"\FileA.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filea.html"
    ),
    DataPair Source:(dataDir + @"\FileB.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-fileb.html"
    ),
    DataPair Source:(dataDir + @"\FileC.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filec.html"
    )
  )
  assert (actual.Equals expected == true)
  -- Scriptディレクトリ
  testObj = testDef (optionsDef BasePath:scriptDir)
  -- 対象ディレクトリのファイルのみ
  actual = ::TestValueStruct (testObj.FromDirectory dataDir)
  -- actual.Dump()
  expected = ::TestValueStruct #(
    DataPair Source:(dataDir + @"\FileA.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filea.html"
    ),
    DataPair Source:(dataDir + @"\FileB.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-fileb.html"
    ),
    DataPair Source:(dataDir + @"\FileC.ms") Destination:(
      scriptDir + @"\Document\docgenerator-test-data-filec.html"
    )
  )
  assert (actual.Equals expected == true)

  /* GetAbsoluteBasePath */
  -- 既定値
  testObj = testDef()
  actual = ::TestValueStruct (testObj.GetAbsoluteBasePath())
  expected = ::TestValueStruct scriptDir
  assert (actual.Equals expected == true)
  -- 下位ディレクトリを指定
  testObj = testDef (optionsDef BasePath:@".\Test")
  actual = ::TestValueStruct (testObj.GetAbsoluteBasePath())
  expected = ::TestValueStruct currentDir
  assert (actual.Equals expected == true)
  -- 上位ディレクトリを指定
  testObj = testDef (optionsDef BasePath:@"..\")
  actual = ::TestValueStruct (testObj.GetAbsoluteBasePath())
  expected = ::TestValueStruct scriptDir
  assert (actual.Equals expected == true)
  -- 更に上位ディレクトリを指定
  testObj = testDef (optionsDef BasePath:@"..\..\")
  actual = ::TestValueStruct (testObj.GetAbsoluteBasePath())
  expected = ::TestValueStruct maxDir
  assert (actual.Equals expected == true)
  /* ベースパスの変更 */
  testObj = testDef()
  actual = ::TestValueStruct (testObj.GetAbsoluteBasePath())
  expected = ::TestValueStruct scriptDir
  assert (actual.Equals expected == true)
  -- 上位ディレクトリ
  testObj.Options.BasePath = @"..\..\"
  actual = ::TestValueStruct (testObj.GetAbsoluteBasePath())
  expected = ::TestValueStruct maxDir
  assert (actual.Equals expected == true)
  /* 末尾バックスラッシュ */
  testObj = testDef (optionsDef BasePath:(currentDir + @"\"))
  actual = ::TestValueStruct (testObj.GetAbsoluteBasePath())
  expected = ::TestValueStruct currentDir
  assert (actual.Equals expected == true)

  /* GetAbsoluteIndexPath */
  -- 既定値
  testObj = testDef()
  actual = ::TestValueStruct (testObj.GetAbsoluteIndexPath())
  expected = ::TestValueStruct indexFile
  assert (actual.Equals expected == true)

  /* GetAbsoluteTemplatePath */
  -- 既定値
  testObj = testDef()
  actual = ::TestValueStruct (testObj.GetAbsoluteTemplatePath())
  expected = ::TestValueStruct defaultTemplateFile
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
