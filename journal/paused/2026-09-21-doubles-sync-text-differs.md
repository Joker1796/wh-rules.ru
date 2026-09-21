> **Статус:** приостановлен
> **Репозитории:** wh11ed
> **Начато:** 2026-09-21
> **Ждём:** решения — принять как перестановку абзацев (baseline) или переписать главу Doubles по
> порядку appdata.

# Doubles: «text differs» в `npm run sync` без baseline

Раздел `Event Companion · Doubles (delta chapter)` в `npm run sync` печатает строки «text differs
from appdata» по шагам главы (Muster Armies, Units and Models 01.02, …). Смысл совпадает,
разошёлся порядок абзацев: мы держим пример перед «каждая команда выбирает Warlord», appdata —
после; у нас нет финальной фразы «A Warhammer Event battle is then waged…». Не FLAGGED, гейт
не краснеет — но и в baseline не записано, поэтому всплывает каждым прогоном.

Варианты: (а) переставить абзацы по appdata и дописать фразу — тогда строки исчезнут сами;
(б) записать в `sync-baseline.json` как принятое. Глава писалась как дельта (см.
`project_doubles_chapter`), поэтому (а) надо сверить с тем, как дельта читается на странице.
