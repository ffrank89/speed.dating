# The calendar

For writers, artists and designers. **No code needed.**

The calendar is the run's hub. It's drawn in its own **dialogue-box style**,
so it matches the dialogue boxes: boxes, outlines, font, and name tabs.

```
┌ CHAPTER 1 ──────────────────────────────────────────────┐
│ 6 days to the boss                See the whole month ▾ │
│  MON    TUE    WED    THU    FRI    SAT    SUN          │
│ ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌────┐        │
│ │ 1 │  │ 2 │  │ 3 │  │ 4 │  │ 5 │  │ 6 │  │ 7  │        │
│ │ ✓ │  │▣▣▣│  │▣▣▣│  │▣▣▣│  │▣▣▣│  │▣▣▣│  │BOSS│        │
│ └───┘  └───┘  └───┘  └───┘  └───┘  └───┘  └────┘        │
└─────────────────────────────────────────────────────────┘

┌ TODAY · TUE 2 ──────────────────────────────────────────┐
│ [1] ♥ Date            [2] Train Culture   [3] Rest      │
│     2 days · Swipe…       1 day · +5…         1 day · … │
└─────────────────────────────────────────────────────────┘
```

- **The top box** is this chapter: its days, each with its weekday on a name
  tab and little pictures of what it offers. Today is bigger and
  highlighted, days gone are faded with what you spent them on, and the
  **boss** sits on the last day from day one.
- **See the whole month** opens up the rest of the calendar, four weeks of
  it. Every day past this chapter shows an **X**: you can't see that far
  ahead (yet). Escape or **Just this week** closes it.
- **Today's choices** sit at the bottom. Click one, or press **1**, **2** or
  **3**:
  - **Date** (2 days): opens the dating app. After the date you're back
    here, two days later.
  - **Train** (1 day): raises an attribute by 5, with a line in the
    calendar's box ("You spend the day on your Culture. Culture +5.").
  - **Rest** (1 day): a line, and the day passes. Perks, items and events
    come later.
  - **Boss** (the last day): for now a line, then the next chapter starts.
  A choice that doesn't fit before the boss day (a 2-day date on the day
  before it) is faded and says **Not enough days left**.
- **C** opens your [Contacts](contacts.md), as before.

The run starts here: after the intro questions, the game opens the calendar.

## Try it

Open `scenes/Calendar/calendar.tscn` and press **F6**. (Played on its own,
your attributes start at 50 each.)

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

One file each. Click one:

| Setting | What it does |
|---|---|
| **Title** | Its name on the calendar ("Date", "Train Culture") |
| **Description** | The line under it on today's choices |
| **Icon** | Its picture (on its day, and on today's choice) |
| **Kind** | What it does: Date, Train, Rest or Boss |
| **Days** | How many days it uses up |
| **Weight** | How often it's offered compared to the others (the date is 3, the rest are 1). 0 = never |
| **Date → App Name / Scene** | The app and screen a date opens (the dating app) |
| **Train → Attribute / Amount** | Which attribute goes up, and by how much |
| **Message → Dialogue Title** | Which title in `dialogue/calendar.dialogue` plays when you pick it |

**A new action** (e.g. "Go to a gig", +8 Culture, 2 days): duplicate
`train_culture.tres`, change its settings, and add it to **Actions** in
`data/calendar_rules.tres`.

## What the calendar says: `dialogue/calendar.dialogue`

The lines for training, resting and the boss. **Placeholder** lines now.
They play in the calendar's box, where today's choices were. Click or press
Space to go on. Lines without a `Name:` have no name tab. They can use
`{{action}}` (Train Culture), `{{attribute}}` (Culture) and `{{amount}}` (5):

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

**Everything else:** `data/calendar_style.tres`:

| Section | What's in it |
|---|---|
| Words | "CHAPTER %d", "%d days to the boss", "TODAY · %s %d", "See the whole month ▾", "1 day" / "%d days", "Not enough days left", "BOSS", and the weekdays |
| Days | Each day's size, the gap between them, the padding inside, number and weekday sizes, picture sizes, how faded past days are, today's growth and highlight colour, the **Hidden Mark** (the X, now the X art from `assets/x1/`), how fast the weeks pop in |
| Today's Choices | Picture, title and detail sizes; show the 1/2/3 keys or not |
| Sounds | Hover, pick, blocked, opening the whole month, a day being crossed off. Kenney stand-ins for now. |

**Where things sit:** open `calendar.tscn`. **Top** holds the days (it's
centred in the space above today's choices). **TodayPanel** is where today's
choices are; the **DialogueBox** for the calendar's lines sits in the same
spot.

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
- `DayAction` (`scripts/data/day_action.gd`), `CalendarRules`,
  `CalendarStyle`.
- `CalendarScene` (`scenes/Calendar/calendar.gd`) builds `DayBox`es and
  `DayChoice`s (`scenes/Calendar/`). A date spends its days, then
  `AppLauncher.open_scene(action.app_name, action.scene)`. The date scene
  comes back with `AppLauncher.open_scene("calendar", ...)`.
- `PlayerManager.ensure_player()` makes a player with 50s when there isn't
  one. The old `current_day` / `advance_day()` / `calendar_action()` are
  gone.
