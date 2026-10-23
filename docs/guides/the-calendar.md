# The calendar

For writers, artists and designers. **No code needed.**

The calendar is the run's hub, and an **app on your phone** (portrait, with
your room dimmed behind it: [the-phone.md](the-phone.md)). It's laid out
like the blinds in Balatro: **three days at a time**, stacked.

```
┌───────────────────────────────┐
│ Calendar                      │
│ 6 days to the boss   [Month ▾]│
│┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓│  ← today (blue border)
│┃ MON · TODAY                 ┃│
│┃ ┌───────┐┌───────┐┌───────┐ ┃│
│┃ │  [♥]  ││  [▣]  ││  [▣]  │ ┃│
│┃ │ Date  ││ Train ││ Rest  │ ┃│
│┃ │2 days ││ 1 day ││ 1 day │ ┃│
│┃ │Swipe..││Cult+1 ││Nothin.│ ┃│
│┃ └───────┘└───────┘└───────┘ ┃│
│┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛│
│┏ TUE  Upcoming ━━━━━━━━━━━━━━┓│  ← coming up (gold, dimmed)
│┃      ♥      ▣      ▣        ┃│
│┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛│
│┏ SUN  Upcoming ━━━━━━━━━━━━━━┓│  ← the boss (red)
│┃  ⚔  BOSS                    ┃│
│┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛│
└───────────────────────────────┘
```

- **Today's card** is on top, with its 2-3 choices side by side, each a box
  with a big picture, the title, how many days it takes and what it does.
  The box under the mouse lights up; click it to pick it (the **1**, **2**
  and **3** keys work too, left to right):
  - **Date** (2 days): opens the dating app on the phone. After the date
    you're back here, two days later. If there's no one left to swipe on,
    **Back to the calendar** gives the 2 days back
    ([dating-app.md](dating-app.md)).
  - **Train** (1 day): raises a stat by 1 (stats go from 1 to
    9), with a line in the calendar's box at the bottom of the phone ("You
    spend the day on your Culture. Culture +1."). The stat's picture flies
    from the choice into the **stats hub** beside the phone, which swallows
    it, and the number goes up ([stats.md](stats.md) → Stats hub).
  - **Rest** (1 day): a line, and the day passes. Perks, items and events
    come later.
  - **Boss** (the last day): for now a line, then the next chapter starts.
  A choice that doesn't fit before the boss day (a 2-day date on the day
  before it) is faded and says **Not enough days left**.
- **The next two days** are dimmed and marked **Upcoming**, with little
  pictures of what they'll offer. When the boss is one of them, its card is
  red. A day past this chapter shows an **X**: **Can't see that far ahead**.
- After a day passes, the new cards fade in, one after another.
- Each card's **border and name tab** say what the day is: blue for today,
  gold for coming up, red for the boss, grey for an X.
- **Month ▾** swaps the cards for the whole month, small, four weeks of it
  (gone days faded, every day past this chapter an X). Escape or **Days ▴**
  closes it.
