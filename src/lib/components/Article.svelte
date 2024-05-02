<script lang="ts">
	export let slug: string;

	const href = `/posts/${slug}`;
</script>

<article>
	<a {href}>
		<slot />
	</a>
</article>

<style>
	article {
		margin-top: calc(var(--spacing-unit) * 7);
		margin-bottom: calc(var(--spacing-unit) * 8);
	}
</style>
