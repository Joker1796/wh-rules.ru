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
