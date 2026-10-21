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
| The calendar | `data/calendar_style.tres` (+ its box style `data/dialogue_styles/calendar.tres`): [the-calendar.md](the-calendar.md) |
| The dating app | `data/dating_app_style.tres`: [dating-app.md](dating-app.md) |
| Contacts and her card | `data/contact_card_style.tres` + her dialogue style: [contacts.md](contacts.md), [result-screen.md](result-screen.md) |
| Microgames | `data/microgame_style.tres`: [making-a-microgame.md](making-a-microgame.md) |
| The intro | Its words: click the top node of `scenes/Intro/IntroQuestions.tscn` |
| How apps open and close | `data/app_transition_style.tres`: [phone-apps.md](phone-apps.md) |

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
  `room_image`, `wallpaper`; `apply_style()`, `await raise()`,
  `await lower()`, `show_up()`, `app_rect()`, `screen_rect()`; signals
  `home_pressed`, `raised`, `lowered`. Nodes: `room`, `dim`, `phone`,
  `body`, `screen` (put an app's nodes here), `home_bar`, `frame`.
- `AppLauncher.phone_down(scene_path)`: phone down into a real-life scene.
  Apps open into `AppTransitionStyle.phone.screen_rect()` when **Open Into
  Phone** is on; `AppLauncher.home_rect()` is the bottom of the phone's
  screen.
- `ContactCard.phone_screen`, `ContactsApp.phone_screen`,
  `MicrogameHost.phone_screen`, `CalendarScene.phone_screen`. The date
  brings her card up with `contact_card.phone_screen.raise()`.
