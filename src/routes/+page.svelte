<script lang="ts">
	import type { PageData } from './$types';

	import PageHead from '$lib/components/PageHead.svelte';
	import Article from '$lib/components/Article.svelte';
	import ArticleTitle from '$lib/components/ArticleTitle.svelte';
	import ArticleMeta from '$lib/components/ArticleMeta.svelte';

	export let data: PageData;
</script>

<PageHead title="Home" />

<p>tiny weblog.</p>

{#each data.posts as { slug, title, date }}
	<Article>
		<ArticleTitle {slug} {title} />
		<ArticleMeta {date} />
	</Article>
{/each}

<slot />
