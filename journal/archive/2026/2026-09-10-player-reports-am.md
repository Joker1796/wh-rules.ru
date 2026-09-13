> **Статус:** закрыт 2026-09-10
> **Репозитории:** wh11ed
> **Итог:** три жалобы из четырёх оказались нашими багами и исправлены в v2.3.12; по четвёртой
> (Lord Solar) правило нашлось — первый вердикт был неверен. Добавлены гейты `detmeta`, `wtags`,
> `dsrules`.
> **Связано:** [хвосты по жалобам](../../paused/2026-09-13-player-report-tails.md)

# Жалобы игрока (Astra Militarum), 2026-09-10 — разбор и план

Игрок («шарю только за имперскую гвардию») прислал 4 пункта. Три из них — наши, один — память
о 10-й редакции. Ниже: вердикт по каждому, что вылезло сверх жалобы, и план правок.
Анализ сделан 2026-09-10, код НЕ трогали. Источники правды: `wh40k-appdata` (ветка `master`)
и `src/data/mfm/*.js` (скрейп MFM v1.4).

---

## 1. Combined Arms: 3 DP на странице фракции вместо 2 — НАШ БАГ

- `src/data/factions/astra-militarum.js:156` → `dp: 3`
- `src/data/mfm/astra-militarum.js:13` → `dp: 2`; `wh40k-appdata/factions/astra-militarum.json` → `dp: 2`
- Рендер: `src/views/faction/FactionRuleView.vue:32-33` (`det.dp`, `det.forceDisposition`)
- Конструктор ростеров читает `src/data/roster/*` (генерится из appdata) → там 2.
  Отсюда ровно то расхождение, которое увидел игрок.

**Это не единичная опечатка — см. §5.**

## 2. Deathstrike: нет текста правила Plasma Warhead — НАШ ПРОБЕЛ

- Тег на профиле есть: `src/data/datasheets/astra-militarum.js`, юнит `deathstrike`,
  `ranged[0].tags = ["BLAST","ONE SHOT","PLASMA WARHEAD"]`.
- Текста нет нигде: ни в `src/data/reference.js` (там живут оружейные способности),
  ни в `src/data/glossary.js`. Теги рендерятся как надпись (`DatasheetCard.vue:48,61` →
  `renderInline('[' + t + ']')`), никакого лукапа определения нет.
- Источник есть: `wh40k-appdata/tables/wargear_ability.json`, запись
  `5ef6bd29-2f9c-4ce4-9ca7-f9fefb8b3814` «Plasma Warhead». Текст игрока совпал с ней слово в слово.

**Это тоже класс, а не один тег — см. §6.**

## 3. Lord Solar Leontus должен автоматически быть варлордом — НЕ НАШ БАГ (10-я редакция)

- В 11 ed его абилка `The Lord Solar` = «At the start of your Command phase, if this model is
  on the battlefield, you gain 1CP». Требования «must be your WARLORD» нет.
- Проверено шире: во **всём** `wh40k-appdata/factions/*.json` строки «must be your Warlord»
  нет ни разу; механика упомянута только в core rules (шаг SELECT UNITS,
  `tables/rule_container_component.json`, единственное вхождение).
- В наших roster-данных существует только флаг `noWarlord` (28 юнитов) — обратного флага нет
  и не нужно.
- **Действие:** ничего не менять, ответить игроку.

## 4. Militarum Tempestus Command Squad: даёт взять только одно спецоружие — НАШ БАГ (UI)

Правило (appdata + `items.js` текст 259):
> Any number of Tempestus Scions can each have their hot-shot lasgun replaced with one of the
> following: flamer / grenade launcher / hot-shot volley gun / meltagun / plasma gun.
> \* You cannot select the same weapon from this list more than once per unit.

Т.е. до 4 Скионов, каждый со СВОИМ спецоружием, дубли запрещены.

- Данные в порядке: `src/data/roster/astra-militarum.js`, юнит `militarum-tempestus-command-squad`,
  группа `gi:1` — `in:"checkbox"`, `repall:1`, 5 опций, **`lim` отсутствует**.
- Ломается в UI: `src/components/roster/UnitEditorFields.vue` → `mode(g, gi)`:
  `cap` (из `wargearGroupCap`) равен `null`, потому что нет `lim` → при `g.o.length > 1`
  возвращается `'radio'` → одна галочка на весь отряд.
