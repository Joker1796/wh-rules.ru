> **Статус:** закрыт 2026-08-20
> **Репозитории:** wh11ed, wh40k-appdata
> **Итог:** 5 сверочных скриптов и Combat Patrol (24/24 фракции) в проде; проверки живут в
> `npm run sync` и гоняются перед каждым релизом.

# appdata coverage plan — cross-machine handoff

**Principle:** wh11ed is a rules resource; `wh40k-appdata` is canon (see
[[feedback_appdata_canon]] / `APPDATA-SYNC-LESSONS.md`). We should pull and guardrail-check
**everything appdata carries that wh11ed also carries** — not just faction datasheets/detachments,
but the Game Tracker's mission data, the core rulebook, and the Event Companion. Anything we render
that appdata also encodes should have a report-only sync script watching it, the same way
`sync-appdata.mjs`/`sync-faction-text.mjs`/`sync-core.mjs`/`sync-tracker.mjs`/
`sync-enh-bodyguards.mjs`/`sync-leader-units.mjs`/`sync-detachment-details.mjs`/
`sync-wargear-options.mjs`/`sync-ally-inclusion.mjs` already do.

This file lives in the repo (not assistant memory) specifically so it's readable from **either
machine** — memory doesn't sync between them (see `[[reference_nested_git_repos]]`,
`[[feedback_git_stash_safety]]`). Delete/trim sections as they're completed, same convention as
`DATASHEET-DRIFT-TODO.md` (now gone) and `MIGRATION.md`.

## Re-verified against app v2.3.1 (data_version 913, 2026-07-28) — clean

wh40k-appdata refreshed from v2.3.0 (912) to v2.3.1 (913) — a small, targeted diff (33 tables, 5
faction bundles: adepta-sororitas/adeptus-astartes/agents-of-the-imperium/emperors-children/
necrons; notably `primary_mission_objective_scoring.json`, `rule_container_component.json`,
`faq.json`/`faq_config.json`, `stratagem.json`). Re-ran everything this session touched:

- `sync-core.mjs`: 274 findings, identical set to the already-fully-triaged one — 0 new.
- `sync-tracker.mjs`: 0 new findings across missions/stratagems/twists/battle sizes/dispositions/
  detachments. (The one changed scoring row, `primary_mission_objective_scoring.json`'s
  stepper→checkbox fix, belongs to "Uphold Your Vows" — not one of the 25 Chapter Approved primary
  missions in `_core-content.json`, out of scope.)
- `scripts/extract-layout-images.mjs`: re-run against the new `.xapk` — all 90 images extracted,
  resulting webp **byte-identical** to what's committed (`git status` showed zero changes after the
  full `images:webp` pipeline) — the app didn't touch these assets in this point release.
- `sync-event-companion.mjs`: found and fixed a real script bug (title-fuzzy-match had no plural/
  singular normalization — see `APPDATA-SYNC-LESSONS.md` lesson 36), no actual content gap.

**Also reviewed** (scoped to just the 5 changed faction bundles, per user direction — not the full
30-faction suite): `sync-appdata`/`sync-faction-text` structural+prose diffs for adepta-sororitas,
space-marines (adeptus-astartes), imperial-agents (agents-of-the-imperium), emperors-children,
necrons. Found and fixed two real, pre-existing points gaps (see `APPDATA-SYNC-LESSONS.md` lesson
37): (a) Assassins + Necron C'tan missing their higher price in a specific detachment (Veiled Blade
Elimination Force / Pantheon of Woe) — added the missing tier. (b) 8 units shared between
space-marines.js and a Chapter file (Assault Intercessor Squad, Assault Intercessors/Vanguard
Veteran Squad/Bladeguard Veteran Squad With Jump Packs, Captain/Chaplain With Jump Pack, Outrider
Squad, Repulsor Executioner) cost more for Blood Angels specifically (Repulsor Executioner also for
Deathwatch/Space Wolves/Dark Angels) — added a new `pointsOverrides` mechanism (id → replacement
`points` array, exported per-Chapter-file, applied by `loadDatasheets`) since the shared-fold
architecture had no way to express a per-Chapter price override before this.

**Not re-verified this round** (pre-existing, ongoing, separate from this session's work — flagged
here since data_version did bump and 5 faction bundles changed, not investigated further): the
remaining 25 factions in the `sync-appdata`/`sync-faction-text`/`sync-ally-inclusion`/
`sync-army-rule-coverage` suite surfaced its usual mix of already-known/resolved findings plus one
new one — Tau Empire's "Drones" army rule (9% word overlap, appears to be missing wh11ed content
about placing a Drone token + Shield Drone's +1W). Worth a look next time faction content is being
triaged.

## Audit of current coverage (done 2026-07-27, cross-referenced against wh40k-appdata's
`SCHEMA.md`, 141 tables total)

**Already covered:**
- The ~48 tables `wh40k-appdata/scripts/build-factions.mjs` folds into the flat
  `factions/<slug>.json` bundle (datasheets, abilities, keywords, wargear profiles, invulnerable
  saves, army rules, detachment rules/stratagems/enhancements, unit composition) — read by
  `sync-appdata.mjs` (structure) and `sync-faction-text.mjs` (prose).
- `_core-content.json` (battle sizes, force dispositions, primary/secondary missions, twists, core
  stratagems) — read by `sync-tracker.mjs`. Full audit 2026-07-28: battle sizes/dispositions/
  disposition-map/detachments (341 checked) all clean. Found and fixed one real script bug — the
  mission-row comparison keyed a `Map` by normalized row text, which silently drops a row whenever
  two rows share identical text (A Grievous Blow/Bring It Down/Engage On All Fronts legitimately do:
  same condition, fixed-tier vs tactical-tier vp) — a future appdata vp change to the dropped row
  would have been invisible. Fixed by grouping into arrays and pairing by vp-sorted position instead
  of a single-key Map. Added two checks that never existed before: (1) primary-mission round-gating
  — cross-referenced every block's heading-derived `BLOCK_ROUNDS` (useTracker.js, now exported) against
  appdata's explicit per-objective `scorablePeriods` field; 0 mismatches across all primary missions
  (secondary missions carry no `scorablePeriods`, gated by heading text alone, already heading-
  checked). (2) Full-text diff of core stratagems' `when`/`target`/`effect`/`restrictions` (previously
  only name+CP were compared) and twists' body+note vs `rules` — found a real rules bug: Crushing
  Impact (15.06) said to roll dice equal to the **enemy** model's T characteristic, when the correct
  rule (confirmed against appdata AND the source PDF as arbiter, `sources/WH40k_11ed_CORE-
  Rules_01-06-2026.pdf`) rolls against **your own** MONSTER/VEHICLE's T — fixed in `battlefields.js`
  (EN only; the RU translation was already correct). All other stratagem/twist findings confirmed
  cosmetic paraphrase (also fixed a `normText()` bug: stray single `*` italic markers from appdata's
  Designer's Note weren't stripped, causing 5 of 6 twists to false-positive). All mission-content
  findings (primary + secondary) reconfirmed as the documented paraphrase/vpCap-collapse/cumulative-
  bonus false-positive classes, same VP both sides — zero scoring bugs found in mission data itself.
