> **Статус:** активен
> **Репозитории:** wh11ed, хаб (скил)
> **Начато:** 2026-09-18
> **Связано:** [проза Legends](2026-09-18-legends-prose.md) — обещание «Legends для остальных фракций» в changelog 2.5.0

# Legends из Faction Pack'ов: пилот Dark Angels и скил

## Откуда

Владелец принёс PDF Faction Pack'а Dark Angels и спросил, можно ли на его примере сделать скил
или инструкцию «как вытащить Legends из пака». Проверка показала, почему это вообще нужно:
**appdata несёт Legends только у орков** (одна публикация `isLegends`); у остальных фракций
датащиты Legends напечатаны только в PDF пака. То есть это не «дособрать прозу», а завести
датащиты из второго источника.

## Что решили

- **Очки — из веб-MFM, там Legends есть.** Первый ответ («в веб-MFM Legends нет») был ошибкой:
  они спрятаны за тумблером «Show Legends» — server action ставит cookie `isLegendsDisplayed=true`,
  страница отдаёт дополнительную секцию `LEGENDS` (у её ценников другой набор CSS-классов, чем у
  кодексных, — скрейпер матчит подпись, а не классы). `scrape-mfm.py` шлёт cookie и пишет
  `legends: [...]`; `sync-mfm-points` ценит `legends: true` листы и печатает список Legends-юнитов
  MFM без датащита у нас — **311 на 19 фракций**, это и есть объём работы по пакам. Заодно всплыл
  настоящий дрифт: у Lootas орков в MFM есть tier 3rd+.
- **EN сразу, RU отдельным проходом** (решение владельца). Тест покрытия RU
  (`datasheets/index.test.js`) ждёт pack-листы без записи в оверлее и печатает их число; запись
  в оверлее переводит лист под полный гейт.
- **Только пилот DA + скил** в этом заходе; остальные фракции — отдельными заходами по слову.
- **Маркер `source: "faction-pack"` + `sourceVersion`** на каждой записи: `sync-appdata` не
  считает её «extra in wh11ed» и напечатает `⟲ … is now in appdata — retire the faction-pack copy`,
  когда appdata догонит. Appdata — источник правды, пак — подмена.
- **В конструктор ростеров pack-листы не попадают**: `gen-roster-data` строит юниты из таблиц
  appdata (состав миниатюр, структура вооружения), у записи из PDF их нет. Осознанное
  ограничение; чтобы снять, нужен ручной авторинг структуры ростера — отдельная задача, если
  спросят.
- **Полуавтомат, не парсер.** `pdftotext -layout` держит таблицы, но рвёт абзацы абилок между
  колонками; обычный режим — наоборот. Записи авторятся руками по двум текстам, проверяет
  `scripts/add-datasheets.mjs` (поля, оружие, id, маркер, коллизии с shared SM-листами у
  Chapter-файлов), дальше `sync:mfm --write`, индексы, гейты.

## Сделано (wh11ed `53fdeff`, `c81f9ee`)

Dark Angels: Ravenwing Talonmaster (105), Deathwing Strikemaster (80), Deathwing Command Squad
(200/400) — на странице юнитов с бейджем Legends, в поиске, в индексе фаз. Скил
`.claude/skills/legends-from-pack/SKILL.md` в хабе; строка в таблице скилов CLAUDE.md; параграф в
`wh11ed/src/data/CLAUDE.md`; changelog 2.5.1 дополнен. Гейты, тесты (1858), сборка — зелёные.

## Вторая фракция: Drukhari (`549b422`)

Все семь листов пака v1.2 (Beastmaster, Court of the Archon, Grotesques, Raven Strike Fighter,
Reaper, Tantalus, Urien Rakarth), EN и RU сразу. Скил отработал без правок скриптов; новое, что
встретилось и что скил покрывает формой записи: несколько профилей с keywords по моделям
(`keywordsByModel`, имена профилей капсом), `damaged`, `transport`, рамочные `rules` (COURT OF THE
ARCHON, MONSTROUS HULKS), лист без лора (Reaper, Raven Strike Fighter — в паке его нет). Опечатку
GW «Electromagentic Cascade» оставили как в источнике. Владелец докачал паки: локально теперь
Aeldari, Necrons, T’au, Tyranids, GSC, Votann, Drukhari — плюс прежние.

