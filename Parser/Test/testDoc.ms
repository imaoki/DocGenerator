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
  testDef = fileIn (pathUtility.GetFullPath @"..\Doc.ms")
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
  actual = ::TestValueStruct (testObj.Parse "/**/")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- ドキュメントコメントのみ（空文字列）
  actual = ::TestValueStruct (testObj.Parse "/*-*/")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- ドキュメントコメントのみ
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- ドキュメントコメントとキーワード
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/fn")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- ドキュメントコメントと変数名
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- 空のドキュメントコメントと変数名
  actual = ::TestValueStruct (testObj.Parse "/*-*/foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントとローカル変数
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/local foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"local"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントとグローバル変数
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/global foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"global"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントとグローバル変数（`::`指定）
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/::foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#VarName Value:"::foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントと関数
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/fn foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"fn"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントと関数（先頭がキーワードの変数名）
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/fn functionName")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"fn"
        ),
        ::AstNodeStruct Type:#VarName Value:"functionName"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントとカスタムアトリビュート
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/attributes Foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"attributes"
        ),
        ::AstNodeStruct Type:#VarName Value:"Foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントと構造体
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/struct Foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"struct"
        ),
        ::AstNodeStruct Type:#VarName Value:"Foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントとパブリックメソッド
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/public fn foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"public",
          ::AstNodeStruct Type:#Keyword Value:"fn"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントとプライベートメソッド
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/private fn foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"private",
          ::AstNodeStruct Type:#Keyword Value:"fn"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ブロック式内ドキュメントコメント
  actual = ::TestValueStruct (testObj.Parse "(/*-hoge*/foo)")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#DocSeq Value:#(
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"hoge"
          ),
          ::AstNodeStruct Type:#VarName Value:"foo"
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ブロック式内ドキュメントコメント（並列）
  actual = ::TestValueStruct (testObj.Parse "(/*-hoge*/foo;/*-hoge*/bar)")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#DocSeq Value:#(
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"hoge"
          ),
          ::AstNodeStruct Type:#VarName Value:"foo"
        ),
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"hoge"
          ),
          ::AstNodeStruct Type:#VarName Value:"bar"
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ブロック式内ドキュメントコメント（ネスト）
  actual = ::TestValueStruct (testObj.Parse "(/*-hoge*/foo;(/*-hoge*/bar))")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#DocSeq Value:#(
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"hoge"
          ),
          ::AstNodeStruct Type:#VarName Value:"foo"
        ),
        ::AstNodeStruct Type:#DocSeq Value:#(
          ::AstNodeStruct Type:#SimpleDoc Value:#(
            ::AstNodeStruct Type:#DocComment Value:#(
              ::AstNodeStruct Type:#Text Value:"hoge"
            ),
            ::AstNodeStruct Type:#VarName Value:"bar"
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- ドキュメントコメントとブロック式の並列
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/fn foo = ((/*-hoge*/bar));/*-hoge*/struct piyo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"fn"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      ),
      ::AstNodeStruct Type:#DocSeq Value:#(
        ::AstNodeStruct Type:#DocSeq Value:#(
          ::AstNodeStruct Type:#SimpleDoc Value:#(
            ::AstNodeStruct Type:#DocComment Value:#(
              ::AstNodeStruct Type:#Text Value:"hoge"
            ),
            ::AstNodeStruct Type:#VarName Value:"bar"
          )
        )
      ),
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"struct"
        ),
        ::AstNodeStruct Type:#VarName Value:"piyo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- コメントと通常のブロックコメント
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*//*fn*/foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- コメントと行コメント
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/--(/*-piyo*/bar)\nfoo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- コメントと文字列リテラル
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/\"(/*-piyo*/bar)\"foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- コメントとパス名リテラル
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/$fn*;foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- コメントとパス名リテラル（引用符）
  actual = ::TestValueStruct (testObj.Parse "/*-hoge*/$'/*-fn*/';foo")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"hoge"
        ),
        ::AstNodeStruct Type:#VarName Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)

  /* docBasic.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docBasic.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"関数。"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"fn"
        ),
        ::AstNodeStruct Type:#VarName Value:"functionName"
      ),
      ::AstNodeStruct Type:#DocSeq Value:#(
        ::AstNodeStruct Type:#DocSeq Value:#(
          ::AstNodeStruct Type:#SimpleDoc Value:#(
            ::AstNodeStruct Type:#DocComment Value:#(
              ::AstNodeStruct Type:#Text Value:"ローカル変数。"
            ),
            ::AstNodeStruct Type:#Keywords Value:#(
              ::AstNodeStruct Type:#Keyword Value:"local"
            ),
            ::AstNodeStruct Type:#VarName Value:"c"
          )
        )
      ),
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"構造体。"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"struct"
        ),
        ::AstNodeStruct Type:#VarName Value:"StructName"
      )
    )
  )
  assert (actual.Equals expected == true)

  /* docExample.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docExample.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      /* ::AstNodeStruct Type:#DocDependent Value:#(
        ::AstNodeStruct Type:#VarName Value:"::foo"
      ), */
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Tag Value:#(
            ::AstNodeStruct Type:#TagType Value:#Var,
            ::AstNodeStruct Type:#ClassForm Value:#(
              ::AstNodeStruct Type:#ClassName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "ClassName"
                )
              )
            ),
            ::AstNodeStruct Type:#Text Value:"変数。"
          )
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"global"
        ),
        ::AstNodeStruct Type:#VarName Value:"sampleVar"
      ),
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"構造体。",
          ::AstNodeStruct Type:#Tag Value:#(
            ::AstNodeStruct Type:#TagType Value:#Remarks,
            ::AstNodeStruct Type:#Text Value:"補足説明。"
          )
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"struct"
        ),
        ::AstNodeStruct Type:#VarName Value:"SampleStruct"
      ),
      ::AstNodeStruct Type:#DocSeq Value:#(
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Number"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"数値。既定値は`0`。"
            )
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"public"
          ),
          ::AstNodeStruct Type:#VarName Value:"Num"
        ),
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "String"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"文字列。既定値は`\"\"`。"
            )
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"private"
          ),
          ::AstNodeStruct Type:#VarName Value:"str"
        ),
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassDef Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "DotNetClass"
                  ),
                  ::AstNodeStruct Type:#ClassName Value:#(
                    ::AstNodeStruct Type:#VarName Value:#(
                      "System"
                    ),
                    ::AstNodeStruct Type:#VarName Value:#(
                      "Text"
                    ),
                    ::AstNodeStruct Type:#VarName Value:#(
                      "RegularExpressions"
                    ),
                    ::AstNodeStruct Type:#VarName Value:#(
                      "Regex"
                    )
                  )
                )
              )
            )
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"private"
          ),
          ::AstNodeStruct Type:#VarName Value:"regexClass"
        ),
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"パブリックメソッド。",
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "param1"
                )
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Integer"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"位置パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "param2"
                )
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Name"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"位置パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "&",
                  "param3"
                )
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "String"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"参照パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "param4"
                ),
                ":"
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#AccessorDef Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Array"
                  ),
                  ::AstNodeStruct Type:#ClassForm Value:#(
                    ::AstNodeStruct Type:#ConstructorDef Value:#(
                      ::AstNodeStruct Type:#VarName Value:#(
                        "DataPair"
                      ),
                      ::AstNodeStruct Type:#KeywordParameter Value:#(
                        ::AstNodeStruct Type:#VarName Value:#(
                          "Name"
                        ),
                        ::AstNodeStruct Type:#ClassForm Value:#(
                          ::AstNodeStruct Type:#ClassName Value:#(
                            ::AstNodeStruct Type:#VarName Value:#(
                              "String"
                            )
                          )
                        )
                      ),
                      ::AstNodeStruct Type:#KeywordParameter Value:#(
                        ::AstNodeStruct Type:#VarName Value:#(
                          "Value"
                        ),
                        ::AstNodeStruct Type:#ClassForm Value:#(
                          ::AstNodeStruct Type:#ClassName Value:#(
                            ::AstNodeStruct Type:#VarName Value:#(
                              "Any"
                            )
                          )
                        )
                      )
                    )
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"キーワードパラメータ。\n\n  `Name`\n  : 名前。\n\n  `Value`\n  : 値。\n\n    ```maxscript\n    getHashValue \"Hello World\" 17\n    ```"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "&",
                  "param5"
                ),
                ":"
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Name"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"キーワード参照パラメータ。\n\n  | 値     | 説明 |\n  | ------ | ---- |\n  | `#Foo` | ほげ |\n  | `#Bar` | ぴよ |"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Returns,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "OkClass"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"戻り値。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Remarks,
              ::AstNodeStruct Type:#Text Value:"補足説明。"
            )
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"public",
            ::AstNodeStruct Type:#Keyword Value:"fn"
          ),
          ::AstNodeStruct Type:#VarName Value:"PublicMethod"
        ),
        ::AstNodeStruct Type:#DocSeq Value:#(
          ::AstNodeStruct Type:#SimpleDoc Value:#(
            ::AstNodeStruct Type:#DocComment Value:#(
              ::AstNodeStruct Type:#Tag Value:#(
                ::AstNodeStruct Type:#TagType Value:#Var,
                ::AstNodeStruct Type:#ClassForm Value:#(
                  ::AstNodeStruct Type:#ClassName Value:#(
                    ::AstNodeStruct Type:#VarName Value:#(
                      "Float"
                    )
                  )
                ),
                ::AstNodeStruct Type:#Text Value:"ローカル変数。"
              )
            ),
            ::AstNodeStruct Type:#Keywords Value:#(
              ::AstNodeStruct Type:#Keyword Value:"local"
            ),
            ::AstNodeStruct Type:#VarName Value:"i"
          )
        ),
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"プライベートメソッド。",
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Returns,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "OkClass"
                  )
                )
              )
            )
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"private",
            ::AstNodeStruct Type:#Keyword Value:"fn"
          ),
          ::AstNodeStruct Type:#VarName Value:"privateMethod"
        )
      )
    )
  )
  assert (actual.Equals expected == true)

  /* docTest.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docTest.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      /* ::AstNodeStruct Type:#DocDependent Value:#(
        ::AstNodeStruct Type:#VarName Value:"::Foo",
        ::AstNodeStruct Type:#VarName Value:"::'Bar Baz'"
      ), */
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"構造体。",
          ::AstNodeStruct Type:#Tag Value:#(
            ::AstNodeStruct Type:#TagType Value:#Var,
            ::AstNodeStruct Type:#ClassForm Value:#(
              ::AstNodeStruct Type:#ClassName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "ClassName"
                )
              )
            ),
            ::AstNodeStruct Type:#Text Value:"変数。"
          ),
          ::AstNodeStruct Type:#Tag Value:#(
            ::AstNodeStruct Type:#TagType Value:#Prop,
            ::AstNodeStruct Type:#ClassForm Value:#(
              ::AstNodeStruct Type:#ClassName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "ClassName"
                )
              )
            ),
            ::AstNodeStruct Type:#Text Value:"プロパティ。"
          ),
          ::AstNodeStruct Type:#Tag Value:#(
            ::AstNodeStruct Type:#TagType Value:#Prop,
            ::AstNodeStruct Type:#ClassForm Value:#(
              ::AstNodeStruct Type:#ClassName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "ClassName"
                )
              )
            )
          ),
          ::AstNodeStruct Type:#Tag Value:#(
            ::AstNodeStruct Type:#TagType Value:#Param,
            ::AstNodeStruct Type:#ParamName Value:#(
              ::AstNodeStruct Type:#VarName Value:#(
                "param"
              )
            ),
            ::AstNodeStruct Type:#ClassForm Value:#(
              ::AstNodeStruct Type:#ClassName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "ClassName"
                )
              )
            ),
            ::AstNodeStruct Type:#Text Value:"位置パラメータ。"
          ),
          ::AstNodeStruct Type:#Tag Value:#(
            ::AstNodeStruct Type:#TagType Value:#Returns,
            ::AstNodeStruct Type:#ClassForm Value:#(
              ::AstNodeStruct Type:#ClassName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "OkClass"
                )
              )
            ),
            ::AstNodeStruct Type:#Text Value:"戻り値。"
          ),
          ::AstNodeStruct Type:#Tag Value:#(
            ::AstNodeStruct Type:#TagType Value:#Remarks,
            ::AstNodeStruct Type:#Text Value:"補足説明。"
          )
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"struct"
        ),
        ::AstNodeStruct Type:#VarName Value:"TestStruct"
      ),
      ::AstNodeStruct Type:#DocSeq Value:#(
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"プロパティ。"
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"public"
          ),
          ::AstNodeStruct Type:#VarName Value:"TestProperty"
        ),
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"メソッドA。",
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "positional"
                )
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "ClassName"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"位置パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "&",
                  "referenceParam"
                )
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "ClassName"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"参照パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "keywordParam"
                ),
                ":"
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "ClassName"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"キーワードパラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "&",
                  "keywordReferenceParam"
                ),
                ":"
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "ClassName"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"キーワード参照パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "&",
                  "'quoted name'"
                ),
                ":"
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "ClassName"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"引用符で囲まれた名前。"
            )
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"public",
            ::AstNodeStruct Type:#Keyword Value:"fn"
          ),
          ::AstNodeStruct Type:#VarName Value:"TestMethod_A"
        ),
        ::AstNodeStruct Type:#DocSeq Value:#(
          ::AstNodeStruct Type:#SimpleDoc Value:#(
            ::AstNodeStruct Type:#DocComment Value:#(
              ::AstNodeStruct Type:#Text Value:"ローカル関数"
            ),
            ::AstNodeStruct Type:#Keywords Value:#(
              ::AstNodeStruct Type:#Keyword Value:"fn"
            ),
            ::AstNodeStruct Type:#VarName Value:"localFunction"
          ),
          ::AstNodeStruct Type:#SimpleDoc Value:#(
            ::AstNodeStruct Type:#DocComment Value:#(
              ::AstNodeStruct Type:#Text Value:"ローカル変数"
            ),
            ::AstNodeStruct Type:#Keywords Value:#(
              ::AstNodeStruct Type:#Keyword Value:"local"
            ),
            ::AstNodeStruct Type:#VarName Value:"localVariable"
          )
        ),
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"メソッドB。",
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Foo"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"基本。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Foo"
                  ),
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Bar"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"プロパティまたは名前空間。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassDef Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Foo"
                  ),
                  ::AstNodeStruct Type:#ClassName Value:#(
                    ::AstNodeStruct Type:#VarName Value:#(
                      "Bar"
                    )
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"定義。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassDef Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Foo"
                  ),
                  ::AstNodeStruct Type:#ClassName Value:#(
                    ::AstNodeStruct Type:#VarName Value:#(
                      "Bar"
                    ),
                    ::AstNodeStruct Type:#VarName Value:#(
                      "Baz"
                    ),
                    ::AstNodeStruct Type:#VarName Value:#(
                      "Hoge"
                    )
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"定義とプロパティ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Foo"
                  )
                ),
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Bar"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"複数のクラス。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#AccessorDef Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Foo"
                  ),
                  ::AstNodeStruct Type:#ClassForm Value:#(
                    ::AstNodeStruct Type:#AccessorDef Value:#(
                      ::AstNodeStruct Type:#VarName Value:#(
                        "Bar"
                      ),
                      ::AstNodeStruct Type:#ClassForm Value:#(
                        ::AstNodeStruct Type:#ClassName Value:#(
                          ::AstNodeStruct Type:#VarName Value:#(
                            "Baz"
                          )
                        )
                      )
                    )
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"ネスト。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ConstructorDef Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Foo"
                  ),
                  ::AstNodeStruct Type:#PositionalParameter Value:(
                    ::AstNodeStruct Type:#ClassForm Value:#(
                      ::AstNodeStruct Type:#ClassName Value:#(
                        ::AstNodeStruct Type:#VarName Value:#(
                          "Bar"
                        )
                      )
                    )
                  ),
                  ::AstNodeStruct Type:#KeywordParameter Value:#(
                    ::AstNodeStruct Type:#VarName Value:#(
                      "Param"
                    ),
                    ::AstNodeStruct Type:#ClassForm Value:#(
                      ::AstNodeStruct Type:#ClassName Value:#(
                        ::AstNodeStruct Type:#VarName Value:#(
                          "Baz"
                        )
                      )
                    )
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"コンストラクタ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Prop,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassDef Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Struct"
                  ),
                  ::AstNodeStruct Type:#ClassName Value:#(
                    ::AstNodeStruct Type:#VarName Value:#(
                      "FooStruct"
                    )
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"依存リンク。"
            )
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"public",
            ::AstNodeStruct Type:#Keyword Value:"fn"
          ),
          ::AstNodeStruct Type:#VarName Value:"TestMethod_B"
        ),
        ::AstNodeStruct Type:#SimpleDoc Value:#(
          ::AstNodeStruct Type:#DocComment Value:#(
            ::AstNodeStruct Type:#Text Value:"メソッドC。",
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "param1"
                )
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Integer"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"位置パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "param2"
                )
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Name"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"位置パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "&",
                  "param3"
                )
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "String"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"参照パラメータ。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "param4"
                ),
                ":"
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#AccessorDef Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Array"
                  ),
                  ::AstNodeStruct Type:#ClassForm Value:#(
                    ::AstNodeStruct Type:#ConstructorDef Value:#(
                      ::AstNodeStruct Type:#VarName Value:#(
                        "DataPair"
                      ),
                      ::AstNodeStruct Type:#KeywordParameter Value:#(
                        ::AstNodeStruct Type:#VarName Value:#(
                          "Name"
                        ),
                        ::AstNodeStruct Type:#ClassForm Value:#(
                          ::AstNodeStruct Type:#ClassName Value:#(
                            ::AstNodeStruct Type:#VarName Value:#(
                              "String"
                            )
                          )
                        )
                      ),
                      ::AstNodeStruct Type:#KeywordParameter Value:#(
                        ::AstNodeStruct Type:#VarName Value:#(
                          "Value"
                        ),
                        ::AstNodeStruct Type:#ClassForm Value:#(
                          ::AstNodeStruct Type:#ClassName Value:#(
                            ::AstNodeStruct Type:#VarName Value:#(
                              "Any"
                            )
                          )
                        )
                      )
                    )
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"キーワードパラメータ。\n\n  `Name`\n  : 名前。\n\n  `Value`\n  : 値。\n\n    ```maxscript\n    getHashValue \"Hello World\" 17\n    ```"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Param,
              ::AstNodeStruct Type:#ParamName Value:#(
                ::AstNodeStruct Type:#VarName Value:#(
                  "&",
                  "param5"
                ),
                ":"
              ),
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "Name"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"キーワード参照パラメータ。\n\n  | 値     | 説明 |\n  | ------ | ---- |\n  | `#Foo` | ほげ |\n  | `#Bar` | ぴよ |"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Returns,
              ::AstNodeStruct Type:#ClassForm Value:#(
                ::AstNodeStruct Type:#ClassName Value:#(
                  ::AstNodeStruct Type:#VarName Value:#(
                    "OkClass"
                  )
                )
              ),
              ::AstNodeStruct Type:#Text Value:"戻り値。"
            ),
            ::AstNodeStruct Type:#Tag Value:#(
              ::AstNodeStruct Type:#TagType Value:#Remarks,
              ::AstNodeStruct Type:#Text Value:"補足説明。"
            )
          ),
          ::AstNodeStruct Type:#Keywords Value:#(
            ::AstNodeStruct Type:#Keyword Value:"public",
            ::AstNodeStruct Type:#Keyword Value:"fn"
          ),
          ::AstNodeStruct Type:#VarName Value:"TestMethod_C"
        )
      )
    )
  )
  assert (actual.Equals expected == true)

  /* docErrorTest1.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docErrorTest1.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#Document Value:#(
      ::AstNodeStruct Type:#SimpleDoc Value:#(
        ::AstNodeStruct Type:#DocComment Value:#(
          ::AstNodeStruct Type:#Text Value:"`doq_seq`の閉じ忘れ。"
        ),
        ::AstNodeStruct Type:#Keywords Value:#(
          ::AstNodeStruct Type:#Keyword Value:"struct"
        ),
        ::AstNodeStruct Type:#VarName Value:"StructName"
      )
    )
  )
  assert (actual.Equals expected == true)

  /* docErrorTest2.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docErrorTest2.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
