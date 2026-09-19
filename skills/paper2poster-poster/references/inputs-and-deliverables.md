# Inputs And Deliverables

## Minimum input

At least one of:

- `paper.pdf`
- arXiv or paper URL
- pasted paper text
- an existing structured summary

## Helpful extra input

- target conference or venue
- audience level: expert, mixed, or general technical
- poster dimensions
- institution or conference logos
- preferred color or branding direction
- deadline
- whether the output should be editable PPTX-oriented, Paper2Poster-oriented, or only a content package

## Default deliverables

If the user does not specify otherwise, produce:

1. `poster_brief.md`
2. `poster_copy.md`
3. `poster_layout.md`
4. `poster_runbook.md`

Add `poster.yaml` when the request mentions Paper2Poster execution, style customization, PPTX generation, or a repo-ready package.

## Recommended `poster_brief.md` fields

- poster title
- audience
- main takeaway
- priority results
- required visuals
- branding notes
- assumptions and unresolved gaps

## Recommended `poster_copy.md` sections

- title block
- motivation / problem
- method
- experiments or evaluation
- key results
- conclusion
- QR / contact placeholder

## Recommended `poster_layout.md` fields

- overall dimensions
- column count
- hero figure placement
- section order
- where charts, tables, and logos should go
- visual hierarchy notes

## Recommended `poster_runbook.md` fields

- input file placement
- generated support files
- exact Paper2Poster command
- what still needs manual confirmation
- final QA checklist
