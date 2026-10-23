> **Статус:** активен — разбор ошибок из отчётов игроков веду я (решение владельца 23.10); первый проход не начат
> **Репозитории:** wh11ed, wh11ed-api
> **Начато:** 2026-10-23
> **Связано:** [замеры производительности](2026-10-20-perf-metrics.md)

# Разбор ошибок из отчётов

Владелец 23.10: «разбор ошибок будешь делать ты». Ошибки приходят в `POST /errors` от тех, кто включил отправку; за 30 дней до 23.10 — 38 строк, 41 случай, ни одна не отмечена исправленной.

## Как разбирать

1. Список: `ssh -i ~/.ssh/wh_rules_vps wh@31.129.57.24 "docker exec wh-rules-api-1 node --import tsx scripts/errors-list.ts --days=30"`; подробно — с отпечатком вместо `--days`. Стек уже раскодирован по source maps версии.
2. По каждой: воспроизвести или найти по стеку в коде **той версии** (`git show v<версия>:<файл>`), проверить, жива ли в `main`. Разбирать до корня (скил `feedback-triage` §2а).
3. Починили → в релиз; после выката: `docker exec wh-rules-api-1 node --import tsx scripts/errors-resolve.ts <отпечаток> <версия>`. Отметка — запись в прод-базу, делать после выката по команде владельца или его `!`.
4. Шум (`chunk` — вкладка до выката) не разбирать; сводка уже сворачивает его в строку (api `6246ded`).

## Очередь (на 23.10)

| Отпечаток | Версия | Что | Где по стеку |
|---|---|---|---|
| `fa5eb909` | 2.10.1 | `Cannot access 'gn' before initialization` (обращение до объявления), Yandex Android, `/ru` | `src/views/tracker/RosterViewView.vue:822` из `useTour.js:82` (watch immediate) |
| `36b2b99c` | 2.10.0 | `too much recursion`, Firefox Windows, `/ru/roster/:id/view` | `rosterEnhEligible.js:23` → `foldName.js:36`, из `RosterUnitBrowser.vue:426` / `rosterValidation.js:53` |
| `eda3aa00` | 2.9.7 | `Cannot read properties of undefined (reading 'kind')`, печать | `src/components/roster/RosterPrintFragment.vue:28` |
| `af303fa0` | 2.9.7, 2.10.0 | неперехваченный `AbortError: signal is aborted without reason`, ×3, Chrome Windows | `src/composables/launchGate.js:36` |
| `379aa3be` | 2.9.7 | `Compressed input was truncated.` (rejection) | стек не смотрел |
| reload loop | 2.9.2–2.10.0 | 27 строк по ×1 — одна ошибка | с 2.10.1 не приходит; вероятно, исправлено `2d1b968a`; с 2.10.4 одна петля — одна строка |

## Дальше

Первый проход по очереди — по команде владельца или в следующую свободную сессию.