## Все ксеносы (`8fc8fdc`, `2156ff5`)

По просьбе владельца — GSC (1), Tyranids (5), Necrons (12), T’au (20), Aeldari (23), всё EN+RU.
Что скил узнал по дороге и что записано в него/скрипты:

- **Порядок ключей важен:** `points` раньше `id` → `sync-mfm-points` ценит соседний лист
  (сканирует вперёд от строки `"id"`). `add-datasheets.mjs` теперь отказывает такой записи.
- Семь файлов датащитов — не строгий JSON (висячая запятая в `leader`); скрипт вставки читает
  массив как JavaScript и пишет обратно JSON — нормализация в несколько строк.
- `faction` не обязателен: у Fortification нет строки FACTION.
- MFM зовёт «Sentry Pylons», пак — SENTRY PYLON: таблица `LEGENDS_MFM_NAMES` в `sync-mfm-points`.
- Tactical Drones т’ау в MFM нет вовсе → `points: []`, без цены.
- «Armoury card» (Aeldari) и «Drones page» (T’au) — оружие/дроны вкладываются в листы, которые на
  них ссылаются, как делают кодексные листы; сноски «см. страницу…» опускаются.
- RU: у Necrons оверлей в форме `{ name, text }`, у остальных — строка + `abilityNamesRu`; при
  добавлении заголовков смотреть, нет ли уже такого ключа (Armour Hunter, Scattershield и т.п. —
  eslint `no-dupe-keys` ловит).

На тот момент в списке MFM оставалось 244 Legends-юнита без датащита — Империум и Хаос;
см. заход 3 ниже.

## Заход 3 — Империум без орденов (2026-09-18)

Sororitas (5), AdMech (4), Imperial Agents (17), Astra Militarum (63) — EN+RU за один заход, все
паки были локально. Что добавилось к знанию:

- AM и Agents — самые «структурные» листы: `transport`, `damaged`, `keywordsByModel`, `rules`
  (ORDERS, ATTACHED UNIT, ARTILLERY TEAM с примечанием разработчика). RU-оверлей кладёт ORDERS в
  `rules`, как и EN-запись из пака (старые листы AM держат его в `special` — это их дело).
- `keywordsByModel` не локализуется — подписи моделей английские, как имена.
- Повторяющиеся тексты (Aerial Deployment, транспорт Chimera-класса, Pinning/Suppression
  Bombardment, «Примечание разработчика» про жетоны Crew) собирались хелперами в скрипте
  генерации оверлея, а не копипастой — иначе 63 листа не вычитать.
- Комментарий в RU-файле про версию пака брать из `sourceVersion` EN-записи, не по памяти
  (AM — v1.2, а не 1.3).

В списке MFM осталось **155**: SM 76 (Armoury card), CSM 31, Space Wolves 18, Blood Angels 10,
Daemons 10, GK 5, DG 5. Пак GK локально не лежит.

## Хвосты

- ~~RU-проход по трём листам DA~~ — сделан тем же днём (`449ff08`): оверлей в `ru/dark-angels.js`,
  4 заголовка в `abilityNamesRu`; тест покрытия держит листы под полным гейтом.
- Space Marines: часть профилей оружия вынесена на «Adeptus Astartes Legends Armoury card» —
  перед SM найти этот документ.
- Локально есть паки SM (76), CSM (31), Agents (17), Aeldari (23), T’au (19), Necrons (12),
  Tyranids (5), GSC (1); Votann в MFM Legends нет. Остальные — качать.
- `gen-roster-data` жалуется «no MFM entry» на `Blitza‑bommer`/`Burna‑bommer` — в MFM имя с
  обычным дефисом, у нас с неразрывным; не этого захода, но `norm()` стоит научить.

