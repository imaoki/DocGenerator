# DocGenerator

スクリプトファイル内のドキュメントコメントを基にHTMLファイルを生成する。

## 特徴

* 解説をMarkdownで記述可能。

* 依存ファイルの抽出と自動リンク。（ディレクトリ単位の変換でのみ有効）

* .NETクラスの自動リンク。

* TOC自動生成。（h3から開始）

* 単一ファイル、およびディレクトリ単位での変換に対応。

* スクリプトファイルのエンコーディングを指定可能。

* 任意のテンプレートファイルを指定可能。

## 使い方

既定では本スクリプトを配置したディレクトリを基準にファイルが生成される。
ここでは`C:\Script\DocGenerator`に配置した前提で進める。

### 単一ファイルを変換

```maxscript
(
  local dg = DocGeneratorStruct()
  dg.FromFile @"C:\Script\Foo\Bar.ms"
)

-- 出力先
@"C:\Script\Document\foo-bar.html"
```

### ディレクトリ単位で変換

* Script
  * Foo
    * Bar.ms
  * Hoge
    * Piyo.ms

```maxscript
(
  local dg = DocGeneratorStruct()
  dg.FromDirectory @"C:\Script" recursive:true
)

-- 出力先
@"C:\Script\Document\foo-bar.html"
@"C:\Script\Document\hoge-piyo.html"
```

### インデックス作成

```maxscript
(
  local dg = DocGeneratorStruct()
  dg.IndexFromDirectory @"C:\Script" recursive:true
)

-- 出力先
@"C:\Script\Document\index.html"
```

### 除外指定

```maxscript
(
  -- 無視するファイル
  local ignore = #(
    @"*\_*",
    @"*\test*",
    @"*\install.ms",
    @"*\uninstall.ms",
    @"*\unregister.ms"
  )
  -- `ignore`の例外指定（必ず変換する）
  local exception = #(
    @"*\TestValue\TestValue.ms"
  )

  local dg = DocGeneratorStruct()
  dg.FromDirectory @"C:\Script" recursive:true ignore:ignore exception:exception
  dg.IndexFromDirectory @"C:\Script" recursive:true ignore:ignore exception:exception
)
```

### オプション

`DocOptionsStruct`を使用してオプションの指定が可能。

```maxscript
(
  local options = DocOptionsStruct BasePath=@"..\"
  local dg = DocGeneratorStruct options
)
```

#### オプション一覧

| プロパティ          | 説明                                                                                                                                                            |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `BasePath`          | 検索の基点になるディレクトリの絶対パスまたは相対パス。既定値は`@".\"`。                                                                                         |
| `DateFormat`        | 更新日に使用する[日時書式指定文字列](https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/custom-date-and-time-format-strings)。既定値は`"yyyy-MM-dd"`。 |
| `DotNetApiBaseUrl`  | 自動リンクに使用する.NET APIブラウザのベースURL。既定値は`"https://docs.microsoft.com/ja-jp/dotnet/api/"`。                                                     |
| `DotNetApiVersion`  | 自動リンクに使用する.NET APIブラウザのバージョン。既定値は`"netframework-4.8"`。                                                                                |
| `EncodingBom`       | UTF-8エンコーディングのBOMの有無。既定値は`false`。                                                                                                             |
| `EncodingName`      | スクリプトファイルのエンコーディングの名前。既定値は`"utf-8"`                                                                                                   |
| `FileNameSeparator` | HTMLファイル名のセパレータ。既定値は`"-"`。                                                                                                                     |
| `SaveDirectoryName` | HTMLファイルの保存先ディレクトリ名。既定値は`"Document"`。                                                                                                      |
| `ShowError`         | 構文エラーをリスナーに出力する。                                                                                                                                |
| `SiteTitle`         | 全体のタイトル。既定値は`"mxsdoc"`。                                                                                                                            |
| `SiteUrl`           | インデックスページのURL。既定値は`"index.html"`。                                                                                                               |
| `TemplatePath`      | テンプレートHTMLファイルの絶対パスまたは相対パス。既定値は`@"Resource\default-template.html"`。                                                                 |