- Валидатор при этом допускает больше: `wargearGroupFallbackCap` = число моделей профиля (4 Скиона).
  Т.е. режет именно редактор, не правило.
- Побочно: `repall:1` в `defaultWargearPoints` / `wargearGroupLive` трактует одну галочку как
  замену у ВСЕХ моделей профиля (`consumed = scope`). При починке множественного выбора это
  надо пересчитать, иначе очки поедут.

---

## 5. СИСТЕМАТИКА: dp / forceDisposition на страницах фракций разъехались с MFM

Сверка всех 270 детачментов `src/data/factions/*.js` ↔ `src/data/mfm/*.js`:

- **9 расхождений по `dp`**
- **52 расхождения по `forceDisposition`**
- MFM ↔ appdata при этом сходятся **1-в-1 (197/197 по обоим полям)** → врут именно рукописные
  страницы фракций, источник в порядке. Шапка `factions/astra-militarum.js` сама декларирует
  приоритет «MFM > Faction Pack > Codex» для dp/FD — то есть правило есть, соблюдение поехало.

### DP (site → должно быть)

| фракция | детачмент | сайт | MFM/appdata |
|---|---|---|---|
| adepta-sororitas | Bringers of Flame | 3 | 2 |
| astra-militarum | Combined Arms | 3 | 2 |
| imperial-agents | Imperialis Fleet | 3 | 2 |
| imperial-agents | Ordo Hereticus, Purgation Force | 3 | 2 |
| imperial-agents | Ordo Malleus, Daemon Hunters | 3 | 2 |
| imperial-agents | Ordo Xenos, Alien Hunters | 3 | 2 |
| imperial-agents | Veiled Blade Elimination Force | 3 | 1 |
| tau-empire | Retaliation Cadre | 2 | 3 |
| thousand-sons | Hexwarp Thrallband | 2 | 3 |

### Force Disposition — 52 штуки

