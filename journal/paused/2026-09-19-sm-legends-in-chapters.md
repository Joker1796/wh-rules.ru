# Legends Space Marines у Орденов

> **Статус:** приостановлен
> **Ждём:** решения владельца — показывать ли 76 pack-Legends Space Marines (Bike Squad, Captain on Bike, реликтовые дредноуты, техника Forge World…) у Орденов (BA/DA/BT/DW/SW)
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
