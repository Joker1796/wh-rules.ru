> **Статус:** активен
> **Репозитории:** wh11ed, wh40k-appdata
> **Начато:** 2026-10-14
> **Связано:** [Снаряжение по моделям](2026-10-14-wargear-per-model.md), [Слежение за обновлениями GW](2026-10-02-gw-update-watch.md), скил `appdata-update`

# Обновление appdata 972 → 981 (приложение 2.8.0, Codex: Adeptus Custodes)

Приложение 2.8.0 вышло в Play 7 октября; письма от слежения не было — владелец узнал со стороны.
APK вытащен `apk-emu.mjs` (vc148), Data Version в профиле совпала с пакетом (981).

## Решения владельца

- Катим одним релизом **2.9.0** вместе с починкой снаряжения по моделям. Ветка
  `data/981-custodes` от `release/2.9.0`, потом слить в релиз.
- «Делай всё»: кодекс, эррата прочих фракций, основные правила, RU, гейты.

## Объём (по `changes.mjs` + `npm run sync`)

- **Custodes:** новые армейские правила (Aegis of the Emperor, Aquila Commander, Martial Ka’tah с
  Favoured ka’tah, Daughters of the Abyss, Special Move Types), 11 детачментов (9 новых, 5 наших
  ушли), перевыпущенные датащиты, своя публикация «Legends: Adeptus Custodes». Генераторами.
- **Эррата прочих:** проза у Sororitas, AdMech, Aeldari, BA, Orks, SW, WE; профили оружия
  (Instigator bolt carbine у всех SM, Sicarius, Combi-weapon/Storm bolter у Chaos и GK, Callidus,
  Marshal); Force Disposition у ~12 детачментов; очки Exorcist/Gretchin/Headtakers.
- **Основные правила:** новые 01.02.12, 01.04.06; текст 09.07.01; FAQ/эррата фракций.

## Ход работы

**2026-10-14, EN-проход** (wh11ed `2aabe2dc`, appdata `5cf9504`, оба не запушены):
- MFM уже v1.6. Custodes — генераторами; 9 переименованных листов записаны в `datasheetRenames.json`
  и в миграцию ростеров v12 (где лист разделили на два — туда, где стандартное снаряжение старого:
  Agamatus → Gyrfalcon, Aquilon → with Solarite Power Gauntlets, Venatari → with Verutum Lances,
  Adrasite/Pyrithite → Adrasite). Выбор снаряжения у Custodes и Kill Tank сбрасывается.
- **Решения без владельца, проверить:** Death Company Captain — power fist A3 WS3+ в 981 считаю
  опечаткой appdata (relic weapon того же листа A7 WS2+, у варианта с ранцем A5 WS2+), оставлено A6
  WS2+ исключением. Bjorn the Fell-handed — эррата «Change BS to 2+» без названия оружия, применена к
  Assault Cannon (единственное его оружие с 3+). Shield-Captain по appdata платит +25 за копьё со
  щитом сверх 180 (возвращается при замене) — так appdata, не проверено в приложении.
- Найдено попутно (уроки 88–92): цены MFM не находились из-за неразрывного дефиса (9 Custodes + 2
  орочьих бомбера); «+N" R» не попадал в модификаторы (4 правила других фракций); вложенные армейские
  правила не читались модификаторами; Noise Marines — appdata 4 sonic blaster на 5 моделей.
- **Отложено, ждёт владельца:** два новых бокса Combat Patrol Custodes (Aquilan Talon, Aquilan Wing) —
  у нас «один бокс на фракцию» (`/combat-patrol/<slug>`), нужна смена модели страницы. RU «было/стало»
  на `/patches` — механизма нет, для 981 не сделано.
- Ложные сигналы сверки, не из этого бампа: `sync-enh-bodyguards` не читает плашки `extras/`
  (с 2026-10-06), поэтому 11 «MISSING».

**2026-10-14, решения владельца после EN/RU-прохода:**
- **Данные — дословно как в приложении.** Мои исключения (Death Company Captain A6 WS2+, Bjorn BS 2+)
  сняты; спорное перечислено в чейнджлоге 2.9.0 блоком «Вероятные ошибки GW» и отмечено на странице
  изменений (`doubts` в `patches.mjs`). Эррату Bjorn смотрел в эмуляторе: только текст, без картинки
  и без названия оружия.
- **Очки — только MFM.** Доплата приложения за стартовое снаряжение не берётся ни у кого
  (`CHARGE_PAID_DEFAULTS` в gen-roster-data; было 15 листов, Shield-Captain 205 → 180).
- Ссылки в чейнджлоге: на правило детачмента ведут через якорь (страница фракции сама выбирает
  детачмент), датащиты открываются модалкой; ссылка на обновление GW — плашкой под разделом.
- Ka’tah — карточками с цветной шапкой (`◈# Имя | RU` в RuleBody), RU-подписи транслитерацией;
  новые термины codex — глоссы (`ac-*`); Anathema Psykana — отдельной плашкой.
- **Combat Patrol: каждый бокс — своя плитка и страница** (`id` бокса, старые адреса = слаг фракции);
  у Custodes три бокса. В работе.
- Шрайк: EPIC HERO в 981 не вернули (снят в 963, страница изменений это показывает).

**2026-10-14, вечер — документы GW от 14.10** (warhammer-community → Downloads, PDF в `sources/`):
- Space Marines Printed Product Updates v1.1: Шрайку CHARACTER и EPIC HERO; приложение склеило строку
  с Librarian in Terminator Armour и потеряло EPIC HERO → применено по PDF (исключение `unit-keyword`,
  блок «Правки из документов GW» на странице изменений, предупреждение «второй Шрайк» удалено).
- Custodes Printed Product Updates v1.0 и Event Companion 1.3 (у Wazbom «oval base») — совпадают
  с приложением / внесено.
- Шесть Faction Pack (Sororitas 1.4, AdMech 1.4, Agents 1.3, Votann 1.2, Tyranids 1.3, Aeldari 1.4):
  правила = эррата 2.8.0; страницы Legends дословно те же, кроме FRAME у Repressor и Battle Sanctum.
  Aquila Kill Team убран из пака Agents, но есть в приложении — остаётся.
- Combat Patrol по боксам — сделан (`9d3ccb53`); вопросы агента к владельцу — в отчёте 14.10.

**2026-10-14, позже.** Владелец: релиз — **2.9.0** (минорный, «гора изменений»). Ветка `release/2.8.3` переименована в `release/2.9.0` (она была только локальной), запись чейнджлога — `2.9.0`; деплой — `BUMP=minor`. Бьорн: эррату читаем как BS 2+ на всё оружие → Assault Cannon 2+, исключение `sw-bjorn-assault-cannon-bs`.

**Сверка Legends (2026-10-14).** Приложение 981: Orks 12, Space Marines 28, Adeptus Custodes 7 — у нас поимённо так же; с 972 ничего не пропало, +7 Custodes. MFM: Sentry Pylon(s) — написание, Tactical Drones — без цены (известно). **Ciaphas Cain** — MFM не даёт цену с 963, лист в паке Astra Militarum v1.2 есть; владелец: **оставляем по паку**, очки прежние (70).
