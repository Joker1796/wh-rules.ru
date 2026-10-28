> **Статус:** активен
> **Репозитории:** wh11ed
> **Начато:** 2026-09-20
> **Ветки:** `feat/dominatus` в wh11ed и wh11ed-api (не сливать без просмотра владельца).

# Колода Dominatus — что это и где её текст

Вопрос владельца 2026-09-20: «существует некая колода Доминус для нарративных игр, найди полную
информацию». Раньше решение было «Dominatus не делаем — GW содержимого колоды не публикует»
(память `project_event_companion_gates`). Разобрались подробнее.

## Что это

«Dominatus – Narrative Campaign Deck» (Armageddon). Карточная нарративная кампания 11-й
редакции на выходные: 2–3 альянса (Liberators / Oppressors / опционально Raiders), 5 партий в
трёх фазах (2 + 2 + 1 решающая), 2000 очков. В стартовом боксе *Armageddon*; отдельно с
2026-06-27, ~$35. 89 карт: 27 Agenda, 9 Agenda Achieved, 9 Briefing, 9 Location, 35 Upgrade
(11 Battle Honour, 10 Battle Skill, 15 Relic — по 5 на альянс) + буклет 12 стр. Нужны ещё Core
Rules и колода Chapter Approved (миссии, вторички, Force Disposition берутся оттуда).

