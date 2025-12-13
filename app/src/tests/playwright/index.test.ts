import { expect, test } from '@playwright/test';

test('index page has expected content', async ({ page }) => {
	await page.goto('/');

	const articles = await page.$$('article');

	// サイトのタイトルが表示されていること
	await expect(page.locator('div:text-is("k-tokitoh")')).toBeVisible();

	// 0より多い数のarticleが存在すること
	expect(articles.length).toBeGreaterThan(0);

	// expect(articles.length).not.toBeGreaterThan(10);  // paginationを実装したらコメントアウトを外す
});

test('clicking on article title in home page navigates to the article', async ({ page }) => {
	await page.goto('/');

	// 記事のタイトルを取得
	const title = await page.textContent('article h3');

	// 遷移
	await page.getByText(title!).click();

	// 遷移先のページで、h2が記事のタイトルと一致すること
	expect(await page.textContent('h1')).toBe(title);
});
