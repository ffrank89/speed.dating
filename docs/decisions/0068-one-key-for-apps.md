# 0068: One key, W, flips through the phone's apps (instead of C and P)

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0054](0054-party-is-your-contacts.md), [0060](0060-switching-apps.md), [0062](0062-recent-apps-order.md), [the-phone.md](../guides/the-phone.md), [contacts.md](../guides/contacts.md)

## Decision

- **W (the `switch_apps` input action) flips through your apps** on the
  calendar, one press at a time: Contacts → Profile → back to the calendar
  → round again. C and P are gone, along with their Input Map actions
  (`open_contacts`, `open_profile`).
- **The order is the scene's order:** the screen underneath (the calendar),
  then each app in the order it sits in the calendar scene (top to bottom
  in the Scene panel). Drag an app up or down to change it. A new app
  dropped into the scene joins the round.
- **Each app's top node** has:
  - **Switch Action** (`switch_apps`): empty = W skips that app.
  - **Open Action**: optional, a key of its own for just that app. Empty
    for Contacts and Profile now.
- **It switches like before:** the iPhone app switcher, in the order of
  recent apps. W is like picking the next app's card: the app you were on
  becomes the most recent. **Escape and the home bar** still go back to the
  app you were on before.
- **With Switching Apps off**, W opens each app like any app and closes the
  last one back to the calendar.
- **The debug note** on the calendar says "Press W to flip through your
  apps: Contacts, Profile, back to the calendar".
- **W is also the microgames' "up"**. They don't clash: microgames play on
  dates, and the apps are only on the calendar.

## Why

Frank, 2026-10-21: "Instead of P and C on the phone screen to go between the
apps lets just use one button to flip between them all. I propose using W".

## Not chosen

- **W going back to the app you used last** (like Alt-Tab): with one tap
  it would only ever swap between two apps, and a third would be out of
  reach.
- **A fixed list of apps in a settings file**: the scene already lists
  them. Its order is the one you see in the Scene panel.

## Revisit when

There are more apps than a few presses can reach, or apps open on other
screens than the calendar.
