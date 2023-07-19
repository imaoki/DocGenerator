# DocGenerator

<!-- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/imaoki/DocGenerator)](https://github.com/imaoki/DocGenerator/releases/latest) -->
[![GitHub](https://img.shields.io/github/license/imaoki/DocGenerator)](https://github.com/imaoki/DocGenerator/blob/main/LICENSE)

スクリプトファイル内のドキュメントコメントを基にHTMLファイルを生成する。
<!-- Generate HTML files based on documentation comments in script files. -->

## 特徴
<!-- ## Features -->

* 解説をMarkdownで記述可能。
  <!-- * Explanations can be written in Markdown. -->

* 依存ファイルの抽出と自動リンク。[^1]
  <!-- * Extraction and automatic linking of dependent files.[^1] -->

* .NETクラスの自動リンク。[^2]
  <!-- * Automatic linking of .NET classes.[^2] -->

* TOC自動生成。（h3から開始）
  <!-- * Automatic TOC generation. (start at h3) -->

* 単一ファイル、およびディレクトリ単位での変換に対応。
  <!-- * Supports conversion of single files and directory units. -->

* スクリプトファイルのエンコーディングを指定可能。
  <!-- * The encoding of the script file can be specified. -->

* 任意のテンプレートファイルを指定可能。
  <!-- * Any template file can be specified. -->

[^1]:ディレクトリ単位の変換でのみ有効。
  <!-- [^1]:Valid only for per-directory conversions. -->

[^2]:現状自動リンクされるのは依存している変数のみで直接依存していない変数はリンクされない。
<!-- [^2]:Currently, only dependent variables are automatically linked, and variables that are not directly dependent are not linked. -->

## ライセンス
<!-- ## License -->

[MIT License](https://github.com/imaoki/DocGenerator/blob/main/LICENSE)

## 要件
<!-- ## Requirements -->

* [imaoki/Markdown](https://github.com/imaoki/Markdown)

* [imaoki/ParserCombinator](https://github.com/imaoki/ParserCombinator)

* [imaoki/Standard](https://github.com/imaoki/Standard)

## 開発環境
<!-- ## Development Environment -->

`3ds Max 2024`

## スクリプトを実行する
<!-- ## Running Scripts -->

01. 依存スクリプトは予めインストールしておく。
    <!-- 01. Dependent scripts should be installed beforehand. -->

02. （任意）`DocOptions.ms`を実行する。
    <!-- 02. (Optional) Run `DocOptions.ms`. -->

03. `DocGenerator.ms`を実行する。
    <!-- 03. Run `DocGenerator.ms`. -->

## 単一ファイル版
<!-- ## Single File Version -->

### スクリプトを実行する
<!-- ### Running Scripts -->

01. 依存スクリプトは予めインストールしておく。
    <!-- 01. Dependent scripts should be installed beforehand. -->

02. `Distribution\DocGenerator.min.ms`を実行する。
    <!-- 02. Execute `Distribution\DocGenerator.min.ms`. -->
    `Distribution\Template`ディレクトリは`DocGenerator.min.ms`と同じディレクトリに配置する。
    <!-- Place the `Distribution\Template` directory in the same directory as the `DocGenerator.min.ms` directory. -->

## 例
<!-- ## Examples -->

[mxsdoc](https://imaoki.github.io/mxskb/mxsdoc/)

## 使い方
<!-- ## Usage -->

ここでは以下のディレクトリ構造を前提とする。
<!-- The following directory structure is assumed here. -->

* Script

  * DocGenerator

  * Foo

    * Bar.ms

  * Hoge

    * Piyo.ms

既定では`DocGenerator`ディレクトリを配置したディレクトリを基準とした相対パスがファイル名になる。
<!-- By default, the file name is relative to the directory where the `DocGenerator` directory is located. -->

### 単一ファイルを変換
<!-- ### Convert single file -->

<!-- ```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.FromFile @"C:\Script\Foo\Bar.ms"
)

-- output destination
-- @"C:\Script\Document\foo-bar.html"
``` -->

```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.FromFile @"C:\Script\Foo\Bar.ms"
)

-- 出力先
-- @"C:\Script\Document\foo-bar.html"
```

### ディレクトリ単位で変換
<!-- ### Directory conversion -->

<!-- ```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.FromDirectory @"C:\Script" recursive:true ignore:#(@"*\DocGenerator\*")
)

-- output destination
-- @"C:\Script\Document\foo-bar.html"
-- @"C:\Script\Document\hoge-piyo.html"
``` -->

```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.FromDirectory @"C:\Script" recursive:true ignore:#(@"*\DocGenerator\*")
)

-- 出力先
-- @"C:\Script\Document\foo-bar.html"
-- @"C:\Script\Document\hoge-piyo.html"
```

### インデックスファイルを作成
<!-- ### Create index file -->

<!-- ```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.IndexFromDirectory @"C:\Script" recursive:true ignore:#(@"*\DocGenerator\*")
)

-- output destination
-- @"C:\Script\Document\index.html"
``` -->

```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.IndexFromDirectory @"C:\Script" recursive:true ignore:#(@"*\DocGenerator\*")
)

-- 出力先
-- @"C:\Script\Document\index.html"
```

### 除外指定
<!-- ### Exclusion -->

<!-- ```maxscript
(
  -- Files to ignore
  local ignore = #(
    @"*\_*",
    @"*\test*",
    @"*\install.ms",
    @"*\uninstall.ms"
  )
  -- Exception specification for `ignore` (must be converted)
  local exception = #(
    @"*\TestValue\TestValue.ms"
  )

  local dg = ::DocGeneratorStruct()
  dg.FromDirectory @"C:\Script" recursive:true ignore:ignore exception:exception
  dg.IndexFromDirectory @"C:\Script" recursive:true ignore:ignore exception:exception
)
``` -->

```maxscript
(
  -- Files to ignore
  local ignore = #(
    @"*\_*",
    @"*\test*",
    @"*\install.ms",
    @"*\uninstall.ms"
  )
  -- `ignore`の例外指定（例外の例外）
  local exception = #(
    @"*\TestValue\TestValue.ms"
  )

  local dg = ::DocGeneratorStruct()
  dg.FromDirectory @"C:\Script" recursive:true ignore:ignore exception:exception
  dg.IndexFromDirectory @"C:\Script" recursive:true ignore:ignore exception:exception
)
```

### オプション
<!-- ### Options -->

`DocOptionsStruct`を使用してオプションの指定が可能。
<!-- Options can be specified using `DocOptionsStruct`. -->

```maxscript
(
  local options = ::DocOptionsStruct BasePath:@"..\..\"
  local dg = ::DocGeneratorStruct options
)
```

詳細は[mxsdoc.DocOptions.ms](https://imaoki.github.io/mxskb/mxsdoc/docgenerator-docoptions.html)を参照。
<!-- See [mxsdoc.DocOptions.ms](https://imaoki.github.io/mxskb/mxsdoc/docgenerator-docoptions.html) for details. -->

## 既知の問題
<!-- ## Known Issues -->

* インデックスファイル作成の際に`BasePath`より上のディレクトリを指定した場合、ファイル名の変換処理が正しく行えずにエラーになる。
  <!-- * If a directory higher than `BasePath` is specified when creating an index file, the file name conversion process will not work correctly and an error will occur. -->

## ドキュメントコメントの構文
<!-- ## Syntax of documentation comments -->

下記の並びで記述されたコメントがドキュメント化される。
<!-- Comments written in the following sequence will be documented. -->

01. 開始記号が"/*-"のコメント
    <!-- 01. Comments with "/*-" as a start sign -->

02. 予約キーワード（0個以上）
    <!-- 02. Reserved keywords (0 or more) -->

03. 変数名
    <!-- 03. Variable name -->

### 最小パターン
<!-- ### Minimum pattern -->

```maxscript
/*-Comment*/
var
```

### 様々なパターン
<!-- ### Various patterns -->

* `Parser\Test\Data\docCommentExample.ms`

* `Parser\Test\Data\docExample.ms`

### ドキュメントコメントの構成要素
<!-- ### Components of documentation comments -->

#### テキスト
<!-- #### Text -->

* コメントの冒頭、またはタグの末尾にあるMarkdownテキスト。
  <!-- * Markdown text at the beginning of a comment or at the end of a tag. -->

* [CommonMark](https://commonmark.org/)準拠。
  <!-- * [CommonMark](https://commonmark.org/) compliant. -->

* パイプテーブル、定義リストが使用可能。
  <!-- * Pipe tables and definition lists are available. -->

#### タグ
<!-- #### Tag -->

以下の種類のタグが使用可能。
<!-- The following types of tags are available -->

<!-- | Tag        | Use                       | -->
<!-- | ---------- | ------------------------- | -->
<!-- | `@var`     | Variable                  | -->
<!-- | `@prop`    | Structure property        | -->
<!-- | `@param`   | Function parameters       | -->
<!-- | `@returns` | Return value of function  | -->
<!-- | `@remarks` | Supplementary explanation | -->

| タグ       | 用途             |
| ---------- | ---------------- |
| `@var`     | 変数             |
| `@prop`    | 構造体プロパティ |
| `@param`   | 関数パラメータ   |
| `@returns` | 関数戻り値       |
| `@remarks` | 補足説明         |

##### 変数
<!-- ##### Variable -->

```
@var <ClassForm> Text(Optional)
```

##### プロパティ
<!-- ##### Property -->

```
@prop <ClassForm> Text(Optional)
```

##### パラメータ
<!-- ##### Parameter -->

```
@param ParameterName <ClassForm> Text(Optional)
```

##### 戻り値
<!-- ##### Return value -->

```
@returns <ClassForm> Text(Optional)
```

##### 補足情報
<!-- ##### Supplementary information -->

```
@remarks Text(Optional)
```

#### クラス形式
<!-- #### ClassForm -->

型を表現するための記法。`<>`で囲んで表記する。
<!-- Notation for expressing types. The notation is enclosed in `<>`. -->

```
<ClassCeclaration>
```

##### 複数の候補
<!-- ##### Multiple candidates -->

複数の型を取りうる場合は`|`で区切って表記する。
<!-- If the type can be more than one, separate them with `|`. -->

```
<ClassCeclaration|ClassCeclaration>
```

##### クラス宣言の種類
<!-- ##### ClassDeclaration types -->

<!-- | Name            | Use                                                          | -->
<!-- | --------------- | ------------------------------------------------------------ | -->
<!-- | Constructor     | Composite types such as `DataPair` and `Dictionary`          | -->
<!-- | Accessor        | Array                                                        | -->
<!-- | ClassDefinition | Structure or `DotNetClass`                                   | -->
<!-- | ClassName       | Single class name or hierarchical structure separated by `.` | -->

| 名前           | 用途                                        |
| -------------- | ------------------------------------------- |
| コンストラクタ | `DataPair`や`Dictionary`などの複合型        |
| アクセサ       | 配列                                        |
| クラス定義     | 構造体または`DotNetClass`                   |
| クラス名       | 単一のクラス名または`.`で区切られた階層構造 |

###### コンストラクタ
<!-- ###### Constructor -->

* 位置パラメーター（1回以上の繰り返し）
  <!-- * Positional parameter (one or more repetitions) -->

  ```
  <VariableName <ClassForm>>
  ```

* キーワードパラメータ（1回以上の繰り返し）
  <!-- * Keyword parameter (one or more repetitions) -->

  ```
  <VariableName ParameterName:<ClassForm>>
  ```

###### アクセサ
<!-- ###### Accessor -->

```
<Array[<ClassForm>]>
```

###### クラス定義
<!-- ###### ClassDefinition -->

```
<VariableName:ClassName>
```

<!-- | Type                                 | VariableName                | -->
<!-- | ------------------------------------ | --------------------------- | -->
<!-- | Structure definition                 | `<StructDef:ClassName>`     | -->
<!-- | Structure instance                   | `<Struct:ClassName>`        | -->
<!-- | Structure definition of unknown type | `<StructDef>`               | -->
<!-- | Structure instance of unknown type   | `<Struct>`                  | -->
<!-- | Attribute definition                 | `<AttributeDef:ClassName>`  | -->
<!-- | Attribute instance                   | `<Attribute:ClassName>`     | -->
<!-- | Attribute definition of unknown type | `<AttributeDef>`            | -->
<!-- | Attribute instance of unknown type   | `<Attribute>`               | -->
<!-- | Reference value                      | `<ValueRef:ClassName>`      | -->
<!-- | `DotNetClass`                        | `<DotNetClass:ClassName>`   | -->
<!-- | `DotNetControl`                      | `<DotNetControl:ClassName>` | -->
<!-- | `DotNetObject`                       | `<DotNetObject:ClassName>`  | -->

| 種類                                   | 表記                        |
| -------------------------------------- | --------------------------- |
| 構造体定義                             | `<StructDef:ClassName>`     |
| 構造体インスタンス                     | `<Struct:ClassName>`        |
| 構造体定義 of 未知の型                 | `<StructDef>`               |
| 構造体インスタンス of 未知の型         | `<Struct>`                  |
| アトリビュート定義                     | `<AttributeDef:ClassName>`  |
| アトリビュートインスタンス             | `<Attribute:ClassName>`     |
| アトリビュート定義 of 未知の型         | `<AttributeDef>`            |
| アトリビュートインスタンス of 未知の型 | `<Attribute>`               |
| 参照値                                 | `<ValueRef:ClassName>`      |
| `DotNetClass`                          | `<DotNetClass:ClassName>`   |
| `DotNetControl`                        | `<DotNetControl:ClassName>` |
| `DotNetObject`                         | `<DotNetObject:ClassName>`  |

###### クラス名
<!-- ###### ClassName -->

<!-- ```
-- After `.`, zero or more repetitions
<VariableName.VariableName>
``` -->

```
-- `.`の後、0回以上の繰り返し
<VariableName.VariableName>
```

不特定の型を取りうる場合は`Any`を使用する。
<!-- Use `Any` if the type can be unspecified. -->
