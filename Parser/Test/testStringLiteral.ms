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
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()
  local code

  testDef = fileIn (pathUtility.GetFullPath @"..\StringLiteral.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 空文字列
  actual = ::TestValueStruct (testObj.Parse "\"\"")
  expected = ::TestValueStruct "\"\""
  assert (actual.Equals expected == true)
  -- 空文字列（引用符閉じ忘れ）
  actual = ::TestValueStruct (testObj.Parse "\"")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 単語
  actual = ::TestValueStruct (testObj.Parse "\"foobar\"")
  expected = ::TestValueStruct "\"foobar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（二重引用符）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\\"bar\"")
  expected = ::TestValueStruct "\"foo\\\"bar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（改行）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\nbar\"")
  expected = ::TestValueStruct "\"foo\\nbar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（復帰改行）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\rbar\"")
  expected = ::TestValueStruct "\"foo\\rbar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（タブ）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\tbar\"")
  expected = ::TestValueStruct "\"foo\\tbar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（アスタリスク）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\*bar\"")
  expected = ::TestValueStruct "\"foo\\*bar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（疑問符）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\?bar\"")
  expected = ::TestValueStruct "\"foo\\?bar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（バックスラッシュ）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\\\bar\"")
  expected = ::TestValueStruct "\"foo\\\\bar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（パーセント）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\%bar\"")
  expected = ::TestValueStruct "\"foo\\%bar\""
  assert (actual.Equals expected == true)
  -- エスケープシーケンス（16進数）
  actual = ::TestValueStruct (testObj.Parse "\"foo\\xa9 bar\"")
  expected = ::TestValueStruct "\"foo\\xa9 bar\""
  assert (actual.Equals expected == true)
  -- 空の逐語的文字列
  actual = ::TestValueStruct (testObj.Parse "@\"\"")
  expected = ::TestValueStruct "@\"\""
  assert (actual.Equals expected == true)
  -- 空の逐語的文字列（引用符閉じ忘れ）
  actual = ::TestValueStruct (testObj.Parse "@\"")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 逐語的文字列（単語）
  actual = ::TestValueStruct (testObj.Parse "@\"foobar\"")
  expected = ::TestValueStruct "@\"foobar\""
  assert (actual.Equals expected == true)
  -- 逐語的文字列（バックスラッシュ）
  actual = ::TestValueStruct (testObj.Parse "@\"C:\\foo\\bar\"")
  expected = ::TestValueStruct "@\"C:\\foo\\bar\""
  assert (actual.Equals expected == true)
  -- 逐語的文字列（制御文字）
  actual = ::TestValueStruct (testObj.Parse "@\"foo\\nbar\"")
  expected = ::TestValueStruct "@\"foo\\nbar\""
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
