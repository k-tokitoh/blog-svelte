<script lang="ts">
	export let slug: string;

	const href = `/posts/${slug}`;
</script>

<a {href}>
	<article>
		<slot />
	</article>
</a>

<style>
	article {
		min-height: 5rem;
		margin-top: calc(var(--spacing-unit) * 1);
		margin-bottom: calc(var(--spacing-unit) * 2);
		display: flex;
		flex-direction: column;
		justify-content: center;
		border-radius: 1rem;
		padding: 0 2.2%;
		transition: all 0.35s ease-in;
	}

	a {
		text-decoration: none;
	}
</style>
