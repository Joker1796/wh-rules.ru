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

## Хвосты

- ~~RU-проход по трём листам DA~~ — сделан тем же днём (`449ff08`): оверлей в `ru/dark-angels.js`,
  4 заголовка в `abilityNamesRu`; тест покрытия держит листы под полным гейтом.
- Space Marines: часть профилей оружия вынесена на «Adeptus Astartes Legends Armoury card» —
  перед SM найти этот документ.
- Локально есть паки SM (76), CSM (31), Agents (17), Aeldari (23), T’au (19), Necrons (12),
  Tyranids (5), GSC (1); Votann в MFM Legends нет. Остальные — качать.
- `gen-roster-data` жалуется «no MFM entry» на `Blitza‑bommer`/`Burna‑bommer` — в MFM имя с
  обычным дефисом, у нас с неразрывным; не этого захода, но `norm()` стоит научить.
