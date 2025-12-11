<script lang="ts">
	import type { PageData } from './$types';
	import type { SvelteComponentTyped } from 'svelte/internal';

	import PageHead from '$lib/components/PageHead.svelte';
	import ArticleMeta from '$lib/components/ArticleMeta.svelte';

	export let data: PageData;

	type C = $$Generic<typeof SvelteComponentTyped<any, any, any>>;
	$: component = data.component as unknown as C;
</script>

<PageHead title={data.frontmatter.title} />
<ArticleMeta date={data.date} />
<div class="title">{data.frontmatter.title}</div>

<svelte:component this={component} />

<style>
	.title {
		margin: 0;
		font-size: 1.6rem;
	}
</style>