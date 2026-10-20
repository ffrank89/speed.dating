# The calendar

For writers, artists and designers. **No code needed.**

The calendar is the run's hub. It's drawn in its own **dialogue-box style**,
so it matches the dialogue boxes: boxes, outlines, font, and name tabs.

```
┌─────────────────────────────────────────────────────────┐
│ 5 days to the boss                See the whole month ▾ │
│  MON    TUE    WED    THU    FRI    SAT    SUN          │
│ ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌────┐        │
│ │ ✓ │  │▣▣▣│  │▣▣▣│  │▣▣▣│  │▣▣▣│  │▣▣▣│  │ ⚔  │        │
│ └───┘  └───┘  └───┘  └───┘  └───┘  └───┘  └────┘        │
└─────────────────────────────────────────────────────────┘

┌ TODAY · TUE ────────────────────────────────────────────┐
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
- Days have **no numbers**, just their weekday (**What Shows → Show Day
  Numbers** brings them back).
- **C** opens your [Contacts](contacts.md), as before.

The run starts here: after the intro questions, the game opens the calendar.

## Try it

**The test bench:** open `scenes/Calendar/CalendarTest.tscn` and press
**F6**. It's the calendar with a bar across the top:

| | |
|---|---|
| **◀ ▶** | Flip through picture backgrounds behind the calendar (and **Pattern**, the animated one). The pictures are the test bench's **Backgrounds** list: click its top node and **Add Element** to try more. |
| **New calendar** | A new run's calendar, with new random choices |
| **Skip day** | Uses up today without doing anything |
| **Boss day** | Jumps to the boss day |
| **Foresight** | How many days past this chapter you can see. Open the whole month to see them. |

**F1** hides the bar. Nothing on the test bench is saved: the files keep
their settings.

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
| **Opens → Scene / App Name** | A screen it opens afterwards, and which app (in `data/apps/`) it opens like. Empty = it stays on the calendar |

**A new action** (e.g. "Go to a gig": 2 days, Culture +3, Heart +2, a
line): duplicate `train_culture.tres`, change its settings, and add it to
**Actions** in `data/calendar_rules.tres`. Nothing else.

## What the calendar says: `dialogue/calendar.dialogue`

The lines for training, resting and the boss. **Placeholder** lines now.
They play in the calendar's box, where today's choices were. Click or press
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

**Everything else:** `data/calendar_style.tres`:

| Section | What's in it |
|---|---|
| Words | "CHAPTER {chapter}", "{days} days to the boss", "TODAY · {weekday}", "See the whole month ▾", "1 day" / "{days} days", "Not enough days left", "BOSS", and the weekdays. The blanks: `{chapter}`, `{days}`, `{weekday}`, `{day}` (the day's number in the run). Leave a blank out and it's just not shown |
| Background | **Background Image**: a picture behind the calendar (empty = the animated pattern), and **Background Dim** over it so the calendar stands out |
| What Shows | Switch parts on and off: the **CHAPTER 1** tab (off), **Show Day Numbers** (off), the **BOSS** caption (off), weekdays, the offer pictures, the pop-up text over a day, "days to the boss", the "See the whole month" button, the line under each choice |
| Days | Each day's size (**Day Size** 330×300, and **Month Day Size** 300×250 when the whole month is open so it fits), the gap between them, the padding inside, number and weekday sizes, picture sizes (**Offer Icon Size** 84, **Spent Icon Size** 150 for a spent day, the boss and the X), how faded past days are, today's growth and highlight colour, the **Hidden Mark** (the X, now the X art from `assets/x1/`), how fast the weeks pop in |
| Today's Choices | Picture, title and detail sizes; show the 1/2/3 keys or not |
| Sounds | Hover, pick, blocked, opening the whole month, a day being crossed off. Kenney stand-ins for now. |

**Where things sit:** three scenes, each with its parts as nodes you can
move, resize or reorder:

| Scene | What's in it |
|---|---|
| `scenes/Calendar/calendar.tscn` | The whole screen. **Background** (the pattern) / **BackgroundImage** / **BackgroundDim** behind. **Top** holds the days (centred in the space above today's choices); **TodayPanel** is today's choices; the **DialogueBox** for the calendar's lines sits in the same spot |
| `scenes/Calendar/DayBox.tscn` | One day: **Tab** (weekday), **Box**, and inside it **Number**, **Offers** (the little pictures), **Picture** (what a past day was spent on, or the boss), **BossLabel**, **HiddenMark** / **HiddenText** (the X) |
| `scenes/Calendar/DayChoice.tscn` | One of today's choices: **Key** (1/2/3), **Icon**, **Title**, **Detail** |

**Your own design:** duplicate `DayBox.tscn` (or `DayChoice.tscn`), change
it (keep the node names), then click the calendar's top node and drop it
into **Day Scene** (or **Choice Scene**). The calendar's **Rules**,
**Style** and **Messages** slots swap the other files the same way.

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
  scene)`). `CalendarRules`, `CalendarStyle` (`words(text, blanks)`,
  `weekday(n)`).
- `CalendarScene` (`scenes/Calendar/calendar.gd`) instances `day_scene`
  (`DayBox`) and `choice_scene` (`DayChoice`), adds them, then calls their
  `setup()`. The date scene comes back with
  `AppLauncher.open_scene("calendar", ...)`. `PlayerManager.get_calendar(rules)`.
- `PlayerManager.ensure_player()` makes a player with 50s when there isn't
  one. The old `current_day` / `advance_day()` / `calendar_action()` are
  gone.
