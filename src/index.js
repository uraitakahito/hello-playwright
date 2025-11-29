import { chromium } from 'playwright';

const WS_ENDPOINT = process.env.PW_WS_ENDPOINT || 'ws://127.0.0.1:3000/';
const TARGET_URL = process.env.TARGET_URL || 'https://example.com';

async function main() {
  console.log(`Connecting to Playwright Server at ${WS_ENDPOINT}...`);

  const browser = await chromium.connect(WS_ENDPOINT);
  console.log('Connected successfully!');

  try {
    const page = await browser.newPage();
    console.log(`Navigating to ${TARGET_URL}...`);

    await page.goto(TARGET_URL);

    const title = await page.title();
    console.log(`Page title: ${title}`);

    const screenshotPath = 'screenshots/screenshot.png';
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.log(`Screenshot saved to ${screenshotPath}`);
  } finally {
    await browser.close();
    console.log('Browser closed.');
  }
}

main().catch((error) => {
  console.error('Error:', error.message);
  process.exit(1);
});