- **C** switches to your [Contacts](contacts.md) and **P** to your Profile
  (your stats); **W** flips through them all (Contacts, Profile, back to
  the calendar), like moving between open apps on an iPhone
  ([the-phone.md](the-phone.md) → Your apps). A **debug note** in the top
  left of the screen lists the keys (it doesn't show in a finished build).

The run starts here: after the intro ("Your Profile"), the calendar opens on
the phone.

## Try it

**The test bench:** open `scenes/Calendar/CalendarTest.tscn` and press
**F6**. It's for trying **art on the calendar itself**, the way the iPhone
frame will be tried. The buttons are top left, beside the phone:

| | |
|---|---|
| **Page ◀ ▶** | Pictures for the page the whole month sits on (**Page Images**). Open **Month ▾** to see it. **None** = a card in the player's style. |
| **Days ◀ ▶** | Pictures for each day's card (**Day Images**). **None** = the player's style. |
| **Room ◀ ▶** | Pictures behind the phone (**Rooms**). **None** = the room in `data/phone_style.tres`. |
| **New calendar** | A new run's calendar, with new random choices |
| **Skip day** | Uses up today without doing anything |
| **Boss day** | Jumps to the boss day |
| **Foresight** | How many days past this chapter you can see |

To try your own pictures: click the test bench's top node and **Add
Element** to its lists. **F1** hides the bars. Nothing on the test bench is
saved: to keep a picture, put it in `data/calendar_style.tres` → **Calendar
Art** (or, for the room, `data/phone_style.tres` → **Your Room**).

**On its own:** open `scenes/Calendar/calendar.tscn` and press **F6**.
(Played without the intro, each stat starts at its **Starting Value**, 5:
[stats.md](stats.md).)

## What's offered: `data/calendar_rules.tres`

| Setting | Now | What it does |
|---|---|---|
| **Days Per Chapter** | 7 | The last one is always the boss |
| **Boss** | `boss.tres` | The boss day's action |
| **Actions** | date, 4 trainings, rest | Everything a day can offer. Add one with **Add Element** and drag in a file from `data/day_actions/` |
| **Options Per Day** | 3 | How many choices each day has (no repeats in a day) |
| **Calendar Days** | 28 | How many days **Month ▾** shows |
| **Foresight Days** | 0 | How many days past this chapter you can see. 0 = they're all X's. A "see into the future" ability would raise this; then those days show what they'll offer, boss days included. |

Each day's choices are drawn at random when the run starts, so no two runs
offer the same days.

## Each action: `data/day_actions/`

One file each. An action is **made of parts, all optional**, so a new one
needs no code. When it's picked, in this order:

1. **Stats:** it changes the player's stats ([stats.md](stats.md)).
2. **Message:** a line from `dialogue/calendar.dialogue` plays.
3. Its **days** are used up, or with **Ends Chapter** the next chapter starts.
4. **Opens:** it opens a screen like an app.

The date, the trainings, rest and the boss are just different mixes:

| | Days | Stats | Message | Ends Chapter | Opens |
|---|---|---|---|---|---|
| Date | 2 | | | | the dating app |
| Train Culture | 1 | Culture +1 | `train` | | |
| Rest | 1 | | `rest` | | |
| Boss | 1 | | `boss` | on | (the boss fight, later) |

| Setting | What it does |
|---|---|
| **Title** | Its name on the calendar ("Date", "Train Culture") |
| **Description** | The line under it on today's choices. Empty = what it changes ("Culture +1") |
| **Icon** | Its picture (on its day, and on today's choice) |
| **Days** | How many days it uses up |
| **Weight** | How often it's offered compared to the others (the date is 3, the rest are 1). 0 = never |
| **Stats** | Which stats it changes, and by how much: **Add Key/Value Pair**, drag a stat file from `data/stats/` on the left, type the amount on the right (Train Culture is Culture 1; below 0 lowers it). Stats that are off are left alone |
| **Message → Dialogue Title** | Which title in `dialogue/calendar.dialogue` plays. Empty = none |
| **Chapter → Ends Chapter** | For the boss day: the next chapter starts instead of using up days. Put that action in the rules' **Boss** slot |
| **Opens → Scene / App Name** | A screen it opens afterwards, and which app (in `data/apps/`) it opens like on the phone. Empty = it stays on the calendar |
| **Opens → Real Life** | On = the screen is real life (a boss fight, say): the phone goes down into it instead of it opening as an app |

**A new action** (e.g. "Go to a gig": 2 days, Culture +1, Charisma +1, a
line): duplicate `train_culture.tres`, change its settings (its **Stats**:
Culture 1 and Charisma 1), and add it to **Actions** in
`data/calendar_rules.tres`. Nothing else. A "Hit the gym" action is Strength 1.

## What the calendar says: `dialogue/calendar.dialogue`

The lines for training, resting and the boss. **Placeholder** lines now.
They play in the calendar's box at the bottom of the phone, over the days
coming up. Click or press Space to go on. Lines without a `Name:` have no name tab. They can use
`{{action}}` (its title), `{{changes}}` ("Culture +1, Heart +1"), and
`{{stat}}` / `{{amount}}` (the first thing it changes: Culture, 1):

```
~ train

You spend the day on your {{stat}}.
{{stat}} +{{amount}}.
=> END
```

## How it looks

Three files, so each kind of change has one home:

| File | What it decides |
|---|---|
| `data/player_style.tres` | **The look**: the cards' colours, font, borders, corners, shadow, the day colours, the buttons. The player's own style, the way each girl's dialogue style decides her boxes. |
| `data/calendar_style.tres` | **The layout and words**: sizes, which parts show, how many days come up, the words, calendar art and sounds |
| `data/phone_style.tres` | The phone, the title's font and your room behind it ([the-phone.md](the-phone.md)) |

The calendar's lines play in `data/dialogue_styles/calendar.tres` (a
dialogue-box style, [dialogue-box.md](dialogue-box.md)).

**The player's style:** `data/player_style.tres`:

| Section | What's in it |
|---|---|
| Cards | **Card Color** (dark slate), **Panel Color** (the darker panels for each choice), **Corner**, **Border Width** (the coloured border), **Shadow Color** / **Shadow Offset** |
| Day Colours | **Today Color** (blue), **Upcoming Color** (gold), **Boss Color** (red), **Hidden Color** (an X), **Past Color** (the month), how faded upcoming days are (**Upcoming Alpha**) and gone days in the month (**Past Alpha**) |
| Words | **Font** (empty = the phone's font; drop a chunky or pixel font here for more of a Balatro feel), **Text Color**, **Faint Text Color** (the lines under titles, "Upcoming"), **Text Outline Width** / **Color** (a dark edge around the words) |
| Choices | **Choice Hover Color** (orange: the border a choice gets under the mouse) and **Choice Hover Width** |
| Buttons | **Month Button Color** (orange), **Button Text Color**, **Button Corner**, **Button Depth** (the darker edge under the button) |

**The calendar's style:** `data/calendar_style.tres`:

| Section | What's in it |
|---|---|
| Words | The title ("Calendar"), "{days} days to the boss" / "1 day to the boss", "Boss day", "CHAPTER {chapter}", "{weekday} · TODAY" and "{weekday}" (the tabs), "Upcoming", "Can't see that far ahead", "Month ▾" / "Days ▴", "1 day" / "{days} days", "Not enough days left", "BOSS", and the weekdays. The blanks: `{chapter}`, `{days}`, `{weekday}`, `{day}` (the day's number in the run) |
| Calendar Art | **Page Image**: the page the whole month sits on. **Day Image**: a picture for each day's card and each day in the month (replaces the player's card; its words use **Day Text Color**). Margins (pixels that never stretch) and **Page Padding** |
| What Shows | **CHAPTER 1** next to the title (off), day numbers in the month (off), the **BOSS** caption in the month (off), weekdays, the offer pictures, the pop-up text over a day, "days to the boss", the Month button, the line under each choice |
| Three Days | **Upcoming Days** (2: how many days after today show), the gap between cards, the padding inside them, the tab size, the size of an upcoming day's pictures and words, the boss's picture size, how fast the cards fade in |
| Month | The whole month's squares: **Month Day Size** (106×150), the gap, weekday size, picture sizes, how much today grows, how fast the weeks pop in |
| Days | The padding inside the month's page and each square, the number size, the **Hidden Mark** (the X, now the X art from `assets/x1/`) |
| Today's Choices | Picture (160), title and detail sizes, the padding inside each box and the gap between them; the Month button's word size |
| Sounds | Hover, pick, blocked, opening the month, a day passing. Kenney stand-ins for now. |

**Where things sit:** four scenes, each with its parts as nodes you can
move, resize or reorder:

| Scene | What's in it |
|---|---|
| `scenes/Calendar/calendar.tscn` | The calendar on the phone. Inside **PhoneScreen → Phone → Body → Screen → Margin → Column**: **TitleRow** (Title, ChapterLabel), **InfoRow** (DaysLeft and the Month button), **Cards** (the day cards go here), **MonthBox** (the whole month, in **Days**). The **DialogueBox** for the calendar's lines is at the bottom of the phone's screen. **ContactsApp** and **ProfileApp** are your other apps; **DebugNote** is the note in the top left. |
| `scenes/Calendar/DayCard.tscn` | One day's card: **Tab** (weekday) and **Status** ("Upcoming"), **Choices** (today's bubbles go here), **Offers** (what a day coming up offers), **Boss** (picture, BOSS, what it does), **Hidden** (the X) |
| `scenes/Calendar/DayChoice.tscn` | One of today's choices: **Icon**, **Title**, **Days**, **Detail** |
| `scenes/Calendar/DayBox.tscn` | A day in the whole month: **Tab** (weekday), **Box**, and in the box **Number**, **Offers**, **Picture** (what a gone day was spent on, or the boss), **BossLabel**, **HiddenMark** / **HiddenText** (the X) |

**Your own design:** duplicate `DayCard.tscn`, `DayChoice.tscn` or
`DayBox.tscn`, change it (keep the node names), then click the calendar's
top node and drop it into **Card Scene**, **Choice Scene** or **Month Day
Scene**. The calendar's **Style**, **Player Style**, **Rules** and
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
  `today_day()`, `fits(action)`, `spend(action)`, `give_back()` (undoes
  the last `spend()`'s days, once, if nothing else happened since; the
  dating app calls it when no one's left), `next_chapter()`;
  calendar-day numbers for the whole view: `calendar_day()`,
  `calendar_today()`, `day_at(number)`, `is_revealed(number)`,
  `is_boss(number)`. Each chapter's days are planned the first time
  they're needed. `RunCalendar.Day`: `options`, `spent_on`, `continued`.
- `DayAction` (`scripts/data/day_action.gd`): parts, applied by
  `CalendarScene._on_picked` in order (`stat_changes()`, the message,
  `spend()` or `next_chapter()`, then `AppLauncher.open_scene(app_name,
  scene)`, or `AppLauncher.phone_down(scene)` with `real_life`).
  `CalendarRules`, `CalendarStyle` (`words(text, blanks)`, `weekday(n)`).
- `CalendarScene.stat_hub` (a `StatHub`, the scene's **StatHub**):
  `_on_picked` raises the stats, then calls `stat_hub.show_changes(changes,
  choice.icon.get_global_rect())` without waiting, so it plays with the line.
- `CalendarScene` (`scenes/Calendar/calendar.gd`): `_build_cards()`
  instances `card_scene` (`DayCard.setup(style, player_style, number, day,
  today, boss_day, seen, font)`) for today and the next **Upcoming Days**,
  and fills today's `card.choices` with `choice_scene` (`DayChoice.setup(style,
  player_style, action, fits, font)`); `_build_month()` instances
  `month_day_scene` (`DayBox.setup(style, player_style, number, day, look,
  boss_day, font)`). Its phone is `phone_screen`; `contacts` and `profile`
  are the overlay apps. The date comes back with
  `AppLauncher.open_scene("calendar", ...)`. `PlayerManager.get_calendar(rules)`.
- `PlayerStyle` (`scripts/data/player_style.gd`): `day_color(today, boss,
  hidden, past)`, `make_card(edge, padding)`, `make_panel()`, `make_tab()`,
  `make_button(color, state)`, `style_label(label, fallback_font, size, color)`.
- `PlayerManager.ensure_player()` makes a player with 50s when there isn't
  one. The old `current_day` / `advance_day()` / `calendar_action()` are
  gone.
