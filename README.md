# これは何

- tiny weblog hosted in <a href="https://blog.k-tokitoh.net" target="\_blank">blog.k-tokitoh.net</a>
- originally a clone of <a href="https://github.com/mvasigh/sveltekit-mdsvex-blog" target="_blank">mvasigh/sveltekit-mdsvex-blog</a>


# インフラ構成

![構成図](./structure.drawio.svg)

# ディレクトリ

- app/infraで分離している
- シンプルな構成のため同一repoにしているが、組織的な開発であれば以下の理由から別repoにするとよさそう
  - 権限/組織の分離がしやすい
  - デプロイサイクルが異なる
  - app/infra間でのコードの再利用性は低い
