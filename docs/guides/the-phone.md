# The phone

For artists, writers and designers. **No code needed.**

The game has two kinds of screens:

| On your phone | Real life |
|---|---|
| The intro (**Your Profile**), the **dating app**, the **calendar**, **Contacts**, **her contact card** after a date, **microgames** | **Dates**, boss fights, stage hazards |

When you're on your phone, the screen is the phone: a portrait phone in the
middle, with your room dimmed behind it. Every phone screen uses the same
phone, so they look like apps on one device.

```
           your room, dimmed
        ┌──────────────────┐
        │ 9:41      5G 100%│  ← status bar
        │ Calendar         │
        │                  │  ← the app
        │                  │
        │       ───        │  ← home bar
        └──────────────────┘
```

**Moving between them:**

| From → to | What you see |
|---|---|
| Phone app → phone app (calendar → dating app, C for Contacts) | The app opens **inside the phone**, growing from what you clicked (or the bottom of the phone's screen) |
| Phone → real life (Start Dating!) | **Phone down**: the phone drops off the bottom of the screen and the date is there behind it |
| Real life → phone (the end of a date, a microgame) | **Phone up**: the phone comes up from the bottom over the date, which dims |
| Her contact card → the calendar | The calendar opens on the phone, and your room comes back around it |

## Change the phone: `data/phone_style.tres`

One file for every phone screen. Change it and the intro, dating app,
calendar, Contacts, her card and microgames all change.

| Section | What's in it |
|---|---|
| **Phone** | **Phone Size** (1000 × 1600: the whole phone, edge included; the screen is 3000 × 1700), **Phone Offset** (move it off the middle), **Screen Color** (behind every app, iPhone's light grey), **Wallpaper** (a picture on the screen behind every app; empty = Screen Color), **Corner** (how rounded), **Edge Width** / **Edge Color** (the phone's rim; 0 = no rim) |
| **Phone → Phone Art** | **Frame Image**: a picture of the phone (an iPhone frame) drawn over the rim, with the screen part see-through. **Frame Spill**: how far it reaches past the phone on each side (buttons, a shadow) |
| **Status Bar** | On or off, its height, the clock (**Clock Text** "9:41"; empty = the real time), the words on the right ("5G 100%"), colour and size |
| **Home Bar** | On or off, its height, the bar's colour and size. Clicking it closes Contacts (and her card, once she's done) |
| **Words** | The phone's own font (**UI Font**, Nunito), size and colour, the **Accent Color** for buttons and links (iPhone blue), and the size of an app's big title ("Calendar", "Contacts") |
| **Your Room** | **Room Image** (behind the phone on phone screens; now `assets/bedroom2.png`), **Room Dim** over it, **Real Life Dim** over a date while the phone is up |
| **Phone Up / Down** | How long the phone takes to come up and go down, the shape of the movement, a little tilt, and the sounds (Kenney stand-ins) |

**How big an app is:** the phone (1000 × 1600) minus its rim (18 on each
side) is a 964 × 1564 screen; minus the status bar (90) and home bar (60),
an app gets **964 × 1414**. Change the phone and every app follows.

**Each scene's own:** every phone screen has a **PhoneScreen** node. Click
it to set, for that scene only:

| Setting | What it does |
|---|---|
| **Behind** | **Room**: your room, dimmed (the intro, dating app, calendar). **Dim**: whatever's underneath, dimmed (her card and microgames, over the date). **Nothing**: just the phone (Contacts, over the calendar's phone) |
| **Room Image** | This scene's own room. Empty = the style's |
| **Wallpaper** | This scene's own picture on the screen. Empty = the style's |
| **App Name** | Which app this screen is (a file in `data/apps/`, e.g. `calendar`): its icon and name show above its card when you switch apps |

## Try it

- `scenes/Phone/PhoneScreen.tscn` is the phone on its own: open it to see
  the parts (**Room**, **Dim**, **Phone → Edge, Body → Wallpaper,
  StatusBar, Screen, HomeBar, Frame**).
- Press **F6** on any phone scene: `scenes/Intro/IntroQuestions.tscn`,
  `scenes/Tinder/Screen.tscn`, `scenes/Calendar/calendar.tscn`,
  `scenes/Phone/Contacts/ContactsApp.tscn`,
  `scenes/Results/ContactCard.tscn`, or the template microgame.
- The calendar test bench (`scenes/Calendar/CalendarTest.tscn`) has a
  **Room ◀ ▶** flipper for trying rooms behind the phone.

