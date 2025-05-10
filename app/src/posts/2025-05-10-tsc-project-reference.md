---
title: typescriptのプロジェクト参照がわからない
---

怪しい理解を雑多に書きつける。

# 前段

## tsconfig と tsc

- tsconfig.json の形式は typescript の仕様として規定されるが、esbuild などの別のビルドツールもこれを利用する
  - ツールによっては意味のない設定項目もある

## tsc によるビルドの対象

```
% npx tsc --help
  tsc
  Compiles the current project (tsconfig.json in the working directory.)
```

- tsc はファイルではなく、プロジェクトに対して実行する
- tsconfig がプロジェクトを表現する

## 複数のプロジェクト

（プロジェクト参照を利用しない場合）

```
- foo/
  - tsconfig.json
  - index.ts  // common/index.tsをimportする
- bar/
  - tsconfig.json
  - index.ts  // common/index.tsをimportする
- common/
  - index.ts
```

- あるファイルに対する tsconfig が一意に定まる必要はない
  - なので、同じファイルに対して config 次第で異なる結果を得る可能性がある

```
% npx tsc -p foo/tsconfig.json  // このときcommon/index.tsはfooというプロジェクトの一部としてビルドされる
% npx tsc -p bar/tsconfig.json  // このときcommon/index.tsはbarというプロジェクトの一部としてビルドされる
```

## vscode と tsc

- vscode ではデフォルトで内蔵の typescript が利用される
  - コマンドパレットで以下により確認できる
    - `TypeScript: Select TypeScript Version...` -> `Use VS Codes's Version 5.8.2`

> あるファイルに対する tsconfig が一意に定まる必要はない

- しかし editor ではあるファイルに対してなんらかの config を適用して検査する必要がある
- vscode では、あるファイルに関して、そのファイルのある階層から順次親ディレクトリへと遡り、最初に見つかった tsconfig を適用する

## インクリメンタルビルド

