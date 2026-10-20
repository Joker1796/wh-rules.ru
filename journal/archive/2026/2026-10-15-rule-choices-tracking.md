> **Статус:** закрыт 2026-10-20
> **Итог:** выборы из правил и фикс генератора в проде с 2.10.0 (бета слита целиком)
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

## Сделано (2026-10-15, бета `feat/tracker-side-cards`, не запушено)

- `735f4d37` — эффект `op: 'state'`: только `cond` + `when`; switchesFor предлагает его той же
  дорогой, что числовые, applyStatMods пропускает. Проверка формы — `rosterModifiers/index.test.js`.
- `95e38100`, `b894f43e`, `97012ec3`, `6811891d` — заведены переключатели: Templar Vows,
  Hyper-adaptations, Synaptic Imperatives, Murderous Agenda (Contracts), Noospheric Transference
  (Halo Override + Override), Blood Tithe, Code Chivalric (Deeds, Qualities, Honoured), Harbingers
  of Dread, Artillery Support, At All Costs, Deathwatch Mission Tactics (+Purgatus), Default to
  Doctrine (Renegade Warband), Benedictions, Hagiomnifex, Idols of Khorne, Technosorcerous
  Augmentations, Prey Adaptation, Adaptive Instincts, Gifted Commander, Martial Warrior,
  Special-issue Optics, Dance of Death, Wrath of Khorne.
