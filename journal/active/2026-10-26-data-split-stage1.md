# Этап 1: ядро отдельно от данных

> **Статус:** активен — план, ждём «поехали» владельца
> **Репозитории:** wh11ed
> **Начато:** 2026-10-26
> **Связано:** [Отделимое ядро и данные бандлами](2026-10-19-core-split.md) — его первый этап

## Постановка (владелец, 2026-10-26, второе уточнение)

Сейчас — **только** отделение ядра (логики) от данных. Главное — ничего не сломать. Ошибки, найденные
по пути, правим сразу. Архитектура максимально чистая: без дублирования, по лучшим практикам; можно
подключать инструменты и навыки, сделанные для таких задач. Архивная версия правил, бандлы, вынос
в отдельный репозиторий — **не в этом этапе** (первый вариант плана этого журнала, 26.10, — в git-истории
файла).

## Замер (2026-10-26)

- `src/composables`: 161 модуль. **63 — чистая логика** (нет Vue, DOM, браузерного хранилища); из них
  44 данных не трогают, **19 импортируют данные напрямую**: `rosterEngine` (3272 строки:
  `conditionalKeywords.json`, `slugify`), `rosterImport` (1865), `rosterStatMods` (1613: `rosterModifiers`,
  `data.types`), `rosterModifiers` (801: `roster/items`, `rosterModifiers/conditions`, `enhancementWeapons`),
  `rosterExport`, `ruleTargets`, `gameStratagems`, `rosterFactionRules`, `stratagemPlay`, `trackerFactions`,
  `seoMetaData`, `sideColors`, `broadcastPayload`, `gameSlices`, `battleLimitFacts`, `ownLimits`,
  `rosterHandoff`, `rosterSummary`, `wargearInfo`.
- Смешанные (логика внутри Vue-композаблов): `useTracker.js`, `rosterUnitCard.js`, `useRosterDerived.js` и др.
- В `src/data` лежит и код: `deepOverlay.js`, `slugify.js`, `extractSubheadings.js`, `data.types.js`, загрузчики
  `*/index.js`.
- Данные статически импортируют 132 файла приложения; 87 скриптов читают `src/data` по пути — **пути
  данных не меняем**.

## Целевая архитектура

Три слоя, зависимости только сверху вниз:

```
app (Vue: views, components, use*-композаблы)  ──►  core  ◄──  data-адаптер (src/data/*/index.js)
                                               └──────────────►  data (только данные)
```

- **`src/core/`** — чистые функции правил: конструктор, валидация, очки, модификаторы, условия,
  импорт/экспорт, логика партии и подсчёта. **Не импортирует** Vue, браузер, `src/data`, `src/composables`,
  `src/components`. Данные получает **аргументами** (уже так у части функций: `def`, `items`, `records`).
  Типы — JSDoc + `@ts-check`, весь `src/core` в `tsconfig` (strict-null уже включён).
- **Данные** (`src/data`) — только данные и их загрузчики. Код из `src/data` (`deepOverlay`, `slugify`,
  `extractSubheadings`) переезжает в `core`/`utils`.
- **Приложение** — связывает: загружает данные и передаёт в ядро. Единственное место, где встречаются
  ядро и данные.
- Где ядру нужен «справочник», а не один объект (словарь условий, `conditionalKeywords`, словарь
  ключевых слов), — **явный параметр-контекст** (`rules`), а не скрытый импорт. Решение по каждому
  случаю — на шаге 3, без новых абстракций сверх нужного (не делаем DI-контейнер).

**Правила чистоты:** ни одного реэкспорта-заглушки «для совместимости» в конце этапа; ни одной копии
функции; перенос = `git mv` + правка импортов (история файла сохраняется).

## Сетка безопасности — до первого переноса

