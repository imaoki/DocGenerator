# DocGenerator

<!-- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/imaoki/DocGenerator)](https://github.com/imaoki/DocGenerator/releases/latest) -->
[![GitHub](https://img.shields.io/github/license/imaoki/DocGenerator)](https://github.com/imaoki/DocGenerator/blob/main/LICENSE)

MAXScriptのドキュメントコメントを基にHTMLファイルを生成する。

## 特徴

* 解説をMarkdownで記述可能。

* 依存ファイルの抽出と自動リンク。[^1]

* .NETクラスの自動リンク。[^2]

* TOC自動生成。（h3から開始）

* 単一ファイル、およびディレクトリ単位での変換に対応。

* スクリプトファイルのエンコーディングを指定可能。

* 任意のテンプレートファイルを指定可能。

[^1]:ディレクトリ単位の変換でのみ有効。

[^2]:現状自動リンクされるのは依存している変数のみで直接依存していない変数はリンクされない。

## ライセンス

[MIT License](https://github.com/imaoki/DocGenerator/blob/main/LICENSE)

## 要件

* [imaoki/Markdown](https://github.com/imaoki/Markdown)

* [imaoki/ParserCombinator](https://github.com/imaoki/ParserCombinator)

* [imaoki/Standard](https://github.com/imaoki/Standard)

* （任意）[imaoki/StartupLoader](https://github.com/imaoki/StartupLoader)
  導入済みの場合はインストール/アンインストールでスタートアップスクリプトの登録/解除が行われる。
  未使用の場合はスクリプトの評価のみ行われる。

## 開発環境

`3ds Max 2024`

## スクリプトを実行する

01. 依存スクリプトは予めインストールしておく。

02. （任意）`DocOptions.ms`を実行する。

03. `DocGenerator.ms`を実行する。

## 単一ファイル版

### スクリプトを実行する

01. 依存スクリプトは予めインストールしておく。

02. `Distribution\DocGenerator.min.ms`を実行する。
    `Distribution\Template`ディレクトリは`DocGenerator.min.ms`と同じディレクトリに配置する。

## 例

[mxsdoc](https://imaoki.github.io/kb/mxsdoc/)

## 使い方

ここでは以下のディレクトリ構造を前提とする。

* Script

  * DocGenerator

  * Foo

    * Bar.ms

  * Hoge

    * Piyo.ms

既定では`DocGenerator`ディレクトリを配置したディレクトリを基準とした相対パスがファイル名になる。

### 単一ファイルを変換

```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.FromFile @"C:\Script\Foo\Bar.ms"
)

-- 出力先
-- @"C:\Script\Document\foo-bar.html"
```

### ディレクトリ単位で変換

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

```maxscript
(
  local dg = ::DocGeneratorStruct()
  dg.IndexFromDirectory @"C:\Script" recursive:true ignore:#(@"*\DocGenerator\*")
)

-- 出力先
-- @"C:\Script\Document\index.html"
```

### 除外指定

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

`DocOptionsStruct`を使用してオプションの指定が可能。

```maxscript
(
  local options = ::DocOptionsStruct BasePath:@"..\..\"
  local dg = ::DocGeneratorStruct options
)
```

詳細は[mxsdoc.DocOptions.ms](https://imaoki.github.io/kb/mxsdoc/docgenerator-docoptions.html)を参照。

## 既知の問題

* インデックスファイル作成の際に`BasePath`より上のディレクトリを指定した場合、ファイル名の変換処理が正しく行えずにエラーになる。

## ドキュメントコメントの構文

下記の並びで記述されたコメントがドキュメント化される。

01. 開始記号が"/*-"のコメント

02. 予約キーワード（0個以上）

03. 変数名

### 最小パターン

```maxscript
/*-Comment*/
var
```

### 様々なパターン

* `Parser\Test\Data\docCommentExample.ms`

* `Parser\Test\Data\docExample.ms`

### ドキュメントコメントの構成要素

#### テキスト

* コメントの冒頭、またはタグの末尾にあるMarkdownテキスト。

* [CommonMark](https://commonmark.org/)準拠。

* パイプテーブル、定義リストが使用可能。

#### タグ

以下の種類のタグが使用可能。

| タグ       | 用途             |
| ---------- | ---------------- |
| `@var`     | 変数             |
| `@prop`    | 構造体プロパティ |
| `@param`   | 関数パラメータ   |
| `@returns` | 関数戻り値       |
| `@remarks` | 補足説明         |

##### 変数

```
@var <ClassForm> Text(Optional)
```

##### プロパティ

```
@prop <ClassForm> Text(Optional)
```

##### パラメータ

```
@param ParameterName <ClassForm> Text(Optional)
```

##### 戻り値

```
@returns <ClassForm> Text(Optional)
```

##### 補足情報

```
@remarks Text(Optional)
```

#### クラス形式

型を表現するための記法。`<>`で囲んで表記する。

```
<ClassCeclaration>
```

##### 複数の候補

複数の型を取りうる場合は`|`で区切って表記する。

```
<ClassCeclaration|ClassCeclaration>
```

##### クラス宣言の種類

| 名前                              | 用途                                        |
| --------------------------------- | ------------------------------------------- |
| [コンストラクタ](#コンストラクタ) | `DataPair`や`Dictionary`などの複合型        |
| [アクセサ](#アクセサ)             | 配列                                        |
| [クラス定義](#クラス定義)         | 構造体または`DotNetClass`                   |
| [クラス名](#クラス名)             | 単一のクラス名または`.`で区切られた階層構造 |

###### コンストラクタ

* 位置パラメーター（1回以上の繰り返し）

  ```
  <VariableName <ClassForm>>
  ```

* キーワードパラメータ（1回以上の繰り返し）

  ```
  <VariableName ParameterName:<ClassForm>>
  ```

###### アクセサ

```
<Array[<ClassForm>]>
```

###### クラス定義

```
<VariableName:ClassName>
```

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

```
-- `.`の後、0回以上の繰り返し
<VariableName.VariableName>
```

不特定の型を取りうる場合は`Any`を使用する。
