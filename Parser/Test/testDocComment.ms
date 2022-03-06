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

  testDef = fileIn (pathUtility.GetFullPath @"..\DocComment.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 通常コメント
  actual = ::TestValueStruct (testObj.Parse "/**/")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 空のドキュメントコメント
  actual = ::TestValueStruct (testObj.Parse "/*-*/")
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 閉じ忘れ
  actual = ::TestValueStruct (testObj.Parse "/*- foobar")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- テキストのみ
  actual = ::TestValueStruct (testObj.Parse "/*- foobar */")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Text Value:"foobar"
    )
  )
  assert (actual.Equals expected == true)
  -- 未定義のタグはテキスト扱いになる
  actual = ::TestValueStruct (testObj.Parse "/*- @foo */")
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Text Value:"@foo"
    )
  )
  assert (actual.Equals expected == true)
  -- paramタグ（tag_typeのみ）
  actual = ::TestValueStruct (testObj.Parse "/*- @param */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- paramタグ（tag_typeとparam_name）
  actual = ::TestValueStruct (testObj.Parse "/*- @param foo */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- paramタグ（tag_typeとparam_nameとclass_form）
  actual = ::TestValueStruct (testObj.Parse "/*- @param foo <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Param,
        ::AstNodeStruct Type:#ParamName Value:#(
          ::AstNodeStruct Type:#VarName Value:#(
            "foo"
          )
        ),
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- paramタグ（完全）
  actual = ::TestValueStruct (testObj.Parse "/*- @param foo <ClassName> bar */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Param,
        ::AstNodeStruct Type:#ParamName Value:#(
          ::AstNodeStruct Type:#VarName Value:#(
            "foo"
          )
        ),
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        ),
        ::AstNodeStruct Type:#Text Value:"bar"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- propタグ（tag_typeのみ）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- propタグ（tag_typeとparam_name）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop foo */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- propタグ（tag_typeとclass_form）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Prop,
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- propタグ（完全）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <ClassName> foo */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Prop,
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        ),
        ::AstNodeStruct Type:#Text Value:"foo"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- remarksタグ
  actual = ::TestValueStruct (testObj.Parse "/*- @remarks */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Remarks
      )
    )
  )
  assert (actual.Equals expected == true)
  -- remarksタグ（text付き）
  actual = ::TestValueStruct (testObj.Parse "/*- @remarks foobar */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Remarks,
        ::AstNodeStruct Type:#Text Value:"foobar"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- remarksタグ（tag_typeの後はテキスト扱いになる）
  actual = ::TestValueStruct (testObj.Parse "/*- @remarks <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Remarks,
        ::AstNodeStruct Type:#Text Value:"<ClassName>"
      )
    )
  )
  assert (actual.Equals expected == true)
  -- param_name
  actual = ::TestValueStruct (testObj.Parse "/*- @param foo <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Param,
        ::AstNodeStruct Type:#ParamName Value:#(
          ::AstNodeStruct Type:#VarName Value:#(
            "foo"
          )
        ),
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- param_name（頭文字がアンダースコア）
  actual = ::TestValueStruct (testObj.Parse "/*- @param _foo <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Param,
        ::AstNodeStruct Type:#ParamName Value:#(
          ::AstNodeStruct Type:#VarName Value:#(
            "_foo"
          )
        ),
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- param_name（頭文字がアンダースコア以外の記号）
  actual = ::TestValueStruct (testObj.Parse "/*- @param $foo <ClassName> */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- param_name（頭文字が数字）
  actual = ::TestValueStruct (testObj.Parse "/*- @param 0foo <ClassName> */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- param_name（参照パラメータ）
  actual = ::TestValueStruct (testObj.Parse "/*- @param &foo <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Param,
        ::AstNodeStruct Type:#ParamName Value:#(
          ::AstNodeStruct Type:#VarName Value:#(
            "&",
            "foo"
          )
        ),
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- param_name（キーワードパラメータ）
  actual = ::TestValueStruct (testObj.Parse "/*- @param foo: <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Param,
        ::AstNodeStruct Type:#ParamName Value:#(
          ::AstNodeStruct Type:#VarName Value:#(
            "foo"
          ),
          ":"
        ),
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- param_name（キーワード参照パラメータ）
  actual = ::TestValueStruct (testObj.Parse "/*- @param &foo: <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Param,
        ::AstNodeStruct Type:#ParamName Value:#(
          ::AstNodeStruct Type:#VarName Value:#(
            "&",
            "foo"
          ),
          ":"
        ),
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- param_name（引用符閉じ忘れ）
  actual = ::TestValueStruct (testObj.Parse "/*- @param 'foo <ClassName> */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- param_name（引用符）
  actual = ::TestValueStruct (testObj.Parse "/*- @param '0 f-o&o:' <ClassName> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Param,
        ::AstNodeStruct Type:#ParamName Value:#(
          ::AstNodeStruct Type:#VarName Value:#(
            "'0 f-o&o:'"
          )
        ),
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "ClassName"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- class_form（閉じ忘れ）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <ClassName */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- class_form（空文字列）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <> */")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- class_form（基本）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <Foo> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Tag Value:#(
        ::AstNodeStruct Type:#TagType Value:#Prop,
        ::AstNodeStruct Type:#ClassForm Value:#(
          ::AstNodeStruct Type:#ClassName Value:#(
            ::AstNodeStruct Type:#VarName Value:#(
              "Foo"
            )
          )
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- class_form（プロパティまたは名前空間）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <Foo.Bar> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
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
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- class_form（定義）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <Foo:Bar> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
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
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- class_form（定義とプロパティ）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <Foo:Bar.Baz.Hoge> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
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
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- class_form（複数のクラス）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <Foo|Bar> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
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
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- class_form（ネスト）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <Foo[<Bar[<Baz>]>]> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
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
        )
      )
    )
  )
  assert (actual.Equals expected == true)
  -- class_form（コンストラクタ）
  actual = ::TestValueStruct (testObj.Parse "/*- @prop <Foo <Bar> Param:<Baz>> */")
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
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
        )
      )
    )
  )
  assert (actual.Equals expected == true)

  /* docCommentBasic.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docCommentBasic.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
      ::AstNodeStruct Type:#Text Value:"要約\n    テキスト。",
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
    )
  )
  assert (actual.Equals expected == true)

  /* docCommentParamName.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docCommentParamName.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
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
    )
  )
  assert (actual.Equals expected == true)

  /* docCommentClassForm.ms */
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @".\Data\docCommentClassForm.ms")
  actual = ::TestValueStruct (testObj.Parse code)
  -- actual.Dump()
  expected = ::TestValueStruct (
    ::AstNodeStruct Type:#DocComment Value:#(
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
      )
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
