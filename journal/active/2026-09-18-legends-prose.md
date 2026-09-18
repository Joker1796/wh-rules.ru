> **Статус:** активен
> **Репозитории:** wh11ed
> **Начато:** 2026-09-18
> **Связано:** [хвосты после разбора жалоб](../paused/2026-09-13-player-report-tails.md)

# Проза Legends: «Warhammer Legends» и «Legendary Proxies»

## Откуда

Баг-репорт `98137b30` (анонимный, 2026-09-18): «перед тем как делать Legends другим фракциям,
добавьте Ufthak Blackhawk для орков». Проверка: датащита у него нет ни у нас, ни в appdata — в
11-й редакции GW его не переиздала. Есть только таблица **Legendary Proxies** в публикации
«Legends: Orks» (`publication.isLegends`): `Ufthak Blackhawk → Warboss` и ещё 13 замен. Эту
таблицу и вводный раздел «Warhammer Legends» мы **никогда не показывали**: синк датащитов их не
видит, синк прозы фракции читает кодекс. Двенадцать датащитов Legends при этом на сайте были.

**Вердикт по репорту:** не баг, добавить нечего — но таблица и есть ответ игроку.

## Что сделано (всё в wh11ed, НЕ закоммичено на момент записи)

- `scripts/gen-faction-legends.mjs` (`npm run legends`, `--check` в `npm run sync`) →
  `src/data/factionLegends.json`; цель прокси резолвится в наш датащит по имени, нерезолв =
  падение; опечатка GW «Biltza Bommer» → `USE_TYPOS`.
- `src/data/factionLegendsRu.json` — перевод интро руками; проксики — имена юнитов, не
  переводятся. Парити интро — в `npm run parity`.
- `FactionDatasheetsView.vue` — секция внизу списка: свёрнутый тоггл «Что такое Warhammer
  Legends» (приглушённый текст, `strong` внутри наследует цвет — иначе в тёмной теме вспыхивал
  белым), таблица прокси со ссылками; поиск на странице фильтрует и прокси. Заодно ключ
  значков и чекбокс «Скрыть юниты Legends» встали в одну строку (`ds-tools`) — раньше
  слипались.
- Глобальный поиск: четвёртый слот `legacy` в `datasheetIndex.js` (пользователь проверил, что
  без него «Ufthak» в Ctrl+K не находился — просил добавить); результат «Warboss» с подписью
  «Legendary Proxies: Ufthak Blackhawk» в обеих локалях. Тест в `useSearch.test.js`.
- Доки: `src/data/CLAUDE.md`, `DATA-SYNC.md` (после `npm run legends` перегонять
  `npm run datasheets:index`), лейблы EN/RU, changelog **2.5.1**.

Проверки: lint чистый, vitest 1852 зелёные (+1 новый), build проходит. Пользователь смотрел
вживую на dev-сервере, три правки по виду внесены.

## Следующий шаг

1. Закоммитить в `wh11ed` (main): `feat(factions): Legends prose — the Warhammer Legends intro
   and the Legendary Proxies table, on the unit list and in search`. 15 файлов, 3 новых.
2. Релиз — скил `release-frontend` (в проде v2.5.0; changelog 2.5.1 уже дописан).
3. Закрыть этот журнал.

## Замечено вне задачи

- `scripts/parity-check.mjs`, блок faction FAQ: читает `entry.items`, а в `factionFaq.json`
  ключ `entries` → гейт по FAQ мёртв (0 пар всегда). Отдельная правка; может поднять реальные
  ошибки.
- «Legends для остальных фракций» обещаны в changelog 2.5.0 — в appdata пока только Orks
  (`isLegends` = 1 публикация). Генератор готов к следующим без правок.
