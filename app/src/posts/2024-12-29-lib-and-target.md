---
title: トランスパイラがわからない
---

<script lang="ts">
  import Image from '$lib/components/Image.svelte'
</script>

仕事では platform 領域の人におまかせしてしまっているし、個人でコードを書くときには雰囲気で設定しているので全然わからなかったが、1 ミリ理解したのでメモする。

色々間違っているかもしれない。

# トランスパイラの役割

- ts -> js の変換
- 構文の変換

# 各種ツール

## 前提

ややこしい理由のひとつは、歴史的経緯によりそれぞれのツールの責務がオーバーラップしていること。

責務の分布について、[こちらの記事](https://zenn.dev/righttouch/articles/86457bf2908379)が 2023-11 時点の見取り図としてわかりやすい。

一気に捉えようとすると混乱するので、トランスパイラについてのみ扱う。

## トランスパイラであるライブラリ

いずれも tsconfig.json を設定ファイルとして利用する。

トランスパイル用のライブラリはパフォーマンス観点で選定し、型チェックは本家の tsc で行うのが主流。

- [tsc](https://github.com/microsoft/TypeScript)

  - 型チェックとトランスパイル / 型チェックのみ(`noEmit: true`) が可能

- (webpack +) [ts-loader](https://github.com/TypeStrong/ts-loader)

  - 型チェックとトランスパイル / トランスパイルのみ(`transpileOnly: true`) が可能

    - [tsc に依存している](https://github.com/TypeStrong/ts-loader/blob/main/package.json#L97)ので、型チェックは tsc に委譲していると思われる

  - 類似の[awesome-typescript-loader](https://github.com/s-panferov/awesome-typescript-loader)は public archive

- (webpack + babel-loader +) [@babel/preset-typescript](https://github.com/babel/babel/tree/main/packages/babel-preset-typescript)

  - トランスパイルのみが可能

- [swc](https://github.com/swc-project/swc)

  - トランスパイルのみが可能
  - Rust 製

- [esbuild](https://github.com/evanw/esbuild)

  - トランスパイルのみが可能
  - Go 製

## トランスパイラを利用するライブラリ

## next.js

- swc
- vercel 帝国の一部

## vite

- esbuild
- （[bundler については現在 esbuild/rollup を併用しており rolldown に移行する予定とのこと](https://ja.vite.dev/guide/why#%E3%81%AA%E3%81%9B%E3%82%99-esbuild-%E3%81%A6%E3%82%99%E3%83%8F%E3%82%99%E3%83%B3%E3%83%88%E3%82%99%E3%83%AB%E3%81%97%E3%81%AA%E3%81%84%E3%81%AE%E3%81%8B)だが、トランスパイラは esbuild 継続なのだと思う）

## angular

- angular cli の一部として、[複数の builder が提供されている](https://angular.dev/tools/cli/build)
- 流れ
  - 最初に webpack を利用した CSR 用のビルダーとして`@angular-devkit/build-angular:browser`があった
  - SSR に対応するために`@nguniversal/*`が登場した
  - esbuild を利用する以下が登場した
    - SSR もできる`@angular-devkit/build-angular:application`
      - v17 以降はこれがデフォルト
    - CSR だけの`@angular-devkit/build-angular:browser-esbuild`
      - [`browser`から 低コストで移行するためのオプション](https://angular.dev/tools/cli/build-system-migration#manual-migration-to-the-compatibility-builder)。
- builder はパッケージに切り出されている
  - `@angular/build`
    - [上記のうち`application`のみを含む](https://github.com/angular/angular-cli/tree/main/packages/angular/build/src/builders)
  - `@angular-devkit/build-angular`
    - [上記のうち`application`以外を含む](https://github.com/angular/angular-cli/tree/main/packages/angular_devkit/build_angular/src/builders)
    - [bundler には webpack を利用している](https://github.com/angular/angular-cli/blob/main/packages/angular_devkit/build_angular/package.json#L59)
      - `esbuild`は`optionalDependencies`に含まれる。`browser-esbuild`でのみ利用されるのだろう
    - ちなみに[`babel-loader`に依存している](https://github.com/angular/angular-cli/blob/main/packages/angular_devkit/build_angular/package.json#L28)
  - よくわからなかったけれど、トランスパイラはプログラマティックに tsc を実行しているんじゃないかな
    - 少なくとも`ts-loader`や`@babel/preset-typescript`を利用している様子はない

# tsconfig の lib, target

あるコードが「この環境では動くがこの環境では動かない」という事象には 2 種類の理由がある。

構文と標準ライブラリである。

例として es2022 の各 feature は以下のように分類される。

- 構文
  - top level wait
  - private class field
  - private class method
  - static class fields
  - class static initialization blocks
- 標準ライブラリ
  - Array.at
  - Object.hasOwn
  - Error.cause
  - RegExp 'd' flag

書かれたコードをより広範な環境で実行できるようにするためにトランスパイラが何をしてくれる/くれないか。

- 構文
  - 入力は、トランスパイラのそのパージョンで扱える全ての構文を扱える（設定は関係ない）
  - 出力は、target で指定した水準までダウンレベルされる
- 標準ライブラリ
  - 入力は、lib で指定したものを扱える
  - 出力は、特に変化しない（lib で指定してもトランスパイラが提供するのは型だけであり実装ではない）
  - そのため、その lib がない環境で動かすためには polyfill が必要となる

lib, target, サポート下限は以下の画像に示すトレードオフの中で定めていく。

<Image src="/lib-target.png" />

# polyfill / ponyfill

本筋とはズレるがついでに。

ある機能が一定以上のバージョンでのみ対応されているとき、そのバージョン以下の環境で利用可能にするための 2 つのアプローチ。

- polyfill
  - 当該 API に対してパッチを当てる
  - ex. Array.prototype にパッチを当てて Array.includes() を拡張する
- ponyfill
  - 同等の機能を、パッチではなく別途用意する
  - ex. arrayIncludes()という関数を定義する
