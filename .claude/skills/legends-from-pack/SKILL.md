---
name: legends-from-pack
description: Завести датащиты Warhammer Legends фракции из PDF Faction Pack'а (appdata несёт Legends только у орков) — текст из PDF, очки из веб-MFM, гейты, EN сначала, RU отдельным проходом. Использовать на «добавь Legends для <фракции>», «датащиты из фекшн-пака», «Legends из PDF».
---

# Legends из Faction Pack'а

**Зачем это существует.** `wh40k-appdata` (дамп приложения GW) содержит Legends только у орков —
одна публикация `isLegends`. У остальных фракций датащиты Legends напечатаны **только в PDF
Faction Pack'а** (раздел «Legends Datasheets», страницы — в оглавлении на первой странице). Это
второй источник правды рядом с appdata, поэтому у каждой такой записи есть маркер, и день, когда
appdata её догонит, обрабатывается явно (см. §7).

**Что получается.** Датащит на странице фракции (с бейджем Legends и чекбоксом «Скрыть Legends»),
в глобальном поиске, в индексе фаз, с очками из MFM — **и в конструкторе ростеров** (с 2026-09-19):
`npm run roster:data` читает `composition`/`loadout`/`options` записи с `source: "faction-pack"`
(`wh11ed/scripts/lib/pack-roster.mjs`, раздел «The Faction Pack Legends» в
`wh11ed/src/components/roster/CLAUDE.md`). Чтение fail-closed: всё, что не распарсилось, генератор
печатает под заголовком «Faction Pack Legends» — читать после каждого нового листа, новая
формулировка = новый шаблон в `parseOption`, а не заметка.

Пилот: Dark Angels, 3 датащита (журнал `journal/active/2026-09-18-legends-from-pack.md`).

## 0. Что нужно

- PDF пака в `sources/Faction pack 11 ed/<группа>/` (можно качать с warhammer-community, см. `sources/README.md`).
- `pdftotext` (poppler) — тот же, что у гейта компаньонов.
- Свежий MFM с Legends: `python3 scripts/scrape-mfm.py` (cookie `isLegendsDisplayed=true` уже в
  скрипте; секция `legends: [...]` в `src/data/mfm/<slug>.js`).

## 1. Список работы

```bash
cd wh11ed && npm run sync:mfm          # хвост отчёта: «Legends unit(s) priced by MFM with no datasheet here»
```

Это имена, которым MFM даёт цену, а у нас нет датащита — по фракциям. Сверить с оглавлением PDF:
в паке может быть лист, которого нет в MFM (тогда очков не будет — записать `points: []` и сказать
об этом в журнале), и наоборот.

## 2. Текст из PDF — двумя способами

```bash
f="sources/Faction pack 11 ed/<группа>/<файл>.pdf"
pdftotext -layout -f <A> -l <B> "$f" <scratch>/<slug>-legends-layout.txt   # таблицы: профиль, оружие
pdftotext         -f <A> -l <B> "$f" <scratch>/<slug>-legends-flow.txt     # порядок чтения: абилки, лор, опции
```

`-layout` держит колонки таблиц, но рвёт абзацы абилок между колонками; обычный режим наоборот.
Каждый датащит — две страницы: правила (профиль, оружие, абилки, keywords) и лор + опции + состав
+ Leader. Гриф «WARHAMMER LEGENDS» в шапке страницы — граница между листами.

## 3. Авторинг записей

Файл `<scratch>/<slug>-legends.json` (любой временный каталог вне репозитория) — массив записей в форме `src/data/datasheets/<slug>.js`
(образец — любая соседняя запись; шаблон ниже). Правила, на которых ловятся ошибки:

- **`id`** — kebab-case от имени; у Chapter-файлов (DA/BA/BT/DW/SW) нельзя занять id из
  `sharedUnitIds` — скрипт вставки это проверяет.
- **Keywords в прозе абилок — ALL CAPS** («friendly ADEPTUS ASTARTES MOUNTED units»); в PDF они
  капителью и в тексте выглядят как обычные слова. Названия core-способностей — обычным текстом
  («has the Lone Operative ability»), оружейные — в скобках `[LETHAL HITS]`. Никаких `**`, кроме
  `**Designer’s Note:**`.
