# Internal roadmap: biology first, statistics second

Status: discussion draft  
Primary audience: tutorial team and Erick Lundgren  
Scope: narrative and structural revision of the effect-size tutorial  
Last updated: 2026-08-24

## Purpose

Reframe the tutorial so that readers begin with the biological quantity they want to synthesize and encounter statistical estimators only after that question is clear.

The main teaching pathway will focus on comparisons between two groups with continuous outcomes. Within this pathway, standardized mean differences (SMDs), the log response ratio (lnRoM), lnM, and variability effect sizes answer different biological questions. SMDs will receive the greatest practical emphasis, while lnM will be presented as a special case for questions about the magnitude of a response regardless of its direction. lnRoM will be presented as the corresponding choice when the biological estimand is proportional or relative change.

This roadmap is a planning and discussion document. It does not yet authorize wholesale rewriting or file renaming.

## Working narrative

The tutorial should lead readers through this sequence:

1. What is the biological question?
2. What quantity should be compared or related across studies?
3. What study designs and reported data represent that quantity?
4. Which effect-size estimand expresses it?
5. Which estimator is appropriate for the design and numerical properties of the data?
6. How can the required information be extracted or reconstructed?
7. Which assumptions, sensitivity analyses, and limitations must be reported?

In shorthand:

> Biological question → estimand → study design and data → estimator → extraction → diagnostics and sensitivity analyses → interpretation

This reverses the dominant impression of the current draft, which often begins with an effect-size label and then explains where it can be used.

## Proposed question map

### Primary pathway: how do two groups differ in a continuous biological response?

This will be the tutorial's core pathway and the main home for SMD-related material.

Readers first decide what kind of biological difference matters:

- **Difference relative to within-group variation:** How separated are the group means relative to variation among observations? Use SMD.
- **Magnitude regardless of direction:** Is the response farther from zero, a target, or another biologically meaningful reference, irrespective of sign? Introduce lnM as a special case within the SMD-centered two-group pathway.
- **Relative or proportional change:** By what proportion is one group mean larger or smaller than the other? Use lnRoM when its scale and assumptions match the biological question.
- **Difference in variability:** Did one group become more or less variable? Route to lnVR or lnCVR as a related but distinct question.

The prose must make clear that these estimands answer different biological questions even when they can be calculated from the same ingredients: group means, standard deviations, and sample sizes.

The choice between SMD and lnRoM is therefore not determined by continuous versus binary data. Both normally belong to two-group comparisons with continuous responses. Study design and response structure identify the available family of comparisons; the biological estimand determines the effect size within that family.

Use terminology carefully:

- **lnRoM** is the log ratio of means (often called the log response ratio) for continuous group outcomes such as weight, biomass, abundance, growth, or concentration.
- **lnRR** is the log risk ratio for binary events such as survival, infection, mortality, or fledging.

The similar names and abbreviations should be addressed explicitly near their first appearance.

### Secondary pathway: how do two groups differ in a binary outcome?

Route readers to lnOR or the log risk ratio (lnRR) only after defining the biological event, denominator, comparison groups, and desired interpretation of odds versus risk. Do not refer to lnRoM as a binary-outcome measure.

### Secondary pathway: how does a biological response vary along a gradient?

Route readers to correlations/Zr after asking whether the predictor is genuinely continuous and whether discretizing it would discard biologically important information.

### Supporting pathway: what if the evidence does not fit these structures?

Cover single-group summaries, custom effect sizes, conversions, reconstructed data, and unusual study designs as extensions rather than as competing starting points.

## Terminology to settle

We should consistently distinguish:

- **Biological question:** the scientific contrast or relationship of interest.
- **Estimand:** the quantity the synthesis is intended to estimate.
- **Estimator:** the formula used to estimate that quantity from reported data.
- **Estimate/effect size:** the numerical result for one comparison or study.
- **Sampling variance:** estimated uncertainty used in weighting and modeling.
- **Data structure:** continuous or binary response; categorical or continuous predictor; paired, independent, repeated, or crossed design.

The phrase “SMD family” needs an explicit editorial definition. For this tutorial it may function as a teaching umbrella for two-group continuous-response comparisons, but we should not imply that every effect size in that pathway is mathematically an SMD. In particular, Erick and the team should approve the precise relationship we claim among SMD, lnM, and lnRoM.

## Proposed tutorial architecture

### Part I — Begin with the biology

1. Why synthesize an effect?
2. Write the biological question before choosing an effect size.
3. Identify the response, contrast or gradient, direction, scale, and unit of replication.
4. Define the estimand in plain language.
5. Use a question-led decision map to enter the appropriate pathway.

### Part II — The main pathway: continuous responses in two groups

1. Differences relative to within-group variation and SMD.
2. Proportional differences in continuous group means and lnRoM.
3. Magnitude differences and lnM as a special case.
4. Why these measures are not interchangeable.
5. Interpretation on biological and statistical scales.
6. Design-specific estimators: independent, paired, repeated, BACI, crossed, and heteroscedastic designs.
7. Numerical issues: bounded data, dimensionality, non-normality, overdispersion, zeros, and missing uncertainty.
8. Extraction from simple summaries through difficult figures and model outputs.

