> **Статус:** активен
> **Репозитории:** wh11ed
> **Начато:** 2026-09-21
> **Связано:** [хвосты после разбора жалоб](../paused/2026-09-13-player-report-tails.md)

# Жалоба: «у Masters of the Maelstrom Гурон — единственный лидер»

Отчёт `caf57233` (2026-09-21, v2.6.4, ru, `/roster/…/view`, PWA на Android). Разбор по скилу
`feedback-triage`.

## Вердикт — наш баг

Сноска `leader.footer` у Masters of the Maelstrom («только HURON BLACKHEART может присоединиться к
юниту, к которому присоединился этот юнит») — текст **10-й редакции**: до июля жила в
`specialAbilities`, при реконсиляции 2026-07-27 переехала в `leader.footer` «по прецеденту Wardens
of Ultramar» — который был такой же устаревшей сноской. В appdata 946 у карточки правило `Support`
без сноски; в CSM Faction Pack v1.2 (26.08.2026) на карточке `CORE: Support`, раздел «Masters of the
Maelstrom» удалён. Core-правило Support само даёт бодигарду одного Leader и одного Support.

Новый гейт (наличие сноски против текста правила appdata) нашёл ещё три того же класса — все
убраны (EN+RU):
- Wardens of Ultramar — «только CAPTAIN TITUS»;
- Captain (SM) — «нельзя к Bladeguard без relic shield / к Hellblaster без plasma pistol»
  (решение владельца: убрать; конструктор это и так не проверял);
- Cybernetica Datasmith — «обязан присоединиться к Kastelan Robots» (противоречит новой
  Data-severed: в паке AdMech явно описано состояние без роботов).

**Урок 62** (`APPDATA-SYNC-LESSONS.md`): все четыре сидели в `sync-baseline.json` как принятый
шум «leader: text differs» с июля — гейт видел, ему велели молчать.

## Отдельное решение: Huron ведёт Masters

В паке CSM v1.2 у Huron в списке Leader есть сам Masters of the Maelstrom; в appdata 946 (группы и
проза) — нет. Решение владельца 2026-09-21: **это баг appdata, делаем исключение по PDF, правило не
заводим, пометить для сверки при апдейте.** Сделано:
- `PACK_ATTACH` в `wh11ed/scripts/gen-roster-data.mjs` (→ `leads` Хурона в roster-данных),
- `PACK_EXTRA` в `wh11ed/scripts/sync-leader-units.mjs` (датащит Хурона: `leader.units` + MotM),
- baseline: строка `extra in wh11ed … Huron Blackheart · bodyguard unit "Masters of the Maelstrom"`,
- оба списка **самоотзывающиеся**: печатают «appdata now has it — drop», как только appdata
  догонит; напоминание в скиле `appdata-update` §3, описание в `roster/CLAUDE.md` рядом с
  `PROSE_ATTACH`.
Проверено движком: Huron → Masters (leader), Masters → Chosen (support), Chaos Lord → те же Chosen
рядом с ними.

## Состояние на конец сессии 2026-09-21

- wh11ed коммит `a1d1840` в `main` — **не запушен, не задеплоен**; прод на v2.6.4.
- `wh11ed/src/data/changelog.js` — запись 2.6.5 (два пункта: датащиты + конструктор) **написана,
  но не закоммичена**: ждёт «ок» владельца по RU-тексту (правило скила `changelog-entry`).
- Гейты чисто: sync (baseline перезаписан: −4 устаревшие, +1 Huron), parity, dsrules, coregrants,
  roster:data:check, modifiers:check, translate:check; 1916 тестов, lint, build.
- В `npm run sync` без baseline печатаются 6 строк по главе Doubles Event Companion («1. Muster
  Armies», «Transports 18.00»…) — **не моё, в baseline не тащил**; глава писалась как дельта
  (см. память `project_doubles_chapter`), скорее всего это ожидаемо — решить отдельно.

## Следующий шаг

1. Показать владельцу RU-текст записи 2.6.5 (`node -e "import('./src/data/changelog.js').then(m=>console.log(m.changelog[0].ru.join('\n')))"`), после «ок» — закоммитить.
2. Релиз по скилу `release-frontend` (деплой сам бампит и пушит).
3. `npm run feedback:delete -- caf57233` (env из скила `feedback-triage`).
4. Закрыть журнал → `archive/2026/`.
