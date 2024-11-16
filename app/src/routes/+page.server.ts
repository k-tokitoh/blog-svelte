import type { PageServerLoad } from './$types';
import { slugFromPath, dateFromPath } from '$lib/slugFromPath';

const MAX_POSTS = 1000;

export const load: PageServerLoad = async () => {
	const modules = import.meta.glob(`/src/posts/*.{md,svx,svelte.md}`);

	const postPromises = Object.entries(modules).map(([path, resolver]) =>
		resolver().then((post) =>
			Object.assign((post as unknown as App.MdsvexFile).metadata, {
				slug: slugFromPath(path),
				date: dateFromPath(path)
			})
		)
	);

	const posts = await Promise.all(postPromises);
	const publishedPosts = posts.filter((post) => post.draft !== true).slice(0, MAX_POSTS);

	publishedPosts.sort((a, b) => (new Date(a.date) > new Date(b.date) ? -1 : 1));

	return { posts: publishedPosts };
};