### Part III — Other biological question structures

1. Binary biological outcomes: lnOR and lnRR.
2. Continuous gradients and associations: correlations and Zr.
3. Differences in variability: lnVR and lnCVR.
4. Single-group, custom, and less common estimands.

### Part IV — Evidence recovery and harmonization

1. Universal extraction principles.
2. Units of replication and non-independence.
3. Reconstruction from figures and non-Gaussian summaries.
4. Conversion between effect sizes, with biological comparability checked before mathematical convertibility.
5. Sensitivity-analysis planning and reporting.

### Appendices and reference tools

- Formula and estimator catalogue.
- `metafor::escalc` cheatsheet.
- Worked R recipes.
- Assumption and sensitivity-analysis checklist.
- Reporting checklist.
- Glossary.

## File-level migration map

| Current file | Main role in the revision | Likely action |
|---|---|---|
| `index.qmd` | Establish the biology-first promise and reader journey | Rewrite the introduction and “How to use” section after the architecture is approved |
| `1-effect-size-overview.qmd` | Define question, estimand, estimator, estimate, and the question-led decision map | Rebuild around biological decisions; move detailed formula material downstream |
| `2.1-SMD-assumptions.qmd` | Core two-group continuous-response pathway | Reframe around directional, magnitude, and relative-change questions; integrate lnM conceptually |
| `2.2-lnOR-assumptions.qmd` | Binary-outcome pathway | Lead with biological event/risk questions, then distinguish lnOR and lnRR |
| `2.3-Zr-assumptions.qmd` | Continuous-gradient pathway | Lead with gradient and association questions, including the cost of discretization |
| `3.0-starting-extraction.qmd` | Bridge from estimand to extraction plan | Move earlier in the reader journey or embed its planning checklist near the opening |
| `3.1-universal-challenges.qmd` | Cross-cutting design and evidence issues | Retain as shared guidance; link to it from every question pathway |
| `3.2-smd-challenges.qmd` | Main extraction handbook | Reorganize by reported evidence and study design; add lnM-specific consequences where needed |
| `3.3-lnOR-challenges.qmd` | Binary-outcome extraction handbook | Preserve, but align headings with biological and reporting situations |
| `3.4-Zr-challenges.qmd` | Gradient/association extraction handbook | Preserve, but align headings with biological and reporting situations |
| `4-converting-effect-sizes.qmd` | Harmonization after biological compatibility is established | Strengthen warnings that mathematical conversion does not establish a shared estimand |
| `5-less-common-effect-sizes.qmd` | Variability, single-group, and genuinely uncommon extensions | Move lnM out as a stand-alone “less common” topic once integrated into the main SMD pathway; retain a cross-reference or concise reference entry |
| `6-escalc-cheatsheet.qmd` | Technical reference | Keep estimator-led and clearly label it as an appendix/reference tool |
| `7-simulating-non-gaussian-responses.qmd` | Advanced reconstruction module | Keep as an advanced extension and strengthen cautions about inference and unit of replication |
| `0-to-do-list.qmd` | Legacy task notes | Replace or cross-reference with this roadmap once the team agrees |
| `_quarto.yml` | Reader-facing navigation | Update only after chapter boundaries and names are approved |

## lnM integration checklist

- [ ] State the biological question lnM answers in one sentence.
- [ ] Define the reference point relative to which magnitude is evaluated.
- [ ] Explain what directional information is intentionally discarded.
- [ ] Contrast lnM with ordinary directional SMD using the same biological example.
- [ ] Contrast lnM with lnRoM; shared inputs do not mean a shared estimand.
- [ ] Document assumptions and edge cases, including zeros and sign changes.
- [ ] Confirm compatible study designs and sampling-variance estimators.
- [ ] Identify which SMD extraction recipes transfer unchanged to lnM.
- [ ] Mark recipes requiring lnM-specific transformations or cautions.
- [ ] Add a worked example carried from biological question through interpretation.
- [ ] Decide whether “special case of SMDs” is pedagogical shorthand or formal mathematical classification.
- [ ] Retain a concise appendix reference after moving the main explanation.

## Decisions for Erick and the team

### Narrative decisions

- [ ] Should SMD be described as the default estimator, or simply receive the greatest practical emphasis within the broader two-group continuous-response family?
- [ ] Should “biology first, statistics second” govern the entire tutorial or primarily the opening and SMD pathway?
- [ ] Do we want one recurring biological example across the tutorial, several domain-specific examples, or both?
- [ ] Should readers choose an estimand before seeing the names SMD, lnM, and lnRoM?
- [ ] How strongly should the tutorial recommend one estimator versus presenting decision-dependent alternatives?

### lnM decisions

- [ ] Approve the exact claim connecting lnM to SMDs.
- [ ] Approve the biological scenarios used to motivate magnitude without direction.
- [ ] Decide where the full lnM assumptions, formulas, and extraction guidance will live.
- [ ] Decide whether lnM should appear in the first decision figure alongside SMD and lnRoM.

