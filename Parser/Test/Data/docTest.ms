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
