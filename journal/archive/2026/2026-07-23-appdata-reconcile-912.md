> **Статус:** закрыт 2026-07-25
> **Репозитории:** wh11ed, wh40k-appdata
> **Итог:** все 5 задач влиты (PR #252), задеплоено в v2.1.0/2.1.1. Историческая справка о том,
> как выглядел хендофф между двумя машинами.

# Appdata reconciliation (912) — handoff for machine 2

> **DONE (2026-07-25).** All 5 tasks (Layers 1-4 + GSC tracker rework, PR #252) are merged to
> `main`. Nothing left from this brief — kept here as a historical record of the reconciliation
> policy/conventions. Next step is machine 1's `BUMP=minor npm run deploy` (2.1.0, both domains).

You are **machine 2**. Machine 1 is the coordinator. This file is your full brief — read it after
`git pull` and work only your assigned slice. When in doubt, do NOT guess: skip and note it.

## What & why

`npm run sync` historically compared datasheet **ability names** and points, but **never** compared
datasheet **keyword lists** or **full rule text**. So over several app versions wh11ed drifted from
the canonical `wh40k-appdata` on: keywords (missing/extra/renamed), datasheet ability wording, and
faction rule text. We are catching up all of it. The 909→912 delta itself was a no-op; this is
**accumulated** drift.

## Policy (non-negotiable)

- **`wh40k-appdata` is canon. Mirror it VERBATIM.** If appdata and wh11ed disagree on a real value,
  change wh11ed to appdata — even for pre-existing drift.
- **Keep appdata's exact spelling, even when it looks like a typo** (e.g. appdata keyword
  `Ghazgkull Thraka` without the `h`, `Kustom Boost-blasta`). Rationale: never risk mistaking a real
  rules change for a typo. Do **not** "correct" appdata.
- **Internal keywords `Frame` / `Mobile` are kept too** — add them where appdata has them.
- **Do NOT strip glosses or layout markup** (`[gloss:…]`, `**bold**`, ALL-CAPS keywords, cross-refs).
  Comparison normalizes markup; the stored data keeps it.
- **Keywords stay English in both locales** — the RU datasheet files carry no `keywords`, so keyword
  edits are **EN only** (`src/data/datasheets/<slug>.js`, not `ru/`).
- **Ability / rule TEXT changes are bilingual** — update EN **and** RU, keeping EN↔RU block parity
  (same count of `▪ ◈ → ### ◆ [img:]` markers) and balanced `**`. ALL-CAPS keywords and
  unit/detachment/stratagem names stay English in RU. Appdata is English-only, so RU is authored by
  hand following the project conventions (see `wh11ed/CLAUDE.md` → *Bilingual content conventions*).
- After any batch: `npm run build` must pass and `npm test` stay green.

## Appdata location

Sibling repo `../wh40k-appdata` (already at data_version 912). If it's elsewhere, set
`WH40K_APPDATA_PATH`. Pull it first so you're on 912.

## Layer 1 — keywords (tool ready, do this first)

Reconcile datasheet `keywords[]` to appdata verbatim with the tool:

```bash
node scripts/appdata-keywords.mjs --faction <your,slugs>          # dry-run, review
node scripts/appdata-keywords.mjs --apply --faction <your,slugs>  # write
```

The tool edits only the per-datasheet `keywords` array, keeps formatting, and **refuses** any
datasheet whose current keywords don't match what it expects (name collision / already edited) —
those print as `SKIP …`. **Handle every SKIP by hand** (find the right datasheet, set its keywords to
appdata's list verbatim). Then `npm run build`.

### Your assigned factions (machine 2)

```
grey-knights, imperial-knights, necrons, orks, space-marines, tau-empire, tyranids
```

Machine 1 takes: adeptus-custodes, adeptus-mechanicus, astra-militarum, black-templars,
blood-angels, chaos-knights, dark-angels, death-guard, deathwatch, drukhari, emperors-children.

Known SKIP you'll hit: `tyranids/Raveners` (two Ravener datasheets collide) — fix by hand.
Necrons `Catacomb Command Barge` (+Noble) is already done by machine 1 on `sync/appdata-912`.

## Layer 2 — datasheet ability text · Layer 3 — faction rule text (UNLOCKED)

Tool: `scripts/appdata-text-diff.mjs` (report-only; fixes are manual, EN + RU).

```bash
node scripts/appdata-text-diff.mjs --datasheets --faction <slugs> --full   # Layer 2
node scripts/appdata-text-diff.mjs --factions   --faction <slugs> --full   # Layer 3
```

It compares SEMANTIC text (glosses/markup normalized away), so every reported line is a real
wording difference. Worst-similarity first; `--full` prints appdata's text already converted to
wh11ed markup (`**bold**`, CAPS keywords, `▪`) — use it as the new EN wording **verbatim**, with
these touch-ups only:
- Normalize appdata's exotic hyphen `‐` to `-`; keep our `\n▪ ` line form for bullets.
- Keep an existing `[gloss:…]` token only if the surrounding wording is unchanged; don't add new ones.
- Old "intentional divergence" comments (e.g. Necrons header re Faction-Pack/wahapedia) are
  OBSOLETE where appdata now differs — appdata wins; update the comment.
- RU: retranslate to mirror the new EN (block parity, balanced `**`, ALL-CAPS keywords and
  unit/detachment/stratagem names stay English).

Scope today: ~230 datasheet-ability + ~656 faction-rule mismatches, most ≥95% (small drift).
Work faction by faction, commit per faction, `npm run build` + `npm test` after each.

### Status 2026-07-25 — Layers 1-4 DONE and merged to main. Only task 5 (GSC) is left.

Tasks 1-4 below are **complete and merged** (machine 1 reviewed + merged #246, #247, #251 — the
last one recreated from #250 after its stacked base branch got deleted on #246's merge and
auto-closed it, same content — and #248). `main` is green: `npm run build` clean, `npx vitest run`
194/194, `npm run parity` 0 errors (2 pre-existing informational notes untouched by this
reconciliation, not blockers: `titan-legions` armyRule `**` count EN 24 vs RU 0, and drukhari
`Kabalite Agonysts`/`Reaper's Wager` enhancement `**` count EN 4 vs RU 8 — worth a follow-up pass
but out of scope for 912).

~~1. Layer 2, machine-2 slice~~ — done (#246).
~~2. Missing abilities (Data-severed, Hail of Bolts)~~ — done (#247).
~~3. Layer 3, all factions~~ — done (#246 + #251).
~~4. Changelog bullet~~ — done (#248).

**5. GSC army tracker rework — still open, this is now the only remaining item** (src/data/armyTrackers/genestealer-cults.js +
   ArmyTrackerCard/ArmySpendModal + useTracker `player.army`):
   - «+2» button for the Deeds That Speak to the Masses enhancement — visible/usable ONLY in
     battle round 1 (it's a starting-pool bonus).
   - Spending points must RECORD the resurrected unit: e.g. `army.resurrected: [{label, cost}]`
     (keep it `.passthrough()`-compatible with the backend envelope).
   - New accordion BELOW «Как работает» (same `army-acc` + CollapseTransition design): list of
     resurrected units + an undo button per entry (refunds the cost, removes the entry).
   - Show the resurrected list in the results recap (ArmyRuleSummary) for GSC.
   - When done, add ONE more changelog bullet for it (same 2.1.0 entry, EN+RU aligned) — don't
     reopen/re-edit the already-merged 912 bullet, append a new line.

Branch off current `main`, PR titled e.g. `feat/gsc-tracker-rework`, do NOT merge — machine 1
merges. **Important: base the PR on `main`, not on another open PR's branch** — a stacked base
branch gets deleted (and the PR auto-closed by GitHub, unrecoverable — has to be recreated) the
moment the PR it stacks on gets merged with `--delete-branch`. After this lands: machine 1 deploys
2.1.0 with `BUMP=minor npm run deploy` (both domains, per MIGRATION.md) — this is now the only
remaining thing before that deploy.

## Workflow

1. `git pull` (both this repo and `../wh40k-appdata`).
2. Branch: `git checkout -b sync/kw-m2` off the latest `sync/appdata-912` (or `main` once merged).
3. Run the tool `--apply` on your factions; resolve every SKIP by hand.
4. `npm run build` (green) + `npm test` (green).
5. Commit per faction or as one "sync: mirror keywords to appdata 912 (machine 2 slice)".
6. Push, open a PR to `main`, and tell machine 1 the branch/PR + any SKIPs you couldn't resolve.

**Do not merge to `main` yourself** — machine 1 coordinates merges.
