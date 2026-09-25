> **Статус:** приостановлен
> **Репозитории:** wh11ed
> **Начато:** 2026-09-25
> **Ждём:** владелец выбирает, с каких пунктов начать (моё предложение — баги А и Б, затем п. 2)

# Аудит Vue-компонентов: дубли и что вынести в общее

Прошли все 168 `.vue` (три агента по областям: модалки/пикеры/тосты; конструктор и трекер;
правила, навигация, вьюхи). Кода не меняли. `npm run dupes` чистый — но он ловит правило CSS,
скопированное в **3+** компонента, а почти все находки ниже — пары, поэтому гейт их не видел.
Номера строк — на состояние `main` после v2.7.1 (e578f1d); перед правкой пересверить.

## Баги, найденные по расхождению копий

- **А. Десктопная панель конструктора: зелёная галочка при предупреждениях.** Значок проблем
  нарисован трижды; мастер (`RosterCreateView.vue:353`) и редактор (`RosterEditorView.vue:329`)
  знают жёлтое `warn`, а `RosterSettingsBar.vue:141` — только `errorCount ? 'has-err' : 'ok'` (проп
  один, `errorCount`). Список без Force Disposition на столе ≥1200px выглядит чистым. Проверено
  по коду. Лечится п. 5.
- **Б. Мастер не снимает улучшения при снятии детачмента.** Редактор зовёт
  `dropOrphanEnhancements()` (`RosterEditorView.vue:599, 605, 616`), мастер — нет
  (`RosterCreateView.vue:564–570`). Юнит остаётся с улучшением, которое ничему не принадлежит.
  Найдено чтением, в браузере не воспроизведено — воспроизвести первым делом. Лечится п. 1.

## Кандидаты, по ценности

1. **`useRosterBuildActions`** — мастер (`RosterCreateView.vue` 549–630) и редактор
   (`RosterEditorView.vue` 575–676) каждый определяют `pickFaction`, `detachmentOptions`,
   `detachmentSummary`, `dispositionCands`, `dpSpent`, `toggleDetachment`, `clearDetachments`,
   `removeEntry`, `duplicateEntry`, `toggleOpen`, `openEntry`, `toggleWarlord`, `battleSizes`.
   Пути записи разные (`syncUnits` vs `touch`) — передавать колбэком. ~70 строк, риск низкий.
2. **Шапка модалки в `BaseModal`.** 8 диалогов рисуют `<header class="modal-head">` через `#header`
   руками: `tracker/SecondaryPickerModal`, `ArmyMultiPickerModal`, `DetachmentPickerModal`,
   `ArmySpendModal`, `ScoringModal`, `GameSummaryModal`, `RosterPickerModal`,
   `roster/EnhancementRuleModal`. **У всех нет доступного имени**: `BaseModal.vue:25` ставит
   `aria-labelledby` только при пропе `title`, а у их `<h3>` нет id (проверено). Предложение:
   проп `subtitle` + слот `#aside` в `.mh-right` перед крестиком; три счётчика `.mh-count` /
   `.pick-count` / `.dp-modal-count` → один глобальный `.mh-count` с `.full`/`.over`. ~110 строк.
   Сверить четыре диалога, которые переопределяют `.modal-head` под двухстрочный заголовок
   (src/components/CLAUDE.md).
3. **Одна оболочка для `CoreRulesView` и `EventCompanionView`** — расходятся на 94 строки из ~360:
   `spyIds`, `useActiveSection`, `goToAnchor`/`onModalSelect`, FAB, `content-visibility` совпадают;
   отличие — `filter` у Core (`useAbilityFilter`). Шелл или `useOnePageChapters(...)`. ~250 строк.
   Держать одну корневую ноду, ключи мобильных действий `core-toc`/`event-toc` разные.
4. **`ChapterToc` + `ChapterTocModal`** — `core/CoreRulesToc.vue` и `event/EventCompanionToc.vue`
   после переименования префикса расходятся на 123 строки; у Core лишь `sectionNum()`, третий
   уровень `NN.MM` (`useCoreRulesSubsections`, только в модалке) и `filter`. Уже разошлись: у Event
   `min-height: 24px` на `.event-toc-chapter` (a11y), у Core нет. Модалки отличаются `max-width`
   (58rem / 46rem). ~200 строк, риск средний (трёхуровневая вёрстка модалки Core — снять снимки).
5. **`RosterPointsTally`** — очки + значок проблем: `RosterCreateView` 341–370, `RosterEditorView`
   316–346, `RosterSettingsBar` 127–153. Чинит баг А. Комментарий в `RosterCreateView` ~878 («copied,
   not shared, scoped styles…») устарел — CSS уже глобальный. ~50 строк.
6. **`FactionOption`** — строка фракции в `FactionsNavModal.vue` (7–68, 105–137) и
   `tracker/FactionPickerModal.vue` (7–65, 116–150); `.fp-group` побайтно одинаков. Модалки оставить
   раздельными (ссылка vs `pick`, состояние «скоро», `.on` + ✓, разные источники данных), общая —
   только строка, как у `DetachmentOption`. ~90 строк. Шире (`FactionGroupedList` на
   `FactionsListView`/`CombatPatrolIndexView` тоже) — сомнительно, по 20–30 строк на копию.