## Заход 4 — Chaos Daemons и Death Guard (2026-09-18)

Daemons 10 (пак v1.1) + DG 5 (пак v1.2), EN+RU одним проходом, коммит wh11ed `9898af6`. Что
отличалось от Империума:

- **В этих паках у Legends нет лора** — `flavor` не заводится, тест покрытия RU это терпит.
- Общие правила Daemons: DAEMONIC ALLEGIANCE → `rules`, «Creature of <god>» → `specialAbilities`
  (тот же раскрой, что у Daemon Prince of Chaos в appdata); GRANDFATHER’S BLESSING → `rules`.
  В RU — константы в шапке файла, а не копипаста по листам.
- В PDF DG опечатка «twin lighting claws» — в данных исправлено на lightning.
- `add-datasheets` для chaos-daemons написал «appended», а не «kept sorted» — файл и раньше не
  был отсортирован по id, это не регресс.

В списке MFM осталось **140**: SM 76 (Armoury card), CSM 31, Space Wolves 18, Blood Angels 10,
GK 5 (пак качать).

## Заход 5 — Chaos Space Marines, все 31 (2026-09-18, wh11ed `1442b4a`)

Хаос закрыт целиком: 14 фракций / 202 листа EN+RU. Страницы пака 40–101 плюс страница 102
«Renegades and Traitors».

- **«Renegades and Traitors»** — не датащит, а таблица, какие листы Legends могут брать Death
  Guard / Thousand Sons / World Eaters (Thunderhawk — все трое; Greater Blight Drone — DG;
  Blood Slaughterer, Greater Brass Scorpion, Kytan Ravager — WE). Положено правилом
  `RENEGADES AND TRAITORS` на эти пять листов, текст по фракции; общее правило отдельной
  страницей заводить не стали — читатель ищет от листа.
- **Lord of Chaos** в паке напечатан в старой редакции («за 0 CP, даже если…»), не как в
  кодексе. Оставлен как в паке — это источник этих листов; в RU отдельная константа
  `LORD_OF_CHAOS_LEGENDS`, чтобы не путать с кодексной.
- **Опечатки PDF, решённые по смыслу:** у Kharybdis core «Deadly Strike» → Deep Strike (своя
  же способность сажает её в Резерв); krak у Renegade Heavy Weapons Squad AP «2» → -2;
  «Missile launcher – krak [ HEAVY]» → `HEAVY`. У Decimator loadout называет «armoured feet»,
  профиля в таблице нет — оставлено как напечатано. У Renegade Ogryn Beast Handler MFM даёт
  два порога (4 и 7 моделей), в паке состав только 1+3 — состав по паку, очки по MFM.
- Лор в паке есть только у последних десяти листов (Exalted Champion → Thunderhawk); у
  Cultist Mob with Firearms он дословно совпадает с Cultist Mob — RU взят оттуда.
- `ONE SHOT` на hunter-killer — базовая оружейная способность, `wtags` текста не требует;
  `Conversion` и `Impaled` — `wargearAbilities` на листе.
- Гейты, 1859 тестов, build — зелёные; `npm run sync` листы пака не трогает.

## Где остановились (2026-09-18, конец дня)

Всё сделанное закоммичено (wh11ed `1442b4a`), **не запушено и не в проде** — прод на v2.5.0,
всё это едет в 2.5.1 вместе с прозой Legends и ролями в партии (api первым). Хаос собран
целиком; в MFM осталось 109 — только ордена космодесанта и Grey Knights. Следующий заход,
если пользователь попросит: SM-ордена (SW 18, BA 10, SM 76 — сначала найти «Legends Armoury
card»), GK 5 (пак качать). Скриптовые хелперы RU-оверлея живут в scratchpad и сессию не
переживут — пересобирать: `apply(path, block, names, comment)` вставляет блок перед
`export const abilityNamesRu` (маркер терпит `//`-строки перед экспортом) и дописывает новые
заголовки, пропуская уже существующие ключи; константы-хелперы (опции, транспорты) идут
отдельной вставкой перед `export default {`.
