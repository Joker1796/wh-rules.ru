> **Статус:** закрыт 2026-07-18
> **Репозитории:** wh11ed
> **Итог:** содержимое трекера (миссии, вторички, твисты, диспозиции, размеры битвы) сверено
> с appdata; расхождения исправлены.

# Game Tracker rule-content audit — wh40k-appdata reconciliation

Context: following the faction/datasheet audit (see `AUDIT-PROGRESS.md`), the Game Tracker's
own rule content — missions, secondaries, twists, Force Dispositions, battle sizes, the 10
Core Rules stratagems, and per-detachment DP/Force Disposition — was reconciled against
`wh40k-appdata` the same way. `wh40k-appdata`'s `build-factions.mjs` was extended to expose
this content (previously not tied to any faction, so it never entered `factions/<slug>.json`)
as `factions/_core-content.json` + `dp`/`forceDisposition` on every detachment. `scripts/
sync-tracker.mjs` (mirrors `sync-appdata.mjs`) diffs it against `useTracker.js`,
`eventCompanion.js`, `battlefields.js` §15, `missions.js`, and all 29 `src/data/mfm/*.js`
files. Run it again after any future `wh40k-appdata` `data_version` bump —
`node scripts/sync-tracker.mjs`.

## Result

Force Dispositions (5), the 10 Core Rules stratagems, the 6 twists, and the
disposition-pair→primary-mission matrix (25 combos) are **byte-clean** against appdata — no
findings at all. The 25 primary + 18 secondary missions' *scoring values* are also correct
everywhere; the diff's per-row noise is wording drift only (see false-positive classes
below), verified by hand, not a single real VP/condition bug found.

Two real, confirmed issues:

1. **Battle sizes: Onslaught was missing.** appdata has 3 (Incursion 2DP/1000pts, Strike
   Force 3DP/2000pts, Onslaught 3DP/3000pts); `useTracker.js`'s `BATTLE_SIZES` only had the
   first two. Added.
2. **3 detachment DP values were wrong** (MFM-scrape data, not appdata's fault — this is
   `wh40k-appdata` confirming the correct value): `src/data/mfm/black-templars.js` had
   Bastion Task Force/Stormlance Task Force's `dp` **swapped** (3/2 instead of 2/3);
   `blood-angels.js` and `deathwatch.js` each had Stormlance Task Force at `dp: 2` instead
   of `3`. All 3 corrected against appdata's value (`space-marines.js`/`dark-angels.js`/
   `space-wolves.js` already had it right, confirming this was an isolated scrape/edit slip
   on those 3 files, not a systematic error).

## Known false-positive classes (don't re-report these as bugs)

- **Paraphrase, same VP.** wh11ed and appdata frequently word the identical condition
  differently — "at least one" vs "one or more", "enemy" vs "your opponent's", "&" vs "and"
  in headings ("First & Second Battle Round" vs "First and Second Battle Round"), "outside"
  vs "not within". Same rule, same VP. `sync-tracker.mjs`'s row-level diff still surfaces
  every such line (it can't tell paraphrase from a real change), so **check the VP number
  first** — if it matches, it's wording drift, not a gap. Examples hit during this audit:
  Consecrate, Death Trap, Delaying Action, Outmanoeuvre, Smoke and Mirrors, Purge and Secure,
  Locate and Deny, Centre Ground, Outflank, Battlefield Dominance.
- **Fixed/tactical `vpCap` collapsed into a boolean row.** Some secondaries carry the exact
  same scoring-criteria text twice in appdata — once as an uncapped per-model stepper (the
  "fixed" mode price) and once with `vpCap` equal to its own `vp` (so it can only ever
  trigger once — functionally a checkbox, this is the "tactical" mode price). wh11ed renders
  the capped copy as a plain "one or more X were destroyed" row instead of a capped stepper.
  Net scoring is identical either way. Hit on: A Grievous Blow, Bring It Down.
- **`isCumulative` bonus collapsed into flat mutually-exclusive tiers.** appdata sometimes
  scores a base condition plus a separate cumulative bonus row (e.g. Assassination: 3vp per
  destroyed CHARACTER + 1vp more if that CHARACTER's W≥4) — wh11ed pre-sums these into flat
  tiers instead (4vp if W≥4, 3vp otherwise: 3+1=4, same total). Check the arithmetic (base +
  bonus) before flagging. Same pattern on Defend Stronghold (3vp control home; +2vp
  cumulative if also no enemies in your deployment zone ⇒ wh11ed's flat 5vp tier).

## Explicitly out of scope (per plan)

- Mission `briefing` intro text (the ~26 cards with a WHEN DRAWN/OBJECTIVE ACTION intro
  paragraph above the scoring blocks) is not diffed word-for-word — appdata's
  `primary_mission_action`/`secondary_mission_action` tables *do* carry this content
  (discovered mid-audit; the original plan assumed appdata had none), but folding it into
  `_core-content.json` and `sync-tracker.mjs` was deferred to keep this PR's scope to
  scoring-value correctness. Worth a follow-up pass.
- Attacker/defender duplication in `missions.js`'s `secondary[]` (36 entries for 18 distinct
  missions) — a code-structure question, unrelated to canon accuracy.
- MFM as the source of unit/enhancement *points* — untouched; only `dp`/`forceDisposition`
  were cross-checked against appdata.
