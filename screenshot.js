const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

const EDGE_PATH = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const APP_URL = 'http://localhost:5000';
const OUTPUT_DIR = path.resolve(__dirname, '..', 'oficina_api', 'docs', 'screenshots');

async function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

async function main() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const browser = await puppeteer.launch({
    executablePath: EDGE_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=400,800'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 400, height: 800 });

  console.log('Navigating to app...');
  await page.goto(APP_URL, { waitUntil: 'networkidle0', timeout: 30000 });
  await sleep(5000);

  // Check what's on the page
  const info = await page.evaluate(() => {
    return {
      title: document.title,
      bodyChildren: document.body.children.length,
      canvasCount: document.querySelectorAll('canvas').length,
      fltElements: document.querySelectorAll('[class^="flt"]').length,
      globalKeys: Object.keys(window).filter(k => k.startsWith('_flutter') || k.startsWith('flutter')).join(', '),
      bodyHTML: document.body.innerHTML.substring(0, 1000)
    };
  });
  console.log('Page info:', JSON.stringify(info, null, 2));

  // Home screen
  console.log('Screenshot: home.png');
  await page.screenshot({ path: path.join(OUTPUT_DIR, 'home.png'), fullPage: false });

  // Try clicking on the canvas center (assuming the app takes full viewport)
  // Many Flutter apps render in a full-viewport canvas
  const canvasInfo = await page.evaluate(() => {
    const canvas = document.querySelector('canvas');
    if (!canvas) return null;
    const rect = canvas.getBoundingClientRect();
    return { x: rect.x, y: rect.y, w: rect.width, h: rect.height };
  });
  console.log('Canvas position:', JSON.stringify(canvasInfo));

  if (canvasInfo) {
    // Click on the "Estoque" card area - roughly at center-top area
    // This is approximate based on a 400x800 viewport
    const clickPoints = [
      { name: 'home_click', x: 200, y: 250 }, // Center area where cards might be
    ];
    for (const pt of clickPoints) {
      await page.mouse.click(pt.x, pt.y);
      await sleep(2000);
      console.log(`Screenshot after click at (${pt.x}, ${pt.y}): ${pt.name}.png`);
      await page.screenshot({ path: path.join(OUTPUT_DIR, `${pt.name}.png`), fullPage: false });
    }
  }

  await browser.close();
  console.log('Done!');
}

main().catch(console.error);
