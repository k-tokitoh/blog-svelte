<script lang="ts">
	export let title: string;

	const siteTitle = 'k-tokitoh';
	const formattedTitle = title ? `${title} | ${siteTitle}` : siteTitle;
</script>

<svelte:head>
	<title>{formattedTitle}</title>

	<meta property="og:site_name" content={siteTitle} />
	<meta property="og:title" content={title} />
</svelte:head>
