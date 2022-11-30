import { expect, test } from '@playwright/test';

test('index page has expected p', async ({ page }) => {
	await page.goto('/');
	// TODO: Provide mock `browser.extension` and check for non-failing page
	expect(await page.textContent('p')).toBe('browser is not defined');
});
