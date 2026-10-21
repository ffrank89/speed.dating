# The calendar

For writers, artists and designers. **No code needed.**

The calendar is the run's hub, and an **app on your phone** (portrait, with
your room dimmed behind it: [the-phone.md](the-phone.md)). Its boxes are
drawn in its own **dialogue-box style**, so they match the dialogue boxes:
boxes, outlines, font, and name tabs. The title, "TODAY" and the button are
in the phone's own font.

```
┌───────────────────────────┐
│ 9:41               5G 100%│
│ Calendar                  │
│ 5 days to the boss  See ▾ │
│ ┌───────────────────────┐ │
│ │ MON│ Date        ✓    │ │   ← a day gone (faded): what it was spent on
│ │ TUE│ Today    ▣ ▣ ▣   │ │   ← today (outlined)
│ │ WED│          ▣ ▣ ▣   │ │   ← what a day offers
│ │ ...                   │ │
│ │ SUN│ ⚔ Boss           │ │
│ └───────────────────────┘ │
│ TODAY · TUE               │
│ [1] ♥ Date    2 days · …  │
│ [2] ▣ Train Culture  …    │
│ [3] ▣ Rest     1 day · …  │
│           ───             │
└───────────────────────────┘
```

- **The week list** is this chapter: a row per day, its weekday on a name
  tab, little pictures of what it offers, and a word or two (what a past
  day was spent on, **Today**, the boss). Today is outlined, days gone are
  faded, and the **boss** sits on the last day from day one. If the rows
  don't fit, the list scrolls, keeping today in view.
- **See the whole month** swaps the week for the whole month, small, four
  weeks of it. Every day past this chapter shows an **X**: you can't see
  that far ahead (yet). Escape or **Just this week** closes it.
- **Today's choices** sit at the bottom. Click one, or press **1**, **2** or
  **3**:
  - **Date** (2 days): opens the dating app on the phone. After the date
    you're back here, two days later.
  - **Train** (1 day): raises an attribute by 5, with a line in the
    calendar's box at the bottom of the phone ("You spend the day on your
    Culture. Culture +5.").
  - **Rest** (1 day): a line, and the day passes. Perks, items and events
    come later.
  - **Boss** (the last day): for now a line, then the next chapter starts.
  A choice that doesn't fit before the boss day (a 2-day date on the day
  before it) is faded and says **Not enough days left**.
- Days have **no numbers**, just their weekday (**What Shows → Show Day
  Numbers** brings them back).
- **C** opens your [Contacts](contacts.md), as before.

The run starts here: after the intro ("Your Profile"), the calendar opens on
the phone.

## Try it

**The test bench:** open `scenes/Calendar/CalendarTest.tscn` and press
**F6**. It's for trying **art on the calendar itself**, the way the iPhone
frame will be tried. The buttons are top left, beside the phone:

| | |
|---|---|
| **Page ◀ ▶** | Pictures for the calendar's page, the thing the days sit on (**Page Images**: the old January desk calendar, a blank white page, the Godot logo, the poster). **None** = the box style. |
| **Days ◀ ▶** | Pictures for each day's box (**Day Images**). **None** = the box style. |
| **Room ◀ ▶** | Pictures behind the phone (**Rooms**). **None** = the room in `data/phone_style.tres`. |
| **New calendar** | A new run's calendar, with new random choices |
| **Skip day** | Uses up today without doing anything |
| **Boss day** | Jumps to the boss day |
| **Foresight** | How many days past this chapter you can see. Open the whole month to see them. |

To try your own pictures: click the test bench's top node and **Add
Element** to its lists. **F1** hides the bars. Nothing on the test bench is
saved: to keep a picture, put it in `data/calendar_style.tres` → **Calendar
Art** (or, for the room, `data/phone_style.tres` → **Your Room**).

**On its own:** open `scenes/Calendar/calendar.tscn` and press **F6**.
(Played without the intro, your attributes start at 50 each.)

## What's offered: `data/calendar_rules.tres`

| Setting | Now | What it does |
|---|---|---|
| **Days Per Chapter** | 7 | The last one is always the boss |
| **Boss** | `boss.tres` | The boss day's action |
| **Actions** | date, 4 trainings, rest | Everything a day can offer. Add one with **Add Element** and drag in a file from `data/day_actions/` |
| **Options Per Day** | 3 | How many choices each day has (no repeats in a day) |
| **Calendar Days** | 28 | How many days **See the whole month** shows |
| **Foresight Days** | 0 | How many days past this chapter you can see. 0 = they're all X's. A "see into the future" ability would raise this; then those days show what they'll offer, boss days included. |

