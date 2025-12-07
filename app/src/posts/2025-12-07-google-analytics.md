---
title: google analytics
---

## 世代

GA はいくつか世代がある。

UA(Universal Analytics)が 2012~2023 年の間提供されていた方法。
GA4 が 2020 年移行提供されている現行の方法。

UA はページビューを基本として、ページの中でクリックなどのイベントが発生するという考え方。
GA4 はページビューもクリックなども同列のイベントとして扱う考え方。

最大の背景は SPA の普及によってクライアント側でのページ遷移が可能となり、ページ遷移を特別な位置づけで扱うことが馴染まなくなったため。

以下は GA4 について述べる。

## 概念

- ディメンション
  - `group by ...`にあたる情報
  - イベントのプロパティやユーザーの属性が利用される。
- 指標
  - `select average(...)`にあたる情報
  - イベントのプロパティが利用される

また、以下は異なることに注意。

- ブラウザのセッション
  - タブ/ウィンドウを閉じたら別セッション
  - session storage の区切り
- GA4 のセッション
  - 30 分イベントがなければ別セッション

## 方法

### gtag を直接埋め込む

以下を html に埋め込む。

```html
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXX"></script>
<script>
	// dataLayerはただの配列で、送信するイベントのキューとして利用される。ロードされるスクリプトが、ここからイベントを読み出して送信する。
	window.dataLayer = window.dataLayer || [];
	// 引数を丸ごとdataLayerという配列にpushするだけ。
	function gtag() {
		dataLayer.push(arguments);
	}
	// このスクリプトの実行 = 初期化 のタイミングを記録する（ページ滞在時間等の基準になる）
	gtag('js', new Date());
	// 測定idを設定
	gtag('config', 'G-XXXXXXXX');
</script>
```

GA4 側で拡張計測機能を on にしていれば、ページ遷移、クリック、スクロールなどのイベントにフックして google にデータを送信する（デフォルトで on）。

独自のイベントを送信したい場合は以下のように行う。

```js
document.querySelector('.hoge-button').addEventListener('click', () => {
	gtag('event', 'hoge_click', { foo: 'bar' });
});
```

これだけでデータが送信され、カスタムイベントは集計対象の 1 項目となる。

もし追加的に以下を行いたければ GUI での登録が必要。

- カスタムプロパティを GA4 上でカスタムディメンションとして扱う
  - カスタムディメンションは上限が 50 個である点に注意する
- カスタムイベントをコンバージョンとして扱う

上記はあくまで GA4 のレポート機能で利用するためなので、送信されたデータを data lake などに転送した後で別途分析する場合は上記登録は不要。

ちなみに ts で`window.gtag`の型定義は`@types/gtag.js`をインストールすることで入れられる。

### GTM

以下 2 点を html に追加する。

gtm.js をロードする部分。

```html
<script>
	(function (w, d, s, l, i) {
		// 直接埋め込みと同様、dataLayerという配列を用意
		w[l] = w[l] || [];
		w[l].push({ 'gtm.start': new Date().getTime(), event: 'gtm.js' });
		// 1つめのスクリプトタグを取得
		var f = d.getElementsByTagName(s)[0],
			// gtag/jsをロードするためのscriptタグを作成
			j = d.createElement(s),
			// window.dataLayer以外のプロパティを使いたい場合はこの関数の第4引数で切り替えることができる
			dl = l != 'dataLayer' ? '&l=' + l : '';
		j.async = true;
		j.src = 'https://www.googletagmanager.com/gtm.js?id=' + i + dl;
		// 1つめのスクリプトタグの前に、作成したelementを挿入
		f.parentNode.insertBefore(j, f);
	})(window, document, 'script', 'dataLayer', 'GTM-MCVNVBM8');
</script>
```

js が実行できない環境だったときに、iframe でリクエストを送信してそのことを google に伝える部分。

```html
<noscript
	><iframe
		src="https://www.googletagmanager.com/ns.html?id=GTM-MCVNVBM8"
		height="0"
		width="0"
		style="display: none; visibility: hidden"
	></iframe
></noscript>
```

ネットワークタブをみると、以下を順番に読んでいることがわかる。

- `https://www.googletagmanager.com/gtm.js?id=GTM-MCVNVBM8`
- `https://www.googletagmanager.com/gtag/js?id=G-3G669F22PR&cx=c&gtm=4e5c31`

GTM を利用する場合も結局`gtag()`がグローバルにロードされるので、カスタムイベントを送信したければ`gtag()`を呼び出す。

### クライアントを同定する情報

初期化時点で gtag/js はクライアントを一意に特定するための情報を生成する。

その後、同じサイトを別タブや別ウィンドウで開き直したとしても同じ情報を送信することで、ユーザー（ブラウザ）が同一であることがわかる。

そのために GA は`_ga`, `_ga_{container_id}`という cookie をつかう。

これは初期化時に js により書き込まれ、google へのイベント送信時に js で読み取って cid, sid などのクエリパラメータに付加される。

hoge.com のドキュメントに GA が仕込まれていれば、これらの cookie の domain は`.hoge.com`になる。

GA としてはブラウザのセッションを越えた永続化層として cookie を利用しているだけであって、`hoge.com`へのリクエストに毎回`_ga`などが付加されるのは副次的な事象に過ぎない。

ちなみにそういう永続化層なら local storage でいいのでは？とも思うが、web storage は origin ベースでサンドボックス化されており、cookie の方がサブドメインでも共有できるのでトラッキング目的では便利だから利用されているようである。
