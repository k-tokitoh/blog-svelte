<!-- 存在しない path にアクセスされた場合 cloudfront によりエラーページを表示したい。
そのためにはエラーページの html を s3 にアップロードする必要がある。
+errors.svelte は html として出力されないため、 page としてエラーページを用意しておく。
参考: https://qiita.com/irohafox/items/53e356b10a23123a1f4f -->

<script lang="ts">
	import Error from '$lib/components/Error.svelte';
</script>

<Error />