Each day's choices are drawn at random when the run starts, so no two runs
offer the same days.

## Each action: `data/day_actions/`

One file each. An action is **made of parts, all optional**, so a new one
needs no code. When it's picked, in this order:

1. **Attributes:** it changes the player's attributes.
2. **Message:** a line from `dialogue/calendar.dialogue` plays.
3. Its **days** are used up, or with **Ends Chapter** the next chapter starts.
4. **Opens:** it opens a screen like an app.

The date, the trainings, rest and the boss are just different mixes:

| | Days | Attributes | Message | Ends Chapter | Opens |
|---|---|---|---|---|---|
| Date | 2 | | | | the dating app |
| Train Culture | 1 | Culture +5 | `train` | | |
| Rest | 1 | | `rest` | | |
| Boss | 1 | | `boss` | on | (the boss fight, later) |

| Setting | What it does |
|---|---|
| **Title** | Its name on the calendar ("Date", "Train Culture") |
| **Description** | The line under it on today's choices. Empty = what it changes ("Culture +5") |
| **Icon** | Its picture (on its day, and on today's choice) |
| **Days** | How many days it uses up |
| **Weight** | How often it's offered compared to the others (the date is 3, the rest are 1). 0 = never |
| **Attributes → Culture / Intellect / Seduction / Heart** | How much it changes each one. 0 = no change; below 0 lowers it |
| **Message → Dialogue Title** | Which title in `dialogue/calendar.dialogue` plays. Empty = none |
| **Chapter → Ends Chapter** | For the boss day: the next chapter starts instead of using up days. Put that action in the rules' **Boss** slot |
| **Opens → Scene / App Name** | A screen it opens afterwards, and which app (in `data/apps/`) it opens like on the phone. Empty = it stays on the calendar |
| **Opens → Real Life** | On = the screen is real life (a boss fight, say): the phone goes down into it instead of it opening as an app |

**A new action** (e.g. "Go to a gig": 2 days, Culture +3, Heart +2, a
line): duplicate `train_culture.tres`, change its settings, and add it to
**Actions** in `data/calendar_rules.tres`. Nothing else.

## What the calendar says: `dialogue/calendar.dialogue`

The lines for training, resting and the boss. **Placeholder** lines now.
They play in the calendar's box at the bottom of the phone, where today's
choices were. Click or press
Space to go on. Lines without a `Name:` have no name tab. They can use
`{{action}}` (its title), `{{changes}}` ("Culture +3, Heart +2"), and
`{{attribute}}` / `{{amount}}` (the first thing it changes: Culture, 3):

```
~ train

You spend the day on your {{attribute}}.
{{attribute}} +{{amount}}.
=> END
```

## How it looks

**The boxes, font and name tabs:** `data/dialogue_styles/calendar.tres`. It
has the same settings as a girl's dialogue style (colour, outline, corners,
picture box, font, name tab), so everything in
[dialogue-box.md](dialogue-box.md) works here too. It starts as a copy of
the default style.

**The phone, its font and your room behind it:** `data/phone_style.tres`
([the-phone.md](the-phone.md)).

**Everything else:** `data/calendar_style.tres`:

| Section | What's in it |
|---|---|
| Words | The title ("Calendar"), "CHAPTER {chapter}", "{days} days to the boss", "TODAY · {weekday}", "Today" (on today's row), "See the whole month ▾", "1 day" / "{days} days", "Not enough days left", "BOSS", and the weekdays. The blanks: `{chapter}`, `{days}`, `{weekday}`, `{day}` (the day's number in the run). Leave a blank out and it's just not shown |
| Calendar Art | Art for the calendar itself, like the iPhone frame. **Page Image**: the page the days sit on (empty = the box style). **Page Image Margin**: pixels at each edge that never stretch (a spiral binding, a border); 0 = the whole picture stretches. **Page Padding**: where the days sit on the page (left, top, right, bottom). **Page Text Color**: the words on the page. **Day Image** / **Day Image Margin** / **Day Text Color**: the same for each day's box |
| What Shows | Switch parts on and off: the **CHAPTER 1** tab (off), **Show Day Numbers** (off), the **BOSS** caption (off), weekdays, the offer pictures, the pop-up text over a day, the words on each row (**Show Day Words**), "days to the boss", the "See the whole month" button, the line under each choice |
| Week | The week list's rows: **Week Row Height** (74), the gap between rows, the weekday tab's width, picture sizes (offers 54, a spent day / the boss / the X 58), the words' size, how much today's row grows (1 = not at all) |
| Month | The whole month's squares: **Month Day Size** (98×92), the gap, the weekday size, picture sizes (offers 26, a spent day / the boss / the X 62), how much today grows, how fast the weeks pop in |
| Days | For both: the padding inside the box the days sit on and inside each day, the number and weekday sizes, how faded past days are, today's outline colour and width, the **Hidden Mark** (the X, now the X art from `assets/x1/`) |
| Today's Choices | Picture, title and detail sizes, the padding inside each choice and the gap between them; show the 1/2/3 keys or not |
| Sounds | Hover, pick, blocked, opening the whole month, a day being crossed off. Kenney stand-ins for now. |