- `_core-rules.json` (Core Rules publication, sections 01-25, incl. 24 Core Abilities/`reference.js`
  — confirmed it DOES run, resolving the "sync-core.mjs section 24" investigation task below) —
  read by `sync-core.mjs`. Upgraded 2026-07-28 from a word-overlap ratio (triage-only, per its own
  original header) to a real word-level diff (same recipe as `sync-faction-text.mjs`/`sync-event-
  companion.mjs`) — the user specifically wanted whole-body comparison, and the ratio had already
  been shown to both under- and over-report elsewhere. Also fixed a systematic false-positive class:
  appdata's own `<b>Example:</b>` inline label was flagging as "missing" against every wh11ed
  `example` field, which never carries that label (it's CSS-generated, `.example-block::before`).
  First full run: 337 findings across sections 01-25 (296 numbered appdata rules). Triaged
  2026-07-28: fixed 4 more script bugs (missing `coreAbilities` `example` field, "Designer's Note:"
  CSS-label false positive same as "Example:", `muster.js`'s oddly-placed `battleSizeTable`, stray
  HTML entities/`<k>` tags) — see `APPDATA-SYNC-LESSONS.md` lesson 32 — dropping the count to 277,
  plus applied ~5 real content fixes (CHARACTER can't be revived via healing, AIRCRAFT exception on
  large-model Strategic Reserves set-up, empty DEDICATED TRANSPORT destruction, a "bodyguard"
  wording gap, plus [ANTI]/[BLAST]/etc. wording nits). Second triage pass 2026-07-28 read all ~78
  distinct diffing sections individually (01-25) and found 2 more real gaps: reviving a model into
  an embarked unit was missing the Transport Capacity check (01.02.03), and Fill Your Army Roster
  (25.04) was missing the exception letting an Incursion battle take a single 3DP detachment. The
  rest confirmed harmless: appdata-side extraction artifacts (missing spaces/stray HTML entities
  from its own raw text), diagram-based worked examples wh11ed already shows as an image (Surge
  Moves/Taking to the Skies/Battle-Shock/Fight Phase/Terrain/Plunging Fire/etc.), procedural
  step-summaries redundant with wh11ed's own subsection navigation, wh11ed-only FAQ additions and
  hand-written section intros/descriptions that legitimately don't match appdata's literal wording,
  and the already-verified Onslaught battle-size row (25.03, confirmed against `useTracker.js`'s
  `BATTLE_SIZES`). **Now exhausted** for this `data_version` (912) — a re-run after the next appdata
  bump would need a fresh read since wording nits like "cannot have" vs "cannot be given" were left
  as-is (cosmetic, not fixed).
- `conditional_keyword` — `gen-conditional-keywords.mjs` (`src/data/conditionalKeywords.json`).
- `detachment_detail` + `detachment_detail_bullet_point` — `sync-detachment-details.mjs` (added
  2026-07-27, see `APPDATA-SYNC-LESSONS.md` lesson 21).
- `enhancement_bodyguard_group(+_datasheet/_keyword)` — `sync-enh-bodyguards.mjs`.
- Leader/Support prose bullet lists — `sync-leader-units.mjs` (deliberately uses prose, not
  `datasheet_bodyguard_group*`, because that table has coverage gaps — see its own header comment).
- `faq` + `faq_config` — `gen-faction-faq.mjs` → `src/data/factionFaq.json`.
- Event Companion publication (`rule_container`+`rule_container_component` under the "Event
  Companion" publication, id `085bb508-…`) + `mission_twist` (the 6 Twists) — `sync-event-
  companion.mjs` (added 2026-07-28, resolves the "Event Companion vs appdata" investigation task
  below). appdata HAS full prose for this — 180 rule_containers across 4 editions (main, Teams,
  Doubles, Dominatus); wh11ed implements only main+Teams (Doubles/Dominatus are a deliberate
  product-scope gap, inventoried only, not diffed). Full-text diff (not a title/number check —
  the user specifically wanted whole-body comparison so a reworded or newly-added rule can't hide
  behind a same-named stale entry), matched per-container by normalized title with a word-overlap
  fallback for spelling drift (appdata's own "LEAVES THE BATTELEFIELD" typo). First run surfaced
  real gaps: wh11ed is entirely missing the "Generating Command Points" rule (max 1 CP/round from
  non-Core sources, excluding Core CP) in both the main and Teams editions, plus several wording
  drifts (rewordings, not errata — appdata's prose was revised since wh11ed's transcription) across
  Mission Sequence steps, Terrain Layouts intro, and Pairings/Rankings.

  **RESOLVED 2026-07-29.** "Generating Command Points" was already added to `eventCompanion.js`'s
  Main edition (`id: 'generating-cp'`) in an earlier session — this paragraph's "not yet applied"
  note was stale. Re-ran the script fresh and triaged every remaining flag by hand: the ~15
  Main-edition "text differs" entries (Mission Sequence steps, Terrain Layouts intro,
  Pairings/Rankings) are all cosmetic paraphrase or redundant connective filler ("that is", "note
  that", a transition sentence the page's own step-by-step layout already implies) — none drop
  actual rules content. The Teams edition's ~20 "+ missing in wh11ed" flags (steps 3-13, the
  sequence-intro heading, "14. TEAM SCORING", the 5 glossary containers, "Pairings and Rankings")
  are also all confirmed non-issues: Teams deliberately condenses identical-to-Main content into one
  summary paragraph (`teams-sequence-note`, cross-refs back to Main) instead of re-transcribing it,
  and "14. TEAM SCORING" is a title-matching artifact (wh11ed splits it across two differently-titled
  sections that do cover the content). Extended the script's own header comment with this finding so
  a future run doesn't need to re-derive it. **No content changes needed — this item is closed.**
- `loadout_choice(_set/_wargear_item)`, `limited_wargear_choice(_set/_wargear_item)` + `wargear_limit`,
  `all_model_wargear_choice(_set/_wargear_item)`, `base_miniature_loadout(_wargear_option)` —
  `sync-wargear-options.mjs` (added 2026-07-28). Presence-only (not a structural 1:1 match — see
  its own header). Tuned out several false-positive classes across two triage passes
  (curly-quote/hyphen normalization, word-form numbers ("twice"/"up to two"), redundant whole-unit
  scaling caps — both the family-1 `miniatureId: null` case AND family-2 sets that duplicate a
  family-1 set's items (Tau Crisis suit drones), leading articles, irregular -y→-ies plurals, the 5
  SM-Chapter sourceIds fallback). Down to **10 flags, every one individually verified** (not just
  pattern-matched) — see `APPDATA-SYNC-LESSONS.md` lesson 23 for the full re-verification pass
  (2026-07-28, prompted by a sanity-check request — the first write-up of this list called two of
  these "plausible naming variants" without actually checking, which was too hasty):
  - **imperial-agents' "Nuncio-acquila" ×3** — CONFIRMED appdata self-contradiction: the
    `wargear_item` catalog name has a typo ("Nuncio-**acquila**"), but that same item's OWN ability
    ruleText (`agents-of-the-imperium.json`'s `wargear[].ruleText`, the Designer's Note) spells it
    "Nuncio‐**aquila**" — matching wh11ed exactly. wh11ed is right; the catalog name is the typo.
  - **blood-angels' Death Company Dreadnought "Brutalis fists/bolt rifles"** — CONFIRMED appdata
    self-contradiction, a **new failure mode**: the structural `base_miniature_loadout_wargear_option`
    row for this datasheet points at the *generic* `wargear_item` ids ("Brutalis fists"/"Brutalis
    bolt rifles", shared with the plain `Brutalis Dreadnought` chassis) instead of this datasheet's
    own Blood-Angels-renamed ids ("Blood fists"/"Blood fist bolt rifles") — while the SAME
    datasheet's flat bundle (`blood-angels.json`'s `wargear[]` array, generated from a different
    appdata pipeline stage) correctly has "Blood fists"/"Blood fist bolt rifles". wh11ed already
    says "blood fists" — matches the correct (flat-bundle) side, not the buggy join.
  - **leagues-of-votann's Hekaton Land Fortress "Panspectral Scanner"** — this one WAS a real
    wh11ed typo (not appdata's fault this time — its flat bundle agrees with itself, one word):
    the datasheet's own wargear-ability name was already correctly "Panspectral Scanner" elsewhere
    in the same file, only the `loadout` string's inline mention had drifted to "pan spectral
    scanner" (two words, lowercase). **Fixed**, EN+RU.
  - **Structural per-hardpoint splits, individually re-traced against wh11ed's own `loadout`/
    `options` text (not just categorized by pattern)**: Battlewagon's "3" — the appdata set's 3
    items (`'Ard Case`/`Grabbin' klaw`/`Wreckin' ball`) are exactly the 3 bullets under "any of the
    following," so the cap is self-evident from the list length, no digit needed. Deff Dread's "4"
    — `loadout` literally states "2 big shootas; 2 dread klaws" = 4 independently-swappable
    mounts, matching appdata's limit=4 exactly. War Dog Moirax/Armiger Moirax/Chaos Warhound
    Titan/Warhound Titan's "2" — each states its 2 weapon-mount swaps as two separate full
    sentences ("This model's X can be replaced with…" / "…Y can be replaced with…"), so "2" is the
    count of sentences, not an omitted total.
- `keyword_restriction_group(+_keyword)`, `restriction_group_detachment_limit`,
  `detachment_excluded_datasheet`, `faction_keyword_excluded_datasheet` —
  `sync-roster-restrictions.mjs` (added 2026-07-28). Before writing any checking logic, all 16
  `keyword_restriction_group` rows were read by hand against the actual wh11ed files — every one
  was already present, correctly worded: Patriarch's "SUPREME COMMANDER" ("You cannot include more
  than one PATRIARCH model…"), Emperor's Champion's "CHOSEN OF THE EMPEROR", Death Jester/
  Shadowseer/Troupe Master's self-referential "TRAVELLING PLAYERS" ("…you cannot include more than
  one of this model…", including both detachment overrides — Ghosts of the Webway/Serpent's Brood's
  "up to three of each"), Commander Farsight↔Ethereal's and The Yncarne/Yvraine/The Visarch's
  mutual-exclusion text, Houndpack Lance's "three or more WAR DOG units", and Sicarius/Marneus
  Calgar/Commissar Graves already covered by the core EPIC HERO limit footnote (`muster.js` 25.04's
  battleSizeTable footnote — no per-unit text needed or expected). **No content debt at all** —
  same pattern as script #2's ally-inclusion rows (see [[feedback_appdata_canon]] /
  [[feedback_verify_dont_assert]]). The script itself needed several false-positive fixes once
  built (self-referential "this model" phrasing, spelled-out numbers ("three" not "3"), a fuzzy
  substring fallback for named-character keywords that don't equal the datasheet's exact title —
  "Sicarius" → "Cato Sicarius").
  The excluded-datasheet tables (23+23 rows) initially looked like they'd surfaced one genuine gap
  — Black Spear Task Force's own rule body never explicitly bans Watch Master/Corvus Blackstar/
  Watch Captain Artemis/Deathwatch Kill Team, unlike appdata's row for it — but tracing those
  specific datasheet ids back to `wh40k-appdata/tables/datasheet.json` showed they're the
  **Codex: Imperial Agents**-printed versions of those same-named units (different ids from the
  Index: Deathwatch versions already in `deathwatch.js`), already banned wholesale by this
  faction's own armyRule ("cannot include any Agents of the Imperium Deathwatch units"). A 4th
  false "missing" report in this same investigation, caught the same way as the previous 3 — see
  [[feedback_verify_dont_assert]]. 4 other faction-level exclusions similarly resolve to a category
  ban (Black Templars' Psyker ban covers its 3 excluded Librarian variants; Chaos Daemons' Shadow
  Legion "Thralls of the First Prince" Daemon Prince/Epic Hero ban covers its 14 named exclusions)
  or a pre-existing structural equivalent (Imperial Knights' Sir Hekhtur already carries no
  factionKeywords/points in wh11ed — an ejected-pilot model, not independently includable; Emperor's
  Children's Khorne Lord of Skulls exists only in `world-eaters.js`; Space Wolves' 4 excluded Codex:
  Space Marines units are simply absent from its `sharedUnitIds` Chapter-fold list — see CLAUDE.md's
  "SM-Chapter datasheet dedup"). All 6 are encoded as a `KNOWN_EQUIVALENT` allowlist in the script
  (with the specific verification each one needed) so they don't false-flag every run.
  **Not covered:** `unit_composition_required_detachment`/`_required_faction_keyword` (83 rows) —
  structural "which faction/detachment can field this points bracket at all" data, closer to the
  datasheet-filing question `sync-appdata.mjs`/the datasheet-drift reconciliation already cover
  than to a prose restriction (confirmed by spot-checking a few resolved rows — e.g. every Blood
  Angels-required row is simply a Blood Angels-only datasheet, already correctly filed under
  `blood-angels.js` and nowhere else). Reported as a plain count, not hard-flagged; worth a closer
  look only if picked up as its own investigation later.
