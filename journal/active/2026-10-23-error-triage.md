> **Статус:** активен — первый проход сделан 23.10: одна ошибка починена (в 2.10.4), три уже были исправлены в 2.10.1, одна ждёт полного стека; 32 отпечатка отмечены исправленными в 2.10.1, `fa5eb909` — в 2.10.4 (владелец, 23.10); следующий проход — по новым строкам `errors-list`
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

## 23.10: первый проход

| Отпечаток | Вердикт |
|---|---|
| `fa5eb909` | **Починено в 2.10.4** (wh11ed `fix/reported-errors`, `3c76401d`). Механизм: `useTourShow` — immediate watch; страница, открытая на шаге тура с `show.viewTab`, читала `viewTabs` до объявления. Класс: 10 вызовов `useTourShow`/`useTourWhile`, живой — один. Шире: `no-use-before-define` даёт 161 срабатывание в 37 файлах, отобраны выполняемые при setup — других живых нет; хрупкое, но не падающее: `FactionDatasheetsView` `firstId` → `groupedDatasheets` (спасает `loaded = false` на старте). Гейт: тест в `RosterViewView.test.js`, красный на старом коде той же ошибкой. |
| `36b2b99c` | **Ждём полного стека.** Firefox упал там, где кончился стек (`hasKeyword` → `foldName`); первые 10 кадров не показывают цикла, остальное отрезано на 1500 символах. Инструмент: отчёт теперь хранит верх и низ стека (wh11ed `chore/drop-perf-report`, `7112912e`). |
| `eda3aa00` | Уже исправлено в 2.10.1 (`76225598`, `shownPages`). |
| `af303fa0` | Уже исправлено в 2.10.1 (`94aef7a1`, запрос не прерывается). |
| `379aa3be` | Уже исправлено в 2.10.1 (`03e2f639`, запись в поток ожидается). |
| петля перезагрузки, 29 строк | Исправлено в 2.10.1 (`2d1b968a`). |

Отметить исправленными — команда для владельца (мне классификатор не дал писать в прод):
`ssh -i ~/.ssh/wh_rules_vps wh@31.129.57.24 'for f in eda3aa00 af303fa0 379aa3be 322f4dac 50579501 4e597a57 cc5d6686 82a0bb6f 3fdbc111 62cfaeee cbf5ad97 9b382125 ed70ea9b f0d2ba5e 106a0da8 cb93044d 80a07f1e a3b667ad c8d0ba50 4a094df2 23bea293 c854e2d9 2776101e 1ea8450c 8610c83f 0fc6725e 75751664 2ab779db d095979d 3b88d6de cf147db9 5dcafbf4; do docker exec wh-rules-api-1 node --import tsx scripts/errors-resolve.ts $f 2.10.1; done'`
23.10: 2.10.4 в проде, `fa5eb909` отмечен исправленным в 2.10.4 (владелец).

Попутно: красный `capsKeywords.test.js` — корень в выкате (откат старых записей чейнджлога в архив унёс единственное `GRAV-ASSAULT`), `deploy.sh` теперь пересобирает список после переноса (`4f15a090`).
