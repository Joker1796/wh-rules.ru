> **Статус:** активен
> **Репозитории:** wh11ed
> **Начато:** 2026-10-15
> **Связано:** [бета трекера](2026-10-08-tracker-beta.md)

# Выборы из правил — отслеживать все, с текстом правила

## Откуда задача

Владелец по пункту чейнджлога 2.9.3 про Take Cover!: «мы очень много пропустили правил, которые не
меняют модификаторы, но надо бы дать их отслеживать тоже, просто для целостности + смотреть текст
правила».

**Механизм.** Переключатель в партии (`switchesFor`, `rosterGameContext.js`) строится только из
эффектов модификаторов: состояние появляется, если его называет `cond` числового эффекта. Отсюда
две дыры:
1. **Выбор без цифр** не заводится вовсе (нечем назвать — нет эффекта).
2. **Выбор с цифрами, у которого эффект закрыт `never`** — читатель записи решил «не отвечается
   картой», и состояние не завели. Take Cover! был таким (потолок 3+), починен в 2.9.3.

Все 96 заведённых состояний (`conditions.js`) какой-то эффект называет — мёртвых нет; теряется то,
чего в реестре нет.

## Аудит (2026-10-15)

Эффектов с `cond: ['never']` — **674**, в **505** записях. Из них сформулированы как выбор/состояние
157 эффектов, 112 правил, по классам:

- **A. Выбор варианта / состояние правила — отслеживается переключателем (46 правил).**
  Армия/детачмент, надолго (битва/раунд), цифры уже записаны и закрыты `never`:
  Templar Vows (BT), Hyper-adaptations и Synaptic Imperatives (Tyranids), Code Chivalric — качества
  Oath (IK), Benedictions: Panegyric Procession (AdMech), Darkness Dread (CK), Blessings of Burning
  Blood / Boon of Blood (WE). Те же по смыслу, но `when` без слов выбора (нашлись вручную):
  Murderous Agenda (Drukhari), Noospheric Transference (AdMech), Blood Tithe (WE).
  Без записей модификаторов вовсе (нет цифр): Artillery Support (AM Siege Regiment), Slaves to None /
  Vendetta / Twisted Doctrine (CSM Renegade Warband), гимны Hagiomnifex (2 из 5 заведены), At all
  Costs и Deathwatch Mission Tactics (Imperial Agents), Idols of Khorne, Channelled Force,
  Techno-sorcerous Augmentations; приказы из улучшений AM — Target Weak Spot, Move to the Shadows,
  On My Signal.
  На юните, выбор на активацию (до конца фазы), цифры есть: Prey Adaptation, Gifted Commander,
  Martial Warrior (Aun’Shi), Adaptive Instincts, Special-issue Optics, Dance of Death; стратагемы с
  вариантом: Hardened Killers, Experimental Ammunition, Avowed Destruction, Wrath of Khorne. Без
  записей: Cruel Amusement, Embodied Prophecy, Harbinger of Death, Bladeguard.
- **B. Разовое применение «раз за битву» — состояние «применено в этой фазе» (20 правил):**
  Finest Hour, Watcher in the Dark, Banner of Macragge, Standard of the Emperor Ascendant, No Foe
  Shall Stand, Disintegration Beams, Moment Shackle, Blinding Spray, Chronoshard, Null Nodules,
  Infernal Infusion, Blinding Speed, Purifying Force, Shadow of Abomination, Unholy Bloodshed,
  Pulsa Rokkit, Dark Blessings, Eagle’s Eye, Flickerjump, Co-ordinated Eradication.
- **C. Не отслеживается картой — честно `never` (47 правил):** против отмеченной/выбранной
  вражеской цели (21), по дальности до маркера цели (26).
- **Не разобрано:** остальные ~393 записи с `never`, сформулированные не через выбор («если цель
  Battle-shocked», «на каждую атаку…») — пройти отдельно, там тоже могут быть состояния.

Отдельно, правила «выберите одно из» по тексту (армия/детачмент/улучшения/способности): 77 правил,
по ним сырая таблица была в scratchpad сессии — генерировать заново скриптом, если понадобится.
Уже ведутся счётчиками армии (11 фракций, `src/data/armyTrackers/`) — доктрины, Imperatives,
Waaagh!, Blessings, Rituals и т. п. — их не трогаем.

## План (предложен владельцу, ждём решения по порядку)

1. **Состояние без цифр:** разрешить завести вариант как состояние без эффекта — подпись, правило
   источник, срок (фаза/ход/раунд/битва), группа «одно из», армия или юнит. `switchesFor` берёт и
   их.
2. **Класс A** — завести всё перечисленное; эффекты с `never`, которые на самом деле выбор, перевести
   на новые условия (как Take Cover!).
3. **Класс B** — «применено» как юнит-состояние на фазу/ход.
4. **Текст правила по нажатию на переключатель** — строка самого варианта (якорь `###`/пункта),
   не только имя правила.
5. **Гейт:** тест падает на правиле «выберите одно из», вариант которого нигде не отслеживается, и на
   `never`, чей `when` назван выбором, без записи в списке исключений с причиной.
