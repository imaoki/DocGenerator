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
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()
  local code

  fileIn (pathUtility.GetFullPath @"..\..\definitionPool.ms")
  testDef = ::docGeneratorDefinitionPool[@"Parser\PathNameLiteral.ms"]
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- $
  actual = ::TestValueStruct (testObj.Parse "$")
  expected = ::TestValueStruct "$"
  assert (actual.Equals expected == true)
  -- $foo
  actual = ::TestValueStruct (testObj.Parse "$foo")
  expected = ::TestValueStruct "$foo"
  assert (actual.Equals expected == true)
  -- $foo/bar
  actual = ::TestValueStruct (testObj.Parse "$foo/bar")
  expected = ::TestValueStruct "$foo/bar"
  assert (actual.Equals expected == true)
  -- $foo/*
  actual = ::TestValueStruct (testObj.Parse "$foo/*")
  expected = ::TestValueStruct "$foo/*"
  assert (actual.Equals expected == true)
  -- $foo*
  actual = ::TestValueStruct (testObj.Parse "$foo*")
  expected = ::TestValueStruct "$foo*"
  assert (actual.Equals expected == true)
  -- $foo0?
  actual = ::TestValueStruct (testObj.Parse "$foo0?")
  expected = ::TestValueStruct "$foo0?"
  assert (actual.Equals expected == true)
  -- $foo/*/*
  actual = ::TestValueStruct (testObj.Parse "$foo/*/*")
  expected = ::TestValueStruct "$foo/*/*"
  assert (actual.Equals expected == true)
  -- $foo/.../bar*
  actual = ::TestValueStruct (testObj.Parse "$foo/.../bar*")
  expected = ::TestValueStruct "$foo/.../bar*"
  assert (actual.Equals expected == true)
  -- $foo...bar*
  actual = ::TestValueStruct (testObj.Parse "$foo...bar*")
  expected = ::TestValueStruct "$foo...bar*"
  assert (actual.Equals expected == true)
  -- $foo...*
  actual = ::TestValueStruct (testObj.Parse "$foo...*")
  expected = ::TestValueStruct "$foo...*"
  assert (actual.Equals expected == true)
  -- $*foo*
  actual = ::TestValueStruct (testObj.Parse "$*foo*")
  expected = ::TestValueStruct "$*foo*"
  assert (actual.Equals expected == true)
  -- $'foo*'
  actual = ::TestValueStruct (testObj.Parse "$'foo*'")
  expected = ::TestValueStruct "$'foo*'"
  assert (actual.Equals expected == true)
  -- $'\*\?\\foo/*-bar*/--hoge*piyo'
  actual = ::TestValueStruct (testObj.Parse "$'\*\?\\foo/*-bar*/--hoge*piyo'")
  expected = ::TestValueStruct "$'\*\?\\foo/*-bar*/--hoge*piyo'"
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
