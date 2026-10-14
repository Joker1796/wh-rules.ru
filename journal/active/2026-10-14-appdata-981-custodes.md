> **Статус:** активен
> **Репозитории:** wh11ed, wh40k-appdata
> **Начато:** 2026-10-14
> **Связано:** [Снаряжение по моделям](2026-10-14-wargear-per-model.md), [Слежение за обновлениями GW](2026-10-02-gw-update-watch.md), скил `appdata-update`

# Обновление appdata 972 → 981 (приложение 2.8.0, Codex: Adeptus Custodes)

Приложение 2.8.0 вышло в Play 7 октября; письма от слежения не было — владелец узнал со стороны.
APK вытащен `apk-emu.mjs` (vc148), Data Version в профиле совпала с пакетом (981).

## Решения владельца

- Катим одним релизом **2.8.3** вместе с починкой снаряжения по моделям. Ветка
  `data/981-custodes` от `release/2.8.3`, потом слить в релиз.
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
