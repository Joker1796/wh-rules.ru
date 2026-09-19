> **Статус:** закрыт 2026-09-19
> **Итог:** 314 pack-листов в конструкторе (wh11ed, читатель `scripts/lib/pack-roster.mjs`), в проде с v2.6.1 (2026-09-19)
> **Репозитории:** wh11ed
> **Начато:** 2026-09-18
> **Связано:** [Legends из Faction Pack'ов](../archive/2026/2026-09-18-legends-from-pack.md)

## Суть

311 Legends-листов из Faction Pack'ов (`source: "faction-pack"`) живут только как справочник:
страница датащита, поиск, индекс фаз, очки. В конструктор ростеров они не попадают — его данные
(`src/data/roster/<slug>.js`, `npm run roster:data`) собираются из таблиц appdata (состав,
структура вооружения, лимиты), а у PDF-листов этих таблиц нет. В конструкторе есть только Legends
орков (12 юнитов, приходят из appdata). В анонсе 2.6.0 это сказано явно.

## План (на 2026-09-19)

- Состав — из `composition` («1 Sergeant», «4-9 Marines», «0-1 Attack Bike»).
- Структура вооружения — из `options`: они в машинном формате («This model’s X can be replaced
  with one of the following:\n▪ …», «Any number of…», «Up to 2…», «For every 5 models…») — те же
  16 шаблонов, которыми RU-опции переводились регексами в заходе 7; парсер должен быть fail-closed
  и печатать всё, что не распарсил, гейтом.
- Очки уже есть (MFM Legends), `legends: true` уже стоит — фильтр «скрыть Legends» в браузере
  юнитов заработает сам.
- Риск: 311 листов × разбор опций; проверять на выборке по одному листу каждого типа (персонаж,
  отряд с сержантом, техника с пинтлами, дредноут с парными руками) прежде чем катить всё.

## Сделано (2026-09-19)

Читатель `wh11ed/scripts/lib/pack-roster.mjs` + `packUnitsFor` в `gen-roster-data.mjs`; устройство
и все решения — раздел «The Faction Pack Legends» в `wh11ed/src/components/roster/CLAUDE.md`. Здесь
только то, чего там нет.

- **314 из 315 листов** прочитаны (1361 юнит в конструкторе против 1047). Не вошли: T’au Tactical
  Drones (MFM не даёт цены — в 11-й они варгир).
- Решения по пути: очки-«добавки» MFM, которые состав не вмещает (Bike Squad «1 model 55», Shadow
  Spectres «1 model 30» — цена Attack Bike/Exarch), **отброшены с отчётом**, а не встроены: наш
  bracket-формат «+N за модель» не выражает. Grenadier Squad с «One of the following» сложен в один
  диапазон на профиль (шире двух легальных сборок). Mark of Chaos для 17 листов CSM — по тексту
  правила Pactbound Zealots, не по списку.
- Предметы интернируются **по имени** (общий id с appdata, где имя совпадает), и **последними** —
  id appdata-предметов не сдвинулись, диф только в файлах фракций с паками.
- RU опций: генератор `gen-roster-texts-ru.mjs` расширен (сноски отделяются и переводятся,
  ~12 новых рамок) — 290/290 pack-инструкций переведены, общий охват 89 % → 94 %.
- Проверки: vitest 1868/1868 (корпусные тесты `index.test.js` подправлены: pack-юниты без `sid`
  считаются отдельно), `roster:data --check`, `texts-ru --check`, `sync`, `coregrants`, lint —
  чисто; корпус импортов listhammer без изменений (в нём нет списков с Legends).

## Открытые вопросы владельцу

- **SM-Legends на страницах Орденов.** `sharedUnitIds` у BA/DA/BT/DW/SW не включают pack-листы
  Space Marines (Bike Squad, Captain on Bike…), поэтому их нет ни на датащит-странице Ордена, ни
  в его ростере. По правилам пака они ADEPTUS ASTARTES и доступны Орденам. Решение — датащит-слой,
  не ростер.
- Qualifier-формулировки Kill Team’ов («Any number of Kill Team Intercessors with plasma
  incinerators…») читаются как профиль по имени — ок; но Bike Squad 4–6 моделей и все Kill Team’ы
  на 6–10 не раскладываются по профилям (два открытых диапазона) — как у Deathwatch из appdata.
- Смоук в редакторе: Bike Squad (3 и 6), Deathwing Command Squad, Chaos Lord on Bike (Mark),
  Assault Squad («can do one of the following» → два пункта, второй гаснет).
