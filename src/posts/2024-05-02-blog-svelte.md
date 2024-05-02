---
title: ブログをsveltekitに移行した
---

ブログの変遷は以下。

- 2018-12 ~ 2021-06 : はてなブログ
- 2021-06 ~ 2024-05 : jekyll @ github pages
- 2024-05 ~ now : sveltekit @ s3 + cloudfront

今回の移行の動機は以下。

- jekyll の liquid template より最近の frontend でつかわれてる技術にしてみようかな
- デプロイ周りも github pages とか vercel とかにおまかせしたことしかなかったので、シンプルな静的サイトのホスティングを aws で構成してみるか

移行先の要件は以下。

- 手軽に書ける & 過去記事も移行できるように、markdown で記述する
- 1 からつくると色々ハマっているうちに飽きてしまいそうだから、基本はテンプレートコピペでつくれる

フレームワークはざっとググって以下を比較検討した。

- gatsby
  - react based で、react は仕事で触ったことあるから新鮮味がないな
- astro
  - UI ライブラリは react/vue/svelte/astro component など選べる
  - どういう組み合わせにするか考えるのもめんどいな
- ⭕ svelte
  - なんか一瞬でつくれるらしい、これでいいじゃん！
    - -> <a href="https://qiita.com/oekazuma/items/eb086527fe59dbdacf6f" target="_blank">Svelte で Markdown 形式で投稿できるブログを 1 分で構築する</a>

ただ上記リンクの記事で紹介されているテンプレートを試してみると、コードは残っているもののガイドから記載が削除されており、ぱっとできなさそうだった。

まあいったん svelte でやる気持ちになったので svelte で調べてみたところ、official な template はなさそうだったが、ざっと調べて以下がでてきた。router はいずれも sveltekit.

- https://github.com/K-Sato1995/sveltekit-blog-template
  - md parser
    - https://github.com/K-Sato1995/md-to-json-converter
    - あまり利用/メンテされてなさそう
- https://github.com/svelteland/svelte-kit-blog-demo
  - md parser
    - unified というエコシステムで remark/rehype するライブラリを組み合わせて利用している
- ⭕ https://github.com/mvasigh/sveltekit-mdsvex-blog
  - md parser
    - https://github.com/pngwn/mdsvex
    - 活発に利用/メンテされてそうなのでこれでいいんじゃね

# 学び

- 静的サイトホスティングという極めて一般的なケースでも s3 + cloudfront だけでなく cloud front functions でケアする必要などがあるんだな
  - 参考: https://dev.classmethod.jp/articles/cloudfront-url-cff/