Механика фазы: Location (бросок или выбор Warmaster'а) даёт war zone rules на все бои фазы и
бонус удержавшему альянсу; Briefing (одна на фазу на альянс) — матрица «моя диспозиция ×
диспозиция противника → Agenda»; Agenda заменяет Primary Mission, выполнена → Agenda Achieved;
конец фазы: Take Control → Ascendancy → Acquire Relics → Narrative Outcome → Discard. Победитель
боя тянет Battle Honour, проигравший — Battle Skill; до 3 апгрейдов на армию, по одному на юнит.

## Где текст

- **appdata:** колоды НЕТ. Есть только «Dominatus Event Companion» (rule_section
  `2019276a-994c-4be9-8ed0-3a0f43b7304e`, два контейнера — Event Guidance и Event Mission
  Sequence) — тот же текст, что PDF в `sources/eng_22-07_…dominatus_event_companion….pdf`
  (v1.1; лежит и 12-06, разница — абзац Generating Command Points).
- **GW / обзоры** (Warhammer Community, Spikey Bits, Sprues & Brews, BoLS, Frontline): только
  состав и общая механика, текстов карт нет. warhammer.com и Chaos Cards отдают 403.
- **Wahapedia** — полная расшифровка колоды, ~18 500 слов:
  https://wahapedia.ru/wh40k11ed/the-rules/dominatus/ — правила кампании, 9 Location с
  бонусами и war zone rules, Briefing с матрицами и Outcome по Narrative Points, 27 Agenda
  (условия + своя Primary Mission с VP-триггерами), все Upgrade и Relic (WHO / EFFECT).
  Единственный полный источник, и он фанатский: если делать по нему — сверять не с чем, кроме
  физической колоды. Скана GW в открытом доступе нет, пиратские сливы не ищем.

## Если решим делать

Объём сопоставим с Event Companion (~18k слов EN + перевод). Естественное место — глава рядом
с Event Companion / Doubles (см. `journal/archive/2026/2026-09-16-doubles-chapter.md` как
образец «дельта вместо пересказа»). Прежде чем начинать: решить про источник и про то, нужен
ли трекеру Dominatus-режим (Agenda вместо primary, апгрейды на юнитах) или достаточно справочника.

## 2026-10-28 — у владельца физическая колода: буклет правил
Фото буклета (7 снимков, обложка + 6 разворотов) — `sources/dominatus/rules/`. Это первоисточник для
**правил кампании** (буклета); тексты самих карт (Location, Briefing, Agenda, Upgrade) на фото нет.
Сверка с тем, что записано выше:
- Upgrade 35 = **11 Battle Honour + 9 Battle Skill + 15 Relic** (выше ошибочно «10 Battle Skill»).
  Honour по фазам 5 / 5 / 1 (фаза 3 — Path to Conquest победителю). Relic — 5 уникальных на альянс.
- Расписание по умолчанию: фазы First Encounters / Pitched Battles / Final Mission — 2 / 2 / 1 бой,
  все Strike Force (буклет не пишет очки). Альянсы: Oppressors и Liberators обязательны, Raiders — опция.
- Старт фазы: Warmaster бросает D6 и выбирает одну из Location этой фазы (по 3 на фазу), игроки
  читают Briefing и собирают свои Agenda (по 3 на фазу на альянс, 9 всего).
- Determine Mission: war zone rules локации на бой; если оба берут Agenda — Primary из колоды CA не
  используется, после Force Disposition по таблице Briefing выходит Agenda с её Primary. Отказ
  (Declining Agendas): Primary из колоды CA, очки по ней набирает только отказавшийся.
- Declare Battle Formations: до 3 Upgrade на армию, каждый своему юниту, на юните не больше одного.
- Determine Victor: выполненная Agenda → Agenda Achieved (держать не больше 3); фазы 1–2 —
  победитель тянет Battle Honour, проигравший Battle Skill (ничья — оба Skill); с ≥1 Agenda Achieved
  тянут 2 и оставляют 1. Дубликатов Upgrade не бывает, полученные остаются навсегда.
- Конец фазы: I Take Control (больше Battle Honour за фазу → локация и её бонус до конца кампании;
  ничья — Honour за всю кампанию, дальше Warmaster), II Ascendancy (больше Agenda Achieved, ничья —
  все), III Relics (фазы 1–2: тянуть столько, сколько Agenda Achieved, оставить 1), IV Narrative
  Outcome (обратная сторона Briefing по Narrative Points), V Discard Agenda Achieved прошлых фаз.
- Modifying Dominatus: Warmaster свободно меняет правила (длиннее кампания, рост размера армий, смена
  фракции/альянса).
Решение «делать ли» по-прежнему за владельцем; для текстов карт канон — сама колода (фото карт).

## 2026-10-28 — фото карт, первая партия
`sources/dominatus/1/` — 2 фото по 9 карт: все 9 Briefing (лицо) и 9 Outcome (оборот). Фото сжаты до
1920×1446 (скорее всего мессенджером). Проба: вырезка одной карты (`sips -c` + `-Z`) читается целиком,
включая курсив Outcome; на Briefing названия Agenda и матрица диспозиций читаемы (значки различаются
цветом/формой — сопоставить с Force Disposition колоды CA). Для текстоёмких Agenda (27), Upgrade (35),
Location (9) такого качества мало: попросил оригиналы файлом, 4–6 карт на кадр, обе стороны.
**Ждём:** решения владельца — расшифровывать эти 18 сейчас или после остальных фото.

## 2026-10-28 — вся колода расшифрована
Владелец доснял все карты (`sources/dominatus/1/`–`5/`, 36 фото). Расшифровка — Vision OCR по
вырезке каждой карты (`sips`/Swift, без внешних сервисов), каждая сверена с фото глазами:
`sources/dominatus/DOMINATUS-RULES.md` (~9,4k слов, только правила, флейвор и тексты Outcome не
переносились). Все 89 карт на месте: 27 Agenda (обе стороны), 9 Briefing (матрицы прочитаны
значками диспозиций — сверены с нашими `dispo-*.webp`), 9 Location (бонус + war zone rules),
9 Agenda Achieved, 35 Upgrade (11 Honour 5/5/1, **9** Skill, 15 Relic по 5).
Замечено на картах: у Capture Trophies на стороне Primary значок Oppressors вместо Raiders;
Victorinius Spaceport и Blackfire Death Pits — одна сетка 7830-AR; Master-crafted Armour «+1 T, Sv
and W» — как напечатано. Primary у Agenda — та же форма, что `missions.js` (`blocks → rows {text, vp,
modifier}`): трекер может считать их без нового механизма.

### План (предложен владельцу)
1. **Справочник** — глава Dominatus в Event Companion рядом с Doubles: буклет, Location, матрицы
   Briefing (значки `DISPOSITIONS`), Agenda через `MissionCard`, Upgrade карточками. Данные —
   отдельный ленивый чанк, EN сначала, RU отдельным проходом; гейты `parity`, `companions`
   (снять пометку «не реализовано»), поиск по названиям.
2. **Трекер, одна партия** — режим «Dominatus»: альянс + фаза в настройке, Agenda по матрице
   (как `primaryFor`), её Primary считается обычным счётчиком; war zone rules локации — в
   напоминании по фазам; галочки условий Agenda Achieved в конце; до 3 (4 в Titangrave) Upgrade на
   юниты в карточке ростера. Формат партии меняется → проверить `wh11ed-api` `domain/game.ts`.
3. **Кампания** (отдельная сущность поверх партий: альянсы, Honour/Skill/Relic игроков, контроль
   локаций, Narrative Points, Ascendancy) — самое большое; для общей кампании нужен бэкенд.
   Предложено отложить до отклика на 1–2.

### Решение владельца 2026-10-28
«Делаем всё, но пока отдельной веткой — я посмотрю». Уточнено: **EN + RU сразу**; кампания —
**общая через аккаунт** (бэкенд: таблицы и эндпоинты в wh11ed-api); Primary из Agenda — **с обычным
лимитом очков** пакета миссий (Agenda заменяет Primary в обычной последовательности миссии).

## 2026-10-28 — этапы 1–2 сделаны (wh11ed `feat/dominatus`, коммит `88748f5e`, не запушено)
- **Справочник** `/dominatus`: правила кампании, 9 Location, 9 Briefing-матриц значками диспозиций,
  27 Agenda (условия Agenda Achieved над Primary через `MissionCard`), 35 Upgrade, глава по
  Dominatus Event Companion (дельта). EN + RU (перевод помощником, паритет — тест). Карточка на
  `/rules`, подменю, ящик, SEO.
- **Трекер**: режим «Битва кампании Dominatus» в шаге 2 (фаза, локация с D6, альянс сторон,
  отказ от Agenda) → Primary = Agenda (`dom-` слаги, как `cp-`); правила зоны боевых действий на
  вкладке миссий; Upgrade в шаге 7 (до 3, 4 в Titangrave); счётчик Agenda Achieved. Колода
  грузится лениво (35 КБ gzip не на всех экранах трекера/ростеров).
- Найдено попутно: `missionTiming` не знал «End of the battle round» и молча считал «любой ход» —
  добавлен момент `round-end`, гейт теперь читает и Agenda.
- Гейты: `dominatus.test.js` (89 карт, матрицы 5×5), `dominatusParity.test.js` (проверен: красный на
  сломанном маркере), `companions` — Dominatus «реализован». Полный прогон 3784 теста, lint, types —
  зелёные; сборка ок; снимки 390/1280 RU/EN без сдвига вбок.
- RU-термины на проверку владельцу — список помощника (зона боевых действий, превосходство, сюжетные
  очки, цель-идол, счёт убийств и т. д.) в отчёте чата 28.10.
- **Этап 3 (кампания через аккаунт)** — ждёт ответов владельца на вопросы по устройству.

### Этап 3 — решения владельца 2026-10-28
Битвы вносит каждый игрок сам, Warmaster подтверждает; смотреть кампанию — по ссылке без входа
(аккаунт нужен только Warmaster’у); карты Upgrade — оба способа (тянет приложение / вносятся руками,
переключатель кампании); конец фазы — автоматически, Warmaster правит.
Устройство: кампания = журнал событий на сервере (append-only, права по типу события: участник —
свой игрок, свои битвы, свои награды; Warmaster — всё), состояние — чистая свёртка в ядре
(`src/core/dominatus/campaign.js`). Игроки входят по ссылке-приглашению с токеном участника, как
гости общей партии.