## Recipes

| I want to... | Do this |
|---|---|
| Use iPhone art | Draw the phone at **Phone Size** (plus **Frame Spill** on each side) with the screen see-through. Drop it in **Phone Art → Frame Image**. The plain rim hides while art is set. |
| Change the room behind the phone | **Your Room → Room Image**. Only one scene: its **PhoneScreen → Room Image**. |
| A wallpaper on the phone | **Phone → Wallpaper** (every app shows on it), or one scene's **PhoneScreen → Wallpaper**. Apps with their own boxes (calendar, dating app) still draw them on top. |
| Change the phone's font | **Words → UI Font**. The girls' boxes keep their own fonts (their dialogue styles). |
| Dark mode | **Screen Color** dark, **UI Text Color**, **Status Text Color** and **Home Pill Color** light. |
| A bigger or smaller phone | **Phone Size**. Keep it under 1700 tall (the screen). Microgames get a bigger or smaller play area too. |
| A slower phone up | **Phone Up / Down → Up Seconds**. |
| No rim | **Edge Width** 0. |

## Each app's own look

The phone is shared; what's on each app is its own file:

| App | Its look |
|---|---|
| The calendar | Its look: the player's style, `data/player_style.tres`; its layout and words: `data/calendar_style.tres`: [the-calendar.md](the-calendar.md) |
| Profile (your stats) | Its settings: click the top node of `scenes/Phone/Profile/ProfileApp.tscn` (below) |
| The dating app | `data/dating_app_style.tres`: [dating-app.md](dating-app.md) |
| Contacts and her card | `data/contact_card_style.tres` + her dialogue style: [contacts.md](contacts.md), [result-screen.md](result-screen.md) |
| Microgames | `data/microgame_style.tres`: [making-a-microgame.md](making-a-microgame.md) |
| The intro | Its words: click the top node of `scenes/Intro/IntroQuestions.tscn` |
| How apps open and close | `data/app_transition_style.tres`: [phone-apps.md](phone-apps.md) |

## Your apps

On the calendar, **W flips through your apps**, one press at a time:

