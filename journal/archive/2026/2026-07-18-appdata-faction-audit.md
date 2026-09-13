> **Статус:** закрыт 2026-07-18
> **Репозитории:** wh11ed
> **Итог:** все 30 фракций сверены с `wh40k-appdata`; процедура и грабли переехали в
> `wh11ed/APPDATA-SYNC-LESSONS.md`, дальнейшие сверки идут скриптами `npm run sync*`.

# wh40k-appdata faction audit — progress tracker

Context: `wh40k-appdata` (private sibling repo, official GW app dump) is now treated as the
100%-authoritative rules source. `scripts/sync-appdata.mjs <slug>` reports what's missing,
extra, or scalar-mismatched in wh11ed's faction/datasheet data compared to it. This file
tracks the faction-by-faction pass through that report — split across two machines working
in parallel. Update this file (tick the box) as part of the same PR that fixes a faction, so
the other machine's next `git pull` sees it's done.

## Protocol (run on both machines)

1. Before EACH faction: `git checkout main && git pull --ff-only` — picks up any
   `scripts/sync-appdata.mjs` false-positive fixes the other machine made.
2. `node scripts/sync-appdata.mjs <slug>` — for every line in the report:
   - `+ missing in wh11ed`: verify against the printed appdata text, then add it (EN + RU,
     following the faction's existing conventions — glosses, bold, ALL-CAPS keywords, etc).
   - `- extra in wh11ed`: check whether it's a genuine removed/renamed/Legends entity, or a
     false positive (e.g. a naming variant — see known false-positive classes below). Fix or
     leave with a one-line reason.
   - `~ ... differs`: check both sides' source before "fixing" — several of these turned out
     to be wh11ed being *more* correct than appdata's flattened points join (see below).
3. `npm run build && npx vitest run` must stay green.
4. Tick this faction's box below, commit it together with the fix.
5. Branch `fix/audit-<slug>`, push, `gh pr create`, `gh pr merge --squash --delete-branch`
   (auto-merge for these audit fixes is pre-authorized — no need to ask per-PR).
6. If a faction reveals a new systematic false positive in the script itself, fix
   `scripts/sync-appdata.mjs` in the same PR (like the ones already found — see below) so
   every faction after it benefits.

## Known false-positive classes already filtered (don't re-report these as bugs)

- **Combat Patrol content.** Publications flagged `isCombatPatrol` (e.g. "Combat Patrol:
  Claw of Ascension") are a separate boxed game mode with fixed 0-point rosters and
  detachment-name-prefixed unit variants; wh11ed is matched-play only and carries none of
  it. `sync-appdata.mjs` now derives the CP datasheet/detachment name sets from the raw
  appdata `tables/` (the bundle flags detachments but not datasheets) and drops them before
  diffing — so a whole missing "detachment + N datasheets, all 0pts" block is almost always
  just a Combat Patrol box, not a real gap.
- The U+2010 hyphen (`‐`) in some appdata names (e.g. "Bio‐horror Disruption") — added to the
  name-normaliser's dash class alongside the U+2011 one.
- wh11ed's `"1CP"` vs appdata's bare `"1"` stratagem CP formatting.
- A `(Aura)`/`(Psychic)` classification suffix wh11ed appends to some enhancement/ability
  names that appdata's bare name doesn't carry.
- Unicode hyphen variants in appdata names (U+2010 HYPHEN, U+2011 non-breaking hyphen) vs a
  regular hyphen-minus in wh11ed's — norm() folds `-–—‑‐` all to `-`.
- MFM "copy tax" points tiers (`note: "1st-2nd"` vs `"3rd+"`, pricier for spamming the same
  unit) — appdata's composition join only exposes the base price. wh11ed having *two* prices
  here is correct, not a bug.
- appdata's own `unit_composition` join occasionally yields duplicate rows for the same
  price — de-duped before comparing.
- wh11ed keeps intentional **"designer's note"** pseudo-abilities on a few datasheets
  (Devastator/Hellblaster Squad) that appdata has no equivalent for — editorial content,
  not a real gap; leave them.
- Some units carry a **second, higher appdata "default" composition at the same model
  count** (imperial-agents Assassins — Callidus 100/**140**, Culexus 85/**125**, Eversor
  120/**145**, Vindicare 125/**155**, the lone **Agent of the Imperium** allied price; necrons
  C'tan Shards — Deceiver 330/**375**, Nightbringer 360/**405**, Void Dragon 345/**380**,
  Transcendent 340/**380**; space-marines squad/jump-pack units — Assault Intercessor Squad
  75/**80**, Assault Intercessors With Jump Packs 85/**95**, Bladeguard Veteran Squad
  80/**85**, Captain/Chaplain With Jump Pack 75/**80**, Outrider Squad 70/**75**, Repulsor
  Executioner 230/**240** (four duplicate 230 rows plus one 240), Vanguard Veteran Squad With
  Jump Packs 100/**105** — provenance unclear, possibly a historical MFM price snapshot kept
  alongside the current one). wh11ed shows the base/lower price; leave these `~ points differ`
  lines as-is, don't "fix" to appdata's higher tier.
- For the 5 SM-Chapter factions (black-templars/blood-angels/dark-angels/deathwatch/
  space-wolves): most of the `extra` list is NOT a real gap — appdata's own per-chapter
  bundle only lists that Chapter's exclusive publications, while wh11ed's list (correctly)
  also includes units shared with `space-marines.js`. Only look at `missing`/`differs` for
  these 5; skim `extra` for genuine renames/removals but don't chase the shared-pool units.
- **appdata itself can have a typo** — Blood Angels' "Martial Examplars" is appdata's own
  misspelling of "Martial Exemplars" (wh11ed already had it right). Likewise orks' Bully
  Boyz stratagem: appdata's "Cut' Em Down" mis-places the apostrophe; wh11ed's "Cut 'Em
  Down" is correct — left alone. Don't blindly copy a
  "missing"/"extra" name pair without a sanity check on which side is actually correct
  English.
- **appdata abilities with `type !== 'datasheet'` are invisible to the script's ability diff**
  (it only compares `d.abilities.filter(a => a.type === 'datasheet')`) — e.g. tau-empire's
  Ta'unar Supremacy Armour "Super-heavy Walker" is appdata `type: 'core'` (grouped with
  Deadly Demise), so it always reports as an "extra ability (not in appdata)" even though it's
  really there under a different type. Verify with a quick raw-JSON check on the faction
  bundle before treating this shape of finding as a real gap.

## Real bugs found so far (patterns to watch for elsewhere)

- An ability's `name` field literally matching the *unit's own name* instead of the ability's
  real name (Deathwatch's Watch Master: ability named "Watch Master" instead of "Rites of
  Battle" — same text, wrong header, in both EN and RU). Check any "extra ability" that reads
  like a unit/character name.
- A stray keyword that leaked from one Chapter's copy into `space-marines.js`'s shared copy
  of a unit (found: "Deathwing" (Dark Angels-only) on the shared Terminator Squad/Land Raider
  Crusader — **fixed** while auditing dark-angels, confirmed against appdata's generic
  Adeptus Astartes copy that neither should carry it, and that dark-angels.js's own
  chapter-local copies already correctly have it).
- Apostrophe-position typos changing meaning ("Fools' Flight" → should be "Fool's Flight",
  Chaos Daemons) — check the stratagem's actual effect text to judge singular vs plural.
- **A Chapter's own bonus ability on a shared-name unit got errata'd and wh11ed still has the
  old one** (Black Templars: Terminator Squad/Land Raider Crusader/Repulsor/Repulsor
  Executioner/Sternguard Veteran Squad each had one datasheet ability swapped for a
  differently-named, differently-worded one in appdata — a real balance/Faction-Pack update,
  not a naming variant). This is exactly why B4 correctly left these chapter-local instead of
  folding them into the shared `space-marines.js` pool — check "differs" units for **all 5
  SM-Chapter factions** for the same pattern, not just missing/extra. Conversely, if an
  ability's *text* is byte-identical to the shared version and only the *name* differs
  (Gladiator Reaper's "Rotating Death" == "Reaping Tally" in appdata's Black Templars view,
  same rules text) — that's a cosmetic chapter-flavored name, not worth duplicating the whole
  datasheet to fix; leave it.
- **A datasheet's `faction`/`core` summary string can be stale generic text** — Black Templars
  had 41 datasheets saying `"faction": "Oath of Moment"` (the generic Space Marines army rule)
  instead of `"faction": "Templar Vows"` (their own). `sync-appdata.mjs` doesn't check this
  field at all (out of scope for the script), so **manually grep each chapter/faction's
  datasheet file for the generic army-rule name** (`grep -c '"faction": "<generic name>"'`)
  and cross-check against the faction's own `armyRule.name` in `src/data/factions/<slug>.js`.
- **A named-character/Primarch "pick one" `abilitySets` group's parent name can drift from
  appdata's `subAbilities` parent name** even when its options are complete and correct —
  chaos-daemons' Be'lakor had `abilities`/`abilitySets` both named "Shadow Form" while appdata
  calls the same group "Shadow Form Abilities" (the 3 sub-options — Wreathed in Shadows, Pall
  of Despair, Shadow Lord — were already present and correct). `sync-appdata.mjs` doesn't know
  about `abilitySets` at all, so it reports this as a missing+extra pair rather than a rename.
  Renamed to match appdata exactly (EN `abilities`/`abilitySets` name + RU overlay key).

## Full-canon re-verification (post-audit sanity pass)

Ran `sync-appdata.mjs` fresh across all 28 factions after every audit PR above had merged (not
just the ones with open findings) — a final check that nothing regressed and nothing was
missed. Found and fixed one real gap (the Be'lakor naming drift above, in `chaos-daemons`,
one of the "already done before the split" factions that predated most of the false-positive
classes documented here). Everything else was already-catalogued noise (SM-Chapter shared-pool
`extra` list, appdata's own Martial Examplars/Cut' Em Down typos, duplicate-default points
rows). Worth re-running this full sweep after any future `wh40k-appdata` data_version bump.

## Machine A — done, now picking up 3 of Machine B's remaining 4

- [x] adepta-sororitas
- [x] adeptus-custodes
- [x] adeptus-mechanicus
- [x] aeldari
- [x] astra-militarum
- [x] black-templars
- [x] blood-angels
- [x] chaos-knights
- [x] chaos-space-marines
- [x] dark-angels
- [x] death-guard
- [x] drukhari
- [x] emperors-children
- [x] tau-empire (reassigned from Machine B — see note below)
- [x] thousand-sons (reassigned from Machine B — see note below)
- [x] world-eaters (reassigned from Machine B — see note below)

## Machine B — 1 faction left (reassignment: keep only the heaviest)

Machine A finished its 13 and is now taking tau-empire/thousand-sons/world-eaters off Machine
B's plate — **Machine B, please only do `tyranids`** (the heaviest of the 4 remaining, ~18 wu)
and skip the other three so we don't collide again like on space-marines.

- [x] genestealer-cults
- [x] grey-knights
- [x] imperial-agents
- [x] imperial-knights
- [x] leagues-of-votann
- [x] necrons
- [x] orks
- [x] space-marines
- [x] space-wolves
- [x] tyranids

## Already done (before the split)

- [x] chaos-daemons
- [x] deathwatch

## Follow-up — DONE

The 5 SM-Chapter factions (black-templars, blood-angels, dark-angels, deathwatch,
space-wolves) each carried a chapter-local "differs" set of units that were the *same unit*
as a `space-marines.js` one but not byte-identical (see CLAUDE.md's SM-Chapter datasheet
dedup note). Reconciled against `wh40k-appdata`: cross-checking every such unit's name
against each Chapter's own appdata publication found only **6 genuinely unique units, all in
Black Templars** (Impulsor, Land Raider Crusader, Repulsor, Repulsor Executioner, Sternguard
Veteran Squad, Terminator Squad). Everything else (~150 unit-copies across the 5 files) was
stale duplication, not real Chapter content — confirmed by checking every field diff against
appdata directly:

- **Stray "Deathwing" keyword** baked into 17 datasheets in the shared `space-marines.js`
  pool itself (Ballistus/Brutalis/Redemptor Dreadnought, Captain/Chaplain/Librarian/Ancient
  in Terminator Armour, Bladeguard Ancient/Veteran Squad, Land Raider (+Redeemer), Repulsor
  (+Executioner), Sternguard/Terminator Assault Squad, Vanguard Veteran Squad with Jump
  Packs) — appdata's generic Adeptus Astartes bundle confirms none of them should carry it.
  This is the same leak class as the earlier Terminator Squad/Land Raider Crusader fix, just
  far more widespread than realized at the time. Fixed directly in `space-marines.js`.
- **Wrong "Support"/"Leader" core-ability label** on ~8 Character units per chapter (e.g.
  Ancient showed "Leader", appdata says "Support" everywhere).
- **Missing "Frame" keyword** on most chapter-local vehicle copies.
- **Stale pre-errata ability text**: Gladiator Reaper/Valiant ("Rotating Death"/"Ferocious
  Assault" instead of "Reaping Tally"/"Priority Target Acquisition"), Terminator
  Squad/Assault Squad's Teleport Homer ("9\"" instead of "8\""), Lieutenant with
  Combi-weapon's Evade and Survive (a fully outdated rules text).
- **Stale points** (e.g. Repulsor Executioner 230/250 vs the correct 240/260).

Each Chapter's `ru/<slug>.js` RU overlay was already ahead of this — its own `SHARED` array
already listed these ids and pulled `smRu[id]` directly — so **no RU changes were needed**,
only the EN files needed their `sharedUnitIds` synced to match. Verified: `own.length +
sharedUnitIds.length` unchanged per chapter before/after (no unit lost or duplicated), full
merged datasheet lists have zero duplicate ids, `npm run build && npx vitest run` green.

## `core`/`faction` field check — added to `sync-appdata.mjs`

wh11ed's flat `core`/`faction` comma-joined summary strings (e.g. `"Deadly Demise D6+6"`,
`"Support"`) were never diffed by the script before — this is exactly the class of bug
hand-found while building Titan Legions (a generic Character mislabeled "Leader" instead of
"Support"), and appdata's own FAQ/errata table has more of these on record ("Master of
Executions, Core Abilities Section: Remove 'Leader', add 'Support'"). The check compares
core+faction as **one merged set**, not two separate fields — wh11ed's `faction` is sometimes
itself a comma-joined list of several faction-type abilities (e.g. Aeldari's "Battle Focus,
Disparate Paths"), and appdata is internally inconsistent about which bucket ("core" vs
"faction") the same ability name lands in per datasheet (e.g. "Super-heavy Walker" is
`type:'faction'` on some datasheets, `type:'core'` on others) — diffing the fields separately
would flag that inconsistency as a false "difference" even when the actual name set matches.

**New false-positive class:** appdata can itself omit a faction-wide ability on one datasheet
that every sibling unit in the same book has. Confirmed for **Poxbringer** and **Lady Malys**
(Chaos Daemons/Drukhari) — every other checked unit in their respective books has
"The Shadow of Chaos"/"Power from Pain", but these two units' own appdata entries lack any
faction-type ability at all. wh11ed's existing data is correct here; **do not "fix" these** —
they will keep showing as `core/faction differ` lines forever, that's expected.

**Real bugs found by this check (fixed):** Cato Sicarius (core "Leader"→"Support"), Land
Speeder (dropped a phantom "Deadly Demise 1"), Doomhammer ("Firing Deck 6"→"12", an errata'd
value), Ares Gunship/Archaeopter Fusilave/Archaeopter Stratoraptor/Hive Crone (each had a
phantom "Hover" not in appdata), thousand-sons' Heldrake (same phantom "Hover" — its `abilities`
field was already correctly faction-specific, only `core` was stale), Ta'unar Supremacy Armour
(missing "Super-heavy Walker"), Ministorum Priest in imperial-agents (a stray, unsupported
"Assigned Agents" faction ability with no corresponding rules text anywhere on the sheet),
Bannernob in orks (a stray "Support" core ability despite having no core-type ability in
appdata at all), Parasite Of Mortrex (missing "Shadow in the Warp"), and Tormentbringer in
chaos-daemons (missing "Leader" — confirmed by its own `leader` field listing Hellflayer as an
attachable unit).

**Also fixed a real regression from the SM-Chapter dedup work above:** Black Templars' Gladiator
Lancer/Reaper/Valiant had been folded into `sharedUnitIds` as "100% generic," but Black
Templars' own appdata book does list unique entries for all 3 (own `"faction": "Templar Vows"`
vs the generic "Oath of Moment" was the tell). Reverted the fold and restored the 3 as local
datasheets with their Black-Templars-specific `faction`/wording. `ru/black-templars.js` needed
no changes — its own `SHARED` array already assumed the correct (unfolded) state.