- `enhancement_required_keyword_group(+_faction_keyword/_keyword)`, `enhancement_excluded_keyword`,
  `enhancement_required_wargear_item`, `enhancement_datasheet_ability` —
  `sync-enhancement-restrictions.mjs` (added 2026-07-28). An enhancement's leading "X model/unit
  only[, excluding Y models]" clause. First version reconstructed the expected wording purely from
  the structural join (fk + kw names, unioned across a multi-group "X or Y" row) and produced **26
  false positives out of 28 flags** on the first run — the join and appdata's own prose routinely
  disagree in ways that are not wh11ed bugs: a redundant containing-faction name omitted when the
  keyword is already faction-exclusive ("Tech-Priest model only", no "Adeptus Mechanicus"; same for
  Militarum Tempestus Officer, Watch Master/Captain/Techmarine, Kâhl, Thousand Sons Psyker), a
  different-but-equally-valid keyword the same single datasheet also carries (Brôkhyr Iron-master's
  enhancement is grouped under keyword "Brôkhyr" in appdata but its own prose says "IRON-MASTER"),
  redundant OR-alternatives already implied by a broader one (Bladeguard Ancient ⊂ Ancient), a
  singular/plural mismatch between the keyword catalog and the sentence ("Monster" vs "excluding
  MONSTERS models"; "Scout Sentinels" the datasheet name vs "SCOUT SENTINEL unit only"), and a
  stray placeholder keyword "DNU" ("Do Not Use") sitting in appdata's own catalog, joined to 8
  otherwise-unrelated rows across Necrons' C'Tan Shards and Imperial Agents' Assassins — an appdata
  data-quality artifact, not a real eligibility name. **Rebuilt as a two-tier check** instead: (1)
  when appdata's OWN rules prose already states an "only" clause, compare wh11ed's clause against
  THAT TEXT directly (significant-word overlap) — sidesteps every disagreement above; (2) only when
  appdata's prose is genuinely silent (states no restriction anywhere) does it fall back to the
  structural reconstruction — this silent case is the entire reason the script exists (see next
  paragraph), so it's still checked, just not the default path. After the rebuild: 909 of 912
  bridged enhancements checked against appdata's own prose, 3 against structural data, **0 flagged**
  (one remaining false positive — Necrons' "Animus Damper" reads appdata's own "VOIDDRAGON" missing
  a space vs the datasheet's correctly-spaced catalog name "Void Dragon", matching wh11ed and every
  other reference — allowlisted as a confirmed appdata prose typo, same class as the Nuncio-acquila
  precedent).
  **This is the whole reason the script exists:** appdata's own prose is sometimes completely
  silent about an eligibility restriction that only the structural join states — found twice this
  session. Necrons' "Veil of Darkness" (found once already, before this script existed, by luck of
  asking the right follow-up question — the original motivating precedent for this script) was
  already fixed. Building this script found a second, previously-unknown instance: space-marines.js's
  "Scroll of Proclamation" was missing "Adeptus Astartes model only." in EN — and RU
  (`ru/space-marines.js`) already had "Только модель Adeptus Astartes." in the equivalent position, so
  this was a **one-sided EN gap**, not a missing translation; fixed 2026-07-28. `enhancement_excluded_
  keyword` (32 rows) and `enhancement_required_wargear_item` (1 row) were checked by hand — every row's
  own appdata prose already states its exclusion/required-wargear clause inline in the same "only"
  sentence, so tier 1 covers them with no separate logic needed. `enhancement_datasheet_ability` (6
  rows, all the same "Deep Strike" core ability) also always has an "only" sentence in prose, covered
  by tier 1. `enhancement_wargear_item_profile` (2 rows — enhancements that grant a specific weapon
  profile, a different question from eligibility) checked by hand, already correct, left out of the
  automated check.