Полный список — в приложении в конце файла. Затронуты: adepta-sororitas (3),
adeptus-custodes, adeptus-mechanicus, aeldari (2), astra-militarum (Mechanised Assault),
black-templars (2), chaos-daemons, chaos-knights (3), chaos-space-marines (2), dark-angels,
death-guard, deathwatch, drukhari (3), emperors-children (4), genestealer-cults (2),
grey-knights (3), imperial-agents (3), imperial-knights (3), necrons, space-marines (6),
space-wolves, tau-empire (2: Kauyon, Mont'ka), thousand-sons (3), world-eaters (2).

### Почему гейт молчал

`scripts/sync-tracker.mjs`, категория `detachments` (строки ~290-321) сверяет
**MFM ↔ appdata**. Они согласованы → отчёт чистый. `src/data/factions/*.js` — поверхность,
которую реально видит игрок — в сверку **не входит вообще**. Классика «гейты должны кусаться».

### Шесть детачментов «NOT IN MFM» — НЕ дрифт

`Luminen Auto-choir` (AdMech), `Serpent's Brood` (aeldari), `Lion's Blade Task Force` (DA),
`Reaper's Wager` (drukhari), `Forgefather's Seekers` + `Emperor's Shield` (SM) — отсутствуют
и в MFM, и в appdata (проверено в т.ч. по слаг-мэппингу aeldari→asuryani,
space-marines→adeptus-astartes). Это Faction-Pack-only детачменты. Будущий гейт должен их
пропускать, а не флагать.

## 6. СИСТЕМАТИКА: 8 оружейных способностей без текста нигде на сайте

Из 30 базовых способностей, встречающихся в `src/data/datasheets/*`, в `reference.js` описаны 22.
Нет текста у 8 (17 профилей оружия суммарно):

| тег | профилей | источник текста |
|---|---|---|
| CONVERSION | 7 | `wh40k-appdata/tables/wargear_ability.json` (несколько вариантов — 12"/18"/24", брать по датащиту!) |
| C'TAN POWER | 3 | там же |
| REVERBERATING SUMMONS | 2 | там же |
| PLASMA WARHEAD | 1 | там же |
| LINKED FIRE | 1 | там же |
| PSYCHIC ASSASSIN | 1 | там же |
| OVERCHARGE | 1 | там же |
| HARPOONED | 1 | там же |

Важно: у `CONVERSION` в appdata **несколько разных записей** с разной дистанцией
(«не ближе 12"», «дальше 18"», «дальше 24"») — нельзя брать одну на всех, надо привязывать
к конкретному оружию/датащиту.

RU-текстов нет и автогенерации на них нет (в отличие от `npm run roster:texts-ru`) — писать руками.

## 7. СИСТЕМАТИКА: «any number … can each have» схлопнуто в radio

Тот же дефект `mode()`, что в §4. Прогон по всем 1375 gear-группам всех фракций:
289 групп «checkbox + >1 опции + без `lim`», из них по формулировке подпадают 6:

| фракция | юнит | gi | repall | опций |
|---|---|---|---|---|
| astra-militarum | Militarum Tempestus Command Squad | 1 | 1 | 5 |
| astra-militarum | Catachan Command Squad | 0 | 1 | 6 |
| tyranids | Carnifexes | 0 | 1 | 5 |
| tyranids | Carnifexes | 1 | 1 | 3 |
| tau-empire | Broadside Battlesuits | 0 | — | 4 |

`space-marines | Reiver Squad` в выборку попал, но это **ложное срабатывание**: «All models in
this unit can each have their combat knife replaced with 1 bolt carbine…» — там действительно
один выбор на весь отряд, radio корректен.

Broadside — отдельная форма («can each be equipped with **up to two** of the following, but
cannot take duplicates»), одним правилом с остальными не чинится.

---

## План правок (вечер)

1. **DP/FD страниц фракций → MFM.** 9 правок dp + 52 правки forceDisposition в
   `src/data/factions/*.js`. Проверить, не дублируется ли значение в `src/data/factions/ru/*.js`
   (у AM `ru: en`, у части фракций RU-оверлей отдельный).
2. **Гейт в `npm run sync`:** добавить сверку `src/data/factions/*.js` ↔ MFM по `dp`/`forceDisposition`
   (в `sync-tracker.mjs` рядом с существующим `checkDetachments`, или отдельным чеком).
   Whitelist для 6 Faction-Pack-only детачментов из §5. Без этого разъедется на следующем бампе MFM.
3. **8 оружейных способностей** в `reference.js` (EN) + RU-оверлей. У CONVERSION — разбираться
   по каждому оружию отдельно.
4. **`mode()` в UnitEditorFields.vue** (или `lim` с `dup: 1` из `scripts/gen-roster-data.mjs`)
   для 5 групп из §7 + пересчёт очков из-за `repall`. Прогнать `rosterEngine.test.js`,
   `UnitEditorFields.test.js`, `rosterValidation.test.js`.
5. **Ответ игроку:** по трём пунктам прав, по Lord Solar — правило изменилось в 11 ed.
6. После правок данных: `npm run build`, `npm run sync`, `npm run radii`, `npm run dupes`;
   запись в `src/data/changelog.js` (сверить версию с `package.json`, см. правило про чейнджлог).

## Как воспроизвести цифры

Скрипты разбора жили в scratchpad сессии (не сохранились). Воспроизводится так:

- **DP/FD дрифт:** пройти по `src/data/factions/*.js` (экспорт вида `export const x = { en, ru }`,
  брать `.en.detachments`), сопоставить по `name` с `src/data/mfm/<slug>.js` `.detachments`,
  сравнить `dp` и `forceDisposition`.
- **Оружейные теги без текста:** собрать все `"tags"` из `src/data/datasheets/*.js`,
  нормализовать (отрезать хвостовые числа/`D6`/`N+` и суффиксы после `:`, схлопнуть `ANTI-*`),
  проверить наличие `'[' + base` в `src/data/reference.js`.
- **radio-схлопывание:** пройти по `src/data/roster/*.js` `.units[].gear[]`, взять
  `g.in !== 'stepper' && g.o.length > 1 && !g.lim`, отфильтровать по тексту
  `items.js.texts[g.t]` на /any number of|each model|all models|every model/i.
  ВАЖНО: `src/data/roster/index.js` использует `import.meta.glob` и под голым node не грузится —
  импортировать файлы фракций напрямую.

---

## Приложение: полный список FD-дрифта (52)

| фракция | детачмент | сайт | MFM/appdata |
|---|---|---|---|
| adepta-sororitas | Bringers of Flame | Purge the Foe | Priority Assets |
| adepta-sororitas | Penitent Host | Take and Hold | Purge the Foe |
| adepta-sororitas | Sanctified Orators | Purge the Foe | Disruption |
| adeptus-custodes | Might of the Moritoi | Purge the Foe | Take and Hold |
| adeptus-mechanicus | Haloscreed Battle Clade | Purge the Foe | Priority Assets |
| aeldari | Warhost | Purge the Foe | Reconnaissance |
| aeldari | Eldritch Raiders | Disruption | Purge the Foe |
| astra-militarum | Mechanised Assault | Purge the Foe | Reconnaissance |
| black-templars | Godhammer Assault Force | Disruption | Purge the Foe |
| black-templars | The Living Miracle | Purge the Foe | Disruption |
| chaos-daemons | Lords of the Warp | Purge the Foe | Take and Hold |
| chaos-knights | Infernal Lance | Purge the Foe | Priority Assets |
| chaos-knights | Lords of Dread | Priority Assets | Take and Hold |
| chaos-knights | Bastions of Tyranny | Disruption | Priority Assets |
| chaos-space-marines | Soulforged Warpack | Purge the Foe | Take and Hold |
| chaos-space-marines | Murdertalon Raiders | Purge the Foe | Reconnaissance |
| dark-angels | Interrogation Conclave | Purge the Foe | Take and Hold |
| death-guard | Contagion Engines | Purge the Foe | Reconnaissance |
| deathwatch | Black Spear Task Force | Priority Assets | Purge the Foe |
| drukhari | Covenite Coterie | Purge the Foe | Take and Hold |
| drukhari | Exhibition of Slaughter | Disruption | Reconnaissance |
| drukhari | Kabalite Agonysts | Purge the Foe | Disruption |
| emperors-children | Carnival of Excess | Priority Assets | Disruption |
| emperors-children | Coterie of the Conceited | Purge the Foe | Priority Assets |
| emperors-children | Frenzied Host | Disruption | Reconnaissance |
| emperors-children | Spectacle of Slaughter | Purge the Foe | Disruption |
| genestealer-cults | Heroes of the Uprising | Purge the Foe | Disruption |
| genestealer-cults | Xenocult Masses | Disruption | Reconnaissance |
| grey-knights | Warpbane Task Force | Purge the Foe | Take and Hold |
| grey-knights | Argent Assault | Purge the Foe | Priority Assets |
| grey-knights | Immaterial Interdiction | Priority Assets | Reconnaissance |
| imperial-agents | Imperialis Fleet | Disruption | Reconnaissance |
| imperial-agents | Ordo Hereticus, Purgation Force | Purge the Foe | Take and Hold |
| imperial-agents | Veiled Blade Elimination Force | Reconnaissance | Disruption |
| imperial-knights | Freeblade Company | Purge the Foe | Priority Assets |
| imperial-knights | Gate Warden Lance | Priority Assets | Take and Hold |
| imperial-knights | Dominus Foebreakers | Purge the Foe | Priority Assets |
| necrons | Pantheon of Woe | Purge the Foe | Disruption |
| space-marines | Ironstorm Spearhead | Purge the Foe | Take and Hold |
| space-marines | Firestorm Assault Force | Purge the Foe | Priority Assets |
| space-marines | 1st Company Task Force | Priority Assets | Purge the Foe |
| space-marines | Fulguris Task Force | Disruption | Reconnaissance |
| space-marines | Subversion Assets | Reconnaissance | Disruption |
| space-marines | Hammer of Avernii | Priority Assets | Purge the Foe |
| space-wolves | Champions of Fenris | Purge the Foe | Priority Assets |
| tau-empire | Kauyon | Priority Assets | Reconnaissance |
| tau-empire | Mont’ka | Purge the Foe | Priority Assets |
| thousand-sons | Warpforged Cabal | Disruption | Priority Assets |
| thousand-sons | Ritual of Regeneration | Purge the Foe | Take and Hold |
| thousand-sons | Sekhetar Cohort | Priority Assets | Disruption |
| world-eaters | Brazen Engines | Purge the Foe | Disruption |
| world-eaters | Butchers of Khorne | Disruption | Take and Hold |

---

## СТАТУС: сделано 2026-09-10 (вечер)

Все шесть пунктов плана выполнены. Что оказалось иначе, чем в анализе выше:

- **Дрифт dp/FD — 63 значения, а не 61.** Шесть «Faction-Pack-only» детачментов из §5 на самом
  деле есть в MFM: первый прогон сравнивал имена посимвольно, а MFM пишет их с кривым апострофом
  (`Serpent’s Brood`) и в одном случае в другом регистре (`Luminen Auto-Choir`). Через `norm()`
  сходятся все шесть, и у двух из них FD тоже разъехался. Whitelist в гейте пустой — и это
  задокументировано в скрипте, чтобы список-исключений не завёлся заново.
- **Оружейных способностей без текста семь, а не восемь.** У `C'TAN POWER` собственного текста нет
  и в appdata: тег помечает, какое оружие подчиняется правилу `Powers of the C’tan` на самом
  датащите Tesseract Vault — оно у нас есть. Остальные семь (у `CONVERSION` — три разных текста по
  дистанции, привязанных к конкретному оружию) добавлены в `wargearAbilities` тех датащитов,
  которые их печатают, EN + RU.
- **Очки от `repall` не поехали.** Ни у одной из четырёх групп нет `dr` и платных опций, так что
  смена `checkbox`+`repall` на `stepper`+`lim` очков не меняет и миграция сохранённым ростерам не
  нужна.
- **Broadside Battlesuits не чинился** — это форма «up to two of the following, but cannot take
  duplicates» на unit-wide группе (`all: 1`), отдельная задача; в классе выше её нет.

Что появилось в репозитории:

- `scripts/check-detachment-meta.mjs` (`npm run detmeta`) — гейт `factions/*.js` ↔ MFM.
- `scripts/check-weapon-abilities.mjs` (`npm run wtags`) — гейт «у тега есть где прочитать текст».
  Оба вписаны в `npm run sync` рядом с `check-rule-omissions` и оба проверены на укус.
- Ветка в `gen-roster-data.mjs`, читающая «any number of … can each have …» как выбор на модель,
  плюс гардрейл-тест по всему корпусу в `src/data/roster/index.test.js`.
- Запись 2.3.12 в `src/data/changelog.js`; уроки 56–59 в `APPDATA-SYNC-LESSONS.md`; разделы про
  два новых гейта в `CLAUDE.md` и `DATA-SYNC.md`.

**Ответ игроку (пункт 5) — НЕ ОТПРАВЛЕН.** Готовый текст — в самом низу этого файла.

---

## Поправка к §3: Lord Solar Leontus — игрок ПРАВ, вердикт выше был неверным

Правило есть и в 11 ed: датащитное `SUPREME COMMANDER` — «If this model is in your army, it must be
your Warlord». В `wh40k-appdata/tables/datasheet_rule.json` оно у **17 датащитов**, включая Lord
Solar Leontus (плюс Ghazghkull, Guilliman, Angron, Mortarion, Magnus, Fulgrim, Abaddon, Be'lakor,
Lion El'Jonson, Cawl, Thulia Ghuld, Morvenn Vahl, Trajann Valoris, Shadowsun, The Silent King,
Patriarch). Первый разбор искал строку только в прозе `factions/*.json` и не заглянул в
`datasheet_rule.json` — отсюда ложное «в 11 ed такого нет».

Что при этом в приложении работает как надо:

- `flags.supreme` стоит у всех 17 юнитов в roster-данных, `rosterValidation` даёт ошибку
  `supremeCommanderNotWarlord` («Lord Solar Leontus должен быть вашим Warlord»), если варлорд не он.
  Автоматически варлордом он не назначается — только ошибка в панели проверки.
- Текст правила печатается на всех 17 датащитах: у 13 в `rules`, у четырёх примархов
  (Mortarion, Angron, Magnus, Fulgrim) — в `specialAbilities`.

Что реально нашлось при перепроверке и починено:

- `Canis Rex` и `Sir Hekhtur` не несли правило **«Using Sir Hekhtur»** вовсе — добавлено, EN + RU.
- Новый гейт `npm run dsrules` (`scripts/check-datasheet-rules.mjs`): каждое именованное правило из
  appdata `rules[]` обязано лежать где-то на нашем датащите. В ALLOW одна запись — Designer's Note у
  Drop Pod (текст про «выделенные красным части модели», а мы арт датащитов не печатаем).
- Гардрейл-тест в `src/data/datasheets/index.test.js`: у каждого юнита с `flags.supreme` правило
  печатается и переводится.

Ловушка, в которую я попал по дороге (записана уроком 60): проверка «есть ли правило» только по
полю `rules` объявила четырёх примархов дырами, и первая правка продублировала им плату. Читать
надо `rules` + `specialAbilities` + `abilities` + `wargearAbilities` + структурные `transport`/`leader`.

---

## ЗАДЕПЛОЕНО: v2.3.12, 2026-09-10

Коммиты `93ae760d` (dp/FD), `4b859873` (тексты способностей + «Using Sir Hekhtur» + гейты),
`66e3ed2f` (ростер), `285ec763` (чейнджлог/доки/«сцион») + `chore: release v2.3.12` `d30e19d2`,
запушены в `main`. Прод отдаёт 2.3.12, CDN очищен, запись в чейнджлоге живая.

Три новых гейта в `npm run sync`: `npm run detmeta`, `npm run wtags`, `npm run dsrules` —
каждый проверен на укус (баг возвращали руками и смотрели на ненулевой выход).

### Открытые хвосты

- **Broadside Battlesuits** — форма «can each be equipped with up to two of the following, but
  cannot take duplicates» на unit-wide группе (`all: 1`, `lim` нет). В класс §7 не входит, в
  редакторе по-прежнему радио. Отдельная задача.
- **Автоварлорд** — юнит с `flags.supreme` не назначается варлордом сам, только ошибка
  `supremeCommanderNotWarlord` в панели проверки. Удобство, не правило; игроку это предложено.
- **Drop Pod «Designer's Note»** — единственная запись ALLOW в `check-datasheet-rules.mjs`:
  текст про «выделенные красным части модели», а арт датащитов сайт не печатает. Если когда-нибудь
  начнём печатать — запись удалить.

### Текст ответа игроку (RU, отправить с почты проекта)

> Спасибо — три из четырёх замечаний оказались нашими багами, и все три уже в проде (v2.3.12).
>
> 1. Combined Arms действительно 2 DP, на странице фракции стояло 3. Пошёл проверять весь список —
>    таких расхождений с Munitorum Field Manual нашлось 63 в 24 фракциях (9 по DP и 54 по Force
>    Disposition). Конструктор списков всё это время считал правильно, врала страница правил.
>    Всё исправлено, и теперь перед каждым релизом эти числа сверяются автоматически.
> 2. Plasma Warhead: текста у этой способности не было нигде — она не базовая, а принадлежит
>    конкретной ракете, и такие у нас просто не отображались. Теперь текст виден в блоке
>    «Способности снаряжения» на датащите Deathstrike; заодно закрыл ещё шесть таких же немых
>    тегов (CONVERSION, LINKED FIRE, OVERCHARGE, HARPOONED, PSYCHIC ASSASSIN, REVERBERATING
>    SUMMONS).
> 3. Militarum Tempestus Command Squad: спецоружие можно было взять только одно на весь отряд —
>    теперь по одному на каждого Сциона, с запретом брать одно и то же дважды, как и написано на
>    датащите. Та же беда была у Catachan Command Squad и у Carnifexes.
> 4. Про Lord Solar Leontus вы правы, и я сначала ответил неверно: правило есть — Supreme
>    Commander, «если эта модель в вашей армии, она должна быть вашим Warlord». Оно напечатано на
>    его датащите, и конструктор списков не считает список законным, если варлорд не он. Чего он
>    не делает — не ставит галочку «Warlord» за вас автоматически, только показывает ошибку в
>    проверке списка. Если удобнее, чтобы ставил сам, — скажите, сделаю.
>
> Заодно ваш четвёртый вопрос вытащил ещё одну дыру: у Canis Rex и Sir Hekhtur не было напечатано
> правило «Using Sir Hekhtur» — теперь есть. Спасибо, пишите ещё.

