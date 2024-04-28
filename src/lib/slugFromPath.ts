export const slugFromPath = (path: string) =>
	path.match(/([\w-]+)\.(svelte\.md|md|svx)/i)?.[1] ?? null;

export const dateFromPath = (path: string) => path.match(/(\d{4}-\d{2}-\d{2})-.+/i)?.[1] ?? null;
