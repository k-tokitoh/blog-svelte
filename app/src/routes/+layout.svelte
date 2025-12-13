<script lang="ts">
	import { page } from '$app/stores';
</script>

<header>
	<a href="/"><div class:small={$page.url.pathname !== '/'}>k-tokitoh</div></a>
</header>

<main>
	<slot />
</main>

<footer />

<style>
	:global(:root) {
		--spacing-unit: 4px;
		--color-background: rgb(13, 34, 58);
		--color-text-primary: oklch(0.985 0 0);
		--color-text-secondary: oklch(0.708 0 0);
	}

	:global(body) {
		margin: 0 auto;
		max-width: min(84ch, 94vw);
		padding: calc(var(--spacing-unit) * 2.5);
		font-family: -apple-system, 'system-ui', 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo,
			sans-serif, 'Segoe UI Emoji';
		-moz-osx-font-smoothing: grayscale;

		background-color: var(--color-background);
		color: var(--color-text-primary);
		line-height: 30.4px;
		font-size: 16px;
	}

	/* zennからとってきた */
	:global(h1, h2, h3, h4, h5, h6) {
		margin: 0;
		font-weight: 700;
		line-height: 1.5;
		outline: 0;
	}

	:global(a, a:visited, a:active) {
		text-decoration: none;
		color: var(--color-text-primary);
		font-weight: 700;
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
