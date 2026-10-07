> **Статус:** закрыт 2026-10-08
> **Репозитории:** wh11ed
> **Начато:** 2026-10-08
> **Итог:** второй Support (Legends Exalted Champion) и одинаковые кнопки размеров Accursed Cultists исправлены; выкачено тихо — без бампа (BUMP=none) и без записи в чейнджлоге, прод = 2.7.18, wh11ed main `b169b09b`

# Хотфикс: один Support на отряд, кнопки размеров

Жалоба игрока (сообщение со скриншотом, не через форму — очередь репортов пуста): «к юниту можно
добавить только один саппорт» и «у Accursed Cultists задвоился выбор количества моделей».

## Что было

- **Второй Support.** `pack-roster.mjs` любую сноску Faction Pack'а «even if … already been attached»
  читал как `flags.alongside` (не занимает слот). Четыре Legends: Exalted Champion (CSM, Support в
  11-й) вставал вторым саппортом на Chosen/Legionaries/Nemesis Claw/Red Corsairs Raiders (14 пар);
  Jokaero, Vargard Obyron, Death Rider Commissar — рядом с любым лидером вместо названных персонажей.
- **Кнопки размеров.** У Accursed Cultists два состава 9–16 по 185 (6–10 Mutant + 3–6 Torment и
  5–10 + 4–6); подпись различала только по названиям профилей — одинаковым.

## Решения

- Владелец: Exalted Champion — обычный саппорт (оговорка из 10-й покрыта правилом «лидер + саппорт»).
  Альтернатива «буквально, максимум 2 персонажа» отклонена.
- Именованные — поле `along` (keywords), `joinsAlongside` в rosterEngine, общий для пикера и
  валидатора. Незнакомая формулировка валит генератор.
- Совпавшие подписи размеров показывают численность профилей.
- Гейты: `index.test.js` «attachment slots» (все пары саппортов, все фракции); `UnitEditorFields.test.js`
  — каждая кнопка размера в корпусе читается по-разному. Урок 82 в APPDATA-SYNC-LESSONS.md.

## Выкат

Коммит `48e63f47`, вместе с фиксом deploy.sh (`5d3b4974`). Первый деплой (с бампом до 2.7.19)
остановлен владельцем на заливке ассетов — хотел без бампа; бамп откатан, выкачено `BUMP=none`,
бандл `index-BxMIE_Za.js`, CDN сброшен, `main` перемотан руками и запушен. Слитые ветки удалены.

## Текст для чейнджлога 2.7.19 (если владелец захочет упомянуть)

EN: { h: 'Roster builder' }
- A unit takes only one Support. The Legends Exalted Champion could join as a second one, and now it cannot.
- The Legends Jokaero Weaponsmith, Vargard Obyron and Death Rider Commissar join a unit that already has a Leader only beside the characters their datasheets name.
- Accursed Cultists have two 9–16 builds at 185 points. Their buttons used to look the same. Now each one shows how many Mutants and Torments it takes.

RU: { h: 'Конструктор ростеров' }
- К отряду можно присоединить только одного Support. Legends Exalted Champion вставал вторым, теперь нельзя.
- Legends Jokaero Weaponsmith, Vargard Obyron и Death Rider Commissar встают к отряду с Leader только рядом с персонажами, которых называет их датащит.
- У Accursed Cultists два состава на 9–16 моделей по 185 очков. Раньше их кнопки выглядели одинаково. Теперь на каждой видно, сколько в нём Mutant и Torment.

## Дальше

Ветка трекера `feat/tracker-side-cards` (worktree ~/Projects/wh11ed-tracker) — main влит
(`27586d03`), 2700/2700 зелёные; не запушена; для 2.7.19 нужна запись в чейнджлоге.