- 設定
  - `"incremental": true`でインクリメンタルビルドになる（[docs](https://www.typescriptlang.org/tsconfig/#incremental)）
- 仕組み
  - ビルドごとにキャッシュファイル（デフォルトでは`.tsbuildinfo`）が生成される
  - ビルド時に、上記キャッシュファイルを参照することで、差分のあるファイルのみをビルドする
- 前提
  - この恩恵が生じるのは tsc のみ
  - esbuild などではビルドの方式が異なるため、この設定の影響を受けない
- ローカル/CI
  - 多くの場合キャッシュファイルは git 管理対象外とされ、キャッシュの恩恵はローカルでのみ生じる
  - CI で利用されないことが多いのは、キャッシュファイルを保存/復元するコストが大きいわりに、キャッシュがわるさをするリスクが大きいため
- どういう場面で利用すべきか
  - ローカルで esbuild でのビルドのみであれば不要（設定しても無意味）
  - commit に hook して tsc での型検査などをしているなら、インクリメンタルビルドにしておくのがベター

# 本題 - プロジェクト参照

- プロジェクト参照というのがある([docs](https://www.typescriptlang.org/docs/handbook/project-references.html#build-mode-for-typescript))

## メリット

### 1

```
- foo/
  - tsconfig.json
  - index.ts
- bar/
  - tsconfig.json
  - index.ts
```

プロジェクト参照を利用しない場合、以下の課題がある。

- `tsc`という 1 回のコマンドでビルドされるのはひとつのプロジェクトのみ。なので上記の例だと、foo と bar でそれぞれ`tsc`を実行する必要がある。

これをプロジェクト参照で解決できる。

ルートに（コンパイル対象をもたない空の）プロジェクトを作成し、そのプロジェクトから foo, bar を参照する。

```
- foo/
  - tsconfig.json
  - index.ts
- bar/
  - tsconfig.json
  - index.ts
- tsconfig.json <- NEW!
```

tsconfig.json

```json
{
	"files": [], // このプロジェクト自体はコンパイル対象をもたない
	"references": [{ "path": "foo/tsconfig.json" }, { "path": "bar/tsconfig.json" }]
}
```

こうすれば`tsc --build`という 1 回のコマンドで、複数のプロジェクトをまとめてビルドできる。

### 2

続きで、foo, bar 両方 から共通のコードを参照する場合を考える。

```
- foo/
  - tsconfig.json
  - index.ts  // common/index.tsをimportする
- bar/
  - tsconfig.json
  - index.ts  // common/index.tsをimportする
- common/
  - index.ts
- tsconfig.json
```

以下の課題がある。

- foo, bar それぞれのプロジェクトにおいて `common/index.ts` に対するビルド処理が重複して実行されるため非効率
- `common/index.ts` が foo, bar いずれの config においてもビルド可能である必要がある

プロジェクト参照によってこれを解決できる。

- common をプロジェクトとして定義し、foo, bar それぞれから参照する

```
- foo/
  - tsconfig.json
  - index.ts
- bar/
  - tsconfig.json
  - index.ts
- common/
  - tsconfig.json <- NEW!
  - index.ts
- tsconfig.json
```

foo/tsconfig.json 及び bar/tsconfig.json

```json
{
	"references": [{ "path": "../common/tsconfig.json" }]
}
```

common/tsconfig.json

```json
{
	"compilerOptions": {
		"composite": true,
		"emitDeclarationOnly": true
	}
}
```

最後のコードブロックでの設定について、引き続き説明する。

## （コンパイル対象をもつプロジェクトから）参照されるプロジェクトに課される条件

プロジェクト参照では、コンパイル対象をもつプロジェクトから参照されるプロジェクトには一定の条件が課される。

上記のメリット 2 の例では、foo は`foo/**/*`というコンパイル対象をもつため（bar も同様）、それらから参照される common にはこの条件が課されることになる。

他方で、上記のメリット 1 の例では、ルートのプロジェクトが`"files": []`という設定によりコンパイル対象をもたないため、そこから参照される foo, bar にはこの条件が課されない。

### 条件 1. composite

該当するプロジェクトは、`"composite": true`と設定される必要がある。また、この設定によっていくつかの制約が発生する。

制約の詳細は[docs](https://www.typescriptlang.org/tsconfig/#composite)に詳しいが、代表的なのは「そのプロジェクトでのコンパイル対象全てが、`files`または`include`での指定範囲に含まれる必要がある」ことだ。

メリット 2 の例において、common プロジェクトでは include がデフォルトの`**/*`（common からの相対パス）になっている。
ここで `common/index.ts`から common 配下にないファイルを参照したとしよう。

(一部を抜粋)

```
- common/
  - tsconfig.json
  - index.ts  // another/index.tsをimportする
- another/
  - index.ts
```

- common プロジェクトでは include 範囲である`common/**/*`に含まれる`common/index.ts`をコンパイルする
- `common/index.ts`で import している`another/index.ts`も common プロジェクト内でコンパイルされる必要がある
- しかし`another/index.ts`は common プロジェクトでの include 範囲（`common/**/*`）に含まれないため、条件に反してエラーになる

```
common/index.ts:1:25 - error TS6307: File '/Users/USERNAME/ghq/github.com/k-tokitoh/test/another/index.ts' is not listed within the file list of project '/Users/USERNAME/ghq/github.com/k-tokitoh/test/foo/tsconfig.json'. Projects must list all files or use an 'include' pattern.

1 import { another } from "../another";
                          ~~~~~~~~~~~~
```

このエラーは以下いずれかの方法で解決できる。

- common で`another/index.ts`を files または include での指定範囲に含める
- another を別プロジェクトとして切り出し、 common から参照する
  - 別プロジェクトであれば、`another/index.ts`は common プロジェクトでのコンパイル対象ではなくなるため

ところで、files/include に関するこの制約はなぜ存在するのだろうか。適当な資料が見当たらなかったが、差し当たって以下のように考えている。

- プロジェクト参照という発想では、ビルド対象はプロジェクトという単位に分割され、それらの依存関係を定義して再利用することでビルドの複雑性を縮減し、効率性を高めることが狙いとなる。
- その世界で、分割されたプロジェクトは明瞭な境界をもつことが望ましい。
- files/include に関する件の制約は、このような要請の表現だと考えられる。
- ただ、この制約をみたせば明瞭な境界が実現するとは限らず、あくまでそうした在り方を実現するための補助と捉えるのが適当だろう。
- なお、理想的な状態ではプロジェクトが互いに排他となるように思われるが、仕様としては複数のプロジェクトで files/include による指定範囲が重複していてもビルドエラーにならないようだ。

### 条件 2. d.ts の emit

コンパイル対象をもつプロジェクトから参照されるプロジェクトに課されるもうひとつの条件は「少なくとも d.ts を emit すること」である。

これは`"noEmit": false`または`"emitDeclarationOnly": true`などの設定により満たすことができる。

ビルド全体が`tsc --build`という単一のプロセスで実行されるのであれば、各プロジェクトの build 結果はディスクに書き出さずメモリでの保持で十分な気もするが、それではメモリ消費が肥大化してしまい、プロジェクト参照という企てが狙いとするビルドの効率化ができない、という判断なのだと思う。

## 例: npm create vite

今回の件を調べる発端は、`npm create vite`がプロジェクト参照する tsconfig を生成したことだった。

```
% npm create vite@6.5.0 test -- --template react-swc-ts
```

```
- tsconfig.json
- tsconfig.app.json
- tsconfig.node.json
- src/
  - ...
- vite.config.ts
```

tsconfig.json

```json
{
	"files": [],
	"references": [{ "path": "./tsconfig.app.json" }, { "path": "./tsconfig.node.json" }]
}
```

tsconfig.app.json（一部を抜粋）

```json
{
	"compilerOptions": {
		"noEmit": true
	},
	"include": ["src"]
}
```

tsconfig.node.json（一部を抜粋）

```json
{
	"compilerOptions": {
		"noEmit": true
	},
	"include": ["vite.config.ts"]
}
```

ここでの最大の関心は、app と node を異なる config でビルドすることだろう。

しかしそれだけであれば、プロジェクト参照を必ずしも利用しなくてよい。`tsconfig.app.json`と`tsconfig.node.json`の 2 つを配置して、それぞれに関して`tsc`すれば実現できる。

しかし上記の構成では 2 つの config に加えて、それらを参照する`tsconfig.json`が配置されている。

これにより、まさに上述したメリット 1, すなわち「1 つの`tsc --build`コマンドで複数のプロジェクトをビルドできる」が実現している。

他方で、上述のメリット 2, すなわち「共通するコードに対するビルド結果の再利用」は見出されない。