| Press W on | You land on | What's in it |
|---|---|---|
| The calendar | **Contacts** | Your party: [contacts.md](contacts.md) |
| Contacts | **Profile** | Your stats (every one that's on: [stats.md](stats.md)), each 1–9 with a bar |
| Profile | The calendar | |

The phone switches **like moving between open apps on an iPhone**: the
app you're on shrinks to a card, the row of open apps slides to the next
app's card (its icon and name above it), and it grows to fill the phone. A
**debug note** in the top left of the calendar screen says so (it doesn't
show in a finished build).

**W's order** is the calendar, then the apps in the order they sit in the
calendar scene (top to bottom in the Scene panel: **ContactsApp**, then
**ProfileApp**). Drag one above the other to change it. A new app dropped
into the scene joins the round.

**It remembers the order you used them in**, like an iPhone:

- The cards are your open apps, the most recent on the right and older
  ones to its left, each a little under the newer one. A new app comes in
  on the right.
- Switching with W makes the app you were on the most recent.
- **Back** (**Escape** or the home bar) goes to the app you were on
  before, like swiping back along an iPhone's home bar: the app slides off
  to the right and the one before comes in from the left.

| You press | You land on | Recent apps, newest first |
|---|---|---|
| W (on the calendar) | Contacts | Contacts, Calendar |
| W | Profile | Profile, Contacts, Calendar |
| Escape | Contacts | (no change) |
| Escape | the calendar | (no change) |
| W | Contacts (its card comes in from the left: it's older) | Contacts, Calendar, Profile |

Each screen keeps its own list (the calendar's starts again after a
date).

**The switch's feel:** `data/app_transition_style.tres` → **Switching
Apps**: on or off (**Switch Between Apps**; off = they open like any app),
how small the cards get (**Switch Card Scale**), how far apart they are
(**Switch Card Spacing**), the seconds for each part (shrink, slide,
grow), the colour behind the cards, the icon and name above each card, and
the sound (Kenney `switch_006` for now). The icons and names come from each
app's file in `data/apps/` (`calendar.tres`, `contacts.tres`,
`profile.tres`); the calendar's comes from its PhoneScreen's **App Name**.

**The debug note** is `scenes/Debug/DebugNote.tscn`: click it in the
calendar scene to change its **Text**. Drop it into any scene for another
note; **Only While Testing** (on) hides it in a finished build.

**The key:** **Project Settings → Input Map** → `switch_apps` (W). Any
scene with `ContactsApp.tscn` / `ProfileApp.tscn` in it gets it; for now
that's the calendar. Each app's top node has **Switch Action** (empty = W
skips that app) and **Open Action** (optional: a key of its own for just
that app, empty now).

**Profile** is a light first version (`scenes/Phone/Profile/ProfileApp.tscn`,
press **F6** to try it). Click its top node to change its words (**Title
Text**, **Subtitle Text**). Its list is Stat Bars
(`scenes/Stats/StatBars.tscn`): click **StatBars** (inside **Column → Scroll →
Stats**) for its sizes and heading, to show only some stats, or drag it to
move it ([stats.md](stats.md) → Stat Bars). The list scrolls when it's taller
than the phone. A full bar is the highest a stat goes (9, from
`data/stats.tres`); the bars use the phone's **Accent Color**. Its icon and
launch screen are
`data/apps/profile.tres` (the Godot logo for now).

## A new phone screen

1. In your scene, add `scenes/Phone/PhoneScreen.tscn` (drag it in).
2. Right-click it → **Editable Children**.
3. Put your nodes inside **Phone → Body → Screen** (a MarginContainer
   filling it is a good start, like the calendar's **Margin**).
4. Set its **Behind**: **Room** for a whole screen, **Dim** for something
   over real life.

To bring it up over real life, a programmer calls `await phone.raise()`
(and `lower()` to put it away).

## Something's wrong

| Problem | Fix |
|---|---|
| The phone moved in the editor goes back when the game runs | Its size and place are **Phone Size** / **Phone Offset** in the style. |
| An app's bottom is cut off | It's taller than 1414. Make its parts smaller, or the phone taller. |
| Two dims, too dark | A scene over another phone screen should have **Behind = Nothing** (like Contacts). |
| The room doesn't show | That scene's **Behind** isn't **Room**, or there's no **Room Image**. |

## For programmers

- `PhoneStyle` (`scripts/data/phone_style.gd`): `phone_rect(screen_size)`,
  `screen_rect()`, `app_rect()`, `make_screen_box()`, `make_edge_box()`,
  `style_label(label, color, size)`.
- `PhoneScreen` (`scenes/Phone/phone_screen.gd`): `style`, `behind`,
  `room_image`, `wallpaper`, `app_name`; `apply_style()`, `await raise()`,
  `await lower()`, `show_up()`, `app_rect()`, `screen_rect()`,
  `await switch_apps(cards, live, from, to)` (the app switcher: a row of
  cards, newest first, each `{"picture", "app"}`; `live` is this screen's
  own card); signals
  `home_pressed`, `raised`, `lowered`. Nodes: `room`, `dim`, `phone`,
  `body`, `screen` (put an app's nodes here), `home_bar`, `frame`.
- `PhoneOverlayApp` (`scenes/Phone/phone_overlay_app.gd`): the base of
  `ContactsApp` and `ProfileApp`: `switch_action` (`switch_apps`, W),
  `open_action` (optional, empty), `app_name`, `open()`, `close()`;
  override `_show_now()`, `_hide_now()`, `_before_close()`,
  `_escape_closes()`. Keys are read in `_input` (a tooltip would swallow
  Escape otherwise). Every app reads W; `_next_app(action)` works out the
  round (null = the screen underneath, then the apps with that
  `switch_action` in tree order) and only the next app (or the one on
  screen, going back to the screen underneath with
  `_switch_to_underneath()`) acts. `AppLauncher.capture_rect(rect)` takes the picture of
  the app you're leaving.
- `RecentApps` (`scenes/Phone/recent_apps.gd`): the open apps on a screen,
  most recently used first (`RecentApps.of(node)`, kept on the scene):
  `entries` (each `overlay`, null = the screen underneath; `app`;
  `picture`), `current`, `settle()`, `bring_to_front(i)`, `back_from(i)`,
  `cards()`.
- `AppLauncher.phone_down(scene_path)`: phone down into a real-life scene.
  Apps open into `AppTransitionStyle.phone.screen_rect()` when **Open Into
  Phone** is on; `AppLauncher.home_rect()` is the bottom of the phone's
  screen.
- `ContactCard.phone_screen`, `ContactsApp.phone_screen`,
  `MicrogameHost.phone_screen`, `CalendarScene.phone_screen`. The date
  brings her card up with `contact_card.phone_screen.raise()`.
