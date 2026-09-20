> **Статус:** приостановлен
> **Репозитории:** wh11ed
> **Начато:** 2026-09-20
> **Ждём:** решения владельца — делать ли Dominatus на сайте и по какому источнику (единственный
> полный — фанатская расшифровка, канона для сверки нет).

# Колода Dominatus — что это и где её текст

Вопрос владельца 2026-09-20: «существует некая колода Доминус для нарративных игр, найди полную
информацию». Раньше решение было «Dominatus не делаем — GW содержимого колоды не публикует»
(память `project_event_companion_gates`). Разобрались подробнее.

## Что это

«Dominatus – Narrative Campaign Deck» (Armageddon). Карточная нарративная кампания 11-й
редакции на выходные: 2–3 альянса (Liberators / Oppressors / опционально Raiders), 5 партий в
трёх фазах (2 + 2 + 1 решающая), 2000 очков. В стартовом боксе *Armageddon*; отдельно с
2026-06-27, ~$35. 89 карт: 27 Agenda, 9 Agenda Achieved, 9 Briefing, 9 Location, 35 Upgrade
(11 Battle Honour, 10 Battle Skill, 15 Relic — по 5 на альянс) + буклет 12 стр. Нужны ещё Core
Rules и колода Chapter Approved (миссии, вторички, Force Disposition берутся оттуда).

Механика фазы: Location (бросок или выбор Warmaster'а) даёт war zone rules на все бои фазы и
бонус удержавшему альянсу; Briefing (одна на фазу на альянс) — матрица «моя диспозиция ×
диспозиция противника → Agenda»; Agenda заменяет Primary Mission, выполнена → Agenda Achieved;
конец фазы: Take Control → Ascendancy → Acquire Relics → Narrative Outcome → Discard. Победитель
боя тянет Battle Honour, проигравший — Battle Skill; до 3 апгрейдов на армию, по одному на юнит.

## Где текст

- **appdata:** колоды НЕТ. Есть только «Dominatus Event Companion» (rule_section
  `2019276a-994c-4be9-8ed0-3a0f43b7304e`, два контейнера — Event Guidance и Event Mission
  Sequence) — тот же текст, что PDF в `sources/eng_22-07_…dominatus_event_companion….pdf`
  (v1.1; лежит и 12-06, разница — абзац Generating Command Points).
- **GW / обзоры** (Warhammer Community, Spikey Bits, Sprues & Brews, BoLS, Frontline): только
  состав и общая механика, текстов карт нет. warhammer.com и Chaos Cards отдают 403.
- **Wahapedia** — полная расшифровка колоды, ~18 500 слов:
  https://wahapedia.ru/wh40k11ed/the-rules/dominatus/ — правила кампании, 9 Location с
  бонусами и war zone rules, Briefing с матрицами и Outcome по Narrative Points, 27 Agenda
  (условия + своя Primary Mission с VP-триггерами), все Upgrade и Relic (WHO / EFFECT).
  Единственный полный источник, и он фанатский: если делать по нему — сверять не с чем, кроме
  физической колоды. Скана GW в открытом доступе нет, пиратские сливы не ищем.

## Если решим делать

Объём сопоставим с Event Companion (~18k слов EN + перевод). Естественное место — глава рядом
с Event Companion / Doubles (см. `journal/archive/2026/2026-09-16-doubles-chapter.md` как
образец «дельта вместо пересказа»). Прежде чем начинать: решить про источник и про то, нужен
ли трекеру Dominatus-режим (Agenda вместо primary, апгрейды на юнитах) или достаточно справочника.
