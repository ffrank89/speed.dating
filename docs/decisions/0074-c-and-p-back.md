# 0074: C for Contacts and P for Profile are back, alongside W

- **Status:** Accepted
- **Date:** 2026-10-23
- **Affects:** [0068](0068-one-key-for-apps.md), [0060](0060-switching-apps.md), [the-phone.md](../guides/the-phone.md), [contacts.md](../guides/contacts.md)

## Decision

- **C** switches to Contacts and **P** to Profile again, the way they did
  before [0068](0068-one-key-for-apps.md). Pressing an app's key while it's
  open goes back to the app you were on.
- **W still flips through all the apps** (calendar → Contacts → Profile →
  calendar). Escape and the home bar still go back.
- **How:** the Input Map has `open_contacts` (C) and `open_profile` (P)
  again, and each app's **Open Action** names its key. Clearing an app's
  Open Action takes its own key away; clearing its **Switch Action** takes
  it out of W's round.
- **The calendar's debug note** lists all three keys.

## Why

Frank, 2026-10-23: "I liked the setup where we used C for contacts and P
for profile tbh lets add that back".

## Not chosen

- Taking W away again: the request was to add C and P back. W can go by
  clearing the `switch_apps` key in the Input Map, or each app's Switch
  Action.