### Scope decisions

- [ ] Confirm whether lnOR/lnRR and Zr remain full parallel pathways or become shorter secondary modules.
- [ ] Decide whether variability questions belong in the main question map.
- [ ] Decide whether conversions remain a chapter or become an advanced appendix.
- [ ] Decide how much experimental reconstruction belongs in the primary tutorial versus an advanced module.
- [ ] Confirm the intended reader: first-time meta-analyst, experienced practitioner facing messy data, or a layered experience for both.

### Editorial decisions

- [ ] Approve stable names for the biological-question categories.
- [ ] Choose the balance of plain-language explanation, mathematics, and R code in the main text.
- [ ] Decide whether internal notes, incomplete sections, and unresolved questions should be hidden from rendered output during revision.
- [ ] Agree on citation and technical-review responsibilities for new or strong recommendations.

## Implementation phases

### Phase 0 — Align on the estimands

Status: proposed

- Agree on the biological-question taxonomy.
- Approve the formal and pedagogical relationship among SMD, lnM, and lnRoM within the two-group continuous-response family.
- Identify claims requiring statistical or literature verification.
- Freeze major file moves until these decisions are recorded.

Exit criterion: Erick and the team approve a one-page narrative map and the intended place of lnM.

### Phase 1 — Prototype the reader journey

Status: not started

- Draft a new opening for `index.qmd`.
- Draft the first question-led decision map.
- Rewrite an outline—not full prose—for `1-effect-size-overview.qmd` and `2.1-SMD-assumptions.qmd`.
- Select recurring biological examples.

Exit criterion: a reader can move from a biological question to SMD, lnM, or lnRoM without first knowing those names.

### Phase 2 — Rebuild the SMD-centered core

Status: not started

- Reorganize the SMD assumptions and interpretation chapter.
- Integrate lnM into the main conceptual pathway.
- Reorganize SMD extraction challenges by design and available evidence.
- Preserve anchors or create redirects/cross-references where practical.
- Add worked examples and explicit interpretation statements.

Exit criterion: the main pathway is internally complete from question through calculation, diagnostics, and interpretation.

### Phase 3 — Align the secondary pathways

Status: not started

- Apply the same question-first pattern to binary outcomes and continuous gradients.
- Remove duplicated generic explanations where the shared chapter can carry them.
- Align terminology, decision points, and reporting advice.

Exit criterion: all principal pathways share the same conceptual sequence and vocabulary.

### Phase 4 — Harmonize advanced material and navigation

Status: not started

- Reframe conversion as a biological-comparability decision before a mathematical operation.
- Reorganize less-common effects after lnM is moved.
- Position reconstruction and simulations as advanced material.
- Update `_quarto.yml`, filenames if approved, cross-references, figures, and appendices.

Exit criterion: navigation and cross-links match the new narrative without orphaned or duplicated sections.

### Phase 5 — Review and validation

Status: not started

- Statistical review of definitions, formulas, recommendations, and compatibility claims.
- Biological review of examples and interpretation.
- Novice-reader review of the question-led journey.
- Render the full Quarto site and inspect links, figures, citations, code, and layout.
- Record remaining limitations and research gaps rather than presenting uncertain advice as settled.

Exit criterion: technical reviewers and representative readers can follow the tutorial and agree that its recommendations match its stated estimands.

## Tracking conventions

Use these labels for roadmap items:

- **Proposed:** ready for team discussion.
- **Agreed:** approved in principle.
- **Drafting:** prose or code is being revised.
- **Review:** ready for technical/editorial review.
- **Blocked:** requires a named decision or missing evidence.
- **Done:** revised, checked, rendered, and accepted.

For each substantive change, record:

- owner;
- affected file or section;
- biological question and estimand;
- decision or source supporting the change;
- review status;
- cross-links, figures, and code affected.

## Immediate next meeting agenda

1. Approve or revise the working narrative sequence.
2. Define what “SMD-centered” means pedagogically and mathematically.
3. Agree on the precise placement and description of lnM.
4. Approve the top-level biological-question map.
5. Choose one recurring example for SMD versus lnM versus lnRoM.
6. Decide the scope of the lnOR/lnRR and Zr pathways.
7. Assign owners for the Phase 1 prototype and technical checks.

## Current working agreements

- **Agreed in principle:** shift the narrative toward biological question first and statistics second.
- **Agreed in principle:** focus primarily on SMDs while organizing the core pathway around two-group continuous responses rather than treating SMD as the parent of all measures in that pathway.
- **Agreed in principle:** present lnRoM alongside SMD for continuous responses when the biological question concerns proportional change; distinguish it explicitly from the binary-outcome log risk ratio (lnRR).
- **Agreed in principle:** bring lnM into the main SMD-centered discussion rather than leaving it only among less-common effect sizes.
- **Still requiring approval:** the exact mathematical and pedagogical wording of lnM as a “special case of SMDs.”
- **Still requiring approval:** the final chapter structure, filenames, navigation, and degree of compression of secondary effect-size pathways.