- Ожили числа, закрытые `never`: Noospheric (+2" M / +1 T / Stealth), Code Chivalric Qualities,
  Darkness (Stealth), выборы юнитов на фазу. Ошибка: Technosorcerous давал [ANTI-INFANTRY 3+] в любой
  фазе стрельбы — теперь только выбранный вариант. Citation in Savagery длилась раунд вместо битвы.
- Тест через реальную цепочку: `src/composables/ruleChoices.test.js`.

**Отложено с причиной:**
- Приказы из улучшений AM (Target Weak Spot, Move to the Shadows) и On My Signal: переключатель
  должен быть на получателях приказа и только если улучшение есть в ростере — switchesFor не умеет
  предлагать состояние по составу ростера.
- Варианты внутри стратагем (Hardened Killers, Experimental Ammunition, Avowed Destruction): иначе
  висят на каждой карточке до применения; нужно предлагать только при применённой стратагеме.
- Bladeguard — у способности нет записи модификаторов (генератор её не предложил).

**Дальше:** шаг 3 (класс B, «раз за битву»), шаг 4 (текст варианта по нажатию), шаг 5 (гейт), потом
отложенное выше и ~393 непросмотренных `never`.

## Повторный анализ (2026-10-18)

Шаги 1–2 живут только в бете (`feat/tracker-side-cards`, 343 коммита от main): в проде и в `release/2.9.7`
нет ни `op: 'state'`, ни 71 из 179 условий. Срез беты (6597165b): 2046 записей, 55 эффектов-состояний в 14
фракциях, 179 условий в ходу, `never` — 635 эффектов в 490 записях (было 674/505).

**Остаток «похожих на выбор» `never` в бете — 139 правил:**
- B. «раз за битву» — **70** (Finest Hour, Moment Shackle, Watcher in the Dark, Plasmacyte, Zealot, Overkill…).
  Самый большой и однородный класс; шаг 3 плана.
- G. вариант стратагемы — 5 в бете (Hardened Killers, Experimental Ammunition, Avowed Destruction, Desperate
  Pledge, Lash of Guilt) + ~16 из 2.9.7 (сегодняшние списки «LETHAL или SUSTAINED»: Anathema Blademastery,
  Mercy is Weakness, Relentless Assault, Vindictive Artillerists…). Нужен выбор только у применённой стратагемы.
- H. выбранный дружественный отряд — 6 (Master of Mechanisms, Blessing of the Omnissiah, Forge’s Blessing,
  Bearer of the Evanescent Ion, Soul Link, Hallucinogen Grenades) + отложенные приказы AM из улучшений.
- C. выбранная вражеская цель — 11, D. выбранный объект — 6: честный `never` (карта цель не знает).
- E. «instead»-варианты по состоянию/цели — 22, F. на атаку под уже включённым правилом — 19: не выборы.

**По тексту правил «выберите одно из»** (только на наших страницах): 81, отслеживается 36, **нет — 45**:
24 без записи вовсе, 6 с пустой, 15 только `never`. Среди них постоянные выборы (Path of the Warrior,
Assigned Agents, Manifold Maladies, Canticles of the Omnissiah, Temple Relics, Choice Samples, Nurgle’s Gift)
и разовые действия, где отслеживать нечего (Demolition Charges, Repair Barge, Floating Death) — разобрать.

**Риск:** 2.9.7 добавляет ~18 записей-выборов с `never`; при слиянии в бету их надо перевести на состояния
вместе с остальными, иначе бета их не покажет переключателями.

## Шаг 3 — «раз за битву» (2026-10-18, ветка беты `feat/once-per-battle` `8cd0cb3e`, не запушена)
- Эффект несёт `once: { per: 'unit'|'army', dur }`; отметка игрока — `ctx.uses[uid][sid]` (стамп), эффект в силе
  в окне правила, потом чип остаётся отмеченным с «Использовано»; повторное нажатие снимает. Per army — у других
  отрядов чип серый «Использовано другим отрядом». Способность персонажа «this unit» общая для присоединённого
  отряда (`attachedUids`). Под опцией «состояния юнитов» (`trackUnitStates`), своей опции нет.
- 70 записей переведены; 5 оставляют `never` поверх (Moment Shackle — выбор из двух, Alchemicus Familiar,
  Shieldbreaker, Pulsa Rokkit, Co-ordinated Eradication — цель). Гейт `onceRules.test.js` (красный на старых данных).
- Тесты беты 3385/3385, typecheck 12 (как было), стенд беты на 127.0.0.1:5174.
- Не сделано: чип на строке отряда в списке (только в карточке); RU-имена способностей на чипах (английские).

## Доктрины из правил отряда (2026-10-18, ветка беты `feat/doctrine-rules` `50c93a61`, поверх `feat/once-per-battle`)
Вопрос владельца: зачтётся ли армейская доктрина в юните и что с правилами «повторно» и «доп. доктрина».
- Армейский выбор доходит до всех отрядов (SOFT_AUTO) — было и раньше; чип теперь «Выбор армии» (не переключатель).
- Повтор доктрины армией (Gladius, Brethren, Spearpoint, Blade of Ultramar, Forgefather) — уже в бюджете счётчика армии.
- Новое: `doctrineRules.js` читает фразы — все три всегда (Calgar, Guilliman, Logan), «in addition» всегда (Adept of
  the Codex, Tactical Insight, Student of the Codex, Dante, Wrath of Angels), Death Company (assault, остальные запрещены),
  временное «in addition» (Mephiston, Lion, Tome) — только лимит, Author of the Codex — лимит 2 всей армии.
- Гейт: каждая фраза «doctrine is active» в шести фракциях прочитана (красный на слепом читателе), читатель в proseReaders.
- Тесты беты 3392/3392, typecheck 12. Не сделано: в конструкторе (вне партии) доктрины из правил не читаются.

## 2026-10-19 — «делай всё»: шаги 4–5, отложенное, корень в генераторе
Ветка беты `feat/rule-choices-rest` от `7aeb81af` (worktree `~/Projects/wh11ed-tracker`), **не запушена, не слита в
`feat/tracker-side-cards`**. Коммиты по порядку:
- `1c745003` варианты стратагем: условие с флагом `onUse` (сначала `stratagem`) предлагается, только пока стратагема
  потрачена на отряд. 8 стратагем (Anathema Blademastery, Avowed Destruction, Mercy is Weakness, Relentless Assault ×2,
  Vindictive Artillerists, Hardened Killers — плюс потерянный вариант +1 Sv и dur `round`, Experimental Ammunition,
  Desperate Pledge).
- `add098c8` аура «выбранного отряда»: `selected: true` — доказывается только чипом ауры, не своим отрядом носителя;
  отряд, который ведёт носитель, тоже получает чип. Master of Mechanisms, Blessing of the Omnissiah, Forge’s Blessing,
  Bearer of the Evanescent Ion, приказ Move to the Shadows (Spec Ops Veteran).
- `2a6567b5` **корень класса «правило меняет число, записи нет»**: генератор читал только бандл Codex SM — шесть Codex
  Supplement без записей (и без моста `sourceIds`); шаблоны не видели `+2W`, `Sv`, знак U+2011, ключевое слово капсом
  без слова keyword. 25 + 66 записей разобраны руками. Гейты: у каждого детачмента на странице есть запись (красный на
  старых данных для 8), `isCandidate` читает четыре написания.
- `b01b881b` выборы-переключатели (Martial Mastery, Angelic Executioner, Cold and Calculating, Path of the Warrior,
  Bladeguard, Vows of Atonement, Tyrannical Motivation, Moment Shackle через `onUse` после применения раз за битву) +
  шаблон `+1 to hit rolls`: ещё 134 записи, 71 из них входящие модификаторы (пустые, как Armour of Contempt).
- `976e7117` **шаг 5, гейт** `src/composables/choiceRules.test.js`: правило с формулировкой выбора отслеживается или
  названо в `WHY` с причиной (лучшая строка по цели/состоянию, движение, бросок, ресурс, выбор в списке, цель/позиция);
  вторая половина — `never`, чей `when` звучит как выбор. На первом прогоне поймал ещё 5 (Supreme Combatant, Adaptable
  Fighters, Prelocational Optimiser, Smash ’Em Up, Backroom Deals ×3).
- `945d6b83` **шаг 4**: у чипа варианта своё «i» с абзацем варианта (`variantPassage.js`: `###`, пункт-маркер, имя
  отдельной строкой); 57 из 114 вариантов находят свой абзац, у остальных «i» всего правила на заголовке набора.
- `0a49e637`, `e1526d23`, `378f3f0e`, `b69a5a1a`: чипы «раз за битву» по-русски и с текстом правила, и на строке отряда в списке; доктрины из правил
  отряда в конструкторе (`rosterUnitCard.js`); «ниже стартовой/половины численности» — состояния в группе с «в полном
  составе»; «в отряде есть модель X» (`gear.mini`); плашки строки учитывают условия снаряжения, как карточка (расходились
  на Tidewall Shieldline); «можно использовать в этой фазе» и потраченные ресурсы — переключатели; Bondsman — аура на
  выбранного ARMIGER через новое поле эффекта `reach`; Eye of Spite и Pyrogenesis получили потерянную половину «вместо».

**Что осталось `never` и почему** — около 500 эффектов: цель (≈350), позиция/дальность (≈95), часть отряда/ключевое
слово (≈60), бросок/на атаку (≈20). Честные; новые выборы ловит гейт.

**Фикс генератора нужен и проду**: записи Supplement-детачментов и 200 пропущенных правил есть только в бете. Перенос на
`main` — отдельным релизом по команде (правка данных + `sourceIds.json` + генератор, без механизмов беты: в main нет
`op: 'state'`/`onUse`/`selected`, такие записи там надо будет писать как `never` или переносить механизмы).
