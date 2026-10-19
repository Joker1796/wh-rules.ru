> **Статус:** закрыт 2026-10-19
> **Итог:** выдачи из текста детачментов — TEXT_GRANTS в gen-conditional-keywords (wh11ed `release/2.9.8`), список KNOWN пуст
> **Репозитории:** wh11ed
> **Начато:** 2026-10-15

# Ключевые слова, которые выдаёт текст детачмента

Остаток класса «правило детачмента видно не тем юнитам» (баг Battlewagon, 2026-10-15, wh11ed
`4606c3bc` в `release/2.9.3`). 6 правил называют цель ключевым словом, которое вводит сам текст
детачмента, а appdata выдачи не записывает (нет в `conditional_keyword` → нет в
`src/data/conditionalKeywords.json`):

- AdMech, Cohort Acquisitus — **Recon Augury** («Friendly Pteraxii / Infiltrators / Rangers /
  Serberys Raiders / Serberys Sulphurhounds units have Recon Augury») → Repolarised Augurs.
- AM, Armoured Infantry — **Armoured Skirmisher** («see Keywords») → Omnissian Unguents,
  Supporting Ordnance.
- CSM, Cult of the Arkifane — **Soul Forge** → Soul-Tally Offerings, Balefire Boon, Unholy Fortitude.

Сейчас они проходят «escape 3» и видны на всех карточках — так лучше, чем спрятать их от тех, к
кому они относятся. Починка — завести эти выдачи (как conditionalKeywords, только из текста
детачмента) и убрать строки из `KNOWN` в `src/composables/ruleTargets.class.test.js`; тест
упадёт на любом новом таком правиле.
