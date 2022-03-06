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
  local templatePath = pathUtility.GetFullPath @".\Data\test-template.html"

  local docDef = fileIn (pathUtility.GetFullPath @"..\Parser\Doc.ms")
  local docDependentTableDef = fileIn (pathUtility.GetFullPath @"..\DocDependentTable.ms")
  local optionsDef = fileIn (pathUtility.GetFullPath @"..\DocOptions.ms")

  local pathA = DataPair Source:@"C:\Test\A.ms" Destination:@"C:\Test\Document\a.html"
  local pathB = DataPair Source:@"C:\Test\B.ms" Destination:@"C:\Test\Document\b.html"
  local pathC = DataPair Source:@"C:\Test\C.ms" Destination:@"C:\Test\Document\c.html"
  local pathD = DataPair Source:@"C:\Test\D.ms" Destination:@"C:\Test\Document\d.html"

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
      ::AstNodeStruct Type:#StructDecl Value:(
        ::AstNodeStruct Type:#VarName Value:"BarStruct"
      ),
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
  local astD = (
    ::AstNodeStruct Type:#DocDependent Value:#(
      ::AstNodeStruct Type:#GlobalVarName Value:"FooStruct",
      ::AstNodeStruct Type:#GlobalVarName Value:"BarStruct",
      ::AstNodeStruct Type:#GlobalVarName Value:"foo",
      ::AstNodeStruct Type:#GlobalVarName Value:"bar"
    )
  )

  local docDependentTable = docDependentTableDef()
  docDependentTable.AddDependent astA pathA
  docDependentTable.AddDependent astB pathB
  docDependentTable.AddDependent astC pathC
  docDependentTable.AddDependent astD pathD

  local dependentD = docDependentTable.GetDependent pathD

  local options = optionsDef BasePath:@"C:\Test" ShowError:false TemplatePath:templatePath
  local parser = docDef ShowError:options.ShowError

  local results = #()
  fn dumpRenderResult = (
    local hr = ::std.StringUtility.PadLeft "\n" 80 "-"
    for result in results do (
      format "%" hr
      format "%" result
    )
    format "%" hr
    ok
  )

  testDef = fileIn (pathUtility.GetFullPath @"..\DocRender.ms")
  testObj = testDef options
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Render */
  -- 空コード
  actual = ::TestValueStruct (testObj.Render (parser.Parse ""))
  -- actual.Dump()
  expected = ::TestValueStruct "mxsdoc\nindex.html\nUntitled\n\n\n"
  assert (actual.Equals expected == true)
  append results (actual.GetValue())
  -- DotNetClassまたはDotNetObjectの自動リンク
  actual = ::TestValueStruct (
    testObj.Render (parser.Parse "/*- @var <DotNetClass:System.Char|DotNetObject:System.Enum> */\nvar\n")
  )
  -- actual.Dump()
  expected = ::TestValueStruct "mxsdoc\nindex.html\nUntitled\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<h3 id=\"var\">var</h3>\n<dl>\n<dt>変数</dt>\n<dd><code>&lt;DotNetClass:<a href=\"https://docs.microsoft.com/ja-jp/dotnet/api/system.char?view=netframework-4.8\">System.Char</a>|DotNetObject:<a href=\"https://docs.microsoft.com/ja-jp/dotnet/api/system.enum?view=netframework-4.8\">System.Enum</a>&gt;</code></dd>\n</dl>\n"
  assert (actual.Equals expected == true)
  append results (actual.GetValue())
  -- グローバル変数の自動リンク
  actual = ::TestValueStruct (
    testObj.Render (parser.Parse "/*- @var <Struct:BarStruct> */\nvar\n") dependent:dependentD
  )
  -- actual.Dump()
  expected = ::TestValueStruct "mxsdoc\nindex.html\nUntitled\n<div class=\"table-of-contents\"><ul><li><a href=\"#var\">var</a></li></ul></div>\n<dl><dt>依存</dt><dd><ul>\n<li><code><a href=\"b.html\">bar</a></code></li>\n<li><code><a href=\"b.html\">BarStruct</a></code></li>\n<li><code><a href=\"a.html\">foo</a></code></li>\n<li><code>FooStruct</code><ul>\n<li><a href=\"a.html\">\\A.ms</a></li>\n<li><a href=\"c.html\">\\C.ms</a></li>\n</ul></li>\n</ul></dd></dl>\n<h3 id=\"var\">var</h3>\n<dl>\n<dt>変数</dt>\n<dd><code>&lt;Struct:<a href=\"b.html\">BarStruct</a>&gt;</code></dd>\n</dl>\n"
  assert (actual.Equals expected == true)
  append results (actual.GetValue())
  -- docTest.ms
  code = ::std.FileUtility.ReadAllText (pathUtility.GetFullPath @"..\Parser\Test\Data\docTest.ms")
  actual = ::TestValueStruct (
    testObj.Render (parser.Parse code) docTitle:"docTest" dependent:dependentD
  )
  -- actual.Dump()
  expected = ::TestValueStruct "mxsdoc\nindex.html\ndocTest\n<div class=\"table-of-contents\"><ul><li><a href=\"#teststruct\">TestStruct</a><ul><li><a href=\"#testproperty\">TestProperty</a></li><li><a href=\"#testmethod_a\">TestMethod_A</a><ul><li><a href=\"#localfunction\">localFunction</a></li><li><a href=\"#localvariable\">localVariable</a></li></ul></li><li><a href=\"#testmethod_b\">TestMethod_B</a></li><li><a href=\"#testmethod_c\">TestMethod_C</a></li></ul></li></ul></div>\n<dl><dt>依存</dt><dd><ul>\n<li><code><a href=\"b.html\">bar</a></code></li>\n<li><code><a href=\"b.html\">BarStruct</a></code></li>\n<li><code><a href=\"a.html\">foo</a></code></li>\n<li><code>FooStruct</code><ul>\n<li><a href=\"a.html\">\\A.ms</a></li>\n<li><a href=\"c.html\">\\C.ms</a></li>\n</ul></li>\n</ul></dd></dl>\n<h3 id=\"teststruct\">struct&nbsp;TestStruct</h3>\n<p>構造体。</p><dl>\n<dt>変数</dt>\n<dd><code>&lt;ClassName&gt;</code></dd>\n<dd><p>変数。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;ClassName&gt;</code></dd>\n<dd><p>プロパティ。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;ClassName&gt;</code></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>param</code></dd>\n<dd><code>&lt;ClassName&gt;</code></dd>\n<dd><p>位置パラメータ。</p></dd>\n</dl>\n<dl>\n<dt>戻り値</dt>\n<dd><code>&lt;OkClass&gt;</code></dd>\n<dd><p>戻り値。</p></dd>\n</dl>\n<dl>\n<dt>補足</dt>\n<dd><p>補足説明。</p></dd>\n</dl>\n<h4 id=\"testproperty\">public&nbsp;TestProperty</h4>\n<p>プロパティ。</p><h4 id=\"testmethod_a\">public&nbsp;fn&nbsp;TestMethod_A</h4>\n<p>メソッドA。</p><dl>\n<dt>パラメータ</dt>\n<dd><code>positional</code></dd>\n<dd><code>&lt;ClassName&gt;</code></dd>\n<dd><p>位置パラメータ。</p></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>&amp;referenceParam</code></dd>\n<dd><code>&lt;ClassName&gt;</code></dd>\n<dd><p>参照パラメータ。</p></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>keywordParam:</code></dd>\n<dd><code>&lt;ClassName&gt;</code></dd>\n<dd><p>キーワードパラメータ。</p></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>&amp;keywordReferenceParam:</code></dd>\n<dd><code>&lt;ClassName&gt;</code></dd>\n<dd><p>キーワード参照パラメータ。</p></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>&amp;'quoted&nbsp;name':</code></dd>\n<dd><code>&lt;ClassName&gt;</code></dd>\n<dd><p>引用符で囲まれた名前。</p></dd>\n</dl>\n<h5 id=\"localfunction\">fn&nbsp;localFunction</h5>\n<p>ローカル関数</p><h5 id=\"localvariable\">local&nbsp;localVariable</h5>\n<p>ローカル変数</p><h4 id=\"testmethod_b\">public&nbsp;fn&nbsp;TestMethod_B</h4>\n<p>メソッドB。</p><dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;Foo&gt;</code></dd>\n<dd><p>基本。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;Foo.Bar&gt;</code></dd>\n<dd><p>プロパティまたは名前空間。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;Foo:Bar&gt;</code></dd>\n<dd><p>定義。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;Foo:Bar.Baz.Hoge&gt;</code></dd>\n<dd><p>定義とプロパティ。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;Foo|Bar&gt;</code></dd>\n<dd><p>複数のクラス。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;Foo[&lt;Bar[&lt;Baz&gt;]&gt;]&gt;</code></dd>\n<dd><p>ネスト。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;Foo&nbsp;&lt;Bar&gt;&nbsp;Param:&lt;Baz&gt;&gt;</code></dd>\n<dd><p>コンストラクタ。</p></dd>\n</dl>\n<dl>\n<dt>プロパティ</dt>\n<dd><code>&lt;Struct:FooStruct&gt;</code></dd>\n<dd><p>依存リンク。</p></dd>\n</dl>\n<h4 id=\"testmethod_c\">public&nbsp;fn&nbsp;TestMethod_C</h4>\n<p>メソッドC。</p><dl>\n<dt>パラメータ</dt>\n<dd><code>param1</code></dd>\n<dd><code>&lt;Integer&gt;</code></dd>\n<dd><p>位置パラメータ。</p></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>param2</code></dd>\n<dd><code>&lt;Name&gt;</code></dd>\n<dd><p>位置パラメータ。</p></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>&amp;param3</code></dd>\n<dd><code>&lt;String&gt;</code></dd>\n<dd><p>参照パラメータ。</p></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>param4:</code></dd>\n<dd><code>&lt;Array[&lt;DataPair&nbsp;Name:&lt;String&gt;&nbsp;Value:&lt;Any&gt;&gt;]&gt;</code></dd>\n<dd><p>キーワードパラメータ。</p>\n<dl>\n<dt><code>Name</code></dt>\n<dd>名前。</dd>\n<dt><code>Value</code></dt>\n<dd>\n<p>値。</p>\n<pre><code class=\"language-maxscript\">getHashValue &quot;Hello World&quot; 17\n</code></pre>\n</dd>\n</dl></dd>\n</dl>\n<dl>\n<dt>パラメータ</dt>\n<dd><code>&amp;param5:</code></dd>\n<dd><code>&lt;Name&gt;</code></dd>\n<dd><p>キーワード参照パラメータ。</p>\n<table>\n<thead>\n<tr>\n<th>値</th>\n<th>説明</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td><code>#Foo</code></td>\n<td>ほげ</td>\n</tr>\n<tr>\n<td><code>#Bar</code></td>\n<td>ぴよ</td>\n</tr>\n</tbody>\n</table></dd>\n</dl>\n<dl>\n<dt>戻り値</dt>\n<dd><code>&lt;OkClass&gt;</code></dd>\n<dd><p>戻り値。</p></dd>\n</dl>\n<dl>\n<dt>補足</dt>\n<dd><p>補足説明。</p></dd>\n</dl>\n"
  assert (actual.Equals expected == true)
  append results (actual.GetValue())

  /* RenderIndex */
  actual = ::TestValueStruct (testObj.RenderIndex "<ul><li></li></ul>")
  -- actual.Dump()
  expected = ::TestValueStruct "mxsdoc\nindex.html\nIndex\n\n<ul><li></li></ul>\n"
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  -- dumpRenderResult()
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
