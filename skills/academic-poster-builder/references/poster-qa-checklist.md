# Poster QA Checklist

Use this checklist when refining an A0 portrait academic poster generated from HTML/CSS.

## Source Fidelity

- Confirm all key claims, metrics, and baselines against the paper.
- Prefer paper-native figures and tables over recreated approximations.
- Check that figure captions describe the mechanism or result, not just the image name.
- Remove duplicate evidence: one main table plus one concise interpretation is usually enough.

## Layout

- Header does not crowd title, authors, institution logos, or QR codes.
- Four metric cards have parallel structure: title, value, comparison.
- Thesis strip is one sentence and appears below the metric cards.
- Section order follows the poster logic and section numbering.
- Three column bottoms align or differ only by a small intentional amount.
- Each section has at least one of: a figure/table plus short explanation, or a compact evidence card.
- If a complete figure creates awkward whitespace, rebalance adjacent explanatory content before cropping or splitting the figure.
- Bottom whitespace is balanced and not caused by hidden overflow.

## Typography

- Title/subtitle hierarchy is clear but not excessively bold.
- Body text is consistent across sections.
- Captions and table text are readable without zoom.
- Figure-internal text is not smaller than surrounding body text when the figure carries the main argument.
- Section headers, metric values, and conclusion text do not use heavy weights everywhere.
- Two-digit section numbers do not overflow their badges.

## Figures and Tables

- Overview/method diagrams are placed in the wide column.
- Comparable plots are the same size.
- Equations are large enough, especially longer equations.
- Coherent figures remain complete unless the user explicitly wants a crop/split and the crop preserves context.
- Tables do not touch panel borders.
- Any chart added to fill space has a label explaining what it means.
- Redundant tables or metrics are removed instead of duplicated.

## QR and Branding

- Use source/official logos where possible.
- QR codes are large enough to scan and have captions when helpful.
- Avoid bottom metadata footers unless required.

## Playwright Measurement Snippet

Run this from the repository root after setting `NODE_PATH` to a Playwright installation if needed.

```js
const path = require("path");
const { chromium } = require("playwright");

(async () => {
  const root = path.resolve("poster_build");
  const browser = await chromium.launch({
    headless: true,
    executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  });
  const page = await browser.newPage({
    viewport: { width: 3179, height: 4494 },
    deviceScaleFactor: 1,
  });
  await page.goto(`file://${path.join(root, "poster.html")}`, { waitUntil: "load" });
  const result = await page.evaluate(() => {
    const overflows = [...document.querySelectorAll(".col > .panel")].filter((panel) => {
      const body = panel.querySelector(".panel-body");
      return (
        panel.scrollHeight > panel.clientHeight + 2 ||
        (body && body.scrollHeight > body.clientHeight + 2)
      );
    }).map((panel) => panel.querySelector(".panel-title")?.innerText.replace(/\n/g, " ").trim());

    const bottoms = [...document.querySelectorAll(".col")].map((col) =>
      Math.round(col.querySelector(".panel:last-child").getBoundingClientRect().bottom)
    );

    return {
      scrollWidth: document.body.scrollWidth,
      scrollHeight: document.body.scrollHeight,
      posterBottom: Math.round(document.querySelector(".poster").getBoundingClientRect().bottom),
      contentBottom: Math.round(document.querySelector(".content").getBoundingClientRect().bottom),
      bottoms,
      overflows,
    };
  });
  console.log(JSON.stringify(result, null, 2));
  await browser.close();
})();
```

Accept only when:

- `scrollWidth` is `3179`.
- `scrollHeight` is `4494`.
- `overflows` is empty.
- Column `bottoms` are aligned or intentionally close.
