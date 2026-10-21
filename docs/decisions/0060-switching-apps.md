# 0060: Contacts and Profile by key, switching like the iPhone's app switcher

- **Status:** Accepted, amended by [0062](0062-recent-apps-order.md) (the switcher keeps the order of recent apps; back goes to the app before) and [0068](0068-one-key-for-apps.md) (one key, W, flips through the apps instead of C and P)
- **Date:** 2026-10-21
- **Affects:** [0054](0054-party-is-your-contacts.md), [0059](0059-three-day-calendar.md)

## Decision

- **Keys, not buttons:** Contacts (**C**) and Profile (**P**) have no
  buttons on the calendar. A **debug note** in the top left of the screen
  (`scenes/Debug/DebugNote.tscn`, hidden in a finished build) tells testers
  the keys.
- **Switching like open apps on an iPhone:** C and P switch the phone to
  that app the way the iPhone's app switcher moves between open apps: the
  calendar shrinks to a card, the app's card (its icon and name above it)
  slides in beside it and grows to fill the phone. Closing (the key again,
  Escape, the home bar) goes back the same way. Pressing the other key while
  one is open switches straight to the other. Its feel is
  `data/app_transition_style.tres` → **Switching Apps** (off = they open
  like any app). Both apps share one base, `PhoneOverlayApp`.
- **Today's choices are plain boxes:** no 1/2/3 numbers and no Pick button;
  the box lights up under the mouse (the player's style → **Choice Hover
  Color**) and a click picks it. The number keys still work, unshown.
- **Bug fixed:** after a training or rest day, the days coming up could be
  drawn on top of today's card. The cards no longer move when they appear
  (they fade in and settle), so the column always keeps them in place.

## Why

Frank, 2026-10-21: "I dont think it makes sense for contacts to be a button
in calendar, same with Profile. Lets give them dedicated buttons that the
player can press to open them. Just add a 'debug screen' note that will let
the user know they can press 'p' to see their profile and 'c' to see their
contacts. If possible, make the animation look like we are moving in between
'in session' apps on an iphone." "No point in having the 1,2,3 there on the
selections. I'd get rid of the number an the Pick button, just let the user
click on the box."

## Not chosen

Swiping sideways between apps along the home bar (the other iPhone
gesture); keeping the buttons alongside the keys.

## Revisit when

Players need to find Contacts and Profile without the debug note (a home
screen, or hints), or more apps join the switcher.
