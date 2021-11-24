/*- @var <ClassName> 変数。 */
global sampleVar

/*-
構造体。
@remarks 補足説明。
*/
struct SampleStruct (
  /*- @prop <Number> 数値。既定値は`0`。 */
  public Num = 0,
  /*- @prop <String> 文字列。既定値は`""`。 */
  private str = "",

  /*- @prop <DotNetClass:System.Text.RegularExpressions.Regex> */
  private regexClass = DotNetClass "System.Text.RegularExpressions.Regex",

  /*-
  パブリックメソッド。
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
  public fn PublicMethod param1 param2 &param3 param4:#() &param5: = (
    /*- @var <Float> ローカル変数。 */
    local i
    (
      ok
    )
    ok
  ),

  /*-
  プライベートメソッド。
  @returns <OkClass>
  */
  private fn privateMethod = (
    ok
  ),

  on Create do ()
)