1. **Существующее:** 2327 тестов, `typecheck`, `lint`, все data-гейты, `smoke`, `perf`, `check-chunk-graph`.
2. **Эталонные снимки поведения (golden master).** Новый тест-набор, который прогоняет реальные
   данные через ядро и сохраняет результат в JSON:
   - 9 тестовых ростеров (`scripts/lib/test-rosters.mjs`) + корпус listhammer (148 списков): очки,
     ошибки и предупреждения валидации, текст экспорта во всех форматах, импорт обратно;
   - карточка каждого юнита каждой фракции после модификаторов (статлайн, оружие, теги, заметки) —
     в ростерах и голым листом;
   - логика партии: подсчёт очков, слайсы, стратагемы по фазам на сохранённых партиях-образцах.
   Любой перенос обязан оставить снимки **побайтно** такими же. Изменился снимок — это либо найденная
   ошибка (правим отдельным коммитом, снимок обновляем осознанно), либо регресс (откат).
3. **Карта зависимостей** до и после: какой модуль что импортирует, цикл зависимостей — ошибка.

## Шаги

0. **Карта.** Граф импортов `src/` (навык `code-modernization:modernize-map` или свой скрипт на
   `node:`-парсинге импортов — решим по объёму вывода). Разметка модулей: ядро / приложение / данные /
   смешанное. Циклы. Результат — список в этом журнале.
1. **Эталонные снимки** (п. 2 сетки). Агент `code-modernization:test-engineer` подходит ровно для
   этого (characterization tests); работу проверяю сам. Снимки коммитим до первого переноса.
2. **Граница и гейт — пустые.** Папка `src/core/`, правило eslint `no-restricted-imports` (уже есть
   eslint, новых зависимостей не нужно) + тест на граф импортов: ядро не тянет Vue/DOM/данные/приложение.
   Альтернатива — `dependency-cruiser` (стандарт для архитектурных правил, devDependency) — на решение.
3. **Перенос листьев.** 44 чистых модуля без данных — в `core` по графу, от листьев к корню; каждый
   коммит: `git mv`, импорты, все тесты + снимки зелёные.
4. **Развязка 19 модулей с данными.** По одному: скрытый импорт данных → параметр/контекст; вызывающий
   код в приложении передаёт данные. Начать с маленьких (`ownLimits`, `wargearInfo`, `rosterSummary`),
   закончить `rosterEngine`/`rosterStatMods`/`rosterModifiers`.
5. **Код из `src/data`** — в `core`/`utils`; в `src/data` остаются данные и загрузчики.
6. **Смешанные композаблы.** Логику из `useTracker`, `rosterUnitCard`, `useRosterDerived` и др. —
   в чистые функции ядра; композабл остаётся тонкой Vue-обёрткой. Самый рискованный шаг: только
   под снимками и тестами трекера.
7. **Типы.** Весь `src/core` под `@ts-check` в `tsconfig`; гейт «без кастов» уже действует.
8. **Ревью.** Независимая критика архитектуры агентом `code-modernization:architecture-critic` (даю ему
   код, не свои выводы), затем `/code-review` и `/simplify` по всему диффу этапа.
9. **Документация.** `src/core/CLAUDE.md` (границы, правила, как добавлять), правки в `wh11ed/CLAUDE.md`,
   `src/data/CLAUDE.md`, `roster/CLAUDE.md`.
10. **Выкат.** Игрок не видит изменений → полный прогон, бета, проверка владельцем, сайт.

Каждый шаг — отдельная ветка/коммиты, вливаемые в релиз по готовности; шаги 3–6 можно выкатывать
частями, раз видимых изменений нет.

## Шаг 0 — карта (2026-10-26, ветка wh11ed `refactor/core-split` от `release/2.10.6`)

Граф импортов `src/` (847 модулей, разовый скрипт, комментарии не считаются):
- Логика (`composables` + `utils`, `.js`): 181 модуль. **Готовы в ядро — 61**: 46 без данных, 15 тянут данные
  напрямую (`rosterEngine`, `rosterImport`, `rosterExport`, `rosterModifiers`, `ruleTargets`, `rosterFactionRules`,
  `trackerFactions`, `seoMetaData`, `sideColors`, `gameSlices`, `battleLimitFacts`, `ownLimits`, `wargearInfo` и др.).
  Среди готовых: `rosterValidation`, `rosterStatMods`, `rosterGameContext`, `gameScoring`, `doctrineRules`,
  `abilityStatus`, `actionLog`.
