/*-
構造体。
*/
struct TestStruct (
  /*- プロパティ。 */
  public TestProperty,

  /*-
  メソッドA。
  */
  public fn TestMethod_A = (
    /*-
    ローカル関数
    */
    fn localFunction = ()

    /*- ローカル変数 */
    local localVariable

    -- グローバル変数宣言
    global globalVariable

    -- グローバル変数参照
    ::foo
  ),

  on Create do ()
)
