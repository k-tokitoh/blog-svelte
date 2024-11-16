<script lang="ts">
	export let date: string | undefined;

	const formattedDate = date && new Date(date).toISOString().substring(0, 10);
</script>

<p>
	<span class="date">{formattedDate}</span>
</p>

<style>
	p {
		margin: 0;
		margin-bottom: calc(var(--spacing-unit) * 0.5);
	}

	.date {
		color: var(--color-text-secondary);
	}
</style>
