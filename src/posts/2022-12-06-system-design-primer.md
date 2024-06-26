---
title: システム設計 はじめの一歩
tags: architecture
layout: post
---

.

# introduction

- アーキテクチャ設計とかできるようになりたいな
- しかし実戦経験を積む機会は現職だと少ないな
- 座学は学びが限られるけどやらないよりましだろう
- [donnemartin/system-design-primer](https://github.com/donnemartin/system-design-primer)とかちょっとみてみるか
- 読むだけだと頭に残らないのでメモして残しておく
- あんまり体系的な資料/教材がみあたらないので、つまみぐいスタイルで

# latency vs throughput

- latency
  - あるタスクが開始してから完了するまでにかかる時間
- throughput
  - 単位時間あたりで完了されるタスクの総量

やり方の違い

- latency を重視する世界
  - タスクが常に進行中であることを優先する
  - リソースが遊休状態になることは許容する
  - 並列数を抑える
  - フロー効率が高い、と呼ぶ
- throughput を重視する世界
  - リソースが常に稼働中であることを優先する
  - タスクが保留状態になることは許容する
  - 並列数を増やす
  - リソース効率が高い、と呼ぶ

システムもそうだし、チーム開発の在り方を考える際にも用いられる概念。

# 分散型システムのあれこれ

- 分散型(distributed)システム = データが replicate されている、っぽい
- ここでいうデータは RDB とかのこともあればメモリのこともある
- replication は一般に performance / reliability のうち少なくともひとつの向上を目的とする

## CAP 理論

- consistency
  - どの partition から読み出しても結果が同じ
- availability
  - とにかく役立つレスポンスを受け取ることができる
- partition tolerance
  - partition A と partition B が分断されても（partition A が動かなくなるとか）全体として動作しつづける
  - これは分散型システムの must 要件

consistency と availability がトレードオフの関係にある。

## consistency level

CAP 理論にでてきた consistency にはいくつかの level がある。

- 強い整合性 : 必ず最新の書き込みを読む
- 弱い整合性 : 強い整合性を満たさない
  - 結果整合性 : 弱い整合性の一種で、十分な時間がたてば必ず最新の書き込みを読む

# fail xx

- fail safe
  - 障害が起きたら機能を全面的に停止する
- fail over
  - 障害が起きたら機能を全面的にカバーして継続運用する
- fail soft
  - 2 つの中間で、最低限の機能を継続して安全に終了する

## サーバ構成における fail over

- サーバを複数台稼働させて冗長性をもたせる
- 以下のパターンがある
  - active/passive (master/slave)
  - active/active (master/master)

# fault xx

- fault tolerance
  - 障害が起きても大丈夫にすること
- fault avoidance
  - 障害をそもそも発生させないこと

# CDN

- push CDN
  - サーバで変更が生じたらサーバが CDN に push する
  - O: ユーザーからのアクセス時に CDN からサーバに問い合わせる必要がないのでレイテンシが小さい
  - O: ユーザーは常に最新の結果を得られる
  - X: アクセスされていなくても CDN にキャッシュするのでストレージ消費が大きい
- pull CDN
  - アクセスされたが（有効期限が切れていない）キャッシュがなかったときに CDN がサーバから pull する
  - O: アクセスされた場合のみ CDN にキャッシュするのでストレージ消費が小さい
  - X: ユーザーからのアクセス時に CDN からサーバに問い合わせるためレイテンシが大きい場合がある
  - X: ユーザーはサーバにあるリソースよりも古いキャッシュを受け取ることがある

# スケーリングの方向

- 水平スケーリング (scale out)
  - O: 小数の高機能なマシンよりも多数の低機能なマシンの方が費用対効果が good
  - O: （オンプレの場合）ハードを転用しやすい
  - X: 複雑性が高い
  - X: 各サーバをステートレスに保つ必要がある
  - X: DB などの集約された箇所では同時接続数が増えることに対応する必要がある
- 垂直スケーリング (scale up)
  - X: 多数の低機能なマシンよりも小数の高機能なマシンの方が費用対効果が bad
  - X: （オンプレの場合）ハードを転用しにくい
  - O: 複雑性が低い
  - O: （単一サーバの場合）各サーバをステートを保持してもよい
  - O: DB などの集約された箇所でも同時接続数が増えない

# proxy

- forward proxy
  - `client <= forward proxy <= server`
- reserve proxy
  - `client => reverse proxy => server`

## reverse proxy

- メリット/使い方
  - サーバの情報を隠蔽
    - 堅牢なセキュリティ
    - スケーリングなどの柔軟性
  - SSL termination
  - パフォーマンス
    - 静的コンテンツ
    - キャッシング
    - gzip などの圧縮
- デメリット
  - 全般
    - 複雑性が増す
  - 単複
    - 単一の場合
      - 単一障害点になりうる
    - 複数の場合
      - さらに複雑性が増す

load balancer は reverse proxy は重なる部分も多い。

# RDB

## ACID

トランザクションの特性。

- Atomicity
  - トランザクションは、全て為された or 全て為されていない、いずれかの状態である
- Consistency
  - トランザクションの開始/終了時に予め与えられた整合性を満たす
  - ex. 口座残高は正数である
- Isolation
  - トランザクションの途中の状態がトランザクション外部から読み取られることがない
- Durability
  - トランザクションが完了したらその状態は失われない

## RDB のスケーリング

### master / slave replication

master は(read/)write に、slave は read に応答する。

### master / master replication

### sharding
