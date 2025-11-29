import { program } from 'commander';
import { chromium } from 'playwright';

program
  .requiredOption('-e, --endpoint <url>', 'Playwright server WebSocket endpoint')
  .requiredOption('-u, --url <url>', 'Target URL to screenshot')
  .parse();

const options = program.opts();

async function main() {
  console.log(`Connecting to Playwright Server at ${options.endpoint}...`);

  const browser = await chromium.connect(options.endpoint);
  console.log('Connected successfully!');

  try {
    const page = await browser.newPage();
    console.log(`Navigating to ${options.url}...`);

    await page.goto(options.url);

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
