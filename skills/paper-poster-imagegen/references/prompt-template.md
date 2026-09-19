# Academic Poster ImageGen Prompt Template

Use this template to generate a reference image for an A0 portrait academic poster. Replace bracketed fields with paper-specific content.

## Core Prompt

```text
Create a high-fidelity A0 portrait academic conference poster reference mockup.

Style:
- ACL / top-tier NLP conference poster style.
- Clean white and very light blue background.
- Deep navy section headers, thin blue borders, restrained green/red result accents.
- Professional moderate-weight sans-serif typography, no comic or handwritten font.
- Dense but readable A0 poster layout, not a marketing page.
- All panels should align cleanly with consistent gutters.

Canvas:
- A0 portrait aspect ratio.
- Three-column main body with a wider center column.
- Header and metric strip at top; no bottom metadata footer.

Header:
- Left: [conference logo / ACL 2026 mark] with [institution logos] below or nearby.
- Center: title "[TITLE]" with [METHOD ACRONYM] emphasized but not oversized.
- Subtitle: "[SUBTITLE]".
- Authors and affiliations in readable size.
- Right: three large QR code blocks with captions [GitHub], [arXiv], [Contact/WeChat].

Metric strip:
Four parallel metric cards with icons, large green numbers, and one-line comparisons:
1. [METRIC 1 LABEL] — [VALUE] — [COMPARISON]
2. [METRIC 2 LABEL] — [VALUE] — [COMPARISON]
3. [METRIC 3 LABEL] — [VALUE] — [COMPARISON]
4. [METRIC 4 LABEL] — [VALUE] — [COMPARISON]

Thesis strip:
"[ONE-SENTENCE CENTRAL CLAIM]"

Main body structure:
Left column:
1. [Motivation / Problem] — concise problem statement, two bullet-style mismatch/problem cards, one key question callout.
2. [Method Core / Design Principles] — compact equations or design-principle cards; readable body text.
3. [Failure Mode / Challenge] — place the complete provided illustrative figure, not split; add a short explanation and one warning/callout.

Center column:
4. [Method Overview] — large complete method diagram using the provided paper figure as a framed image.
5. [Key Diagnostic / Mismatch] — large complete paper figure/table screenshot, with caption.
6. [Mechanism Evidence] — 2x2 grid of comparable plots; equal plot sizes; add two concise interpretation notes below.

Right column:
7. [Main Results] — simplified main result table with highlighted method row and two short callouts.
8. [Generalization / Extensibility] — compact tables or cards.
9. [Robustness / Sensitivity] — two plots with a body-sized explanation, not a tiny footnote.
10. [Conclusion / Takeaways] — four concise check-mark takeaways.

Important constraints:
- Preserve complete paper figures; do not crop or split coherent figures merely to fill space.
- Use actual provided figure thumbnails as framed image areas where possible; do not invent alternate charts.
- Do not duplicate the same result table in multiple sections.
- Do not add random extra panels, contact footer, project lead footer, or unindexed sections.
- Avoid generic filler text. Fill space by enlarging important figures or adding paper-backed context.
- Ensure section text is readable and consistent across sections.
- Make the bottom edges of the three columns visually align.
- QR codes and logos should be visible and proportionate.

Output should look like a polished reference mockup for later HTML/PPT implementation, not the final factual source.
```

## Negative Prompt / Avoid List

```text
Avoid: tiny unreadable text, random fake equations, invented numbers, duplicated tables, split or incomplete figures, huge accidental blank space, decorative footer metadata, chaotic unnumbered panels, overly thick title font, tiny author/affiliation line, tiny QR codes, QR codes without captions when captions are expected, unrelated icons, hand-drawn university logos, stock-photo hero design, marketing landing page layout, one-column or strict equal-width layout when center method figures need more space.
```

## Review Checklist for Generated Mockups

Reject or revise the prompt if the mockup has any of these problems:

- Header hierarchy does not match the intended poster.
- Title/subtitle/author scale is wildly inconsistent.
- Metric cards are missing icons, numbers, comparisons, or parallel structure.
- Thesis strip is missing or too verbose.
- Important paper figures are redrawn, split, cropped, or replaced by generic graphics.
- A section is mostly whitespace while a nearby figure/table is too small.
- Blank space is filled with generic prose instead of meaningful paper-backed context.
- Body text size differs strongly across sections.
- Robustness/sensitivity notes are tiny footnotes.
- Main result semantics are duplicated in multiple places.
- Bottom column edges are visibly misaligned.
- QR codes/logos are decorative rather than useful.

## Translation to HTML/PPT

When implementing from the mockup:

- Rebuild layout with real HTML/PPT elements.
- Replace all generated text with verified paper text.
- Replace all generated plots, equations, logos, and QR codes with real assets.
- Render and measure overflow; never rely on the mockup for exact alignment.