## ドキュメントコメント

下記の並びに該当するコメントがドキュメント化される。

```
開始記号が`/*-`のブロックコメント
予約キーワード（0個以上）
変数名
```

### 最小パターン

```maxscript
/*-コメント*/
var
```

### 様々なパターン

```maxscript
/*-
構造体。
@var <ClassName> 変数。
@prop <ClassName> プロパティ。
@prop <ClassName>
@param param <ClassName> 位置パラメータ。
@returns <OkClass> 戻り値。
@remarks 補足説明。
*/
struct TestStruct (
  /*- プロパティ。 */
  public TestProperty,

  /*-
  メソッドA。
  @param positional <ClassName> 位置パラメータ。
  @param &referenceParam <ClassName> 参照パラメータ。
  @param keywordParam: <ClassName> キーワードパラメータ。
  @param &keywordReferenceParam: <ClassName> キーワード参照パラメータ。
  @param &'quoted name': <ClassName> 引用符で囲まれた名前。
  */
  public fn TestMethod_A = (
    /*-
    ローカル関数
    */
    fn localFunction = ()

    /*- ローカル変数 */
    local localVariable

    -- グローバル変数
    ::FooStruct
    ::foo
    ::bar
  ),

  /*-
  メソッドB。
  @prop <Foo> 基本。
  @prop <Foo.Bar> プロパティまたは名前空間。
  @prop <Foo:Bar> 定義。
  @prop <Foo:Bar.Baz.Hoge> 定義とプロパティ。
  @prop <Foo|Bar> 複数のクラス。
  @prop <Foo[<Bar[<Baz>]>]> ネスト。
  @prop <Foo <Bar> Param:<Baz>> コンストラクタ。
  @prop <Struct:FooStruct> 依存リンク。
  */
  public fn TestMethod_B = (),

  /*-
  メソッドC。
  @param param1 <Integer> 位置パラメータ。
  @param param2 <Name> 位置パラメータ。
  @param &param3 <String> 参照パラメータ。
  @param param4: <Array[<DataPair Name:<String> Value:<Any>>]> キーワードパラメータ。

  `Name`
  : 名前。

  `Value`
  : 値。

    ```maxscript
    getHashValue "Hello World" 17
    ```
  @param &param5: <Name> キーワード参照パラメータ。

  | 値     | 説明 |
  | ------ | ---- |
  | `#Foo` | ほげ |
  | `#Bar` | ぴよ |
  @returns <OkClass> 戻り値。
  @remarks 補足説明。
  */
  public fn TestMethod_C = (),

  on Create do ()
)
```

#### 変換後のHTMLコード

```html
<div class="table-of-contents"><ul><li><a href="#teststruct">TestStruct</a><ul><li><a href="#testproperty">TestProperty</a></li><li><a href="#testmethod_a">TestMethod_A</a><ul><li><a href="#localfunction">localFunction</a></li><li><a href="#localvariable">localVariable</a></li></ul></li><li><a href="#testmethod_b">TestMethod_B</a></li><li><a href="#testmethod_c">TestMethod_C</a></li></ul></li></ul></div>
<dl><dt>依存</dt><dd><ul>
<li><code><a href="b.html">bar</a></code></li>
<li><code><a href="b.html">BarStruct</a></code></li>
<li><code><a href="a.html">foo</a></code></li>
<li><code>FooStruct</code><ul>
<li><a href="a.html">\A.ms</a></li>
<li><a href="c.html">\C.ms</a></li>
</ul></li>
</ul></dd></dl>
<h3 id="teststruct">struct&nbsp;TestStruct</h3>
<p>構造体。</p><dl>
<dt>変数</dt>
<dd><code>&lt;ClassName&gt;</code></dd>
<dd><p>変数。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;ClassName&gt;</code></dd>
<dd><p>プロパティ。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;ClassName&gt;</code></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>param</code></dd>
<dd><code>&lt;ClassName&gt;</code></dd>
<dd><p>位置パラメータ。</p></dd>
</dl>
<dl>
<dt>戻り値</dt>
<dd><code>&lt;OkClass&gt;</code></dd>
<dd><p>戻り値。</p></dd>
</dl>
<dl>
<dt>補足</dt>
<dd><p>補足説明。</p></dd>
</dl>
<h4 id="testproperty">public&nbsp;TestProperty</h4>
<p>プロパティ。</p><h4 id="testmethod_a">public&nbsp;fn&nbsp;TestMethod_A</h4>
<p>メソッドA。</p><dl>
<dt>パラメータ</dt>
<dd><code>positional</code></dd>
<dd><code>&lt;ClassName&gt;</code></dd>
<dd><p>位置パラメータ。</p></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>&amp;referenceParam</code></dd>
<dd><code>&lt;ClassName&gt;</code></dd>
<dd><p>参照パラメータ。</p></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>keywordParam:</code></dd>
<dd><code>&lt;ClassName&gt;</code></dd>
<dd><p>キーワードパラメータ。</p></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>&amp;keywordReferenceParam:</code></dd>
<dd><code>&lt;ClassName&gt;</code></dd>
<dd><p>キーワード参照パラメータ。</p></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>&amp;'quoted&nbsp;name':</code></dd>
<dd><code>&lt;ClassName&gt;</code></dd>
<dd><p>引用符で囲まれた名前。</p></dd>
</dl>
<h5 id="localfunction">fn&nbsp;localFunction</h5>
<p>ローカル関数</p><h5 id="localvariable">local&nbsp;localVariable</h5>
<p>ローカル変数</p><h4 id="testmethod_b">public&nbsp;fn&nbsp;TestMethod_B</h4>
<p>メソッドB。</p><dl>
<dt>プロパティ</dt>
<dd><code>&lt;Foo&gt;</code></dd>
<dd><p>基本。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;Foo.Bar&gt;</code></dd>
<dd><p>プロパティまたは名前空間。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;Foo:Bar&gt;</code></dd>
<dd><p>定義。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;Foo:Bar.Baz.Hoge&gt;</code></dd>
<dd><p>定義とプロパティ。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;Foo|Bar&gt;</code></dd>
<dd><p>複数のクラス。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;Foo[&lt;Bar[&lt;Baz&gt;]&gt;]&gt;</code></dd>
<dd><p>ネスト。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;Foo&nbsp;&lt;Bar&gt;&nbsp;Param:&lt;Baz&gt;&gt;</code></dd>
<dd><p>コンストラクタ。</p></dd>
</dl>
<dl>
<dt>プロパティ</dt>
<dd><code>&lt;Struct:FooStruct&gt;</code></dd>
<dd><p>依存リンク。</p></dd>
</dl>
<h4 id="testmethod_c">public&nbsp;fn&nbsp;TestMethod_C</h4>
<p>メソッドC。</p><dl>
<dt>パラメータ</dt>
<dd><code>param1</code></dd>
<dd><code>&lt;Integer&gt;</code></dd>
<dd><p>位置パラメータ。</p></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>param2</code></dd>
<dd><code>&lt;Name&gt;</code></dd>
<dd><p>位置パラメータ。</p></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>&amp;param3</code></dd>
<dd><code>&lt;String&gt;</code></dd>
<dd><p>参照パラメータ。</p></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>param4:</code></dd>
<dd><code>&lt;Array[&lt;DataPair&nbsp;Name:&lt;String&gt;&nbsp;Value:&lt;Any&gt;&gt;]&gt;</code></dd>
<dd><p>キーワードパラメータ。</p>
<dl>
<dt><code>Name</code></dt>
<dd>名前。</dd>
<dt><code>Value</code></dt>
<dd>
<p>値。</p>
<pre><code class="language-maxscript">getHashValue &quot;Hello World&quot; 17
</code></pre>
</dd>
</dl></dd>
</dl>
<dl>
<dt>パラメータ</dt>
<dd><code>&amp;param5:</code></dd>
<dd><code>&lt;Name&gt;</code></dd>
<dd><p>キーワード参照パラメータ。</p>
<table>
<thead>
<tr>
<th>値</th>
<th>説明</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>#Foo</code></td>
<td>ほげ</td>
</tr>
<tr>
<td><code>#Bar</code></td>
<td>ぴよ</td>
</tr>
</tbody>
</table></dd>
</dl>
<dl>
<dt>戻り値</dt>
<dd><code>&lt;OkClass&gt;</code></dd>
<dd><p>戻り値。</p></dd>
</dl>
<dl>
<dt>補足</dt>
<dd><p>補足説明。</p></dd>
</dl>
```

### ドキュメントコメントの構成要素

#### テキスト

* コメントの冒頭、またはタグの末尾にあるMarkdownテキスト。

* [CommonMark](https://commonmark.org/)準拠。

* パイプテーブル、定義リストが使用可能。

#### タグ

以下の種類のタグが使用可能。

| タグ       | 用途                         |
| ---------- | ---------------------------- |
| `@var`     | グローバル変数やローカル変数 |
| `@prop`    | 構造体プロパティ             |
| `@param`   | 関数やメソッドの引数         |
| `@returns` | 関数やメソッドの戻り値       |
| `@remarks` | 補足説明                     |

##### 変数

```
@var <型表記> テキスト（オプション）
```

##### プロパティ

```
@prop <型表記> テキスト（オプション）
```

##### パラメータ

```
@param パラメータ名 <型表記> テキスト（オプション）
```

##### 戻り値

```
@returns <型表記> テキスト（オプション）
```

##### 補足

```
@remarks テキスト（オプション）
```

#### クラスフォーム

型を表現するための記法。`<>`で囲んで表記する。

```
<型宣言>
```

##### 複数の候補

複数の型を取りうる場合は`|`で区切って表記する。

```
-- `|`以降は0回以上の繰り返し
<型宣言|型宣言>
```

##### 型宣言の種類

| 名称           | 用途                                          |
| -------------- | --------------------------------------------- |
| コンストラクタ | `DataPair`や`Dictionary`等の複合型            |
| アクセサ       | 配列                                          |
| クラス定義     | 構造体や`DotNetClass`                         |
| クラス名       | 単一のクラス名、または`.`区切りの階層的な構造 |

###### コンストラクタ

```
-- 位置パラメータ（1回以上の繰り返し）
<変数名 <型表記>>

-- キーワードパラメータ（1回以上の繰り返し）
<変数名 パラメータ名:<型表記>>
```

###### アクセサ

```
<Array[<型表記>]>
```

###### クラス定義

```
<変数名:クラス名>
```

| 型の種類                     | 変数名                     |
| ---------------------------- | -------------------------- |
| 構造体定義                   | `<StructDef:クラス名>`     |
| 構造体インスタンス           | `<Struct:クラス名>`        |
| 型が不明な構造体定義         | `<StructDef>`              |
| 型が不明な構造体インスタンス | `<Struct>`                 |
| 参照値                       | `<ValueRef:クラス名>`      |
| `DotNetClass`                | `<DotNetClass:クラス名>`   |
| `DotNetControl`              | `<DotNetControl:クラス名>` |
| `DotNetObject`               | `<DotNetObject:クラス名>`  |

###### クラス名

```
-- `.`以降は0回以上の繰り返し
<変数名.変数名>
```

不特定の型を取りうる場合は`Any`を使用する。
