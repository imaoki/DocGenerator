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
  local code
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()

  fileIn (pathUtility.GetFullPath @"..\..\definitionPool.ms")
  testDef = fileIn (pathUtility.GetFullPath @"..\DocDependent.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 数字
  actual = ::TestValueStruct (testObj.Parse "1")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 変数名
  actual = ::TestValueStruct (testObj.Parse "foo")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 引用符付き変数名
  actual = ::TestValueStruct (testObj.Parse "'foo'")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 単項演算子
  actual = ::TestValueStruct (testObj.Parse "-1")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 文字列リテラル
  actual = ::TestValueStruct (testObj.Parse "\"foo\"")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 配列リテラル
  actual = ::TestValueStruct (testObj.Parse "#()")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 単一のブロック式
  actual = ::TestValueStruct (testObj.Parse "()")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 単一のブロック式（閉じ忘れ）
  actual = ::TestValueStruct (testObj.Parse "(")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 同一スコープのブロック式
  actual = ::TestValueStruct (testObj.Parse "();()")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- ネストしたブロック式
  actual = ::TestValueStruct (testObj.Parse "(((((((())))))))")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 行コメント
  actual = ::TestValueStruct (testObj.Parse "-- foo")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 通常のブロックコメント
  actual = ::TestValueStruct (testObj.Parse "/* foo */")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- グローバル変数
  actual = ::TestValueStruct (testObj.Parse "::foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarName Value:"foo"
    )
  )
  assert (actual.Equals expected == true)
  -- グローバル変数宣言
  actual = ::TestValueStruct (testObj.Parse "global foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- グローバル変数宣言（前にスペース無し）
  actual = ::TestValueStruct (testObj.Parse "isGlobal foo")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- グローバル変数宣言（後ろにスペース無し）
  actual = ::TestValueStruct (testObj.Parse "globalXyz bar")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- グローバル変数宣言（シンボル付き）
  actual = ::TestValueStruct (testObj.Parse "global ::foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- 構造体宣言
  actual = ::TestValueStruct (testObj.Parse "struct FooStruct ()")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#StructDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"FooStruct"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ブロック式とグローバル変数
  actual = ::TestValueStruct (testObj.Parse "(\n::foo\n::bar\n)")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarName Value:"foo",
      ::AstNodeStruct Type:#GlobalVarName Value:"bar"
    )
  )
  assert (actual.Equals expected == true)
  -- ブロック式とグローバル変数宣言
  actual = ::TestValueStruct (testObj.Parse "(\nglobal foo\n)")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ブロック式と構造体定義
  actual = ::TestValueStruct (testObj.Parse "(\nstruct FooStruct ()\n)")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 構造体定義とグローバル変数
  actual = ::TestValueStruct (testObj.Parse "struct FooStruct (\n::foo\n)")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#StructDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"FooStruct"
      ),
      ::AstNodeStruct Type:#GlobalVarName Value:"foo"
    )
  )
  assert (actual.Equals expected == true)
  -- 構造体定義とグローバル変数宣言
  actual = ::TestValueStruct (testObj.Parse "struct FooStruct (\nglobal foo\n)")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#StructDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"FooStruct"
      ),
      ::AstNodeStruct Type:#GlobalVarDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ネストしたブロック式とグローバル変数
  actual = ::TestValueStruct (testObj.Parse "(\n(\n::foo\n)\n)")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarName Value:"foo"
    )
  )
  assert (actual.Equals expected == true)

  /* docDependent.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docDependent.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#StructDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"TestStruct"
      ),
      ::AstNodeStruct Type:#GlobalVarDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"globalVariable"
      ),
      ::AstNodeStruct Type:#GlobalVarName Value:"foo"
    )
  )
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
