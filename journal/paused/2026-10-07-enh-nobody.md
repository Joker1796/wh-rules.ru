> **Статус:** приостановлен
> **Репозитории:** wh11ed
> **Начато:** 2026-10-07
> **Ждём:** решения владельца — браться ли (не срочно, жалоб не было)

# Улучшения, которые конструктор не даёт никому

Нашлось 2026-10-07 при сверке «кому можно улучшение» (тот же заход, что `ds`-группы appdata,
коммит wh11ed `e17d65aa`, в 2.7.18). Эти 11 к той правке не относятся: у них нет `ds`, они требуют
персонажа, которым юнит становится по правилу детачмента, а конструктор этого не моделирует.

| Фракция | Детачмент | Улучшения | Требование в тексте |
|---|---|---|---|
| Astra Militarum | Steel Hammer | Battalion Commander, Titan Killer, Assault Hatches | «ASTRA MILITARUM TITANIC CHARACTER model only» |
| Chaos Knights | Houndpack Lance | Preyslayer’s Mantle, Loping Predator, Panoply of the Cursed Knights | «War Dog model only» |
| Chaos Daemons | Shadow Legion | Leaping Shadows, Fade to Darkness, Malice Made Manifest | SHADOW LEGION (юниты союзников; в конструкторе грант есть — проверить, не ложное ли срабатывание пробы) |
| Genestealer Cults | Final Day | Vanguard Tyrant | Winged Hive Tyrant (юнит Tyranids) |
| Imperial Knights | Questor Forgepact | Magos Questoris | Tech-Priest (юнит AdMech) |

Проба считала без `grantedKeywords` (выданных детачментом ключевых слов), поэтому Shadow Legion,
скорее всего, ложный: `conditionalKeywords.json` выдаёт его 19 демонам. Остальные — настоящие
пробелы: CHARACTER, выданный детачментом (Steel Hammer, Houndpack Lance), и носитель из союзной
фракции (Final Day, Questor Forgepact).

## Что сделать

1. Для каждого прочитать правило детачмента: кто и как становится CHARACTER / попадает в армию.
2. CHARACTER от детачмента — как грант в `conditionalKeywords.json` (так уже устроен SHADOW LEGION);
   носитель из союзников — `enhEligible` по пулу с союзниками.
3. Гейт: «у каждого улучшения есть хотя бы один юнит, которому его можно дать» (с грантами и
   союзниками) — сейчас его нет, отсюда и пробел.
