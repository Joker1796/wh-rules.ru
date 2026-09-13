> **Статус:** закрыт 2026-09-02
> **Репозитории:** wh11ed
> **Итог:** конструктор ростеров в проде с v2.3.0 (PR #319, 223 коммита). Архитектура и рабочие
> инварианты живут в `wh11ed/src/components/roster/CLAUDE.md` — этот файл только про ход работ.

# Roster Builder — status

Written 2026-08-03 after merging `main` into `feat/roster-builder` (branch had diverged 13
days / 396 main commits). Transient tracking doc — architecture reference lives in
`src/components/roster/CLAUDE.md` (directory-scoped, loads contextually instead of bloating
`wh11ed/CLAUDE.md`); this file is just the "what's left" list so it doesn't get re-derived
from the commit log again. Delete once every item below is closed.

## Status: functionally complete v1, undocumented (now documented)

The commit history (`git log --oneline <merge-base>..055cf56`) runs through named phases —
Phase 2a (derived data layer) → Phase 9 ("hand off to the tracker") — followed by a round of
polish commits (warlord/enhancement eligibility, tabbed editor, accordions, wargear group
order). The core loop (build a list → validate → export/share → hand off to the Game Tracker)
is implemented and tested.

## Open items

0. **Warhammer Legends and the pre-codex Orks list — BOTH CLOSED 2026-09-02 (shipped v2.3.10).**
   Legends datasheets were listed, badged and filterable but the validation panel said nothing, so
   a matched-play list holding one came out clean; `validateRoster` now raises `legendsUnit` as a
   WARNING (never an error — this file does not block a list, it says what an organiser would).
   And a roster saved before Codex: Orks held indices into a bundle that was regenerated —
   measured against the pre-bump data, 16 of 51 surviving datasheets changed their wargear-group
   count and five changed size brackets — so `useRosters.js` SCHEMA_VERSION 7 drops the picks,
   drops the size only on those five, and renames the two datasheets GW re-issued as squadrons
   (Wartrakk → Wartrakks, Rukkatrukk Squigbuggy → Rukkatrukk Squigbuggies). The five datasheets the
   codex DELETED are deliberately untouched: `unknownUnit` already reports them, and silently
   removing a unit from someone's army is worse than showing the warning.

   Still open from the same report, and NOT a code question: a player says the Nob in a Boyz mob
   "should have a kustom choppa option". Our data matches appdata option-for-option (6 choice
   groups plus the two Default Wargear groups; the Nob starts with Kustom Choppa + Kombi-skorcha,
   which is printed in the loadout line, the melee table and the swap sentences), and the loadout
   accounting is right — with 2 Nobs, one taking a Power Klaw leaves "Kustom Choppa ×1". Either the
   reader is looking for a control for something that is a default, or the printed codex differs
   from GW's app data, which is a question for the user, not a fix.

1. **`RosterUnitRulesModal` doesn't overlay live modifiers.** It renders the unit's *base*
   datasheet only — a chosen enhancement, wargear pick, or Warlord trait that changes a
   stat/ability isn't reflected in the preview. Explicitly flagged in the component's own
   comment (`src/components/roster/RosterUnitRulesModal.vue:4-7`). The roster entry (wargear
   picks, enhancement, warlord flag) is already available to the caller — this is a "do the
   overlay" task, not a "find the data" task.
   **Grew into its own multi-phase task on 2026-08-19 — plan, decisions and progress now live
   in `src/components/roster/CLAUDE.md` → «Modifier overlay» (собственный док ретирнут 2026-08-22).** Short version of what the research found: appdata has
   almost no structural modifiers (6 ability + 2 weapon-profile links across 961 enhancements),
   so an overlay attributes rather than silently recomputes — same philosophy as the existing
   `grantedKeywords` prop on `DatasheetCard`.
2. **Cloud backup — DECIDED AND BUILT 2026-08-22.** Rosters now sync to `wh11ed-api`
   (`/rosters`, four routes mirroring `/games`; `useRosterSync.js` on the frontend). The
   decisions, all the user's: saved lists only (drafts stay on the device), uploads happen on
   the **Save click** rather than on every autosave, one metadata `GET` per visit to `/roster`
   with blobs fetched only for what changed, last-write-wins on the client's `updatedAt`,
   server-side tombstones for deletes (a client-only note turned out to propagate nothing —
   the other device just re-uploaded its copy), and the whole collection uploads on first sign-in.
   Full rationale in `src/components/roster/CLAUDE.md` → "Cloud sync". **Shipped 2026-08-26**:
   the `rosters` table is migrated, the function serves `/rosters` on both api hosts, and a list
   saved in the installed PWA was confirmed to reappear in a browser on the same account.
3. **Stale comment** in `scripts/gen-roster-data.mjs`'s header claiming it "emits units
   without gear for now" — **fixed 2026-08-19** while working on item 5.

4. **`lockDs` inverted eligibility for all 13 attach-granting enhancements — FIXED 2026-08-19.**
   Reported as Necrons' Murdermind being offered on Skorpekh Destroyers though its own text says
   **CRYPTEK** model only.

   Cause: `gen-roster-data.mjs` read appdata's `enhancement_bodyguard_group` (+ `_datasheet`) as a
   whitelist of datasheets allowed to TAKE the enhancement and emitted it as `lockDs`. Those
   tables actually list the units the *bearer* may attach to — which this repo already documented
   correctly in `scripts/sync-enh-bodyguards.mjs`'s header. The gate fired in both directions:
   Murdermind was offered on the four Destroyer datasheets and refused to all 7 Crypteks;
   Slippery Git landed on Kommandos and not the Warboss; Catechism of Divine Penitence on
   Repentia Squad and not the Canoness; Wolf-touched on Wulfen. All 13 enhancements carrying such
   a group were affected, across ~10 factions.

   Fix: that one source was removed from the generator and the roster data regenerated (13
   `lockDs` entries gone). **`lockDs` itself stayed** — the first fix sketch here was wrong about
   that. Its other source, the hand-curated `ENH_LOCK_FIXES`, is legitimate and load-bearing: 36
   "(Upgrade)"-type enhancements name one unit in their prose while appdata records no
   unit-specific keyword at all, so without the lock they show on any Character of the faction
   (Necrons' Enlivened Sentinels appearing on Immortals). Regression tests in
   `rosterEngine.test.js` pin both halves — real data for the attach-granting ones, a fixture for
   the curated lock. The regeneration also brought the roster data up from appdata 913 to 925,
   which added 4 Aeldari units (Clanblade, Dragon Knights, Leystalker, Stonesinger) and changed
   no points, sizes or detachments.

   **Follow-up, also done (2026-08-19):** the attach those tables really describe is now modelled.
   `enhancement_bodyguard_group` is read again — for its actual meaning — and emitted as `attach`
   on the enhancement, so taking Murdermind widens a Cryptek's attachment picker to the Destroyer
   squads instead of leaving it at Immortals. `rosterEngine.js`'s new `leadsFor()` is the single
   place that merges a datasheet's printed `leads` with an entry's granted ones; the picker, the
   reverse "attached leaders" lists and `validateRoster`'s two attachment checks all go through
   it. 13 enhancements across 10 factions grant an attach; all 13 resolve within their own
   faction.

5. **A wargear option can be a BUNDLE of items — FIXED 2026-08-19.**
   Reported on Drukhari Wracks: the instruction offers "1 model's twin torturer's
   tools can be replaced with **1 hexrifle and 1 torturer's tool**", but the checkboxes only let
   you take the hexrifle.

   Not a rendering bug — it goes down to appdata. A `wargear_option` row carries exactly ONE
   `wargearItemId`; the "…and 1 torturer's tool" half of the swap exists only in the group's
   prose. The GW app's own model is a multi-select over those items, with the prose as the
   constraint; `gen-roster-data.mjs` reads the same flat list and `UnitEditorFields`'s `mode()`
   turns any group of 2+ options into a one-of radio. So a bundle option silently loses its
   other half, and the entry's loadout — hence the export, and Tier A's weapon-table trim —
   is missing a weapon the model really has.

   Measured across all 30 factions: **182 of 1475 wargear groups, on 125 units**, name two or
   more of their own items in a single option. Two shapes:
   - **105 plain bundles** — a whole group whose one instruction is a bundle ("This model's
     zealot's vindictor can be replaced with 1 holy pistol and 1 power weapon"). There is no
     choice to make here at all; it should be a single toggle granting both items, and today it
     renders as a 2-way radio where either pick is wrong.
   - **77 bullet bundles** — a real one-of list where at least one bullet combines items
     ("◦ 1 heavy bolter and 1 Mortifier flamer / ◦ 2 Mortifier flamers"). The choice is genuine;
     it is the option that needs to be a set.

   A milder third class (~181 groups) is the **quantity** in the prose — "replaced with 2 bright
   lances" against a single item row. Harmless where it stands, since the weapon table lists a
   name once regardless, but the same parse would fix it.

   **What was built.** `gen-roster-data.mjs`'s `linkWargearBundles` reads the pairing out of the
   prose — and then verifies it against structure, which is what makes it more than a guess:
   appdata's `loadout_choice` enumerates each miniature's complete legal loadouts (1145 of 1146
   datasheets have them), so every set the prose yields must fit inside one of them. **172 groups
   rewritten; 1 left flat** (Space Marines' Lieutenant, whose appdata text reads "1 neo- volkite
   pistol" with a stray space, so the name doesn't resolve — exactly the fail-open case). The run
   prints the leftovers by name.

   Reading the list turned up two shapes the first pass missed, both now handled: appdata uses
   four bullet markers (`◦ ■ ▫ •`), and one list (Grey Knights' Brotherhood Terminator Squad) has
   no marker at all — just a head line ending in ':' with an option per line, plus a `*` footnote
   that is a remark about the options rather than one of them. `splitInstruction` in
   `rosterEngine.js` reads the same shapes for rendering and returns that footnote separately.

   Option slot 0 became polymorphic (item id, or the full `[[id, count], …]` set) with
   `optionItems`/`optionLabel` as its only readers — see `src/components/roster/CLAUDE.md`.
   Because a pick is stored as an index INTO the option list, the renumbering forced
   `useRosters.js` SCHEMA_VERSION 2: v1 rosters lose their `wg` picks rather than have an old
   index silently re-read as a different weapon. Everything else about them survives.

6. **How many models may take an option — FIXED 2026-08-19**, the other half of item 5.

   `wargear_option_group` says what a squad may take, never how many models may take it. That was
   guessed from the instruction text, and the guess was wrong both ways: "Up to 4 Dominions can
   each…" read as no cap at all, "For every 5 models, up to 2 Seraphim" as one. Not cosmetic —
   `unitWargearPoints` multiplies a paid option by its count, so a wrong cap misprices the army.

   appdata has it structurally, in the family the generator used to dismiss as redundant:
   `limited_wargear_choice_set` repeats the same choices and `wargear_limit` gives the cap as a
   step table keyed by unit size, with a duplicate cap per threshold (Cadian Shock Troops: 2 picks
   / 1 of a kind at 10 models, 4 / 2 at 20 — hoisting that to the group would misread half the
   brackets). **219 groups capped**; 43 ambiguous + 82 cross-group sets left alone, and one group
   left uncapped because the prose contradicts the table (named in the run). The quantity class
   from item 5 is partly answered here too — a matched set carries the count ("2 inferno pistols").

   Consequences worth knowing: the cap now decides the editor's MODE, so a group letting several
   models each take something is per-option steppers sharing a budget even where appdata calls it
   a checkbox (that was rendering as one choice for the whole squad); a group whose threshold the
   unit hasn't reached says so in words rather than disappearing, so an existing pick can still be
   cleared; and `validateRoster` gained `overWargearLimit`/`overWargearDup` for the list that was
   legal until its unit shrank.

   **The tail — the quantity in prose OUTSIDE a limited set — CLOSED 2026-08-20.** 76 groups /
   125 options across 22 factions ("this model's 2 starcannons can be replaced with 2 bright
   lances"; 121 of them ×2, two ×4, two ×6). Not purely display after all: `wargearNames` feeds
   the TEXT EXPORT, so a shared list printed `• Bright lance` where the model carries two, on the
   same screen where the default loadout already prints `Starcannon ×2`.

   No structural source exists for these — `loadout_choice` records the model's TOTAL of a weapon,
   not one option's share (Baneblade's twin heavy bolter reads 1/3/5 across its legal loadouts;
   67 of 161 items are ambiguous that way), and the other three `count`-bearing tables either
   already feed the generator or are all-1s (`all_model_wargear_choice_wargear_item`, 71 rows).
   So the prose is it, and `itemsNamedIn` already parsed the number — it was thrown away whenever
   the statement named a single item.

   **The trap that made this worth measuring first:** the prose mixes two different numbers. "Up to
   2 seeker missiles" / "up to 4 big shootas" state an ALLOWANCE — how many separate picks, each
   of one item — and reading them as a set would arm a Tiger Shark with six missiles for one pick.
   7 groups are in that shape, and they are exactly the 7 whose number contradicts every legal
   loadout in appdata; a head line matching `up to N` now drops the count and keeps membership.
   69 groups gained a real quantity.

   Two things deliberately did NOT change. Points: `unitWargearPoints` multiplies by the number of
   PICKS, never by the count — Forgefiend's "2 Hades autocannons → 2 ectoplasma cannons" costs the
   5 points appdata charges for the swap, and a test pins that. SCHEMA_VERSION: the count is written
   onto the existing options in place, so unlike the bundle rewrite no option INDEX moves and stored
   picks stay valid.

7. **The same instruction shown twice — FIXED 2026-08-19.** Reported on Drukhari Wracks ("На
   каждые 5 моделей в отряде:" appearing twice).

   appdata hangs option groups off MINIATURES, not off the datasheet, so a bullet about the whole
   unit is recorded once per miniature profile — checkbox on the leader model, stepper on the
   rank-and-file one. Not just a repeated heading: each copy carried its own allowance, so the
   swap could be taken twice.

   `mergeMiniatureDuplicates` folds a pair into one unit-wide group (`all: 1`, no `m`) when the
   instruction text AND the option sets match — a leader with a real separate allowance is always
   worded differently, so it can't collide. **101 pairs across 50 units**; in all of them the
   copies agreed on what they replace. Running it before the limit matching was the bigger win:
   identical groups were what made a limited set ambiguous, so ambiguity fell 43 → 1 and capped
   groups rose 219 → 261.

   The text match is **whitespace-normalised**, which is the whole of the follow-up commit: the
   two copies are typed into appdata twice and one pair (Deathwatch Terminator Squad) differs by
   a trailing space, so it interned as a different text id and the first, exact version of the
   fold walked past it. It is deliberately **not** order-normalised — a reordered option list is
   a different statement, not the same one written twice.

   A corpus scan of every within-unit pair sharing an option set says what is left, and both
   classes are meant to stay: 7 pairs share the lead-in but differ in options (Battle Sisters'
   "1 Battle Sister's boltgun can be replaced with one of the following" is printed once for the
   special- and once for the heavy-weapon slot — two allowances, and GW prints it that way too),
   and 15 share the options under different text (a base allowance plus an "if this unit contains
   10 models" one). Exact, whitespace-variant and reordered duplicates are all at zero, and
   `src/data/roster/index.test.js` keys its invariant on the normalised text so the next one
   fails a test rather than doubling a section.

   SCHEMA_VERSION 3 for the same reason as v2 — group indices moved, and a stale index would
   quietly mean a different weapon.

8. **The instruction's own words hid what a swap gives up — FIXED 2026-08-20.** Found while
   measuring item 6's tail, and bigger than that tail: a group's `rep` (the item it replaces) is
   parsed out of the prose, and the parse silently produced nothing for **129 of the 910 groups**
   that say "replaced with". `rep` is not cosmetic — `defaultLoadoutLines` uses it to shrink the
   "starts equipped with" line, and Tier A's overlay (`rosterModifiers.js`) uses it to drop the
   swapped-away weapon row, so a missing one leaves a weapon on the card that the model gave up.

   Three causes, all the same shape — the name in the prose is not spelled the way the item table
   spells it: a **quantity** in front of it ("this model's 2 lastrum storm bolters", 54 groups), a
   **U+2010 hyphen** inside it ("multi‐laser", "hot‐shot lascarbine", 18 groups — the same class of
   silent no-op as apostrophes in enhancements and `ë` in Votann detachments), and a **plural
   possessive** ("up to 3 models' combi-bolters", which the `'s`/`’s` pattern never matched).
   Fixed by keying the name vocabulary through `norm()`, stripping a leading count and a trailing
   plural before the lookup, accepting `s’` as a possessive, and walking every possessive in the
   sentence rather than only the first (an item's name can itself contain "and" — Cult claws and
   knife — so the whole phrase is tried before splitting on it). **781 → 973 groups** know what
   they give up; the 19 left over were read in a second pass — see item 14.

9. **40 units had no default loadout at all — FIXED 2026-08-20.** Same session, found by asking why
   Blood Angels Captain's "heavy bolt pistol" resolved to nothing: **144 datasheets have no
   `base_miniature_loadout` row**, and for **136 of them** appdata records the starting gear as a
   wargear option group whose instruction is literally "Default Wargear" — a group the generator
   drops as redundant. So those units shipped with no `defaults`: no "starts equipped with" line in
   the editor, and nothing for the overlay to subtract from. `staticLoadout()` now reads that group
   when the loadout table has no row (same `[[miniIdx, [[item, count]]]]` shape, count 1 — all a
   `wargear_option` can express). **32 units in the roster corpus gained a default loadout**; the 8
   still without one are genuinely unarmed (Aegis Defence Line, Drop Pod, Skull Altar, Spore Mines…).

10. **Leaders lost every attachment stated as a KEYWORD — FIXED 2026-08-20.** Found by auditing
    which appdata tables no script reads (full audit in `APPDATA-COVERAGE-PLAN.md`).
    `datasheet_bodyguard_group` can name its targets through `datasheet_bodyguard_group_keyword`
    instead of `_datasheet`, and the generator only ever read the list table. All **36** such groups
    are keyword-only — none is also listed — so those attachments simply did not exist: Captain and
    23 other leaders could not lead a Sternguard Veteran Squad, Tor Garadon/Iron Father Feirros/
    Marneus Calgar in Armour of Antilochus could not lead Eradicators, the Terminator-armour
    characters could not lead a Terminator Squad, and the four Inquisitors had no Imperium
    Battleline Infantry.

    Same class as the `enhancement_bodyguard_group` bug one day earlier, opposite sign — eligibility
    MISSING rather than invented. Worth knowing: **wh40k-appdata's own bundle has the same hole** —
    `adeptus-astartes.json` emits `{"bodyguardType":"leader","units":[]}` for exactly these groups —
    so the fix reads the raw table, not the bundle.

    Keywords resolve against the faction's own datasheets (plus the shared Codex: Space Marines pool
    for a Chapter, or Blood Angels Captain would find no Sternguard). **56 leader→unit links**
    recovered, and a keyword group can name a unit a listed group already covers, so `leads` is now
    deduped — the picker was about to offer the Inquisitor four units twice.

11. **Per-profile model counts — DONE 2026-08-20.** The one item the table audit
    (`APPDATA-COVERAGE-PLAN.md`) ranked as real work rather than a defect. `unit_composition` +
    `unit_composition_miniature` give the model count of each MINIATURE PROFILE per points bracket
    (`Acothyst 1-1 | Wrack 4-4` at 60 pts), and nothing in the project read them: the bracket
    carried a total parsed out of the bundle's `models: '5-10'` string and nothing else.

    **Mapping.** Compositions sort by `displayOrder` and pair with the bundle's `points[]` BY INDEX
    — all 1545 line up on both points and the min/max sum. Matching on points instead breaks on the
    units that price several compositions the same (Corsair Voidscarred has four 7-model builds at
    140), which is what made the first measurement look like 13 disagreements.

    **Emitted** as `sizes[i].comp = [[miniIndex, min, max?], …]`, multi-profile datasheets only:
    488 brackets on 249 units, ~100 KB across the lazily-loaded faction files. Rejected if the two
    lists disagree in length, points or total — 0 did.

    **`modelsPerMini(def, entry)`** turns that into `Map(profile → models)`: fixed rows as they
    stand, the single free profile takes the remainder. Where TWO profiles are free (7 compositions
    — Deathwatch kill teams, Accursed Cultists) it returns `null` and every caller falls back,
    because that split is the player's and nothing records it.

    **What it fixed, in order of how wrong it was:**
    - **412 groups on multi-profile units never subtracted anything.** `defaultLoadoutLines` and
      Tier A's weapon trim both bailed out on `def.minis?.length > 0` for want of a model count, so
      a swapped-away weapon stayed on the card next to the one that replaced it. Both now spend a
      swap against the group's own profile, through one shared `swapsByMini()` instead of the copy
      each used to carry. 331 profile-bound groups fixed; the 81 unit-wide (`all`) ones still
      subtract nothing — they belong to no single profile.
    - **62 uncapped steppers were over by the squad's leader models.** "Any number of Sicarian
      Ruststalkers can each have their transonic razor replaced" allowed 10 in a 10-model unit; the
      Princeps is not one of them, so it is 9. Four of those groups are paid, i.e. it was also a
      way to overpay. `validateRoster` gained the matching check for a list built before the cap.
    - **42 duplicate brackets, folded.** appdata publishes a bracket a second time under an ally
      grouping keyword (`referenceGroupingKeywordId`), so Aquila Kill Team showed four size pills
      for two real choices and Callidus Assassin two for one. Folded on models+points+breakdown —
      Callidus keeps its genuinely different 100 and 115 pts entries. **SCHEMA_VERSION 4** because
      bracket indices moved; `size`/`count` fall back to the unit's default rather than being
      re-read as a different bracket, and wargear picks survive.
    - **32 brackets that read identically now say what differs.** Corsair Voidscarred prices three
      7-model builds at 140 points; the pills differed only in which specialist is in the squad, so
      those pills — and only those — carry the deciding profile names. All 32 resolve to a non-empty
      name. A composition line ("1× Acothyst + 6× Wrack") sits under the model stepper.

12. **Two detachments sharing a tag were takeable — FIXED 2026-08-20.** "This detachment has the
    DYNASTY tag and cannot be taken with another DYNASTY detachment" (core rules 25.04, and
    `muster.js` already prints the general form: "some detachment rules list … other detachments
    that your army … cannot include"). **26 tags across 17 factions, and 19 of those pairs fit
    inside a 3 DP budget** — so an illegal army was two clicks away, unflagged.

    The DATA was already right and already complete: `detachment.unique` in the hand-written
    faction files, shown on the reference page (`FactionRuleView`'s "Unique: …"). What it never did
    was reach the roster layer — `buildDetachment` read `dp` and `forceDisposition` from mfm and
    stopped there. (A first pass at measuring this claimed 34 missing tags; that was a regex over
    the source files, not the data. Importing the modules says 57 tags, all 55 of appdata's
    agreeing, plus two appdata lacks.)

    Three sources, none complete alone, so the generator takes ours and reports disagreement:
    mfm has 55, appdata's `detachment_unique_keyword` the same 55, and the faction files two more
    (World Eaters' ONSLAUGHT pair, off the Faction Pack). The failure being guarded against is
    silent — if the mfm scrape stops finding tags after a site change, the editor quietly stops
    barring illegal pairs — so `sync-detachment-details.mjs` now cross-checks every tag against
    appdata and names the two known wh11ed-only ones so a real regression stands out.

    Enforced in both places, for the two different ways a bad list happens: the picker greys out a
    detachment whose tag is taken (visible with the reason, like an already-used enhancement),
    and `validateRoster` reports `detachmentTagClash` for a list that was imported or predates the
    tag. The picker is shared with the Game Tracker's setup screen, which gets the same guard.

13. **Allegiance choices — the mark a unit picks — BUILT 2026-08-20.** The last real item from the
    table audit. Two mechanics share appdata's `allegiance_ability`/`_group` pair, and the roster
    knew neither: **92 units**, 48 with a mandatory choice, 36 with a capped one, 8 uncapped.

    - **Mark of Chaos** (43 Chaos Space Marines datasheets, only inside Pactbound Zealots). The
      detachment rule is already in our data verbatim, restrictions and all, and two of the three
      restrictions matter here. "You cannot select KHORNE for a Psyker unit" needs **no parsing**:
      the 5 Psyker datasheets point at a second group that simply has no Khorne. "A Character unit
      can only be attached to a unit if both share the same keyword" is now enforced —
      `leaderTargetsFor` hides a target that took a different mark (one that hasn't chosen yet
      stays offered, since marks are picked in any order) and `validateRoster` reports
      `allegMismatch` for a list built before the check.
    - **Daemonic Allegiance** (5 datasheets, ungated): the Daemon Princes and the Soul Grinder,
      whose mark also **arms it** — "additionally equipped with: phlegm bombardment" — so the
      choice feeds `loadoutItemIds` and the weapon shows on the card.
    - **The CHARACTER-granting upgrades** (44 datasheets over 5 detachments: Headhunter Task Force,
      Steel Hammer, Houndpack Lance, Solar Spearhead, Subterranean Assault). Same widget, different
      meaning — and the consequence that matters is `enhEligible`: a Rhino that gained CHARACTER can
      carry an enhancement, which is the whole point of the upgrade.

    Everything is structural — the 274 `conditional_keyword` rows that
    `gen-conditional-keywords.mjs` deliberately skips (a static datasheet page has no roster to
    choose in) are exactly what supplies the granted keyword here. Emitted as `unit.alleg`
    `{ g, t, det?, req?, max?, o: [{ n, kw?, wg? }] }`; `det` is the detachment NAME, because that
    is what a roster stores. No SCHEMA_VERSION bump — `entry.alleg` is a new field, no index moves.

    Shown as a pill row in the unit editor (gated on the detachment, with the added weapon named on
    the option), printed in the text export — the rules require the mark noted on the roster, so a
    list without it isn't legal — and validated three ways: `allegMissing`, `allegOverLimit`,
    `allegMismatch`.

    **Not done, deliberately:** the characteristic changes a Daemonic Allegiance mark brings (+1 T,
    +2 S on hellforged weapons, +2" M, +3 A on the infernal cannon). Those belong in Tier C's
    sidecar — 12 short entries behind its existing proofread-and-pin pipeline — and the text is
    already visible on the card as the datasheet's own `specialAbilities`, so nothing is hidden
    meanwhile. Done in the 2026-08-22 review pass (see `src/components/roster/CLAUDE.md`).

14. **The last 19 unparsed instructions — 17 read, 2 left on purpose, 2026-08-20.** The tail of
    item 8, sorted into six classes and fixed by reading the datasheet instead of the sentence.

    - **"X or Y" — 8 groups.** "their Autoch-pattern bolter **or** ion blaster replaced with…"
      doesn't say which weapon is given up, but the profile usually does: its default loadout holds
      one of the two. Resolved against the profile's own defaults, which is also why this is the
      one reading with a **known limit** — the answer is right for the FIRST such swap, and a model
      that already traded X for Y through an earlier group has moved on where static data can't
      follow. **2 stay unresolved** because the profile genuinely holds both (a Havoc starts with
      the autocannon *and* the lascannon; the Wulfen Dreadnought with both its melee weapons), so
      the choice is the player's and guessing would delete a weapon the model still has.
    - **A weapon CATEGORY instead of a name — 3 groups.** "1 model's **ranged weapon** can be
      replaced with 1 shardlauncher" (all three Termagants swaps). Answerable from
      `wargear_item_profile`'s `type` when the profile carries exactly one weapon of that type.
    - **appdata spelling one item two ways — 4 groups.** The prose says "kustom-mega blasta" where
      the item table says "Kustom mega-blasta" (punctuation), "absolver" where it says "Absolvor"
      (one letter), "plague combi-bolter" where the item is just "Combi-bolter" (one extra
      adjective). Three tiers below the exact lookup, each accepting **only when exactly one item
      can be meant**: a punctuation-blind index, a one-character-at-equal-length match, and a
      one-word prefix.
    - **A nested "and" — 1 group.** "their autopistol **and** cult claws **and** knife" is two
      items, not three, because "Cult claws and knife" is one of them. Every way of splitting on
      "and" is now tried, fewest pieces first, and the first reading where every piece is a real
      item wins.
    - **No possessive at all — 1 group.** "Each model can have each shuriken cannon it is equipped
      with replaced with…" (War Walkers, the only one corpus-wide) got its own pattern.

    **973 → 990 groups.** The suffix tier is the one that needed a guard and got two: it first ate
    "condemnor bolt pistol and null mace" down to "Null mace" (104 groups silently answering with
    the last weapon named), then read "its bolt shotgun" as a name when it was a fresh clause. Both
    are now impossible — the prefix must be exactly one word, and not an article or possessive.
    Verified by diffing every group's resolved `rep` against the previous generator, old vs new:
    **17 gained, 0 lost, 0 changed**. Six pinning tests added, and the corpus ceiling in
    `index.test.js` tightened from ≤25 unparsed to ≤2.

15. **A ticked checkbox spent the swap on the whole squad — FIXED 2026-08-20.** Found by asking
    whether item 14's "X or Y" caveat could actually bite. It can, but the bigger finding was
    underneath it: `swapsByMini` read every non-stepper group as consuming **every model of the
    profile**, so "1 Battle Sister's boltgun can be replaced with one of the following" — a
    checkbox — removed all **nine** boltguns from the "starts equipped with" line and dropped the
    row from the datasheet card. **100 groups corpus-wide** word their allowance that way ("1
    model's…", "Up to 2…", "One Celestian Insidiant's…"); only **5** actually mean the whole
    profile ("All models in this unit can each have their…", "Any number of…").

    Item 14 had quietly made this worse for 3 of them: Canoptek Macrocytes' two "1 model's gauss
    scalpel or tesla caster" groups and Hearthkyn Warriors' "Up to 2 … or ion blaster" went from
    showing one weapon too many (no `rep` at all) to showing five and nine too few.

    The generator now flags the 5 whole-profile groups with `repall`, and a checkbox without it
    spends one model per ticked option — which is what a single yes/no means. No SCHEMA_VERSION
    bump: `repall` is a new field on a group, no index moves.

    **The "X or Y" caveat itself stands and is smaller than it looked.** In all 8 groups the
    alternative exists precisely because a sibling group can produce it — Hearthkyn's ion blaster
    comes from the group above it, Macrocytes' tesla caster from theirs — so a model that already
    traded X for Y is a normal build, not an edge case, and `rep` still names X. What that costs is
    now bounded by the ticks actually made rather than by the squad size: at worst the line keeps a
    weapon that was traded away twice over, the same error class the parse had before item 14 for
    all 19.

16. **Audit of the whole feature, 2026-08-20 — 9 findings, all fixed.** A read-only pass over the
    ~10.5k lines (5 views, 7 components, the 8 pure composables, the generator and the whole
    generated corpus). What it did NOT find matters too: 24 issue codes and 88 UI labels all present
    in both locales with matching parameters; DP and enhancement points identical to the MFM across
    268 detachments and 909 enhancements; no dangling references anywhere in the corpus; the
    entry chunk still free of roster data. The nine that were real:

    1. **Points were appdata's, not the MFM's.** appdata records several parallel price rows per
       datasheet — one per Chapter, one per allied context — and mapping them onto `sizes` turned a
       price list into a size list: **29 brackets on 21 units** offered the same size twice at two
       prices, the first arbitrarily pre-selected, and **30 brackets disagreed with the price the
       same unit's datasheet page shows** (up to 35 points on Inquisitor Draxus; Space Marines were
       quoting Blood Angels' numbers). The generator now takes brackets from appdata and prices from
       the MFM, collapsing 79 duplicate rows, and a Chapter's own price for a shared Codex unit
       rides on the file as `unitPoints` (11 units, matching the datasheet layer's
       `pointsOverrides`). Details in `src/components/roster/CLAUDE.md` → Points.
    2. **The editor offered an enhancement the validator called illegal.** `enhOptionsFor` asks
       about the entry (an allegiance upgrade can hand a vehicle CHARACTER); `validateRoster` asked
       about the printed sheet. Reproduced on real data: Telemon Dreadnought in Solar Spearhead,
       offered Honoured Fallen, flagged `enhIneligible`. 44 datasheets across 5 detachments.
    3. **The creation wizard lost every unit if you left any way but "Done"** — they lived in
       component state until `finish()`, while the roster itself had been created back on step 2.
    4. **…and its own copy of `removeUnit` forgot to detach a Leader** — precisely the divergence
       `useRosterEditing` was created to prevent. Both operations now come from `rosterEngine`
       (`addUnitEntry`/`removeUnitEntry`).
    5. **An entry whose datasheet id vanished was invisible, not reported**: 0 points, filtered out
       of every list and the export, no issue raised. Rosters outlive the data they were built
       against. New `unknownUnit` issue.
    6. **The share-link preview showed no wargear at all** — `RosterSharedView` was the only
       `buildRosterText` caller not passing `items`, so every line resolved to an empty string and
       was filtered out. The payload also gained the storage `SCHEMA_VERSION`, and `importRoster`
       now migrates it: a link is as long-lived as a bookmark and carries the same
       indices-into-generated-data a stored roster does.
    7. **Death Company Dreadnought was armed with the Brutalis Dreadnought's weapons** — an upstream
       `base_miniature_loadout` row in wh40k-appdata. Only 1 of 1036 units whose default loadout
       disagrees with its own printed one (the other 8 hits were spelling variants). Fixed locally
       by a named substitution (`LOADOUT_ITEM_FIXES`), pinned by a test so it gets dropped when
       upstream fixes it. **Worth reporting upstream.**
    8. **Three unread fields.** `alleg.min` (Houndpack Lance requires exactly 3 War Dogs — only the
       cap was checked), `enhancements[].notWarlord` (World Eaters' Disciple of Khorne), and
       `leads[].reqDet`/`exclDet` (59 each; harmless today only because appdata states both halves
       of every gated pair — verified 0 one-sided gates). All three now read; two new issue codes.
       Also latent and now closed: `RosterViewView` skipped the `grantedKeywordsFrom` pre-pass its
       sibling reader does.
    9. **No `--check` for the roster data** — the largest generated surface of the feature, and the
       only generated sidecar in the repo without one. `npm run roster:data:check`, wired into
       `npm run sync`.

    Two data-quality checks written during the audit became tests rather than scripts: "no unit
    offers the same bracket at two prices" and "points agree with the MFM wherever the MFM prices
    that size" (`src/data/roster/index.test.js`). 848 tests, build clean.

    **Not changed, deliberately:** the wizard still offers model counts inside a range bracket
    (6-10 → 6,7,8,9,10) — appdata's own bracket wording, verified against the source; and
    `Flash Gitz`' second bracket really is labelled "5-10" upstream where it means 6-10.

17. **A wizard-built list showed 0 points — FIXED 2026-08-21** (`cdc3d04`), and the fix named the
    rule the codebase had been keeping only by habit. `roster.summary`
    (`{ points, unitCount, issues }`) is what the two list screens show — `RosterListView` and the
    tracker's `RosterPickerModal` — because neither may load a faction's data chunk, and points
    live in that chunk. So the summary is a **cache**, and it was written in exactly one place:
    `RosterEditorView`. A roster finished in the creation wizard therefore reached the list
    priced at zero, and so did every roster imported from a share link (a share payload carries
    no summary on purpose — it would be the sender's arithmetic).

    The rule now lives in one module, `src/composables/rosterSummary.js`: *whoever changes a
    roster while holding its faction data writes the summary.* Both editing screens do it through
    `useRosterEditing` (one `watchEffect`, moved out of the view), the wizard does it on finish.
    `refreshSummaries()` is the safety net under those writers — the list screens call it on
    mount; it prices only rosters whose cache is missing or contradicted by their own unit count,
    loads at most one faction chunk per faction involved, and writes straight onto the roster
    rather than through `updateRoster`, because repairing a number the app failed to cache is not
    the user editing their list and the list shows `updatedAt`. Its own chunk (6.35 kB) rides the
    list screens, not the entry chunk.

18. **The wizard keeps a draft — BUILT 2026-08-21** (`ce22b3d`). Reloading the page or navigating
    away mid-wizard used to lose everything. Now the roster is created **as soon as a faction is
    picked**, carries `draft: true` + `draftStep`, and the wizard puts its id in the URL
    (`/roster/new?draft=<id>`), so a reload resumes at the same step with the same units. The
    save button is «Сохранить» (`rosterSave`, shared with the editor) and it is what clears the
    draft flags. `RosterListView` grew tabs — Saved / Drafts, with the step shown in the draft's
    meta row — and opening a draft reopens the wizard rather than the read-only view.
    `RosterPickerModal` never offers a draft: attaching a half-built list to a game is not a
    thing anyone means to do. No migration was needed — an absent flag means saved — and the
    flags stay out of share links and game snapshots because both whitelist their fields.

    User decisions behind it (2026-08-21, not derivable from the code): draft starts at the
    faction pick, «New roster» always starts a NEW draft rather than resuming the last one,
    reopening resumes at the step it was left on, and drafts are hidden from the tracker picker.

## Where the merge-into-main work is recorded

The `main`-catch-up merge itself (conflict resolution, a stale test fixed for `BaseModal`'s
`<Teleport>`, `getFaction()` → `loadFaction()` call-site updates) is documented in the merge
commit message (`git log --grep "Merge branch 'main' into feat/roster-builder"`), not
repeated here — this file is about the feature's own state, not that housekeeping.

## How roster cloud sync actually went out (2026-08-26)

Shipped in the documented order — schema, function, smoke, frontend — as part of the v2.3.0
release. Two things the checklist that used to live here got wrong, both now corrected in
`wh11ed-api/README.md`, which is the permanent home for this procedure:

- **Terraform is not an option.** Its state was a local file in a checkout that no longer exists;
  an apply from an empty state would try to create all eleven resources, the users' database
  among them. The function went out with `yc serverless function version create`, mirroring the
  live version's config.
- **`npm run migrate` did not run** — ydb-sdk keeps `Driver` on its ESM default export only, which
  esbuild hides and Node does not. Fixed the same day; the command works from the repo again.

The env defaults moved to `wh-rules.ru` in the same function version, which also closed step 1 of
the domain cutover (`MIGRATION.md`, Phase 3).
