  /*-
  スクリプトから抽象構文木を生成する。
  @param code: <String> MAXScriptコード。
  @param path: <String> スクリプトファイルのパス。
  @param encoding: <String> エンコーディングの名前。既定値は`"utf-8"`。
  @param bom: <BooleanClass> BOMの有無。既定値は`false`。
  @returns <Struct:AstNodeStruct|UndefinedClass> 抽象構文木のルートノード。
  @remarks
  `code`または`path`のいずれかを指定する。
  両方指定した場合は`path`が優先される。
  */
