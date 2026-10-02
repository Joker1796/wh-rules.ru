> **Статус:** активен
> **Репозитории:** wh11ed
> **Начато:** 2026-10-02

# Слежение за обновлениями GW

2 октября игрок сообщил о тихой переоценке MFM раньше, чем мы её заметили. Нужна проверка,
которая сама пишет на почту, когда GW что-то выпустил.

## Решения владельца (2026-10-02)

- Только первоисточники: приложение (App Store + Google Play), сайт MFM, Downloads на
  warhammer-community.com. **BSData не отслеживаем.**
- Вариант А: GitHub Actions в wh11ed + письмо через Postbox, как у баг-репортов.

## Как устроено

- `wh11ed/scripts/watch-gw.py` + `.github/workflows/gw-watch.yml` (коммит `4b6e53a`), раз в 3 часа.
- App Store — JSON `itunes.apple.com/lookup?bundleId=com.gamesworkshop.w40k`; Play — `[[["x.y.z"]]`
  со страницы магазина; APK скачивать руками (APKPure отвечает роботам 403).
- MFM — сравниваются цены: прогон `scrape-mfm.py` (28 с) против `src/data/mfm`, в письме дифф.
  Свежий прогон 2026-10-02 совпал с репозиторием байт в байт.
- WarCom — POST `www.warhammer-community.com/api/search/downloads/` (`downloads_v2`, 37 документов),
  ключ — имя файла (slug не уникален), PDF по `assets.warhammer-community.com/<file>`.
- Состояние — `state.json` в orphan-ветке `watch-state`; первый запуск только запоминает.
- Источник не прочитался → запуск падает → письмо «проверка сломалась».
- Проверено: сухой прогон с подставленным старым состоянием даёт правильное письмо; шаги ветки
  состояния — на локальном bare-репо.

## Где остановились

**Работает с 2026-10-02.** Ключ Postbox `ajevepeq4bnhbslr2ob8` (скоуп `yc.postbox.send`, SA
`wh11ed-postbox`, отдельный от ключа API) лежит только в секретах GitHub wh11ed: `POSTBOX_KEY_ID`,
`POSTBOX_SECRET`, `WATCH_MAIL_TO` (= `FEEDBACK_MAIL_TO` из `wh11ed-api/deploy.env`). wh11ed запушен.
Прогоны: baseline (run 37000600627), тестовое письмо «[WH Rules] GW: App Store 2.7.2» через откат
состояния (37000679104) — ушло, повтор — «nothing new» (37000741649).

Дальше: дождаться первого настоящего письма; если оно окажется шумным — правило в `watch-gw.py`.
Закрыть журнал после первого реального срабатывания.

Попутно: в App Store 2026-10-02 08:14 UTC вышло приложение **2.7.2** («Codex: Space Marines is now
available»), в Play пока 2.7.1 (из него данные 972). Возможен новый бамп данных.
