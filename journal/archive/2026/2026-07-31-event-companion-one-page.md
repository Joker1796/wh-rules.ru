> **Статус:** закрыт 2026-07-31
> **Репозитории:** wh11ed
> **Итог:** тот же приём, что и с кор-правилами, применён к Event Companion.
> **Связано:** [Кор-правила одной страницей](2026-07-31-core-rules-one-page.md)

# Event Companion одной страницей — бриф задачи

Продолжение задачи «кор-правила одной страницей» (см. `CORE-RULES-ONE-PAGE-TASK.md`,
влита в main PR #318): тот же приём применяется ко второму разделу сайта — **Event
Companion** (турнирные правила matched play). Семь роутов
(`/event-companion`, `/event-companion/sequence`, `/missions`, `/layouts`,
`/pairings`, `/teams`, `/faq`) сворачиваются в одну прокручиваемую страницу с оглавлением
вверху и плавающей кнопкой, открывающей то же оглавление в модалке.

**Важное отличие от Core Rules:** Event Companion — не единообразные пронумерованные
правила (`Section[]` с `subsections[].sectionNum`), а смесь **прозных страниц на
`RuleBlock`** (Introduction, Sequence, Pairings, Teams) и **самодельных виджетов**
(Missions — фильтры + карточки миссий, Layouts — интерактивная матрица 5×5 + просмотрщик
раскладок, FAQ — список вопрос/ответ). Готовый `composables/columnChunks.js` из задачи
Core Rules **не переиспользуется напрямую** — он рассчитан на `Section[]` с `sectionNum`, а
блоки Event Companion такого поля вообще не имеют (нужен новый, более простой хелпер).

---

## Утверждённые решения

| Вопрос | Решение |
|---|---|
| Раздел «Teams» | **Включить в объединённую страницу и показать в оглавлении** (сейчас сознательно скрыт из subnav/bottom-nav — виден только в мобильном drawer и по прямой ссылке). Раз всё объединяется в одну страницу, прятать один из семи разделов стало бы нелогичным исключением |
| Двухколоночная раскладка | **Только для прозных глав** (Introduction / Mission Sequence / Pairings & Rankings / Teams — они на `RuleBlock`). Missions / Terrain & Layouts / Errata & FAQs остаются во всю ширину — это самодельные виджеты (сетка миссий со своей masonry, интерактивная матрица + просмотрщик раскладок, список FAQ), которые не масштабируются как обычный текстовый блок |
| Ширина на десктопе | **1280px**, как у `/core-rules` — тот же класс-модификатор `.main-content--wide`, расширенный ещё и на `isEventRoute` |
| Старые URL | **Редирект на якорь** (тот же приём, что и в Core Rules) |
| Плавающая кнопка TOC | **Тот же механизм**, что на `/core-rules`: вклад в `MobileUtilityBar` на мобилке, FAB в существующей колонке на десктопе — новых сущностей не заводим, `MobileUtilityBar`/`useMobileActionBar.js` уже поддерживают несколько именованных вкладов |
| Производительность | **Всё сразу + `content-visibility`** — тот же приём, что и в Core Rules; данные Event Companion и так уже грузятся одним модулем (`eventCompanion.js` + `missions.js`), а не семью раздельными файлами, так что дробить нечего |
| URL страницы | **Переиспользуем `/event-companion`** (текущий путь Introduction) как путь объединённой страницы — в отличие от Core Rules, где для слияния заводился новый `/core-rules`, здесь у раздела уже есть короткий «корневой» путь, отдельный `/event-companion-full` или похожий заводить незачем (плюс не теряется SEO-история самого частого из семи URL) |

---

## Текущее состояние (карта)

**7 роутов** в [src/router/index.js:317-323](src/router/index.js#L317-L323):
`/event-companion` (`EventIntroView`), `/event-companion/sequence` (`EventSequenceView`),
`/event-companion/missions` (`EventMissionsView`), `/event-companion/layouts`
(`EventLayoutsView`), `/event-companion/pairings` (`EventPairingsView`),
`/event-companion/teams` (`EventTeamsView`), `/event-companion/faq` (`EventFaqView`).
Реестр анкоров — `eventGroups`/`eventGroupsRu`
([src/router/index.js:179-261](src/router/index.js#L179-L261)): у каждой группы уже свой
`path`, но **не `hash`** (в отличие от `navGroups`, где `hash` появился при слиянии Core
Rules) — то же самое понадобится и здесь.

**Семь вью — три разных «породы»:**

| Вью | Строк | На `RuleBlock`? | Особое |
|---|---|---|---|
| `EventIntroView` | 84 | Да (1 блок) | Aside с запиской переводчика; прячет собственный заголовок `RuleBlock` (у него уже есть hero) |
| `EventSequenceView` | 77 | Да (`blocks`/`secondary`/`designerNotes`, 3 массива) | Два `<h2 class="group-heading">`-разделителя между массивами; у части блоков `block.table` → `DataTable` рядом |
| `EventPairingsView` | 54 | Да (`blocks`) | Один блок обёрнут в `.event-flavor` (флейвор-цитата) |
| `EventTeamsView` | 56 | Да (`blocks`) | У части блоков `block.table` → `DataTable`, как в Sequence |
| `EventMissionsView` | 244 | **Нет** | Фильтр-бар (тип + диспозиция, оба в `localStorage`), группировка карточек `MissionCard` по диспозициям, `TwistCard`-сетка, своя masonry `.mcards{column-width:320px}` |
| `EventLayoutsView` | 590 (**самая тяжёлая**) | **Нет** | Таблица footprints, сворачиваемая легенда LAYOUTS KEY (`CollapseTransition`, `localStorage`), интерактивная `MissionMatrix` 5×5 + панель матчапа с вкладками A/B/C + `LayoutCard` (просмотрщик с зумом) |
| `EventFaqView` | 50 | **Нет** | Список `FaqItem`, эррата через `renderInline` |

Итого ≈1155 строк — заметно больше, чем в среднем весила глава Core Rules, почти всё в
Missions (244) и Layouts (590).

**Данные** — [src/data/eventCompanion.js](src/data/eventCompanion.js) (1641 строка): один
модуль `{ en, ru }`, **не массив `Section[]`**, а объект с разноформенными ключами
(`sequence.blocks/secondary/designerNotes`, `pairings.blocks`, `teams.blocks`,
`terrain.{intro,footprints,keyNote,legend[]}`, `dispositions[]`, `matchups[]` (генерируется
из литеральных данных `.map()`-ом при импорте), `glossary[]`, `twists.blocks`, `faq.items[]`
— без единого `id`). `getEventContent(locale)` мёржит EN/RU **рекурсивно по ключам**
(`mergeLocale`), а не `en[i]`/`ru[i]` по индексу, как в Core Rules. Все семь вью тянут
**один и тот же** `getEventContent()` и берут свой кусок — в этом смысле слияние данных уже
произошло раньше слияния страниц. Отдельно — `missions.js`/`missionsRu.js`
(`getMissions(locale)`, читает только `EventMissionsView`).

**Виджеты, которые не годятся под колонки:**

| Компонент | Где ещё используется |
|---|---|
| `MissionMatrix.vue` (177 строк) | Только в `EventLayoutsView` |
| `LayoutCard.vue` (217 строк) | **Да** — `GameSetup.vue` (визард трекера), пикеры раскладок трекера. Любые правки — не ломать эти вызовы |
| `MissionCard.vue` (212 строк) | **Да** — `GameSetup.vue`, `MissionPickerModal.vue`, `SecondaryPickerModal.vue`. **Не** используется в `ScoringModal.vue` трекера (тот дублирует похожую вёрстку независимо, вопреки формулировке в CLAUDE.md) |
| `TwistCard.vue` (78 строк) | Только в `EventMissionsView` |

**Кто знает про event-пути** (полный список мест правки):

- [src/App.vue:431-441](src/App.vue#L431-L441) `eventSubNavItems`
- [src/composables/useRefNavigation.js](src/composables/useRefNavigation.js) `EVENT_MAP` —
  `EC:<key>` токены в `seeAlso`-прозе (`eventCompanion.js`) и в hardcoded `introRefs`
  (`EventMissionsView.vue`)
- [src/composables/useSearch.js:300-378](src/composables/useSearch.js#L300-378)
  `indexEventCompanion` — 7 разных `route:` строк; **Teams вообще не индексируется** (ни
  одной строчки `ec.teams.*` в функции) — это отдельный, давно существующий пробел, не
  только следствие того, что раздел скрыт из subnav
- [src/composables/useSeoMeta.js:89-137](src/composables/useSeoMeta.js#L89-137) `ROUTES` —
  7 записей, включая `/event-companion/teams`
- [scripts/gen-seo-routes.mjs:32-38](scripts/gen-seo-routes.mjs#L32-38) `STATIC_ROUTES`
- [src/composables/useViewRestore.js:17](src/composables/useViewRestore.js#L17)
  `SECTION_SELECTOR` — покрывает `step-*`/`missions-*`/`pairing-*`/`ranking-*`, но **не**
  `team-*`/`teams-*` (кроме `pairing-system`, который случайно попадает под `pairing-*`) —
  фича «продолжить с того же места» в PWA уже сейчас не видит секции Teams; при переносе на
  общую страницу это станет заметнее и требует починки
- `PageNav` (prev/next по `eventGroups`) — после слияния листать станет некуда (симметрично
  тому, что случилось с Core Rules); скорее всего компонент целиком осиротеет — проверить,
  не тянет ли его что-то ещё (Combat Patrol?), и если нет — удалить
- `NavSidebar.vue` — `goToGroup`/`isActive`/`handleAnchorClick`/`groupKey` уже написаны
  универсально (принимают любую группу с `path`+`hash`+`sections`) для Core Rules, **кроме**
  одного места: `isActive()`'s фолбэк `route.hash || navGroups[0].hash` **захардкожен на
  `navGroups`** — на странице Event Companion без hash в URL он подставит первый якорь
  *Core Rules*, а не Event Companion. Нужно обобщить на `section.groups[0].hash`
- ссылки на `/event-companion` в `src/data/landing.js`/`rulesLanding.js` — **не потребуют
  правки**, раз путь переиспользуется как есть (в отличие от `/introduction` в задаче Core
  Rules, который менялся на `/core-rules` везде)

---

## Целевая архитектура

```
/event-companion  →  EventCompanionView.vue
                      ├── hero
                      ├── EventCompanionToc (вверху, как CoreRulesToc)
                      ├── <section class="event-chapter" id="ec-chapter-intro">     ChapterIntro
                      ├── <section class="event-chapter" id="ec-chapter-sequence">  ChapterSequence
                      ├── … missions / layouts / pairings / teams / faq
                      └── (PageNav не рендерим)

                 +  EventCompanionTocModal (BaseModal + тот же EventCompanionToc)
                 +  плавающая кнопка: MobileUtilityBar (≤900px) / FAB-колонка (≥901px)
```

Якоря — новые, отдельные от любых существующих content-id (`introduction` и т.п.), чтобы не
плодить коллизий:

| Глава | Якорь | Старый путь |
|---|---|---|
| Introduction | `ec-chapter-intro` | `/event-companion` (**остаётся живым путём**, не редиректом) |
| Mission Sequence | `ec-chapter-sequence` | `/event-companion/sequence` |
| Missions | `ec-chapter-missions` | `/event-companion/missions` |
| Terrain & Layouts | `ec-chapter-layouts` | `/event-companion/layouts` |
| Pairings & Rankings | `ec-chapter-pairings` | `/event-companion/pairings` |
| Teams | `ec-chapter-teams` | `/event-companion/teams` |
| Errata & FAQs | `ec-chapter-faq` | `/event-companion/faq` |

Внутри прозных глав (Introduction/Sequence/Pairings/Teams) — новый хелпер вместо
`columnChunks.js` (тот держится на `sub.sectionNum`, у блоков Event Companion такого поля
нет вообще):

```js
// src/composables/blockColumnChunks.js
// Блок "широкий", если после него идёт DataTable (block.table) — как wound/battleSize
// таблицы в Core Rules, только на уровне блока, а не главы.
export function chunkBlocks(blocks, isWide = (b) => !!b.table) { … }
```

`<h2 class="group-heading">`-разделители в Sequence (между `blocks`/`secondary`/
`designerNotes`) закрывают текущую колоночную группу — та же роль, что у `GroupLabelBlock` в
Battle Round. Группа из одного блока уже автоматически схлопывается в full-width (правило
перенесено из `columnChunks.js` как есть) — значит, Introduction (всего один `RuleBlock`) и
Pairings' одиночный `.event-flavor`-блок не потребуют отдельного кейса.

---

## План работ

### Фаза 0 — подготовка
1. Новая ветка (например `feat/event-companion-one-page`) от свежего `main` — задача Core
   Rules уже влита (PR #318), начинаем с чистого места.
2. Базовые метрики `npm run build` (Missions/Layouts — самые тяжёлые чанки среди семи, для
   сравнения после).
3. Сверить, нет ли в коде мест, которые проверяют `route.path === '/event-companion'` как
   признак именно Introduction (а не «объединённой страницы») — при переносе `/event-companion`
   станет путём всей объединённой страницы.

### Фаза 1 — главы как компоненты
`src/components/event/` (по аналогии с `src/components/core/`):
`ChapterIntro.vue`, `ChapterSequence.vue`, `ChapterMissions.vue`, `ChapterLayouts.vue`,
`ChapterPairings.vue`, `ChapterTeams.vue`, `ChapterFaq.vue`. Из каждой вью убрать
`.view`/`.view-hero`/`PageNav`, перенести логику и scoped-стили **дословно**. Спецблоки
(фильтры Missions, матрица+легенда Layouts, таблицы Sequence/Teams) переносятся без
изменений. Старые `src/views/event/*.vue` удалить.

### Фаза 2 — EventCompanionView
`src/views/EventCompanionView.vue`: hero, `<EventCompanionToc>`, семь
`<section class="event-chapter" :id="…">`, `content-visibility: auto` (тот же CSS, что и
`.core-chapter`, можно вынести оба в один общий класс, если он останется буквально
идентичным — проверить на месте, не плодить дубль ради дубля). `scrollToAnchor()` на mount/
`watch(route.hash)`, как в `CoreRulesView`.

### Фаза 3 — ширина и двухколоночная раскладка
1. `App.vue`: `.main-content--wide` — расширить условие на `isEventRoute` (он уже есть в
   `App.vue`, ничего заводить не нужно).
2. `blockColumnChunks.js` (см. выше) — использовать в `ChapterIntro`/`ChapterSequence`/
   `ChapterPairings`/`ChapterTeams`. CSS — тот же глобальный `.rule-columns` из
   `style.css`, никакого нового CSS-класса не требуется.
3. `ChapterMissions`/`ChapterLayouts`/`ChapterFaq` — **не оборачивать** в `.rule-columns`,
   рендерить как есть (их внутренняя раскладка — `.mcards` masonry и интерактивная матрица —
   уже сама себе typography).
4. Проверить глазами на 1024/1280/1440/1920: `.mcards{column-width:320px}` при 1280px
   контейнере сама добавит колонок карточкам миссий (это ожидаемо и хорошо, а не баг); матрица
   Layouts не должна потеряться в лишнем пустом пространстве по бокам — при необходимости
   дать ей свой `max-width` внутри широкого контейнера.

### Фаза 4 — оглавление и навигация
1. `src/components/event/EventCompanionToc.vue` — калька `CoreRulesToc.vue`: `variant:
   'page'|'modal'`, читает `eventGroups`/`eventGroupsRu` (после добавления им `hash`).
   Двухуровневого NN.MM-дриллдауна здесь не будет (у блоков нет такой нумерации) — просто
   глава → секция, как в компактном варианте Core Rules TOC.
2. `EventCompanionTocModal.vue` — калька `CoreRulesTocModal.vue` (`BaseModal`).
3. Плавающая кнопка — тот же `useContributeMobileActions('event-toc', …)` на мобилке (ключ
   иной, чем `'core-toc'`, конфликтов нет — активен всегда только один роут) и `.fab-btn` в
   той же позиции, что `.core-toc-fab`, на десктопе.
4. `App.vue` `eventSubNavItems` → `{ hash, label }`, плюс шестой пункт для Teams. Подсветка
   активной главы — по scroll-spy, **переиспользуя `useActiveSection.js` как есть** (он уже
   не завязан на Core Rules, просто принимает список id). Логику `isCoreChapterActive`/
   `goToCoreAnchor` либо продублировать в компактном виде под Event Companion, либо вынести
   в общий хелпер `subnavAnchorHelpers.js` — решить по месту, не блокирует старт.
5. `NavSidebar.vue` — **обязательная правка**: `isActive()`'s фолбэк `navGroups[0].hash` →
   `section.groups[0]?.hash` (иначе при заходе на `/event-companion` без hash подсветится
   первая глава Core Rules).
6. `PageNav.vue` — после слияния используется только в … нигде (если проверка Фазы 0
   подтвердит). Удалить вместе с оставшимся импортом `eventGroups`/`eventGroupsRu` там, где
   он был только ради него.

### Фаза 5 — роутинг и редиректы
```js
export const EVENT_PATH = '/event-companion'
export const EVENT_CHAPTER_ANCHORS = {
  '/event-companion/sequence': 'ec-chapter-sequence',
  '/event-companion/missions': 'ec-chapter-missions',
  '/event-companion/layouts':  'ec-chapter-layouts',
  '/event-companion/pairings': 'ec-chapter-pairings',
  '/event-companion/teams':    'ec-chapter-teams',
  '/event-companion/faq':      'ec-chapter-faq',
}
```
`/event-companion` сам становится роутом `EventCompanionView` (не редиректом — это уже путь
объединённой страницы), остальные шесть — редиректы на якорь, как `CORE_CHAPTER_ANCHORS`.
`useRefNavigation.js`: `EVENT_MAP` заменить на анкор-реестр — `EC:<key>` без явного `#anchor`
должен резолвиться на анкор соответствующей главы (сейчас без явного анкора он вёл на верх
страницы, что было ок, пока страница = глава; теперь без анкора он приземлится на верх ВСЕЙ
объединённой страницы — регрессия для `EC:sequence`/`EC:missions`/… без `#anchor`, которых
в прозе большинство).

### Фаза 6 — смежные системы
1. `useSearch.js`: `indexEventCompanion` — один `EVENT_ROUTE` вместо семи строк-путей;
   заодно **добавить индексацию Teams** (`ec.teams.blocks`) — её никогда не было, отдельный
   баг, but заодно.
2. `useSeoMeta.js`: одна запись `/event-companion` вместо семи, описание вбирает ключевики
   всех шести остальных глав (по образцу `/core-rules`).
3. `scripts/gen-seo-routes.mjs`: `STATIC_ROUTES` — шесть путей убрать, `/event-companion`
   остаётся.
4. `useViewRestore.js`: `SECTION_SELECTOR` — добавить `[id^="team"]` (покрывает
   `team-composition`/`team-scoring-bp`/`teams-pairing`; `pairing-system` уже покрыт
   случайно через `[id^="pairing-"]`, но лучше не полагаться на совпадение).
5. `src/i18n/ui.js`: `subNavEventTeams` — сейчас мёртвый ключ (RU-перевод не проверялся,
   раз нигде не рендерился) — проверить/поправить текст, он становится реально видимым.

### Фаза 7 — тесты и проверки
1. Обновить `useSearch.test.js`/`useSeoMeta.test.js` под новые пути (по образцу правок из
   задачи Core Rules).
2. Новые тесты: резолв шести редиректов на нужный якорь (аналог `coreRedirects.test.js`);
   `EC:` токены без явного анкора резолвятся на анкор своей главы.
3. `npm test`, `npm run build` — сравнить вес чанков с базовыми метриками Фазы 0.
4. Ручная проверка (телефон + десктоп 1024/1280/1440/1920):
   - все 6 старых URL → нужная глава; `/event-companion` без hash → верх страницы;
   - фильтры Missions (тип + диспозиция) и их `localStorage` работают как раньше на общей
     странице;
   - легенда LAYOUTS KEY (свёрнута по умолчанию), матрица → выбор матчапа → `LayoutCard` с
     зумом — всё работает внутри `content-visibility`-секции, включая повторное открытие
     после скролла мимо и обратно;
   - Teams теперь виден в TOC/модалке/subnav/поиске;
   - `EC:` кросс-ссылки из прозы (`Mission Sequence EC:sequence` и т.п.) приземляются на
     нужную главу;
   - resume-фича PWA подхватывает якоря Teams (`useViewRestore` из Фазы 6.4);
   - плавающая кнопка не конфликтует с back-to-top/resume на этой странице;
   - колонки — только у 4 прозных глав, `.mcards`/матрица/FAQ не пострадали, группа из
     одного блока (Introduction, флейвор-блок Pairings) не превратилась в узкую колонку с
     пустотой рядом.

### Фаза 8 — деплой
`npm run deploy` с чистого `main`. Проверить: 6 старых URL редиректят; `sitemap.xml`
содержит `/event-companion` и не содержит шести остальных.

---

## Инварианты — не сломать

Те же, что в задаче Core Rules (см. `CORE-RULES-ONE-PAGE-TASK.md`): данные `src/data/*.js`
не трогаем, PWA `globPatterns` не трогаем, `BaseModal` без body scroll-lock и без своего
шелла, длительности анимаций — только `--motion-*` токены, линтера нет.

Дополнительно для этой задачи: **`LayoutCard.vue`/`MissionCard.vue` используются трекером**
(`GameSetup.vue`, пикеры) — любые правки в них ради Event Companion не должны менять их
поведение/пропсы для трекера.

## Риски

| Риск | Митигация |
|---|---|
| Новый `blockColumnChunks.js` дублирует логику `columnChunks.js` | Оба хелпера маленькие и решают разные формы данных (`sectionNum` vs плоский `{id,title,body,table}`) — дублирование осознанное, не абстрагировать преждевременно |
| `EC:` токен без явного `#anchor` ведёт на верх страницы вместо своей главы | Явно предусмотрено в Фазе 5 — анкор-реестр по умолчанию, а не `null` |
| `NavSidebar`'s `navGroups[0].hash`-фолбэк подсвечивает не ту главу на `/event-companion` | Обязательный пункт Фазы 4.5, не опция |
| `EventLayoutsView`'s стейтфул-виджет (выбранный матчап, открытая легенda) плохо переживёт `content-visibility` при скролле мимо и обратно | Vue-состояние не зависит от `content-visibility` (это только layout/paint), но проверить на реальном скролле — самый сложный виджет из всех перенесённых |
| Расширение до 1280px растягивает `.mcards`/матрицу непредсказуемо | Смотрим глазами в Фазе 3.4; при необходимости — `max-width` внутри контейнера у конкретного виджета |
| `useViewRestore` резюме не видит Teams-секции | Фаза 6.4 — `SECTION_SELECTOR` расширяется явно, не полагаемся на случайное совпадение `pairing-*` |
| Teams давно не индексировался поиском — можно забыть при переносе | Явно вынесено отдельным пунктом Фазы 6.1 |

## Открытые вопросы (решить по ходу, не блокируют старт)

1. `.event-flavor`-блок в Pairings — оставить колоночно-пригодным как обычный блок, или
   всегда full-width (это флейвор-цитата, возможно свёрстана шире обычного текста)? Смотреть
   глазами.
2. Брейкпоинт/gap колонок для Event Companion — переиспользовать 1024px/1.5rem от Core
   Rules, или у более коротких прозных глав удобнее другое значение? Подобрать глазами.
3. Выносить ли `isCoreChapterActive`/`goToCoreAnchor` и их будущие Event-аналоги в общий
   хелпер, или оставить два маленьких параллельных куска в `App.vue`? Не блокирует, решить
   по месту при написании Фазы 4.
4. `PageNav.vue` — подтвердить, что после слияния у него не осталось ни одного потребителя
   (проверить Combat Patrol и всё остальное), и удалить, если так.
