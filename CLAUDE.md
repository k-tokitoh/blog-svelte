# CLAUDE.md

このファイルは、このリポジトリでコードを扱う際のClaude Code (claude.ai/code)へのガイダンスを提供します。

## 概要

MDsveXを使用してMarkdownの記事を処理するSvelteKitベースの静的ブログです。TerraformでAWS S3 + CloudFrontにデプロイされます。

## 必須コマンド

```bash
# 開発
npm run dev          # 開発サーバーを起動 (http://localhost:5173)
npm run build        # 静的サイトを./buildにビルド
npm run preview      # ビルドしたサイトをローカルでプレビュー

# テスト
npm run test:unit    # Vitestユニットテストを実行
npm run test         # すべてのテストを実行（ユニット + Playwright E2E）

# コード品質
npm run check        # TypeScriptの型チェック
npm run lint         # ESLintを実行
npm run format       # Prettierでコードをフォーマット
```

## アーキテクチャ

### コンテンツ管理
- ブログ記事は`app/src/posts/`内のMarkdownファイル
- 命名規則：`YYYY-MM-DD-title.md`
- frontmatterで`draft: true`の記事は本番環境で非表示
- 記事の画像やアセットは`app/static/YYYY-MM-DD-title/`に配置

### 主要な統合ポイント
1. **記事の読み込み**：`app/src/routes/+page.ts`が`import.meta.glob`を使用して全記事を動的インポート
2. **記事の処理**：MDsveXがビルド時にMarkdownをSvelteコンポーネントに変換
3. **記事のメタデータ**：ファイル名（日付）とfrontmatter（タイトル、ドラフト状態）から抽出
4. **静的生成**：SvelteKit adapter-staticが`./build`ディレクトリにビルド

### デプロイアーキテクチャ
- 静的ファイルはS3バケットにデプロイ
- CloudFrontがコンテンツをグローバル配信
- インフラは`/terraform`のTerraformで管理
- 本番環境の設定は`/terraform/environments/production`

## 重要なパターン

### 新しい記事の追加
1. ファイルを作成：`app/src/posts/YYYY-MM-DD-title.md`
2. 最低限`title`を含むfrontmatterを追加
3. オプション：アセットディレクトリ`app/static/YYYY-MM-DD-title/`を作成
4. ビルド時に記事は自動的に表示される

### テストのアプローチ
- ユニットテストはVitestを使用（例：`app/src/lib/utils.test.ts`）
- E2EテストはPlaywrightを使用（`app/tests/`を参照）
- ページネーションは未実装 - すべての記事がホームページに読み込まれる