- **Оружие:** теги — массив ALL CAPS (`"SUSTAINED HITS 1"`, `"ANTI-VEHICLE 3+"`), профили одного
  оружия — отдельные строки `"Plasma cannon – standard"` / `"… – supercharge"` (тире `–`), у
  огнемётов `"bs": "N/A"`.
- **`loadout`:** `**The X is equipped with:** a; b.` — абзацы через `\n\n`.
- **`options`:** одна строка на пункт; подпункты `\n▪ 1 assault cannon`; сноска `*` — в той же
  строке после `\n`.
- **Leader и Support** — одна и та же форма `leader: { text, units[] }`; `core` включает
  `"Support"`. Список может называть юнит, которого у нас нет (Relic Terminator Squad) — это
  нормально.
- **`rules`** — для рамочных правил вроде ATTACHED UNIT (имя капсом, как в PDF).
- **Нет:** `baseSize` (в PDF его нет), картинок.
- **`points: []`** — заполнит `sync:mfm --write`.
- **Маркер:** `"legends": true, "source": "faction-pack", "sourceVersion": "<версия пака>"`.

```json
{
  "id": "…", "name": "…", "points": [], "flavor": "…",
  "profiles": [{ "name": "…", "m": "6\"", "t": "4", "sv": "3+", "w": "2", "ld": "6+", "oc": "1", "inv": "5+" }],
  "ranged": [{ "name": "…", "tags": ["…"], "range": "24\"", "a": "2", "bs": "3+", "s": "4", "ap": "0", "d": "1" }],
  "melee":  [{ "name": "…", "tags": [], "a": "3", "ws": "3+", "s": "4", "ap": "0", "d": "1" }],
  "core": "Deep Strike", "faction": "Oath of Moment",
  "abilities": [{ "name": "…", "text": "…" }], "wargearAbilities": [], "rules": [],
  "composition": ["1 …"], "loadout": "**This model is equipped with:** …", "options": ["…"],
  "leader": { "text": "This model can be attached to the following units:", "units": ["…"] },
  "keywords": ["Infantry", "Character", "…"], "factionKeywords": ["Adeptus Astartes", "…"],
  "legends": true, "source": "faction-pack", "sourceVersion": "1.2"
}
```

**Space Marines:** часть профилей оружия вынесена на «Adeptus Astartes Legends Armoury card» —
это отдельный PDF/страница, без неё оружейные строки не собрать; сначала найти её.

## 4. Вставка, очки, индексы

```bash
node scripts/add-datasheets.mjs <slug> <scratch>/<slug>-legends.json  # валидирует, вставляет по алфавиту id
node scripts/sync-mfm-points.mjs --write                              # points из секции legends MFM
npm run datasheets:index && npm run phases:index                      # поиск и индекс фаз
npm run roster:data                                                   # ростер: лист попадает в конструктор; читать отчёт «Faction Pack Legends»
npm run roster:texts-ru                                               # RU для новых формулировок опций (fail-open, % покрытия в отчёте)
```

## 5. Гейты

Скил `data-gates`. Что здесь важно:

- `npm run wtags` — тег на оружии без текста: добавить `wargearAbilities`/`rules` на сам датащит.
- `npm run sync` — записи с `source: 'faction-pack'` **не** считаются «extra in wh11ed»; строка
  `⟲ … is now in appdata — retire the faction-pack copy` — сигнал §7.
- `npx vitest run src/data/datasheets` — тест покрытия RU **ждёт** pack-записи без RU-оверлея
  (печатает их число), а с оверлеем требует полного перевода.
- `npm run build`.

## 6. RU — отдельным проходом

Скил `ru-translate`: записи в `src/data/datasheets/ru/<slug>.js` по `id` (абилки — по EN-имени,
`abilityNamesRu` для заголовков). Появление записи в оверлее переводит лист из «ожидает» в «под
гейтом». До этого RU-локаль показывает EN — по решению 2026-09-18.

## 7. Когда appdata догонит

`npm run sync` напечатает `⟲ … is now in appdata`. Тогда: запись из пака **удалить**, лист
приходит обычным путём appdata (`legends: true` без `source`), RU-оверлей остаётся и сверяется
парити. Appdata — источник правды, пак был подменой.

## 8. Закрыть

Запись в `changelog.js` (по именам юнитов), журнал в хабе, коммит `data(<slug>): Legends from
the Faction Pack v<версия> — <юниты>`.