- `army_rule` (via each faction's flat `armyRules[]` bundle export, not the raw `army_rule_
  faction_keyword`/`army_rule_excluded_from_command_bunker_faction_keyword` tables originally
  planned for this slot) — `sync-army-rule-coverage.mjs` (added 2026-07-28). Reading the raw rows by
  hand first (per this file's own standing advice) showed those two tables are Command-Bunker-app UI
  bookkeeping — which of a Chapter's OWN factions can select a given army-rule ROW, and whether that
  row is hidden from a digital army-builder's selectable list — not roster restrictions or excluded-
  content. `army_rule` itself has no body/`rules` field at all (see `SCHEMA.md`); the actual prose is
  in each faction's flat bundle `armyRules[]`, where **19 factions carry 2+ distinctly-named army
  rules** (e.g. adeptus-astartes: "Oath of Moment" + "Space Marine Chapters"; dark-angels: "Oath of
  Moment" + "The Deathwing" + "The Ravenwing" + "The Unforgiven"). wh11ed deliberately merges these
  into one combined `armyRule.body` per faction (`### ` subheadings), but `sync-faction-text.mjs`'s
  army-rule comparison only gathers candidates whose NAME fuzzy-matches wh11ed's single
  `armyRule.name` — so a second, differently-named rule can go completely unrepresented with nothing
  ever flagging it. Built a new check instead: for every distinctly-named, non-stub army rule (a pure
  cross-reference like "described in full on the Army Rules page of Codex: Space Marines" carries no
  content of its own to check), does its distinctive vocabulary appear somewhere in the faction's
  whole text (armyRule + every detachment rule, since Deathwatch/Space Wolves place a mono-Chapter
  restriction on each detachment rather than the top-level armyRule)?
  **2 real, previously-unknown gaps found and fixed 2026-07-28:** `space-wolves.js` was completely
  missing **"Curse of the Wulfen"** — not a phrasing nit, a genuine passive ability (+1/+3 Objective
  Control on Infantry/Vehicle models near a friendly Space Wolves Character (excluding Wulfen) or Wolf
  Priest) was absent from the entire file. `blood-angels.js` was completely missing **"The Sons of
  Sanguinius"** (the mono-Chapter restriction + Designer's Note) — every other Chapter book had SOME
  form of this (Dark Angels' "The Unforgiven" in full, Space Wolves' "Sons of Russ" partially,
  Deathwatch's own detachment text), Blood Angels had none at all. Both merged into their faction's
  combined `armyRule.body` the same way Dark Angels already does it. Both are EN-only factions
  (`ru: en`), so no RU parity work was needed.
  A crude word-overlap check is a blunt instrument here — free-text prose, not a closed keyword
  vocabulary — so it's deliberately loose (flag under 85%) and produced several more candidates that
  were each read by hand and confirmed NOT gaps (encoded as a `KNOWN_EQUIVALENT` allowlist): Death
  Guard's "Nurgle's Gift (Aura)" (present verbatim, low score is from reworded per-Plague flavour
  italics); Space Wolves' "Sagas" (a framing sentence only — every detachment already implements its
  own named Saga mechanic under its own heading) and "Sons of Russ" (the hard restriction is already
  boilerplate on every detachment, only the soft Designer's Note is omitted, deliberately); World
  Eaters' "Pact of Blood" (a muster-time note that Blood Legions isn't independently selectable —
  wh11ed has no standalone page for it either, for the same reason, already covered by script #2's
  ally-inclusion work). **One confirmed real gap, out of scope for THIS script but investigated and
  fixed the same day:** Tau Empire's "Drones" rule includes "Shield Drone: Add 1 to the bearer's
  Wounds characteristic" — a real wargear-level mechanic that appeared nowhere in `tau-empire.js`'s
  datasheets. Traced structurally (`loadout_choice`/`limited_wargear_choice` joined to the "Shield
  Drone" `wargear_item`) to **11 datasheets** that offer it as an equip option (Breacher Team, Strike
  Team, Ethereal, Pathfinder Team, Broadside Battlesuits, Cadre Fireblade, both Commander battlesuit
  variants, all 3 Crisis Battlesuit variants) — every one of them was missing the plain-English
  explanation of what "Marker Drone" (Markerlight keyword + Observer even after Advancing) and
  "Shield Drone" (+1 Wounds) actually grant, and Breacher Team/Strike Team were also missing
  "Guardian Drone" (-1 to enemy Wound rolls targeting the unit). The "Gun Drone"/"Missile Drone"
  weapon-granting options were confirmed ALREADY correct — every affected unit's `ranged[]` already
  lists the drone's weapon profile (Twin pulse carbine/Missile pod), just not accompanied by a named
  ability explaining why. Added a `wargearAbilities` entry for Guardian/Marker/Shield Drone to each
  of the 11 datasheets, EN+RU (shared RU constants `GUARDIAN_DRONE`/`MARKER_DRONE`/`SHIELD_DRONE` in
  `ru/tau-empire.js`, matching the file's existing shared-constant convention).
- `allied_faction(+_datasheet/_keyword/_parent_faction_keyword/_points_limit/_required_detachment)`,
  `faction_keyword_allied_faction` — `sync-ally-inclusion.mjs` (added 2026-07-28). 21 total
  `allied_faction` rows; 13 gate on ≥1 detachment (checked, 32 detachment-checks total since a row
  can span several), 8 are universal (no gating detachment at all).
  **Found along the way:** a detachment's ally clause can legitimately live in the *faction's*
  `armyRule.body` instead of the detachment's own `rule.body` — Drukhari's "Corsairs and Travelling
  Players" and chaos-space-marines' "Cults of the Dark Gods" are both Faction-Pack additions (per
  their own inline source comments) that turned an older per-detachment restriction appdata's
  `allied_faction_required_detachment` table still lists into a blanket army-wide rule; the script
  checks both locations. Of the 5 flags that remain (all Drukhari, "Asuryani" not found): confirmed
  non-issue — Corsairs/Anhrathe have no `faction_keyword` of their own in appdata (only a plain
  `keyword`), so appdata approximates their identity as "Asuryani" (the nearest umbrella), while
  wh11ed's actual text correctly says "Harlequins and Anhrathe" (more precise than appdata's tag).
  **Self-review pass (same day) fixed 3 real bugs in the universal-rule check**, found by asking
  "what's still not certain here" rather than accepting the first clean run: (a) the shared-keyword
  fallback accepted generic words ("Chaos"/"Infantry", 24-55% of all datasheets in the game) as an
  ally-identity signal — now filtered by game-wide frequency (>2% = too generic); (b) the points
  regex only matched "pts", not "points" (Questor Forgepact/Iconoclast Fiefdom both write "points"
  in full — false-flagged until fixed); (c) most seriously, bare name-presence when searching a
  whole faction file counted a **restriction** ("your army cannot include any Agents of the
  Imperium Deathwatch units") and a faction's own **self-reference** (searching aeldari.js for
  "Asuryani" — its own name, used constantly in targeting text) as false "found"s. Replaced with a
  `bodyGrantsInclusion` check requiring the established idiom "can include … <ally>" with no
  "cannot" in between.
  **Correction, same day (2026-07-28):** the "only 1 of 8 present, 7 missing" conclusion above was
  itself wrong — a false positive in the checker, not a real content gap. The check searched every
  RECEIVING faction's whole file for the clause, but GW actually publishes this kind of rule as a
  single named army rule on the ALLY's own codex page (Chaos Daemons' "Daemonic Pact", Imperial
  Knights' "Freeblades", Titan Legions'/Chaos Titan Legions' "Titanic Support", Imperial Agents'
  "Assigned Agents") — not copy-pasted into every faction that can take it. wh11ed already follows
  that same convention for **all 8** universal rows, verbatim (verified word-for-word against
  Wahapedia's 10th-edition transcriptions, cross-checked against appdata's own battle-size/keyword
  numbers — see APPDATA-SYNC-LESSONS.md lesson 24). `sync-ally-inclusion.mjs` was fixed to check the
  ally's own page first (`resolvedOnOwnPage` in the script) before falling back to the
  per-receiving-faction search; a clean run now reports all 8 as either found on the ally's own page
  (7) or found via the pre-existing per-faction search (Harlequins→Asuryani). **There is no missing
  ally-inclusion content and no content-authoring task here** — script #2 is fully done and verified.
  **One more thing checked before calling it closed:** why does `allied_faction` carry two separate
  rows for "Agents of the Imperium" (`dc938d45…`, applying to ~12 generic Imperium factions, and
  `be1bdcb9…`, applying to Deathwatch only) with identical battle-size numbers, if it's the same
  rule? Confirmed via `wh40k-appdata/factions/deathwatch.json`: Deathwatch is its own top-level
  appdata faction bundle (own `publications` entry, "Index: Deathwatch") — but its own `armyRules`
  list does **not** include an "Assigned Agents"-style rule at all. So the duplicate row isn't a
  different text, it's a structural artifact of Deathwatch being a separate selectable Army Faction
  in appdata's schema even though the actual entitlement text (imperial-agents.js's "Assigned
  Agents", gated on "every model has the IMPERIUM keyword") already covers it — Deathwatch units
  have IMPERIUM keyword too. No separate wh11ed text is needed for `be1bdcb9`.

  **Real gaps found and fixed 2026-07-28** (appdata is canon — see `[[feedback_appdata_canon]]`):
  Devastator Squad was missing the "heavy flamer" weapon-swap option entirely (no `ranged[]` profile,
  no `options` mention) despite appdata carrying it structurally across all 4 factions that share
  the unit — added the profile (12", D6, N/A, S5, AP-1, D1, [TORRENT]/[IGNORES COVER], reusing the
  identical profile already used elsewhere in `space-marines.js`) and the option line, EN+RU, fixed
  once in the shared pool. Death Company Marines with Jump Packs' power fist/power weapon swap said
  "1 model" but appdata's bracket is 2 at the unit's 5-model minimum (irregular scaling — 3 at 10,
  not a clean double) — corrected the base count to "up to 2 models"; the 10-model→3 nuance is left
  unstated (same "why fabricate an uncertain ratio" reasoning as the structural-noise cases above).

  **Resolved 2026-07-28 (no wh11ed change needed) — verified, not just dismissed:** Inquisitorial
  Agents' Tome-skull structural bracket (`wargear_limit`) reads 6/11-model where the other 3
  brackets on the same unit read 5/10 — first glance called this an appdata inconsistency, but that
  was wrong; re-derived it properly instead. The 3 "5/10" sets are scoped to `miniatureId` = the
  **Inquisitorial Agent** miniature specifically (checked against `miniature.json`), so their
  `modelCount` counts *that sub-type only*. Tome-skull's set is the sole one with
  `miniatureId: null` — not scoped to one miniature — so its `modelCount` counts the **whole unit**
  (Agents + Gun Servitors) instead, a different but equally valid basis, not a typo. Checked whether
  the two bases actually agree given this datasheet's composition (5–10 Agents, 1–2 Gun Servitors,
  *2 Servitors only allowed with 10 Agents*): every legal roster is either 5–9 Agents+1 Servitor (6–10
  models total) or 10 Agents+1–2 Servitors (11–12 total) — so ⌊agents/5⌋ and the ≥6/≥11 total-model
  thresholds produce the identical Tome-skull count in **every** valid composition (the Servitor cap
  being locked to 10 Agents is exactly what makes "total ≥ 11" and "agents = 10" coincide). appdata
  is encoding the same "for every 5 Agents" rule via a total-model proxy that only works because of
  that composition constraint — confirmed self-consistent, not a data quirk. wh11ed's prose already
  matches (verbatim, cross-checked against `agents-of-the-imperium.json`'s `wargearRules`). The
  printed 10th-ed card (user-provided) additionally confirmed the composition itself (no Ogryns, no
  Auspex/Cloaking/Personal Teleporter options, different ability set) changed since 10th ed in a way
  wh11ed and current appdata both already reflect correctly — nothing to backport from the old card.

**Confirmed out of scope by design (don't build anything here):**
- `datasheet_points_step`, `detachment_faction_detachment_points_cost` — points are MFM territory,
  not appdata rules text (see `[[feedback_appdata_canon]]`).
- Every `isCombatPatrol` detachment/datasheet/publication — see `combatPatrolNames()` in
  `scripts/lib/sync-common.mjs`; wh11ed carries none of it (see the Combat Patrol section below for
  the one thing that might change here later).

## Tomorrow: 3 more guardrail scripts, in this order (ranked by how often this exact category
produced a real bug during the 30-faction reconciliation — see `APPDATA-SYNC-LESSONS.md`)

Each follows the established pattern: report-only, wired into `scripts/sync.mjs` (add a `run(...)`
line) + this repo's `npm run sync`, bridged via `src/data/sourceIds.json` where a stable uuid link
exists (never match by bare name alone — collisions are common, see `sync-leader-units.mjs`'s
header comment for the list of repeat names across factions).

**Done:** `sync-wargear-options.mjs` (wargear/loadout structural options), `sync-ally-inclusion.mjs`
(allied-faction inclusion clauses), `sync-roster-restrictions.mjs` (roster-composition
requirements/exclusions), `sync-enhancement-restrictions.mjs` (enhancement eligibility clauses),
`sync-army-rule-coverage.mjs` (multi-army-rule faction coverage) — see the "Already covered" list
above. All 5 planned scripts are now built.

## Investigation tasks (do BEFORE deciding whether points 6-7 below are even buildable)

- **Terrain & Layouts / mission_layout family — RESOLVED 2026-07-29, guardrail built.**
  `mission_pack_briefing(+_narrative_point)` and `mission_pack_location(+_location_bonus/
  _warzone_rule)` are all **empty** (0 rows each in this data_version) — not part of this
  investigation in practice. The rest — `mission_layout` (48 rows: 45 real "X / Y - Layout Z" + 3
  unused generic placeholders), `force_disposition_mission` (25 ordered friendly/opposition pairs),
  `force_disposition_mission_recommended_preset` (75 rows, 3 per pair) + `mission_preset` +
  `mission_deployment` — DOES fully encode the same layout↔matchup↔A/B/C pairing wh11ed already
  has, confirmed two independent ways: (1) `mission_layout`'s own row names (already what
  `extract-layout-images.mjs` parses) match all 45 of wh11ed's matchup/letter combos with zero
  gaps; (2) the recommended-preset chain, read fresh (friendly/opposition → 3 presets → layout +
  deployment), is self-consistent — every ordered pair's 3 recommended presets resolve to distinct
  A/B/C letters whose own layout name is for that same disposition pair. **Not rich enough to
  replace the APK-extraction pipeline** (no image field, confirmed via `SCHEMA.md` same as the
  2026-07-28 note below) but plenty rich for a standing guardrail — built `sync-layouts.mjs`
  (wired into `npm run sync`), first clean run: 0 issues. One thing appdata carries that wh11ed's
  UI doesn't currently show: each layout's named "Deployment Map" (Hammer and Anvil, Crucible of
  Battle, Sweeping Engagement, Search and Destroy, Dawn of War, Tipping Point — the standard named
  core-rulebook deployment shapes; +3 Combat-Patrol-only ones, out of scope per usual convention).
  Printed informationally by the new script; NOT added to the UI — that's a product decision
  (would mean labelling each `LayoutCard` with its deployment-map name), not a sync-guardrail
  question, so left for the user to decide separately.