7. **`RosterGroupHead` + `groupLabel(g, labels)`** — заголовок группы и шапка блока:
   `RosterUnitList.vue` 29–39, 351–377 vs `RosterViewView.vue` 224–233, 1666–1690 (CSS скопирован с
   комментариями); выражение `g.ally ? g.ally.name : labels[GROUP_LABEL_KEYS[g.id]]` ещё в
   `RosterUnitBrowser.vue:318`, `RosterPrintSheet.vue:231`. ~45 строк.
8. **`TopBanner`** — `UpdateNoticeBar.vue` 44–81 и `DomainMoveBanner.vue` 88–125, стили
   идентичны до префикса. Логика показа/закрытия остаётся у каждого. ~50 строк.
9. **Загрузка данных фракции** — `loadRosterFaction(...)`-вотчер в View, Print, Create (522),
   `useRosterEditing` (37); `loadRosterFactionRules` в `RosterViewView` 742–745, 1398–1406 **без**
   проверки устаревшего ответа, в `RosterPrintView` 209–222 — с ней. `useRosterFactionData` /
   `useRosterFactionRules` с гардом. ~30 строк.
10. **`sideName(pl, i, labels)`** в `useTracker.js` — «Вы / Соперник» в 9 местах: ScoreBoard:10,
    ScoreBreakdown:26, RoundTracker:387, ArmyRuleSummary:113, PhaseRules:242, PartyModal:231,
    TrackerHomeView:431, TrackerHistoryView:79, EditSetupModal:322; HistoryView и HomeView
    считают иначе. ~15 строк.

## Мелочи

- Сетка карточек `LandingView` (21–37, 98–147) = `RulesLandingView` → `SectionCardGrid`; брейкпойнты
  600 vs 640px — выбрать один. ~60 строк.
- `useDatasheetParts` в `datasheetParts.js`: `DatasheetCard` 1120–1162, 1228–1250 и `RosterPrintCard`
  309–360 повторяют `markSet`, `coreParts`, `keywordGroups`, `rangedRows`/`meleeRows`,
  `noteSections` (уже разошёлся: `hidePossible` vs `showPossible`). Раздельная типографика
  остаётся. ~30 строк.
- `GameSetup` vs `EditSetupModal`: логика выбора раскладки и строка прикреплённого ростера
  (EditSetupModal 458–482) → `useSetupLayout` + `AttachedRosterLine`. `pickRoster` различается
  намеренно. ~50 строк.
- CSS акцента фракции (`.themed` + `:root[data-theme]`) одинаков в Create 888–901, Editor 889–902,
  View 1895–1908 и `FactionAccentScope` → глобальный класс. roster/CLAUDE.md «Shared derivations»
  оставляет это scoped-стилю экрана — причина выглядит устаревшей, решать владельцу.
- `.rvst-box` (View 1767–1790) — уменьшенная копия `.ds-stat-box` → глобальный `.stat-plate`.
- `.hdr-icon` в `RosterEditorView` 716–732 и `RosterViewView` 1560–1577.
- `.tp-actions` в `MissionPickerModal` и `TwistPickerModal` → глобальный `.picker-actions`.
- `AppSubnav.vue` 99–133: `coreSubNavItems`/`eventSubNavItems` — один computed; вместе с п. 3–4
  вынести `localizedGroups(en, ru)` (`locale === 'ru' ? xRu : x` в 6 файлах).
- `RosterUndoBar` повторяет `AppToast` с кнопкой; но у него своя полоса во всю ширину и свой ярус
  над `MobileUtilityBar` — делать только если появится второй тост с действием.

## Ждёт решения владельца

- **Поля настроек ростера нарисованы трижды и разошлись**: мастер, шаг 1 (`RosterCreateView`
  103–241, `.field`/`.seg`: есть счётчик DP и «?» при превышении, нет заметок), вкладка настроек
  редактора (`RosterEditorView` 97–225, плитки `.choice`: есть заметки, нет DP), десктопная панель
  `RosterSettingsBar`. `RosterSetupFields` сэкономит ~120 строк, но сначала — какой набор полей и
  какой вид правильные.

## Проверено и не кандидат

Печатная карточка отдельно от экранной (roster/CLAUDE.md «Printing a list»); два пикера
детачментов (одиночный vs бюджет DP — общая только строка); `SearchModal` мимо `BaseModal`
(палитра команд); `OptionHelpModal`/`ScoreHelpModal`; `ChapterDoubles`/`Pairings`/`Teams`
(event/CLAUDE.md, тесты монтируют по имени); Links/Support/Disclaimer (общий только `.hero`,
разрешён); два `ChapterIntro`; навбар/сайдбар/нижняя навигация (разные структуры, данные уже
общие из router); строки `RosterViewView` vs `RosterUnitRow`; `UpdateToast` (без UI). Все
`*Modal.vue` уже на `BaseModal`.

## Заметки к исполнению

- Каждое слияние — отдельный коммит, с тестами и снимками вёрстки (reference_playwright_screens
  в памяти: RU, 320–414px, после `document.fonts.ready`).
- После п. 3–4 поправить комментарий EventCompanionToc «Mirrors CoreRulesToc.vue's identical
  exclusion» и строку event/CLAUDE.md про «calqued on CoreRulesToc».
- Баги А и Б — пункты чейнджлога ближайшего релиза (скил `changelog-entry`).