- Не готовы только из-за зависимостей (сами чистые): `gameStratagems`, `stratagemPlay`, `rosterGameLink`,
  `rosterHandoff`, `rosterShare` (тянут `useRosters`/`useTracker`/`useBilingualMerge`), `gameStats`,
  `markReconcile` (через хранилища), `rosterSummary` (`buildInfo`).
- Смешанные: `useTracker` (2013 строк), `rosterUnitCard`, `useRosterDerived`, `useBilingualMerge`, `trackerLayout`.
- **Обратные зависимости данные → логика:** `data/combatPatrolMissions.js` → `composables/combatPatrolBox.js`;
  `data/{roster,rosterModifiers}/*`, `data/data.types.js` → `composables/roster.types.js` (типы);
  `data/armyTrackers`, `data/rosterModifiers/appliesWhile.js` → `utils/foldName.js`.
- Вне `composables`/`utils` логики мало: `components/tracker/partySeats.js`, `helpText.js`, `roster/typeableCount.js`.

## Шаг 1 — эталонные снимки (2026-10-26)

`npm run golden` (wh11ed `3ba20b01`, `d26d39a3`): 30 фракций × каждый детачмент — ростер из всех юнитов
с присоединёнными лидерами; очки, валидация, экспорт в 6 форматах, обратный импорт GW/WTC, карточка каждого
юнита через `useRosterUnitCard`. Детерминированность проверена (два прогона побайтно равны). Снимки — **не в
git** (77 МБ, решение владельца): эталон снят с кода `326e460f` (верх `release/2.10.6`), пересоздаётся
`git switch --detach 326e460f && npm run golden:baseline`. ~8 мин в один поток.
По пути: в стенде была гонка (первая карточка фракции снималась до загрузки) — ждём флаги готовности карточки.

## Целевая раскладка ядра (черновик к шагу 3)

«Чистый» ≠ «ядро»: из 61 чистого модуля часть — помощники интерфейса. В ядро идёт только предметная логика.

- `core/roster/` — `rosterEngine`, `rosterValidation`, `rosterEnhEligible`, `rosterLimit`, `battleLimitFacts`,
  `ownLimits`, `rosterExport`, `rosterImport`, `rosterHold`, `rosterCompanionRows`, `combatPatrolRoster`,
  `combatPatrolBox`, `wargearInfo`, `weaponGroups`.
- `core/rules/` (модификаторы и чтение правил) — `rosterModifiers`, `rosterStatMods`, `ruleTargets`,
  `doctrineRules`, `abilityStatus`, `abilityDominance`, `rosterGameContext`, `stratagemPhases`, `variantPassage`,
  `weaponTag`, `weaponTagQualifier`.
- `core/game/` — `gameScoring`, `missionTiming`, `cpLedger`, `actionLog`, `gameLog`, `unitStatus`, `strictRules`,
  `trackerGen`.
- `core/shared/` — `foldName`, `roster.types.js` (типы).
- **Остаются в приложении** (представление): `datasheetParts`, `rosterModNotes`, `columnChunks`, `blockColumnChunks`,
  `anchors`, `segSlider`, `usePageMotion`, `revealAxis`, `rosterNameFit`, `sanitizeHtml`, `plural`, `tone`, `wordDiff`,
  `copyTier`, `baseSize`, `datasheetGroups`, `keywordUnits`, `legendaryProxies`, `factionKeywordMarkup`, `unitLinkMarkup`.
- **Адаптеры данных / инфраструктура приложения**: `rosterFactionRules` (загрузка прозы фракции), `trackerFactions`,
  `seoMetaData`, `sideColors`, `gameSlices` (синхронизация).
- `utils/capsKeywords` — помощник генератора (`scripts/gen-datasheet-index.mjs`), не трогаем.

