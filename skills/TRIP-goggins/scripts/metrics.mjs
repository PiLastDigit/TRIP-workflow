// Objective design receipts for GOGGINS MODE.
//
// "No receipt, no score" only holds if some of the receipts are numbers.
// This module runs one in-page pass and returns measurements for the
// dimensions that CAN be measured, so a judge cannot inflate them and son
// cannot argue them:
//
//   restraint       -> distinct type sizes / colors / shadows / radii
//   typography      -> the type scale actually in use, and its ratios
//   spacing rhythm  -> gap histogram + values that fall off the scale
//   hierarchy       -> WCAG contrast ratios, worst offenders first
//   (regression)    -> horizontal overflow + the elements causing it
//
// Taste stays unmeasurable — distinctiveness, concept, wit are still the
// judge's eyes. This just removes the excuses.
//
// Usage from an eyes script (Playwright):
//
//   import { collectMetrics, formatMetrics } from './metrics.mjs';
//   const m = await collectMetrics(page, { label: 'home-mobile' });
//   console.log(formatMetrics(m));
//
// Any page object exposing `evaluate(fn, arg)` works.

const IN_PAGE = (opts) => {
  const MAX_ELEMENTS = opts.maxElements;
  const px = (v) => Math.round(parseFloat(v) * 100) / 100 || 0;

  const tally = (map, key) => {
    if (key === undefined || key === null || key === '') return;
    map.set(key, (map.get(key) || 0) + 1);
  };
  const top = (map, n) =>
    [...map.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, n)
      .map(([value, count]) => ({ value, count }));

  // --- color helpers ---------------------------------------------------
  const parseColor = (c) => {
    const m = /rgba?\(([^)]+)\)/.exec(c || '');
    if (!m) return null;
    const p = m[1].split(/[ ,/]+/).filter(Boolean).map(Number);
    if (p.length < 3 || p.some(Number.isNaN)) return null;
    return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 };
  };
  const over = (fg, bg) => {
    // composite fg (possibly translucent) over an opaque bg
    const a = fg.a;
    return {
      r: fg.r * a + bg.r * (1 - a),
      g: fg.g * a + bg.g * (1 - a),
      b: fg.b * a + bg.b * (1 - a),
      a: 1,
    };
  };
  const lum = ({ r, g, b }) => {
    const ch = [r, g, b].map((v) => {
      const s = v / 255;
      return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
    });
    return 0.2126 * ch[0] + 0.7152 * ch[1] + 0.0722 * ch[2];
  };
  const ratio = (a, b) => {
    const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
    return Math.round(((hi + 0.05) / (lo + 0.05)) * 100) / 100;
  };
  const effectiveBg = (el) => {
    let node = el;
    while (node && node !== document.documentElement) {
      const c = parseColor(getComputedStyle(node).backgroundColor);
      if (c && c.a > 0.95) return c;
      if (c && c.a > 0) return c; // translucent layer: close enough, flag-worthy either way
      node = node.parentElement;
    }
    const root = parseColor(getComputedStyle(document.documentElement).backgroundColor);
    return root && root.a > 0 ? root : { r: 255, g: 255, b: 255, a: 1 };
  };
  const selectorFor = (el) => {
    const id = el.id ? `#${el.id}` : '';
    const cls = (el.className && typeof el.className === 'string'
      ? '.' + el.className.trim().split(/\s+/).slice(0, 2).join('.')
      : '');
    return `${el.tagName.toLowerCase()}${id}${cls}`.slice(0, 60);
  };

  // --- walk ------------------------------------------------------------
  const sizes = new Map();
  const weights = new Map();
  const families = new Map();
  const textColors = new Map();
  const bgColors = new Map();
  const shadows = new Map();
  const radii = new Map();
  const gaps = new Map();
  const contrast = [];
  const seenContrast = new Set();

  const all = [...document.querySelectorAll('body *')].slice(0, MAX_ELEMENTS);
  let visible = 0;

  for (const el of all) {
    const box = el.getBoundingClientRect();
    const cs = getComputedStyle(el);
    if (cs.display === 'none' || cs.visibility === 'hidden' || box.width === 0 || box.height === 0) continue;
    visible++;

    const fontPx = px(cs.fontSize);
    const ownText = [...el.childNodes]
      .filter((n) => n.nodeType === 3 && n.textContent.trim().length > 1)
      .map((n) => n.textContent.trim())
      .join(' ');

    if (ownText) {
      tally(sizes, fontPx);
      tally(weights, cs.fontWeight);
      tally(families, (cs.fontFamily || '').split(',')[0].replace(/["']/g, '').trim());
      tally(textColors, cs.color);

      const fg = parseColor(cs.color);
      if (fg) {
        const bg = effectiveBg(el);
        const key = `${cs.color}|${bg.r},${bg.g},${bg.b}|${fontPx}`;
        if (!seenContrast.has(key)) {
          seenContrast.add(key);
          const r = ratio(over(fg, bg), bg);
          const bold = parseInt(cs.fontWeight, 10) >= 700;
          const large = fontPx >= 24 || (bold && fontPx >= 18.66);
          const floor = large ? 3 : 4.5;
          contrast.push({
            selector: selectorFor(el),
            sample: ownText.slice(0, 40),
            ratio: r,
            fontPx,
            fg: cs.color,
            bg: `rgb(${Math.round(bg.r)}, ${Math.round(bg.g)}, ${Math.round(bg.b)})`,
            floor,
            passes: r >= floor,
          });
        }
      }
    }

    const bgc = parseColor(cs.backgroundColor);
    if (bgc && bgc.a > 0.02) tally(bgColors, cs.backgroundColor);
    if (cs.boxShadow && cs.boxShadow !== 'none') tally(shadows, cs.boxShadow.slice(0, 70));
    if (cs.borderRadius && cs.borderRadius !== '0px') tally(radii, cs.borderRadius);

    if (cs.display === 'flex' || cs.display === 'grid' || cs.display === 'inline-flex') {
      for (const g of [cs.rowGap, cs.columnGap]) {
        const v = px(g);
        if (v > 0) tally(gaps, v);
      }
    }
    for (const p of [cs.paddingTop, cs.paddingLeft, cs.marginTop]) {
      const v = px(p);
      if (v > 0) tally(gaps, v);
    }
  }

  // --- spacing scale ---------------------------------------------------
  const gapValues = [...gaps.keys()].sort((a, b) => a - b);
  const onGrid = (v, b) => Math.abs(v % b) < 0.51 || Math.abs((v % b) - b) < 0.51;
  // Best-fit base with a reported hit rate, not a pass/fail: a real design
  // system sits at 80–95% because browser default margins are em-based.
  const fits = [8, 4].map((b) => ({
    base: b,
    pct: gapValues.length
      ? Math.round((gapValues.filter((v) => onGrid(v, b)).length / gapValues.length) * 100)
      : 0,
  }));
  const best = fits.sort((a, b) => b.pct - a.pct || b.base - a.base)[0];
  const base = best && best.pct >= 50 ? best.base : null;
  const onScalePct = best ? best.pct : 0;
  const offScale = base ? gapValues.filter((v) => !onGrid(v, base)) : gapValues;

  // --- type scale ratios ----------------------------------------------
  const sizeValues = [...sizes.keys()].sort((a, b) => a - b);
  const ratios = sizeValues
    .slice(1)
    .map((v, i) => Math.round((v / sizeValues[i]) * 100) / 100);

  // --- overflow --------------------------------------------------------
  const doc = document.documentElement;
  const overflowing = [];
  if (doc.scrollWidth > doc.clientWidth + 1) {
    for (const el of all) {
      const r = el.getBoundingClientRect();
      if (r.width > 0 && r.right > doc.clientWidth + 1) {
        overflowing.push({ selector: selectorFor(el), right: Math.round(r.right), width: Math.round(r.width) });
      }
      if (overflowing.length >= 8) break;
    }
  }

  return {
    url: location.href,
    viewport: { w: window.innerWidth, h: window.innerHeight },
    elements: { scanned: all.length, visible, truncated: document.querySelectorAll('body *').length > MAX_ELEMENTS },
    type: {
      distinctSizes: sizes.size,
      sizes: sizeValues,
      scaleRatios: ratios,
      distinctWeights: weights.size,
      weights: [...weights.keys()].sort(),
      families: top(families, 5),
    },
    color: {
      distinctTextColors: textColors.size,
      distinctBgColors: bgColors.size,
      textColors: top(textColors, 8),
      bgColors: top(bgColors, 8),
    },
    depth: {
      distinctShadows: shadows.size,
      shadows: top(shadows, 5),
      distinctRadii: radii.size,
      radii: [...radii.keys()],
    },
    space: { scaleBase: base, onScalePct, distinctGaps: gaps.size, gaps: gapValues, offScale },
    contrast: {
      failures: contrast.filter((c) => !c.passes).length,
      pairs: contrast.length,
      worst: contrast.sort((a, b) => a.ratio - b.ratio).slice(0, 8),
    },
    overflow: {
      horizontal: doc.scrollWidth > doc.clientWidth + 1,
      scrollWidth: doc.scrollWidth,
      clientWidth: doc.clientWidth,
      offenders: overflowing,
    },
  };
};

/**
 * Run the measurement pass on a loaded page.
 * @param {{evaluate: Function}} page - Playwright page (already navigated & settled)
 * @param {{label?: string, maxElements?: number}} [opts]
 */
export async function collectMetrics(page, opts = {}) {
  const { label = '', maxElements = 4000 } = opts;
  const data = await page.evaluate(IN_PAGE, { maxElements });
  return { label, ...data };
}

/** Compact markdown block, ready to paste into a round report as receipts. */
export function formatMetrics(m) {
  const L = [];
  L.push(`### metrics — ${m.label || m.url} @ ${m.viewport.w}×${m.viewport.h}`);
  L.push(
    `- type: ${m.type.distinctSizes} distinct sizes [${m.type.sizes.join(', ')}]` +
      ` · ratios [${m.type.scaleRatios.join(', ')}]` +
      ` · ${m.type.distinctWeights} weights [${m.type.weights.join(', ')}]` +
      ` · families ${m.type.families.map((f) => f.value).join(' / ') || 'none'}`
  );
  L.push(
    `- restraint: ${m.color.distinctTextColors} text colors · ${m.color.distinctBgColors} bg colors` +
      ` · ${m.depth.distinctShadows} shadows · ${m.depth.distinctRadii} radii`
  );
  const off = m.space.offScale;
  L.push(
    `- spacing: base ${m.space.scaleBase ? m.space.scaleBase + 'px' : 'no grid'}` +
      ` (${m.space.onScalePct}% on grid) · ${m.space.distinctGaps} distinct values` +
      ` · off-scale [${off.slice(0, 12).join(', ') || 'none'}${off.length > 12 ? `, +${off.length - 12} more` : ''}]`
  );
  L.push(`- contrast: ${m.contrast.failures}/${m.contrast.pairs} pairs below WCAG floor`);
  for (const c of m.contrast.worst.filter((c) => !c.passes)) {
    L.push(`    ${c.ratio}:1 (needs ${c.floor}) ${c.selector} ${c.fontPx}px "${c.sample}" ${c.fg} on ${c.bg}`);
  }
  L.push(
    `- overflow: ${m.overflow.horizontal ? `HORIZONTAL SCROLL ${m.overflow.scrollWidth}px > ${m.overflow.clientWidth}px` : 'none'}`
  );
  for (const o of m.overflow.offenders) L.push(`    ${o.selector} right=${o.right}px width=${o.width}px`);
  if (m.elements.truncated) L.push(`- note: scan truncated at ${m.elements.scanned} elements`);
  return L.join('\n');
}

/**
 * Assertions worth failing a round over — regressions that screenshots
 * alone catch unreliably. Returns [] when clean; each entry is a receipt.
 * Extend per mission; the suite only grows.
 */
export function assertNoRegressions(m, { maxDistinctSizes = 8, maxShadows = 4, contrastFloor = 0 } = {}) {
  const fails = [];
  if (m.overflow.horizontal) {
    fails.push(
      `HORIZONTAL OVERFLOW @${m.viewport.w}px: scrollWidth ${m.overflow.scrollWidth} > ${m.overflow.clientWidth}` +
        (m.overflow.offenders[0] ? ` — first offender ${m.overflow.offenders[0].selector}` : '')
    );
  }
  if (m.contrast.failures > contrastFloor) {
    const w = m.contrast.worst.find((c) => !c.passes);
    fails.push(`CONTRAST: ${m.contrast.failures} pairs below WCAG (worst ${w.ratio}:1 on ${w.selector})`);
  }
  if (m.type.distinctSizes > maxDistinctSizes) {
    fails.push(`TYPE SPRAWL: ${m.type.distinctSizes} distinct font sizes (cap ${maxDistinctSizes}) [${m.type.sizes.join(', ')}]`);
  }
  if (m.depth.distinctShadows > maxShadows) {
    fails.push(`SHADOW SPRAWL: ${m.depth.distinctShadows} distinct box-shadows (cap ${maxShadows})`);
  }
  return fails;
}
