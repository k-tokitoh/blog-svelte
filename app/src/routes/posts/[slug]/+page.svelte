<script lang="ts">
	import type { PageData } from './$types';
	import type { SvelteComponentTyped } from 'svelte/internal';

	import PageHead from '$lib/components/PageHead.svelte';
	import ArticleMeta from '$lib/components/ArticleMeta.svelte';

	// ./page.ts の load() から得られる情報
	export let data: PageData;

	type C = $$Generic<typeof SvelteComponentTyped<any, any, any>>;
	$: component = data.component as unknown as C;
</script>

<PageHead title={data.frontmatter.title} />
<h1 class="title">{data.frontmatter.title}</h1>
<ArticleMeta date={data.date} />

<div class="body">
	<svelte:component this={component} />
</div>

<style>
	.body :global(h1),
	.body :global(h2) {
		font-size: 1.5em;
		border-bottom: 1px solid var(--color-text-secondary);
	}

	.title {
		margin: 0;
		font-size: 1.6rem;
	}
</style>
