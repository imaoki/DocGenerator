# DocGenerator

<!-- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/imaoki/DocGenerator)](https://github.com/imaoki/DocGenerator/releases/latest) -->
[![GitHub](https://img.shields.io/github/license/imaoki/DocGenerator)](https://github.com/imaoki/DocGenerator/blob/main/LICENSE)

Generate HTML files based on documentation comments in script files.
<!-- スクリプトファイル内のドキュメントコメントを基にHTMLファイルを生成する。 -->

## Features
<!-- 特徴 -->

* Explanations can be written in Markdown.
  <!-- 解説をMarkdownで記述可能。 -->

* Extraction and automatic linking of dependent files.[^1]
  <!-- 依存ファイルの抽出と自動リンク。 -->

* Automatic linking of .NET classes.[^2]
  <!-- .NETクラスの自動リンク。 -->

* Automatic TOC generation. (start at h3)
  <!-- TOC自動生成。（h3から開始） -->

* Supports conversion of single files and directory units.
  <!-- 単一ファイル、およびディレクトリ単位での変換に対応。 -->

* The encoding of the script file can be specified.
  <!-- スクリプトファイルのエンコーディングを指定可能。 -->

* Any template file can be specified.
  <!-- 任意のテンプレートファイルを指定可能。 -->

[^1]: Valid only for per-directory conversions.
<!-- ディレクトリ単位の変換でのみ有効。 -->

[^2]: Currently, only dependent variables are automatically linked, and variables that are not directly dependent are not linked.
<!-- 現状自動リンクされるのは依存している変数のみで直接依存していない変数はリンクされない。 -->

## Examples
<!-- 例 -->

[mxsdoc](https://imaoki.github.io/mxskb/mxsdoc/)

## Requirements
<!-- 要件 -->

* [imaoki/Markdown](https://github.com/imaoki/Markdown)

* [imaoki/ParserCombinator](https://github.com/imaoki/ParserCombinator)

* [imaoki/Standard](https://github.com/imaoki/Standard)

## Development Environment
<!-- 開発環境 -->

`2022.3 Update`

## Running Scripts
<!-- スクリプトを実行する -->

01. Dependent scripts should be installed beforehand.
    <!-- 依存スクリプトは予めインストールしておく。 -->

02. (Optional) Run `DocOptions.ms`.
    <!-- （任意）`DocOptions.ms`を実行する。 -->

03. Run `DocGenerator.ms`.
    <!-- `DocGenerator.ms`を実行する。 -->

## Standalone version
<!-- スタンドアローン版 -->

### Running Scripts
<!-- スクリプトを実行する -->

01. Dependent scripts should be installed beforehand.
    <!-- 依存スクリプトは予めインストールしておく。 -->

02. Execute `Distribution\DocGenerator.min.ms`.
    <!-- `Distribution\DocGenerator.min.ms`を実行する。 -->

    Place the `Distribution\Template` directory in the same directory as the `DocGenerator.min.ms` directory.
    <!-- `Distribution\Template`ディレクトリは`DocGenerator.min.ms`と同じディレクトリに配置する。 -->

## Usage
<!-- 使い方 -->

The following directory structure is assumed here.
<!-- ここでは以下のディレクトリ構造を前提とする。 -->

* Script

  * DocGenerator

  * Foo

    * Bar.ms

  * Hoge

    * Piyo.ms

By default, the file name is relative to the directory where the `DocGenerator` directory is located.
<!-- 既定では`DocGenerator`ディレクトリを配置したディレクトリを基準とした相対パスがファイル名になる。 -->

### Convert single file
<!-- 単一ファイルを変換 -->

```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.FromFile @"C:\Script\Foo\Bar.ms"
)

-- output destination
-- @"C:\Script\Document\foo-bar.html"
```

### Directory conversion
<!-- ディレクトリ単位で変換 -->

```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.FromDirectory @"C:\Script" recursive:true ignore:#(@"*\DocGenerator\*")
)

-- output destination
-- @"C:\Script\Document\foo-bar.html"
-- @"C:\Script\Document\hoge-piyo.html"
```

### Create index file
<!-- インデックスファイルを作成 -->

```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.IndexFromDirectory @"C:\Script" recursive:true ignore:#(@"*\DocGenerator\*")
)

-- output destination
-- @"C:\Script\Document\index.html"
```

### Exclusion
<!-- 除外指定 -->

```maxscript
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
```

### Options

Options can be specified using `DocOptionsStruct`.
<!-- `DocOptionsStruct`を使用してオプションの指定が可能。 -->

```maxscript
(
  local options = ::DocOptionsStruct BasePath:@"..\..\"
  local dg = ::DocGeneratorStruct options
)
```

See [mxsdoc.DocOptions.ms](https://imaoki.github.io/mxskb/mxsdoc/docgenerator-docoptions.html) for details.
<!-- 詳細は[mxsdoc.DocOptions.ms](https://imaoki.github.io/mxskb/mxsdoc/docgenerator-docoptions.html)を参照。 -->

## Known Issues
<!-- 既知の問題 -->

* If a directory higher than `BasePath` is specified when creating an index file, the file name conversion process will not work correctly and an error will occur.
  <!-- インデックスファイル作成の際に`BasePath`より上のディレクトリを指定した場合、ファイル名の変換処理が正しく行えずにエラーになる。 -->

## Syntax of documentation comments
<!-- ドキュメントコメントの構文 -->

Comments written in the following sequence will be documented.
<!-- 下記の並びで記述されたコメントがドキュメント化される。 -->

01. Comments with "/*-" as a start sign
    <!-- 開始記号が"/*-"のコメント -->

02. Reserved keywords (0 or more)
    <!-- 予約キーワード（0個以上） -->

03. Variable name
    <!-- 変数名 -->

### Minimum pattern
<!-- 最小パターン -->

```maxscript
/*-Comment*/
var
```

### Various patterns
<!-- 様々なパターン -->

* `Parser\Test\Data\docCommentExample.ms`

* `Parser\Test\Data\docExample.ms`

### Components of documentation comments
<!-- ドキュメントコメントの構成要素 -->

#### Text
<!-- テキスト -->

* Markdown text at the beginning of a comment or at the end of a tag.
  <!-- コメントの冒頭、またはタグの末尾にあるMarkdownテキスト。 -->

* [CommonMark](https://commonmark.org/) compliant.
  <!-- [CommonMark](https://commonmark.org/)準拠。 -->

* Pipe tables and definition lists are available.
  <!-- パイプテーブル、定義リストが使用可能。 -->

#### Tag
<!-- タグ -->

The following types of tags are available
<!-- 以下の種類のタグが使用可能。 -->

| Tag        | Use                       |
| ---------- | ------------------------- |
| `@var`     | Variable                  |
| `@prop`    | Structure property        |
| `@param`   | Function parameters       |
| `@returns` | Return value of function  |
| `@remarks` | Supplementary explanation |

##### Variable
<!-- 変数 -->

```
@var <ClassForm> Text(Optional)
```

##### Property
<!-- プロパティ -->

```
@prop <ClassForm> Text(Optional)
```

##### Parameter
<!-- パラメータ -->

```
@param ParameterName <ClassForm> Text(Optional)
```

##### Return value
<!-- 戻り値 -->

```
@returns <ClassForm> Text(Optional)
```

##### Supplementary information
<!-- 補足情報 -->

```
@remarks Text(Optional)
```

#### ClassForm
<!-- クラス形式 -->

Notation for expressing types. The notation is enclosed in `<>`.
<!-- 型を表現するための記法。`<>`で囲んで表記する。 -->

```
<ClassCeclaration>
```

##### Multiple candidates
<!-- 複数の候補 -->

If the type can be more than one, separate them with `|`.
<!-- 複数の型を取りうる場合は`|`で区切って表記する。 -->

```
<ClassCeclaration|ClassCeclaration>
```

##### ClassDeclaration types
<!-- クラス宣言の種類 -->

| Name            | Use                                                          |
| --------------- | ------------------------------------------------------------ |
| Constructor     | Composite types such as `DataPair` and `Dictionary           |
| Accessor        | Array                                                        |
| ClassDefinition | Structure or `DotNetClass`                                   |
| ClassName       | Single class name or hierarchical structure separated by `.` |

###### Constructor

* Positional parameter (one or more repetitions)

  ```
  <VariableName <ClassForm>>
  ```

* Keyword parameter (one or more repetitions)

  ```
  <VariableName ParameterName:<ClassForm>>
  ```

###### Accessor

```
<Array[<ClassForm>]>
```

###### ClassDefinition

```
<VariableName:ClassName>
```

| Type                                 | VariableName                |
| ------------------------------------ | --------------------------- |
| Structure definition                 | `<StructDef:ClassName>`     |
| Structure instance                   | `<Struct:ClassName>`        |
| Structure definition of unknown type | `<StructDef>`               |
| Structure instance of unknown type   | `<Struct>`                  |
| Attribute definition                 | `<AttributeDef:ClassName>`  |
| Attribute instance                   | `<Attribute:ClassName>`     |
| Attribute definition of unknown type | `<AttributeDef>`            |
| Attribute instance of unknown type   | `<Attribute>`               |
| Reference value                      | `<ValueRef:ClassName>`      |
| `DotNetClass`                        | `<DotNetClass:ClassName>`   |
| `DotNetControl`                      | `<DotNetControl:ClassName>` |
| `DotNetObject`                       | `<DotNetObject:ClassName>`  |

###### ClassName

```
-- After `.`, zero or more repetitions
<VariableName.VariableName>
```

Use `Any` if the type can be unspecified.
<!-- 不特定の型を取りうる場合は`Any`を使用する。 -->

## License
<!-- ライセンス -->

[MIT License](https://github.com/imaoki/DocGenerator/blob/main/LICENSE)
