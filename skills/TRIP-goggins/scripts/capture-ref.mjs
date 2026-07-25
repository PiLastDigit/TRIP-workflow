// Capture a reference-product screenshot for GOGGINS MODE.
//
// The mission standard is "stand next to Linear / Stripe / a Bloomberg
// terminal". Naming a product anchors to a MEMORY of that product — both
// models are then judging against a prior, not a reference. This puts real
// pixels in state/refs/ so the bar is visible to the judge and attachable to
// son.
//
// Usage:
//   node capture-ref.mjs <label> <url> [--mobile] [--viewport 1440x900] [--full] [--retina]
//   node capture-ref.mjs linear-issues https://linear.app
//
// Writes <skill>/state/refs/<label>.png (override with --out <dir>).
//
// LIMIT — read this before trusting the output: public URLs give you MARKETING
// pages. The actual product UI behind a login is what most missions should be
// judged against, and this script cannot reach it. For app-UI missions, have
// the user drop their own screenshots into state/refs/ instead. A marketing
// hero is a fine reference for a landing-page mission and a misleading one for
// a dashboard.

import { chromium } from 'playwright';
import { mkdir, stat } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const args = process.argv.slice(2);
const flag = (name) => {
  const i = args.indexOf(name);
  if (i === -1) return null;
  const v = args[i + 1];
  args.splice(i, v && !v.startsWith('--') ? 2 : 1);
  return v && !v.startsWith('--') ? v : true;
};

const mobile = !!flag('--mobile');
const fullPage = !!flag('--full');
const retina = !!flag('--retina');
const vpArg = flag('--viewport');
const outArg = flag('--out');
const [label, url] = args;

if (!label || !url) {
  console.error('usage: capture-ref.mjs <label> <url> [--mobile] [--viewport WxH] [--full] [--out dir]');
  process.exit(64);
}

const [w, h] = mobile
  ? [390, 844]
  : (typeof vpArg === 'string' ? vpArg.split('x').map(Number) : [1440, 900]);

const outDir = typeof outArg === 'string'
  ? outArg
  : fileURLToPath(new URL('../state/refs/', import.meta.url));
await mkdir(outDir, { recursive: true });
const out = `${outDir.replace(/\/$/, '')}/${label}${mobile ? '-mobile' : ''}.png`;

// Cookie/consent walls ruin a reference shot, and the wall is served in the
// site's language, not yours — an English-only selector list misses a French
// "Tout accepter" every time. One multi-language regex over button roles,
// plus the usual CMP ids.
const CONSENT_TEXT =
  /^(accept all|accept|allow all|i agree|agree|got it|ok|tout accepter|accepter|j'accepte|alle akzeptieren|akzeptieren|zustimmen|einverstanden|aceptar todo|aceptar|accetta tutt[oi]|accetta|godkänn alla)$/i;
const CONSENT_IDS = [
  '#onetrust-accept-btn-handler',
  '#didomi-notice-agree-button',
  '[data-testid="uc-accept-all-button"]',
  '.fc-cta-consent',
];

const dismissConsent = async (page) => {
  for (const sel of CONSENT_IDS) {
    const el = page.locator(sel).first();
    if (await el.isVisible().catch(() => false)) {
      await el.click({ timeout: 1500 }).catch(() => {});
      return true;
    }
  }
  for (const role of ['button', 'link']) {
    const el = page.getByRole(role, { name: CONSENT_TEXT }).first();
    if (await el.isVisible().catch(() => false)) {
      await el.click({ timeout: 1500 }).catch(() => {});
      return true;
    }
  }
  return false;
};

const browser = await chromium.launch();
try {
  const page = await browser.newPage({
    viewport: { width: w, height: h },
    // 1x keeps the file attachable: a 2x desktop shot is ~2 MB, and four of
    // those on one Codex turn is a lot of tokens for a reference.
    deviceScaleFactor: retina ? 2 : 1,
    isMobile: mobile,
  });
  await page.goto(url, { waitUntil: 'networkidle', timeout: 45000 });

  let dismissed = await dismissConsent(page);
  await page.keyboard.press('Escape').catch(() => {});

  await page.evaluate(() => document.fonts?.ready).catch(() => {});
  // Marketing pages animate on scroll; settle, then return to the top.
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await page.waitForTimeout(900);
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.waitForTimeout(700);
  // Consent walls often inject late — try again now that the page settled.
  if (!dismissed) {
    dismissed = await dismissConsent(page);
    if (dismissed) await page.waitForTimeout(500);
  }

  await page.screenshot({ path: out, fullPage });
  const { title, vw } = await page.evaluate(() => ({ title: document.title, vw: window.innerWidth }));
  const { size } = await stat(out).then((s) => ({ size: Math.round(s.size / 1024) }));
  console.log(`captured ${out}`);
  console.log(`  url:      ${url}`);
  console.log(`  title:    ${title}`);
  console.log(`  viewport: ${vw}px${fullPage ? ' (full page)' : ''} @${retina ? 2 : 1}x · ${size} KB`);
  console.log(`  consent:  ${dismissed ? 'banner dismissed' : 'none found'}`);
  if (/^https?:/.test(url)) {
    console.log('  NOTE: public page — not the product UI behind a login. Check the PNG before trusting it as the bar.');
  }
} finally {
  await browser.close();
}
