<script lang="ts">
	import { page } from '$app/stores';
</script>

<header>
	<a href="/"><h1 class:small={$page.url.pathname !== '/'}>k-tokitoh</h1></a>
</header>

<main>
	<slot />
</main>

<footer />

<style>
	:global(:root) {
		--spacing-unit: 4px;
		--color-background: rgb(37, 37, 37);
		--color-text-primary: oklch(0.985 0 0);
		--color-text-secondary: oklch(0.708 0 0);
	}

	:global(body) {
		margin: 0 auto;
		max-width: 68ch;
		padding: calc(var(--spacing-unit) * 2.5);
		font-family: ui-sans-serif, system-ui, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji',
			'Segoe UI Symbol', 'Noto Color Emoji';
		-webkit-font-smoothing: antialiased;
		-moz-osx-font-smoothing: grayscale;

		background-color: var(--color-background);
		color: var(--color-text-primary);
		line-height: 1.51;
		font-size: 16px;
	}

	:global(a, a:visited, a:active) {
		text-decoration: none;
		color: var(--color-text-primary);
		font-weight: 700;
	}

	:global(a:hover) {
		text-decoration: underline;
	}

	.small {
		font-size: 1.6rem;
	}

	h1 {
		margin-bottom: calc(var(--spacing-unit) * 2);
	}

	footer {
		margin-top: calc(var(--spacing-unit) * 8);
	}

	main {
		overflow-wrap: break-word;
	}
</style>