**Where things sit:** four scenes, each with its parts as nodes you can
move, resize or reorder:

| Scene | What's in it |
|---|---|
| `scenes/Calendar/calendar.tscn` | The calendar on the phone. Everything is inside **PhoneScreen → Phone → Body → Screen → Margin → Column**: **Title**, the **Header** (days to the boss, See the whole month), **Month** (the **ChapterPlate** tab and **MonthBox**, the page with the week list in **WeekScroll → Week**, and the month in **Days**), **TodayPanel** (TODAY · MON and the **Choices**). The **DialogueBox** for the calendar's lines is at the bottom of the phone's screen. **ContactsApp** is your Contacts (C). |
| `scenes/Calendar/DayRow.tscn` | A day in the week list: **Tab** (weekday) and **Box**, and in the box **Number**, **Picture** (what a past day was spent on, or the boss), **HiddenMark** / **HiddenText** (the X), **Words**, **BossLabel**, **Offers** (the little pictures) |
| `scenes/Calendar/DayBox.tscn` | A day in the whole month: the same parts (no Words), the tab on top |
| `scenes/Calendar/DayChoice.tscn` | One of today's choices: **Key** (1/2/3), **Icon**, **Title**, **Detail** |

**Your own design:** duplicate `DayRow.tscn`, `DayBox.tscn` or
`DayChoice.tscn`, change it (keep the node names), then click the
calendar's top node and drop it into **Week Day Scene**, **Month Day
Scene** or **Choice Scene**. The calendar's **Rules**, **Style** and
**Messages** slots swap the other files the same way.

## Something's wrong

| Problem | Fix |
|---|---|
| A day offers nothing | **Actions** is empty, or every action's **Weight** is 0. |
| Picking Train or Rest says nothing | Its **Dialogue Title** is empty, or not a title in `calendar.dialogue`. |
| The date choice is always faded on the day before the boss | It takes 2 days and the boss day can't be used. That's on purpose. |
| The calendar starts over | It's kept for the whole run; playing `calendar.tscn` with F6 starts a new one each time. |

## Not built yet

Follow-up dates, a real training screen, events (perks and items), the boss
fight, and seeing into the future (the setting's there; nothing raises it
yet).

## For programmers

- `RunCalendar` (`scripts/calendar/run_calendar.gd`), kept on
  `PlayerManager.get_calendar()`: `chapter`, `today`, `days()`,
  `today_day()`, `fits(action)`, `spend(action)`, `next_chapter()`;
  calendar-day numbers for the whole view: `calendar_day()`,
  `calendar_today()`, `day_at(number)`, `is_revealed(number)`,
  `is_boss(number)`. Each chapter's days are planned the first time
  they're needed. `RunCalendar.Day`: `options`, `spent_on`, `continued`.
- `DayAction` (`scripts/data/day_action.gd`): parts, applied by
  `CalendarScene._on_picked` in order (`attribute_changes()`, the message,
  `spend()` or `next_chapter()`, then `AppLauncher.open_scene(app_name,
  scene)`, or `AppLauncher.phone_down(scene)` with `real_life`).
  `CalendarRules`, `CalendarStyle` (`words(text, blanks)`, `weekday(n)`).
- `CalendarScene` (`scenes/Calendar/calendar.gd`) instances
  `week_day_scene` (`DayRow`) or `month_day_scene` (`DayBox`, both
  `day_box.gd`) and `choice_scene` (`DayChoice`), adds them, then calls
  their `setup()` (`DayBox.setup(style, number, day, look, boss_day,
  month)`). Its phone is `phone_screen` (a `PhoneScreen`). The date comes
  back with `AppLauncher.open_scene("calendar", ...)`.
  `PlayerManager.get_calendar(rules)`.
- `PlayerManager.ensure_player()` makes a player with 50s when there isn't
  one. The old `current_day` / `advance_day()` / `calendar_action()` are
  gone.
