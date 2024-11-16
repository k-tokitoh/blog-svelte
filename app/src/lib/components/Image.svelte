<script lang="ts">
	export let src: string;
	export let alt: string = '';
</script>

<div class="container">
	<img {src} {alt} />
</div>

<style>
	.container {
		display: flex;
		justify-content: center;
	}

	img {
		width: min(100%, 540px);
	}
</style>
