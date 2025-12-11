<script lang="ts">
	import type { PageData } from './$types';

	import PageHead from '$lib/components/PageHead.svelte';
	import Article from '$lib/components/Article.svelte';
	import ArticleMeta from '$lib/components/ArticleMeta.svelte';

	export let data: PageData;
</script>

<PageHead title="Home" />

<p class="lead">tiny weblog.</p>

{#each data.posts as { slug, title, date }}
	<Article {slug}>
		<ArticleMeta {date} />
		<div class="title">{title}</div>
	</Article>
	<hr />
{/each}

<slot />

<style>
	.lead {
		margin-top: calc(var(--spacing-unit) * 2);
		margin-bottom: calc(var(--spacing-unit) * 12);
	}

	.title {
		margin: 0;
		font-size: 1.3rem;
	}

	hr {
		border-color: var(--color-text-secondary);
	}
</style>