## DONE (2026-07-28): Layout diagrams now pulled from the app's APK, not PDF-cropped

**Correction to an earlier (wrong) conclusion in this same file.** The first pass concluded
"appdata does NOT carry the visual layout geometry" based on `wh40k-appdata`'s JSON tables (`tables/
mission_layout.json` etc. — name-only rows, no image field, confirmed via `SCHEMA.md`). That's true
of the JSON *data dump*, but the user correctly pushed back and asked to check the **APK itself**
(`sources/apk/*.xapk`) rather than stop at the dump — and the pictures ARE there, just not
data-referenced: the app's compiled Android resources carry them as `res/drawable/ic_layout_<uuid>.
webp` / `res/drawable/ic_measurement_layout_<uuid>.webp`, where `<uuid>` is that row's own
`mission_layout.id` with dashes replaced by underscores (a naming convention, not a JSON field — so
`grep`-ing the schema for "image" legitimately found nothing). **Lesson: "no field for X in the data
dump" is not the same claim as "X isn't in the app" — a compiled app can carry an asset addressed
purely by a resource-name convention that never appears in any exported table.**

What's actually in the base APK (`com.gamesworkshop.w40k.apk` inside the `.xapk`), verified against
all 45 real matchup/letter combos (100% match, 0 missing):
- `ic_layout_<id>.webp` — clean diagram, no measurements, 1535×1961, alpha channel.
- `ic_measurement_layout_<id>.webp` — same diagram + inch callouts, confirmed **pixel-identical** to
  wh11ed's existing PDF-cropped images (same numbers, same layout) but at native higher resolution
  (wh11ed's PDF crops were 1040×1414).
- (+3 unused generic "Mission Layout A/B/C" placeholders, +3 Combat Patrol deployment diagrams under
  `mission_deployment.id` instead — neither used.)

Built `scripts/extract-layout-images.mjs`: reads `mission_layout.json`, parses each row's `"X / Y -
Layout Z"` name against the 5 dispositions to recover `(a, b, letter)`, unzips both webp variants
for all 45 real layouts out of the `.xapk`, converts to PNG (via `sharp`, preserving alpha) into
`public/images/event/layout-<a>-<b>-<letter>.png` (measurement, replaces the old asset) and
`...-clean.png` (new). Run manually (`node scripts/extract-layout-images.mjs [xapk-path]`, defaults
to the newest `*.xapk` in `../sources/apk/`) whenever the app updates, then `npm run images:webp`.

**Gotcha found mid-build:** `gen-webp.mjs` forces PNG sources to lossless — fine for the other two
PNG cases (`turn/*.png`, `intro/datasheet.png`, which are flat vector-style graphics) but these
layout diagrams have a noisy/textured background, so lossless bloated them to ~1MB each (vs the old
JPG-sourced ~128KB). Fixed by excluding `event/layout-*.png` from the lossless branch — lossy WebP
still carries a lossy-compressed alpha channel just fine, landing back at ~100-130KB per image
despite the higher resolution.

**New feature, not just a refresh:** since the app ships both variants, added a "Measurements /
Clean" toggle to `EventLayoutsView.vue` (persisted `wh11ed-event-layout-measurements`), wired through
`LayoutCard.vue`'s new `showMeasurements` prop and `matchups[].layouts[].imageClean`. `layoutEdges`
(hand-read attacker/defender bar orientation) is unchanged — still needed since `LayoutCard` overlays
its own edge-marker bars on top of either image variant, same as before.

**Structural guardrail — BUILT 2026-07-29.** `scripts/sync-layouts.mjs` compares wh11ed's 45
`layoutImages` keys / A-B-C assignment against `mission_layout` + `mission_preset` +
`force_disposition_mission_recommended_preset`, wired into `npm run sync`. First run: 0 issues.

## Future task (queued, not started): verify tracker VP-cap constants against `mission_pack.json`

Side-discovery while investigating the layout tables 2026-07-28: `wh40k-appdata/tables/
mission_pack.json`'s "Chapter Approved 2026-2027" row carries explicit numeric fields —
`primaryMissionScoreGameLimit: 45`, `primaryMissionScoreBattleRoundLimit: 15`,
`secondaryMissionScoreGameLimit: 45`, `fixedSecondaryMissionCapLimit: 20`,
`battleReadyArmyPointModifier: 10` — a direct structured source for the hardcoded constants in
`src/composables/gameScoring.js` (`PRIMARY_GAME_CAP`, `FIXED_SECONDARY_CAP`, `SECONDARY_GAME_CAP`,
`BATTLE_READY_VP`), all of which already match. One field has **no corresponding check in code at
all**: `primaryMissionScoreBattleRoundLimit: 15` — a per-round primary VP cap. Worth checking whether
any current primary mission's per-round rows can actually sum above 15 (if the mission design itself
never allows it, the cap is moot; if some combination of stepper rows theoretically could, the
tracker may be missing an explicit clamp `RoundTracker.vue`/`gameScoring.js` needs). Not investigated
yet — a follow-up, not part of the layouts task above.

**RESOLVED 2026-07-29 — false alarm, already implemented (just not in the file this note pointed
at).** `PRIMARY_ROUND_CAP = 15` already exists in `src/composables/useTracker.js` (not
`gameScoring.js`, which is why the original search here missed it) and is already fully wired up:
`setPrimaryRow` clamps `round.primary = Math.min(raw, PRIMARY_ROUND_CAP)`, `setRoundPrimary`
clamps the same way for the no-card fallback path, `primaryTotal`'s remaining-budget calc
(`Math.min(PRIMARY_ROUND_CAP, PRIMARY_GAME_CAP - others)`) accounts for it, and `RoundTracker.vue`
both displays "X / 15 VP" per round and caps the `NumberStepper`'s max at it. Covered by
`useTracker.scoring.test.js` (24 tests, incl. dedicated over-cap clamping cases). No content or
code gap — the value matches appdata's `primaryMissionScoreBattleRoundLimit: 15` exactly.

## Combat Patrol support + "Rules" nav umbrella — ALL 3 PHASES DONE (2026-07-29)

Phases 1-3 are all implemented and verified: `npm test` 215/215 (4/4 consecutive clean full-suite
runs after the bundle-weight fix below), `npm run build` clean, `node scripts/sync-combat-patrol.mjs`
reports all **24/24 factions clean** (full Phase 3 faction list — see batches 1-6 below). The
feature is complete end to end: data, both CP views, nav umbrella, SEO, and all faction content.

Live now: `/rules` landing page (3 cards), navbar "Rules" hover-dropdown replacing the separate
Core Rules/Event Companion links, mobile bottom-nav "Rules" button → `RulesNavModal.vue`, drawer's
merged "Rules" accordion (Core Rules / Event Companion / Combat Patrol with divider subheadings),
`/combat-patrol` + `/combat-patrol/necrons` pages, SEO wired (both `gen-seo-routes.mjs` and
`useSeoMeta.js`, Combat Patrol routes auto-derived from `combatPatrol.js` so Phase 3 needs no
further SEO changes), `landing.js`'s Core+Event cards collapsed into one "Rules" card.

**What & why.** wh40k-appdata carries a full ruleset for ~24 factions' Combat Patrol boxes
(`isCombatPatrol` detachment/datasheets/enhancements/stratagems/army-rule, currently filtered out
everywhere via `combatPatrolNames()` in `scripts/lib/sync-common.mjs`). Adding it as real content,
alongside a navigation restructure: a new top-level umbrella **"Rules"** («Правила») grouping **Core
Rules** + **Event Companion** (already labelled «Путеводитель по ивентам» in RU — no rename, that's
just what the feature is) + the new **Combat Patrol**, replacing today's two separate "Core Rules" /
"Event Companion" navbar links. Desktop: hover reveals the 3 choices exactly like the existing
Factions mega-menu, clicking the umbrella link goes to a new `/rules` landing page with 3 clickable
summary cards. Mobile bottom nav: opens a modal to choose between the 3 (mirrors
`FactionsNavModal.vue`). Combat Patrol's own data is **hand-authored** (matching every other
faction's convention — see `titan-legions.js`, the smallest existing hand-authored faction file,
not machine-generated prose) and checked against appdata by a new report-only
`scripts/sync-combat-patrol.mjs`, exactly like every other faction, so it stays easy to keep in sync
on future appdata bumps.

**Confirmed design decisions:**
- **One combined page per Combat Patrol faction** (detachment/army rule + stratagems + enhancements
  + the fixed roster's datasheets all on one page, not split rules/datasheets pages like normal
  factions) — content per box is small (1 detachment rule, 2-3 stratagems, 1-2 enhancements, 4-5
  fixed-composition datasheets).
- **Drawer (mobile hamburger) nests Core Rules / Event Companion / Combat Patrol under one "Rules"
  parent accordion** — achieved by flattening `navSections` to `[rules, factions, tracker]` where
  "rules"' `groups` is the concatenation of `navGroups`+`eventGroups`+a new `combatPatrolGroups`,
  each preceded by a non-clickable subheading divider (`{label, isDivider:true}`, no `path`) — no new
  recursion depth needed in `NavSidebar.vue`, just a template branch for divider rows.
- **`/` landing page collapses its "Core Rules" + "Event Companion" cards into one "Rules" card**
  pointing at `/rules`.
- **Combat Patrol rule text is transcribed verbatim from the CP box's own appdata rows**, even where
  that's pre-errata relative to the normal Codex (confirmed precedent: Necrons' CP-box "Reanimation
  Protocols" reads "reanimates D3" vs the errata'd Codex "heals D3" — different appdata `army_rule`
  ids entirely). Matches the project's "mirror the primary source verbatim" convention.

**Research already done (2026-07-29), don't re-derive:**
- appdata shape confirmed via `publication.json`'s `isCombatPatrol:true` rows (24, not 30 — not
  every faction has a CP box) → linked `detachment`/`army_rule`/`enhancement`/`stratagem`/`datasheet`
  rows, checked in depth for Necrons ("Amonhotekh's Guard": detachment rule "Territorial
  Imperatives", army rule "Reanimation Protocols" pre-errata, 3 stratagems, 2 enhancements — one
  `isCombatPatrolDefault`, 5 datasheets: Necron Warriors/Skorpekh Destroyers/Canoptek
  Doomstalker/Canoptek Scarab Swarms/Overlord Amonhotekh), Orks ("'Ardmob"), Space Marines ("Assault
  Force") — pattern consistent across all 3: 1 publication → 1 detachment (dp:1, one
  forceDisposition) → 1 detachment rule → 2 enhancements → 3 stratagems → 4-5 fixed, name-prefixed,
  `points: null` datasheets (no `options`/loadout-choice structures — genuinely fixed loadouts).
- CP is confirmed **not** in MFM at all (checked `mfm/leagues-of-votann.js` — no CP entry) — CP
  rosters are points-free by design, don't try to plug into the MFM/points pipeline.
- wh11ed's existing faction/datasheet shape (`armyRule`/`detachments[].{rule,stratagems,enhancements}`,
  datasheet `profiles`/`ranged`/`melee`/`core`/`faction`/`abilities`/`composition`/`loadout`/
  `keywords`/`factionKeywords`/`baseSize`) maps directly onto CP content — reuse `DatasheetCard.vue`/
  `StratCard.vue`/`RuleBlock` unmodified, just omit `points`/`options`.
- Nav mechanics fully traced: `App.vue`'s Factions `.nav-dropdown` (lines ~24-47, CSS-only
  hover/`:focus-within` reveal + `nd-suppressed` click-fix) and `FactionsNavModal.vue` are the exact
  templates to copy. `subNavItems` computed (lines ~424-431) needs a new Combat Patrol exclusion
  (like the existing `isLinksRoute` one) since its 2 page types need no subnav bar.
  `scripts/gen-seo-routes.mjs`'s `STATIC_ROUTES` and `src/composables/useSeoMeta.js`'s `ROUTES` map
  are two **separate** hardcoded lists (neither auto-derives from router config) — both need new
  entries, easy to forget one.
- `gen-source-ids.mjs` has its own local `combatPatrolNames()` copy instead of importing the shared
  one from `sync-common.mjs` — worth unifying while touching this file for the new `cpdet:`/
  `cpstrat:`/`cpenh:`/`cpds:`/`cparmyrule:` id-bridge kinds.

**Phasing:**
1. ~~**Phase 1**~~ — DONE. `src/data/combatPatrol.js` (Necrons "Amonhotekh's Guard" pilot),
   `CombatPatrolIndexView.vue`/`CombatPatrolFactionView.vue` + routes, `scripts/sync-combat-patrol.mjs`
   (+ `sync.mjs` wiring), `gen-source-ids.mjs` CP kinds (`cpdet:`/`cpstrat:`/`cpenh:`/`cpds:`/
   `cparmyrule:`, local `combatPatrolNames()` copy unified with the shared one).
2. ~~**Phase 2**~~ — DONE. "Rules" nav umbrella live everywhere (navbar/bottom-nav/drawer/landing),
   see above.
3. **Phase 3 — IN PROGRESS.** Author the remaining factions' CP content in batches, each verified by
   `node scripts/sync-combat-patrol.mjs` (prints the exact not-yet-authored faction list already) + a
   small PR, same incremental pattern as the rest of this dataset. SEO routes and the drawer's
   Combat Patrol group list both auto-grow from `combatPatrol.js` — no extra steps needed per faction.
   - **Batch 1 (2026-07-29) — DONE:** Space Marines ("Assault Force"), Orks ("'Ardmob"), T'au Empire
     ("Sudden Dawn Cadre"), Astra Militarum ("Drayden's Lance"). All report clean via
     `sync-combat-patrol.mjs`; `sourceIds.json` regenerated (57 new `cp*` keys, all matched — no
     unmapped entries). Notable one-off cases handled: Space Marines' CP army rule ("Combat
     Doctrines") is a genuinely different ability from the Codex's "Oath of Moment", not a reworded
     copy; T'au's box links **two** CP-only army rules (Drones + For the Greater Good) merged into
     one `armyRule` via a `###` subheading, same convention as `titan-legions.js`; Orks' 'Ardmob Boyz
     had two appdata datasheet rows for a Boss Nob weapon swap, merged into one wh11ed datasheet with
     an `options` line (the one documented exception to "CP has no options" — a genuine in-box loadout
     choice, not a missing-data gap); Astra Militarum had a duplicate near-identical "Attilan Rough
     Riders" appdata row (an inconsistent Goad Lance LANCE tag) — picked the internally-consistent one.
   - **Batch 2 (2026-07-29) — DONE:** Adepta Sororitas ("Sanctuary Guardians"), Adeptus Custodes
     ("Tristraen's Gilded Blades"), Adeptus Mechanicus ("Purge Corps Deltic-9"), Imperial Agents
     ("Inquisitor's Hand" — appdata slug `agents-of-the-imperium`, wh11ed slug `imperial-agents`,
     via `SLUG_MAP`). All clean via `sync-combat-patrol.mjs`; `sourceIds.json` regenerated (103 new
     `cp*` keys, all matched). 3 of these 4 CP army rules turned out **verbatim identical** to the
     faction's normal Codex armyRule text (Acts of Faith, Doctrina Imperatives, and Assigned Agents
     minus its battle-size table) — copied straight from `src/data/factions/*.js` instead of
     re-transcribing from appdata by hand. One more near-duplicate datasheet row resolved the same
     way as the Rough Riders case in batch 1: Imperial Agents' "Inquisitor's Hand Vigilant Squad"
     had two appdata rows differing only in a couple of missing weapon tags — kept the more complete one.
   - **Batch 3 (2026-07-29) — DONE:** Aeldari ("Kygharil's Protectors" — appdata slug `asuryani`,
     wh11ed slug `aeldari`, via `SLUG_MAP`), Black Templars ("Vow-Sworn of Vedrenn"), Blood Angels
     ("Sanguinary Spearhead"), Dark Angels ("The Vengeful Brethren"). All clean via
     `sync-combat-patrol.mjs`; `sourceIds.json` regenerated (146 new `cp*` keys, all matched).
     Surfaced a real gap in the sync script itself: 3 of these 4 factions link **more than one**
     CP army rule (Dark Angels links all 4 of Oath of Moment/Deathwing/Ravenwing/Unforgiven; Black
     Templars and Blood Angels link 2 each), which wh11ed correctly combines into one `armyRule`
     (same convention as the normal Codex files, e.g. `dark-angels.js`'s "Oath of Moment & The
     Unforgiven") — the script's original army-rule check only compared against a single found
     row and false-flagged all 3. Fixed: it now checks that every CP-linked row's name is
     represented in the combined wh11ed name (mirrors `sync-army-rule-coverage.mjs`'s existing
     approach to the same multi-rule pattern for normal content). All 4 of this batch's CP army
     rules also turned out **verbatim identical** to the Codex ones (same discovery as batch 2) —
     copied straight from `src/data/factions/{aeldari,black-templars,blood-angels,dark-angels}.js`.
     One garbled appdata text block hand-reconstructed (Dark Angels' Bladeguard Veteran Squad
     "Bladeguard" ability — broken mid-sentence HTML tags in the source, but the intended game text
     was unambiguous from context). Two more appdata near-duplicate datasheet rows resolved the
     same way as batches 1-2 (Aeldari's "Kygharil's Protectors Dire Avengers", Blood Angels'
     "Sanguinary Spearhead Sanguinary Guard" — both exact duplicates this time, not just near-miss
     tag differences).
   - **Batch 4 (2026-07-29) — DONE:** Death Guard ("Maggot Lords"), Drukhari ("Coven of Agonies"),
     Emperor's Children ("Callous Blades"), Genestealer Cults ("Claw of Ascension"). All clean via
     `sync-combat-patrol.mjs`; `sourceIds.json` regenerated (190 new `cp*` keys, all matched).
     Death Guard, Drukhari and Emperor's Children each link 2 CP army rules — same "combined
     armyRule.name" pattern as batch 3, and (same discovery again) all verbatim-identical to the
     Codex text, copied from the existing faction files. Genestealer Cults' "Cult Ambush" is the
     first CP army rule this project that is **genuinely CP-specific** rather than a Codex copy —
     it hardcodes "Combat Patrol: 2 Resurgence points" and this box's own unit reincarnation costs,
     unlike the normal Codex version's battle-size-scaled table; transcribed from appdata as
     printed (with its "Atalal Jackals" typo corrected to match the real datasheet name, "Atalan
     Jackals"). 3 more appdata near-duplicate datasheet rows resolved the same way as previous
     batches (Aeldari-style exact duplicates for Drukhari's "Coven of Agonies Wracks" and Emperor's
     Children's "Callous Blades Flawless Blades"; a mixed-completeness duplicate for Genestealer
     Cults' "Claw of Ascension Hybrid Metamorphs", resolved by merging the more-complete weapon
     tags from each of the two rows rather than picking one wholesale).
   - **Batch 5 (2026-07-29) — DONE:** Grey Knights ("Crowe's Sanctifiers"), Chaos Space Marines
     ("Zarkan's Daemonkin" — appdata slug `heretic-astartes`, wh11ed slug `chaos-space-marines`),
     Leagues of Votann ("Bane-slayer's Bulwark"), Space Wolves ("Askar's Wolfpack"). All clean via
     `sync-combat-patrol.mjs`; `sourceIds.json` regenerated (234 new `cp*` keys, all matched).
     Grey Knights' "Gate of Infinity" is the second genuinely CP-specific army rule found (after
     Genestealer Cults in batch 4) — the box's own copy omits the Codex's battle-size unit-count
     table and its "can make an ingress move next Movement phase" acceleration clause entirely,
     not just a formatting difference. Space Wolves links all 4 of its Codex army rules (Oath of
     Moment/Curse of the Wulfen/Sagas/Sons of Russ, all 4 confirmed verbatim-identical to Codex) —
     same multi-rule combining as Dark Angels in batch 3. One more appdata cosmetic-naming quirk
     hit the sync script directly this time: Leagues of Votann's own datasheet.json literally
     spells one of its 4 units "Bane Slayer's Bulwark Brokhyr Thunderkyn" (no hyphen) while the
     other 3 use "Bane-Slayer's Bulwark" (hyphenated) — initially authored hyphenated for
     consistency with its siblings, `sync-combat-patrol.mjs` caught the exact-name mismatch, fixed
     by matching appdata's literal (inconsistent) spelling for that one datasheet.
   - **Batch 6 (2026-07-29) — DONE, Phase 3 COMPLETE (24/24):** Thousand Sons ("Prism of
     Zadophon"), Tyranids ("The Vardenghast Swarm"), World Eaters ("Frenzied Reavers"). All clean
     via `sync-combat-patrol.mjs`; `sourceIds.json` regenerated (8,882 entities across 30
     factions, 0 unmatched `cp*` keys). Kaa'skrek (Thousand Sons) needed a `faction:` field for
     both its CP-linked abilities ("Cabal of Sorcerers" + "Pact of Sorcery") — caught and fixed
     before the sync run. Every faction with an appdata Combat Patrol box now has hand-authored,
     sync-verified content in `combatPatrol.js` — Phase 3 of the plan is finished.
   - **Bundle-weight fix (2026-07-29):** once `combatPatrol.js` reached its full 24-faction size
     (~4,400+ lines), `StratagemsView.test.js`'s timing-sensitive `settle()` helper started failing
     4/4 full-suite runs (previously an occasional flake) while still passing 100% in isolation.
     Root cause: `router/index.js` and `useSeoMeta.js` **statically** imported the full
     `combatPatrol.js` (to build `combatPatrolGroups`/`combatPatrolGroupsRu` and the CP SEO meta) —
     both files sit in the module graph of virtually every page/test, so the whole 24-faction data
     file (rule text + all fixed-roster datasheets) was riding in the app's root bundle, violating
     the project's own "dynamic import of heavy data files" convention. Fixed by extracting a new
     lightweight `src/data/combatPatrolIndex.js` (slug/name/boxName only, ~24 lines) that
     `router/index.js`/`useSeoMeta.js`/`CombatPatrolIndexView.vue` now read instead;
     `CombatPatrolFactionView.vue` (the only place that needs the full box content) switched from a
     static import to a dynamic `await import('../../data/combatPatrol.js')` in a `watchEffect`,
     matching the pattern already used by `StratagemsView.vue`/`FactionFaqView.vue` for other heavy
     data files. `sync-combat-patrol.mjs` gained a drift check verifying `combatPatrolIndex.js`
     stays in sync with `combatPatrol.js`. Result: `combatPatrol.js` now builds as its own ~240 KB
     chunk instead of bloating the root entry chunk (confirmed via `npm run build`'s chunk-size
     output — the previously-inflated root `index-*.js` dropped back to its normal ~413 KB); `npm
     test` passed 4/4 consecutive full-suite runs afterward (was 4/4 failing before).

## Table-level coverage audit (2026-08-20) — what of appdata we still don't read

Everything above audits coverage per FEATURE. This one goes the other way: walk all 130 files in
`wh40k-appdata/tables/` and ask which ones no wh11ed script ever opens. Counting: **65 tables are
read** by `scripts/`, **55 are never mentioned**, and 17 of those 55 are empty (0 rows —
`amendment`, `mission_pack_*`, `detachment_required_datasheet`, `enhancement_keyword_points_cost`,
`army_rule_behaviour_type`, …), leaving **38 non-empty tables we don't open**.

38 overstates the gap. Most of them reach us already folded into the faction BUNDLES
(`wh40k-appdata/factions/<slug>.json`), which is what the generators actually read:
`datasheet_ability`/`datasheet_datasheet_ability` → `abilities`, `wargear_item_profile`
(+`_wargear_ability`) → `wargear[].profiles`, `invulnerable_save` → `invulnerableSaves`,
`datasheet_damage` → `damageAbility`, `detachment_rule` → `detachments[].rules`,
`datasheet_faction_keyword` → `factionKeywords`. Those are covered; the raw table is just not the
road they take.

What is genuinely missing, ranked:

1. **`datasheet_bodyguard_group_keyword` (44 rows / 36 groups) — a live defect, fixed 2026-08-20.**
   A bodyguard group can name its targets by KEYWORD instead of listing datasheets, and
   `gen-roster-data.mjs` only ever read `datasheet_bodyguard_group_datasheet`. All 36 such groups
   are keyword-only (none is also listed), so those attachments were simply absent: Captain and 8
   other Space Marine leaders lost Sternguard Veteran Squad, Tor Garadon/Iron Father Feirros lost
   Eradicator Squad. Same class as the `enhancement_bodyguard_group` bug from 2026-08-19, opposite
   sign — eligibility MISSING rather than invented. Note the bundle loses it too
   (`adeptus-astartes.json` carries `{"bodyguardType":"leader","units":[]}` for exactly these), so
   wh40k-appdata's own bundle generator has the same hole; we read the raw table instead.
2. **`unit_composition_miniature` (2300 rows) — DONE 2026-08-20**, see `ROSTER-BUILDER-PROGRESS.md`
   item 11. Kept here for the measurements.

   **Was: not used, and it answers a documented limitation.**
   It gives `min`/`max` PER MINIATURE PROFILE per points bracket (Wracks: `Acothyst 1-1 |
   Wrack 4-4` at 60 pts, `Acothyst 1-1 | Wrack 8-9` at 120), covering **all 303 multi-miniature
   datasheets** and 1145 of 1146 overall. Today unit sizes are parsed out of the bundle's
   `models: '5-10'` STRING (`parseModels`), and both `defaultLoadoutLines` and Tier A's weapon trim
   (`rosterModifiers.js`) refuse to subtract anything on a multi-miniature datasheet, explicitly
   because "there is no single model count". This table is that count. Not done — a real task, with
   the roster editor's per-miniature wargear as its main consumer.
3. **`allegiance_ability` (26) + `allegiance_ability_group` (10)** — allegiance/mark mechanics tied
   to a detachment, with `isMandatory`, `maxRosterLimit`/`minRosterLimit`, `requiresWargearItemId`
   and rules like "This model is additionally equipped with: phlegm bombardment". The roster builder
   knows nothing about them. Worth scoping before calling roster v1 finished.
4. **Validation odds and ends.** `detachment_unique_keyword` (55) — **DONE 2026-08-20**, though not
   as a data gap: wh11ed already had every tag (`detachment.unique`, hand-written, 57 of them) and
   the table's value turned out to be as an independent cross-check, now wired into
   `sync-detachment-details.mjs`. The gap was that the tag never reached the roster layer, so two
   detachments sharing one could both be taken — see `ROSTER-BUILDER-PROGRESS.md` item 12.

   `army_rule_excluded_from_command_bunker_faction_keyword` (37) — **not useful, and this was
   already established**: `sync-army-rule-coverage.mjs`'s header records the reading of the raw
   rows, which is that this table and `army_rule_faction_keyword` are Command-Bunker-app UI
   bookkeeping (which of my own factions can select this army-rule ROW, and whether it shows as a
   separate option in a digital army builder), not a roster restriction. `army_rule` carries no
   prose at all. Listing it above as a candidate was this audit's own oversight.

   `stratagem_phase` (2016 — structural phase per stratagem, which the tracker/stratagem pages
   could filter on) is still open.
5. **Missions** (`primary_mission*`, `secondary_mission*`, ~15 non-empty tables) are untouched by
   design — tracker mission data is hand-authored and checked by `sync-tracker.mjs` against
   `_core-content.json`, not against these.

Quantity (`count`) lives in exactly four tables: `base_miniature_loadout_wargear_option` (defaults —
used), `loadout_choice_wargear_item` (legal loadouts — used as the bundle verifier),
`limited_wargear_choice_wargear_item` (used for limits and per-option counts) and
`all_model_wargear_choice_wargear_item` — where **all 71 rows have count = 1**, so it adds nothing.
There is no fifth, structural source of "this option grants 2 of them": for the groups outside a
limited set the number exists only in the prose. Measured and acted on in
`ROSTER-BUILDER-PROGRESS.md` item 6.

## Deploy log
- 2026-07-27 — v2.1.6 deployed: floating faction buttons (desktop) + mobile utility bar,
  Vehicles/Infantry unit-list split, full 30-faction datasheet/rules reconciliation vs appdata
  (PR #264), `sync-detachment-details.mjs` guardrail.
