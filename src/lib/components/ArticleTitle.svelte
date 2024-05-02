<script lang="ts">
	export let large = false;
	export let title: string;
</script>

{#if large}
	<h2 class="heading">
		{title}
	</h2>
{:else}
	<h3 class="heading">
		{title}
	</h3>
{/if}

<style>
	h2 {
		margin: 0;
		margin-top: calc(var(--spacing-unit) * 12);
		font-size: 2.2rem;
	}

	.heading {
		margin: 0;
		font-size: 1.8rem;
	}
</style>
