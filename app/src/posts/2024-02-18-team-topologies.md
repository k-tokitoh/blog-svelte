---
title: team topologiesと組織の規模/成熟度
layout: post
---

team topologies で示されるモデルはエンタープライズ的な大規模組織かつ成熟したプロダクトを念頭においている気がした。理由は以下。

### 規模

- 例示がみんな大企業
- 著者はコンサルのようで、クライアントは大企業が多いんじゃないかな
- チーム数の話
  - stream aligned team とそれ以外の比率は 6~9:1 とのこと
  - 例えば stream aligned team 以外の 3 タイプが 1 チームずつの場合、18~27:3 でチーム数合計は 21~30
  - 記載されたとおり 1 チーム 5~9 人とすると、開発組織は 105~270 人
  - 少なくとも示されたチームタイプを額面通り適用できるのは人数が 3 桁オーダーの開発組織か
- platform に投資するだけの規模の経済があるか
  - セルフサービス化を推奨しているが、もちろん一定コストがかかる
  - いったんつくってしまえばスケールするのに追加コストがかかりにくい
  - つまり一定以上の規模の経済が働けば pay するし、働かなければ pay しない
- enabling team の支援期間の話
  - 数週間から数ヶ月だけ関われ、とのこと
  - enabling team が 1 つ、支援対象となるチームが 20 あったとして、2 ヶ月ごとに 2 チームを並行して支援対象にしたとする
  - すべてのチームに対する支援が一巡するのに 20 ヶ月かかる
  - まあ 2 年弱したら新しく enable されるべき課題がでてきたり、新たな支援対象チームができてたりして、次の一回しの意味がありそう
  - 支援対象のチームが例えば 8 とかだったら、一巡するのに 8 ヶ月
  - 全チームが平均 8 ヶ月おきに助っ人チームに来てもらって嬉しいというの、想像しにくい
- 別の人も書いてた
  - [こちらの記事](https://note.com/nutsfall/n/n121efef78483)に以下の記載
  - 「チームトポロジーにある４種類のチームを使ったモデルは、それなりのサイズ感のある組織で開発するのに向いていると思います。」
  - 「これまで先人たちが実践し、失敗を繰り返しながら得てきた知見の先にある、エンタープライズ向けの知識が詰まっている本なのではと感じながら読んでいました。」

### 成熟度

- ストリームが十分に安定的で細かい単位に分けられることを前提にしている
  - チームは 5~9 人なので、delivery のパワーは一定程度に限られる
  - プロダクト全体をパワフルに開発していくためには、プロダクトに対して多数のチームをアサインするために、それなりに細かい単位としてストリームを定義する必要がありそう
  - この本ではチームが受け持つストリームがころころ変わることは前提にしてなさそうなので、細かい単位に分割されたストリームが「そこに 1 チームを割り当てる価値がある」状態がつづくことが想定されてそう
  - これは一定程度成熟したプロダクトでのみ成り立つ前提だと思う

### それを踏まえて

開発組織の人数が 1 桁なら 1,2 の stream aligned team がごりごりやるのがいいだろう。
開発組織の人数が 3 桁ならチームタイプを概ね教義どおり適用できるだろう。
いま所属する組織は開発組織の人数が 2 桁である。
それくらいの規模だと、team topologies の発想を取り入れつつも実践手法はカスタマイズしていく必要がある気がする。
そのあたりは考えて実行していきたいし、知見も集めていきたい。