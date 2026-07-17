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

  // First, enable accessibility by clicking the semantics placeholder
  const enableA11y = await page.$('flt-semantics-placeholder');
  if (enableA11y) {
    await enableA11y.click();
    console.log('Clicked accessibility placeholder');
    await sleep(2000);
  }

  // Home screenshot
  console.log('Screenshot: home.png');
  await page.screenshot({ path: path.join(OUTPUT_DIR, 'home.png'), fullPage: false });

  // Now explore the semantics tree
  const tree = await page.evaluate(() => {
    const root = document.querySelector('flutter-view');
    if (!root) return 'no flutter-view';
    // Look for semantics nodes
    const semantics = root.querySelectorAll('flt-semantics');
    const result = [];
    semantics.forEach((s, i) => {
      const rect = s.getBoundingClientRect();
      result.push({
        index: i,
        role: s.getAttribute('role'),
        label: s.getAttribute('aria-label'),
        text: s.getAttribute('flt-label') || s.textContent,
        rect: { x: rect.x, y: rect.y, w: rect.width, h: rect.height },
        visible: rect.width > 0 && rect.height > 0,
        tag: s.tagName,
      });
    });
    return result;
  });
  console.log('Semantics nodes:', JSON.stringify(tree, null, 2).substring(0, 3000));

  // Try clicking on elements that contain "Estoque" or "Cliente"
  const clickableTexts = ['Estoque', 'Cliente', 'Novo', 'Atendimento', 'Ordem'];
  for (const text of clickableTexts) {
    const clicked = await page.evaluate((searchText) => {
      const elements = document.querySelectorAll('[aria-label], [flt-label], [role="button"]');
      for (const el of elements) {
        const label = el.getAttribute('aria-label') || el.getAttribute('flt-label') || '';
        if (label.toLowerCase().includes(searchText.toLowerCase())) {
          el.click();
          return { found: true, label, searchText };
        }
      }
      return { found: false, searchText };
    }, text);
    console.log(`Click "${text}":`, JSON.stringify(clicked));
    if (clicked.found) {
      await sleep(3000);
      await page.screenshot({ path: path.join(OUTPUT_DIR, `${text.toLowerCase()}.png`), fullPage: false });
      console.log(`Screenshot: ${text.toLowerCase()}.png`);
    }
  }

  await browser.close();
  console.log('Done!');
}

main().catch(console.error);
