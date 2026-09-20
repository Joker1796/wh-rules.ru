# Legends Space Marines у Орденов

> **Статус:** закрыт 2026-09-20
> **Итог:** «да» — 65–72 из 76 Legends SM у каждого Ордена через `sharedUnitIds` (wh11ed `3f1fb83`), **в проде с v2.6.3 (2026-09-20)**; исключения и их основания — `wh11ed/src/data/CLAUDE.md` «SM-Chapter datasheet dedup»
> **Репозитории:** wh11ed
> **Начато:** 2026-09-19
> **Связано:** [Legends в конструкторе](../archive/2026/2026-09-18-legends-in-roster-builder.md), [Legends из паков](../archive/2026/2026-09-18-legends-from-pack.md)

## Суть

`sharedUnitIds` в `wh11ed/src/data/datasheets/<орден>.js` (84 общих Codex-юнита) не включает pack-листы
Space Marines, поэтому у Орденов их нет ни на странице датащитов, ни в конструкторе (ростер
складывает Ордену тот же список, что и датащит-слой). По паку эти листы — ADEPTUS ASTARTES, доступны
всем Орденам; часть Орденов при этом несёт собственные версии (Space Wolves — свои Long Fangs и
Thunderwolf-персонажи, Blood Angels — свой Furioso), которые должны перекрывать общие по id.

## Если «да»

Правка в датащит-слое: дописать pack-id SM в `sharedUnitIds` каждого Ордена, исключив id, которые
Орден уже несёт сам (скрипт `add-datasheets.mjs` это проверяет для вставки; для списка — сверить
руками или маленьким скриптом). Ростер подхватит без правок: `loadRosterFaction` складывает по тому же
списку. Очки Орденов для этих юнитов — `pointsOverrides`/`unitPoints`, если MFM Ордена даёт другую цену
(у Legends-секции MFM Орденов проверить).

## Как решили (2026-09-20)

Прямой фразы «Ордена могут брать Legends SM» в паках нет. Основание — правило Ордена («любой
ADEPTUS ASTARTES не из другого Ордена») плюс единственное место, где GW проговаривает это косвенно:
**пак Deathwatch поимённо запрещает семь Legends-листов SM** (Assault Squad, Assault Squad with Jump
Packs, Attack Bike Squad, Land Speeder Storm, Relic Terminator Squad, Scout Bike Squad, Scout Sniper
Squad) — запрещать недоступное GW бы не стала.

Исключения по Орденам: все — четверо с ключевым словом ULTRAMARINES; DW — семь выше; BT — оба
Librarian (Codex BT: «cannot include any ADEPTUS ASTARTES PSYKER»); SW — Venerable Dreadnought (свой
лист с тем же id) и Apothecary on Bike (**решение владельца** по аналогии с appdata-исключением
Apothecary/Apothecary Biologis у SW — в тексте правил этого нет). Ferren Areios дан Орденам
(**решение владельца**): на датащите только ADEPTUS ASTARTES, хотя MFM ставит его под Ultramarines.

Что подхватилось само: ростер (генератор копирует `sharedUnitIds`), RU на страницах (runtime fold),
поиск с бейджем, очки. Руками — `SHARED` в 5 RU-файлах (их читает `gen-seo-routes.mjs` напрямую).
SEO-страниц 3793 → 4491. Побочно выяснилось, что `sources/mfm/mfm_v3.7.pdf` — MFM 10-й редакции
(записано в `sources/README.md`).
