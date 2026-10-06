> **Статус:** закрыт
> **Итог:** в проде с v2.6.5 (2026-09-21): четыре сноски 10-й редакции убраны, Huron ведёт Masters по PDF (самоотзывающиеся PACK_ATTACH/PACK_EXTRA), отчёт caf57233 удалён из очереди.
> **Репозитории:** wh11ed
> **Начато:** 2026-09-21
> **Связано:** [хвосты после разбора жалоб](2026-09-13-player-report-tails.md)

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

## Состояние на конец сессии 2026-09-21 (вторая сессия)

- wh11ed коммиты `a1d1840` (эта задача) и `894d067` (автообновление PWA + чейнджлог 2.6.5) в
  `main` — **не запушены, не задеплоены**; прод на v2.6.4.
- Запись 2.6.5 владелец сжал сам (три пункта: датащиты, конструктор, обновление PWA; без
  «спасибо игроку») — закоммичена в `894d067`.
- Гейты чисто (см. первую сессию); 6 строк по главе Doubles в `npm run sync` без baseline —
  не моё, решить отдельно.

## Закрыто 2026-09-21 (третья сессия)

Релиз v2.6.5 (`chore: release v2.6.5` = wh11ed `a133ed0`), смоук живого домена пройден, отчёт
`caf57233` удалён. Строки «text differs» по главе Doubles в `npm run sync` — отдельный хвост:
[Doubles в sync](../paused/2026-09-21-doubles-sync-text-differs.md).