## Шаги 2–4 — ход работ (2026-10-26, ветка wh11ed `refactor/core-split`)

- `c8b131c9` — пустой `src/core`, гейт границы (eslint: без Vue/данных/приложения, только встроенные глобалы JS
  + WHATWG-кодеки; `boundary.test.js` ловит и динамический `import()`), `src/core/CLAUDE.md`.
- `4d58d0b9`, `b6dba392`, `2d4c6ca1`, `d465b872` — перенос чистых модулей: `shared` (foldName, типы, slugify),
  листья `roster`/`rules`/`game`, словарь условий (`conditions.js` — код движка, лежал в `data`).
- Раскладка поправлена с владельцем: показ (`battleLimitFacts`, `ownLimits`, `wargearInfo`, `rosterHold`,
  `rosterCompanionRows`) остаётся в приложении; `weaponGroups` → `core/rules`.
- `7fb2ede0` — выдачи ключевых слов на юните: `gen-roster-data` пишет `grants` (133/133), Chapter — `sharedGrants`;
  `grantedKeywordsFor(def, detachments)`. Проверено на всех данных: 134 выдачи союзникам все привязаны к детачменту
  источника, который хозяин не выбирает; у заимствованных SM-юнитов выдач SM нет — результат не меняется.
  Превью юнита в каталоге и редакторе теперь получает `def` (вариант 1 владельца: показывает и «кого вводит в игру»).
- `38008c96` — `rosterEngine`, `rosterValidation` → `core/roster`.
- `5cc8c417`, `0efffa1e` — диспозиции → `core/roster/dispositions.js`; импорт/экспорт получают справочник фракций
  (`factionGroups`) аргументом и переехали в `core/roster`.
- Эталон: побайтно совпал после каждого шага с изменением кода (30/30).
- Уроки инструмента переноса: относительные и «от src/» пути, шаблонные `import(\`…${x}\`)` — правит сам.

## Шаг 4 закончен, шаг 5 (2026-10-26)

- `50ada4c9` — словарь ключевых слов: параметр `vocabulary` (scopesMisread, ruleAppliesTo, гейты rosterStatMods);
  загрузчик — `src/data/datasheets/index.js`; карточка и экран ростера держат его в `shallowRef`.
- `ebf069cb` — оружие улучшений на самом улучшении (`weapons`, по id appdata, 8/8); чтение — `scripts/lib/enhancement-weapons.mjs`;
  13 размещений побайтно те же.
- `adb2b328` — `stands` на юните (по id предмета); `items.js` хранит всю таблицу для приложения (`wargearInfo`);
  индекс «строка → предмет» побайтно тот же у всех юнитов. Отступ от согласованного «таблица предметов целиком» —
  проще и без 30 правок сигнатур, тот же принцип «данные на том, что описывают».
- `0b5d1f99` — `clockOf` → `src/composables/gameClock.js` (настройки трекера — приложение); `smChapters.js` → `core/shared`
  (отступ от «аргументом»: это структура фракций, совпадает с группой `astartes`, читают шесть модулей).
- `6123ef78` — `ruleTargets`, `rosterModifiers`, `rosterStatMods`, `rosterGameContext` → `core/rules`; `data.types.js` → `core/shared`.
- Ядро: 35 модулей, ~13,2 тыс. строк. Вне ядра чистыми остались только помощники показа и адаптеры (32, по раскладке).
- Эталон 30/30 после каждого шага. Инструмент переноса не видит `path.join(HERE, 'dir')` и `import.meta.glob` — правились руками.

## Ошибки, найденные по пути

Правим сразу (разрешение владельца 26.10), каждая — отдельным коммитом с тестом и строкой здесь.

## Вопросы владельцу

1. Имя папки — `src/core/`? (вынос в отдельный репозиторий — позже, имя пакета решим тогда)
2. Граница: `eslint no-restricted-imports` + свой тест (без новых зависимостей) или `dependency-cruiser`?
3. Эталонные снимки — в git (~несколько МБ JSON) или генерировать в тесте и сравнивать с хешем?
