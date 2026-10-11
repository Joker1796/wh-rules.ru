> **Статус:** приостановлен
> **Репозитории:** wh11ed
> **Начато:** 2026-10-11
> **Ждём:** решения владельца — делать ли модификаторы для Legends из Faction Pack и в каком объёме

# У Legends из Faction Pack нет модификаторов ростера

Нашлось при разборе жалобы про T'au Shield Drone (wh11ed `93805021`, ветка `fix/shield-drone`).
Слой `src/data/rosterModifiers/` строится генератором `gen-roster-modifiers.mjs` по appdata: каждая
запись держит `sid` — UUID appdata. У листов из Faction Pack (`source: "faction-pack"`, ~314 штук,
скил `legends-from-pack`) UUID нет, поэтому записей у них нет вообще: ни «+1 W носителю», ни
способностей, ни снаряжения. Карточка такого юнита показывает только напечатанные цифры.

Пример: Shield Drone починен на 11 юнитах T'au, а у трёх Legends — Commander in Crisis
Battlesuit, Crisis Battlesuits, XV9 Hazard Battlesuits — дрон по-прежнему ничего не добавляет.

Что нужно решить: заводить ли записи для pack-листов вручную (с каким ключом вместо `sid` —
например, `pack:<slug>:<unit>:<rule>`) и как генератор/`--check` их будет считать (сейчас
такая запись стала бы «orphan»).
