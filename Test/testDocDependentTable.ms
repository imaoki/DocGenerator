/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
(
  -- clearListener()

  local nowTime = (DotNetClass "System.DateTime").Now.ToString "HH:mm:ss"
  local sw = DotNetObject "System.Diagnostics.Stopwatch"

  local currentFile = getSourceFileName()
  local pathUtility = ::PathUtilityStruct currentFile

  local actual
  local expected
  local testDef
  local testObj

  format "[run %]@\"%\"\n" nowTime currentFile
  /* Setup Start ------------------------------------------------------------ */
  local code
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()

  local pathA = DataPair Source:@"C:\Test\A.ms" Destination:@"C:\Test\Document\a.html"
  local pathB = DataPair Source:@"C:\Test\B.ms" Destination:@"C:\Test\Document\b.html"
  local pathC = DataPair Source:@"C:\Test\C.ms" Destination:@"C:\Test\Document\c.html"

  local astA = (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#StructDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"FooStruct"
      ),
      ::AstNodeStruct Type:#GlobalVarDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"foo"
      ),
      ::AstNodeStruct Type:#GlobalVarName Value:"bar"
    )
  )
  local astB = (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"bar"
      ),
      ::AstNodeStruct Type:#GlobalVarName Value:"FooStruct",
      ::AstNodeStruct Type:#GlobalVarName Value:"foo"
    )
  )
  local astC = (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"FooStruct"
      )
    )
  )

  testDef = fileIn (pathUtility.GetFullPath @"..\DocDependentTable.ms")
  testObj = testDef()
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* AddDependent */
  -- Foo
  actual = ::TestValueStruct (testObj.AddDependent astA pathA)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- Bar
  actual = ::TestValueStruct (testObj.AddDependent astB pathB)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- Baz
  actual = ::TestValueStruct (testObj.AddDependent astC pathC)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* GetDependent */
  -- Foo
  actual = ::TestValueStruct (testObj.GetDependent pathA)
  expected = ::TestValueStruct (
    DataPair VarName:#("bar") Path:#(#(pathB))
  )
  assert (actual.Equals expected == true)
  -- Bar
  actual = ::TestValueStruct (testObj.GetDependent pathB)
  expected = ::TestValueStruct (
    DataPair \
        VarName:#(
          "foo",
          "FooStruct"
        ) \
        Path:#(
          #(pathA),
          #(pathA, pathC)
        )
  )
  assert (actual.Equals expected == true)
  -- Baz
  actual = ::TestValueStruct (testObj.GetDependent pathC)
  expected = ::TestValueStruct (DataPair VarName:#() Path:#())
  assert (actual.Equals expected == true)

  /* Initialize */
  actual = ::TestValueStruct (testObj.Initialize())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- 確認
  actual = ::TestValueStruct (testObj.GetDependent pathA)
  expected = ::TestValueStruct (DataPair VarName:#() Path:#())
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
