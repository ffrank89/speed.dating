# 0054: Your party is your phone's Contacts

- **Status:** Accepted, amended by [0068](0068-one-key-for-apps.md) (W flips through the apps; C is gone)
- **Date:** 2026-10-20
- **Affects:** [calendar.md](../design/calendar.md), [core-loop.md](../design/core-loop.md), [girls.md](../design/girls.md), [0037](0037-phone-app-overlays.md), [0052](0052-result-is-her-contact-card.md), [0053](0053-full-date-flow.md)

## Decision

The party is shown as **contacts in your phone** (`scenes/Phone/Contacts/ContactsApp.tscn`). Every girl who gave you her number is a contact; that's your party. **Press C** (the `open_contacts` input action) and it opens over the screen like an iPhone app, exactly the way a microgame opens over the date (`data/apps/contacts.tres`, growing from the bottom middle of the screen); C, Escape or the bar at the bottom closes it back. For now it's only on the calendar.

- **The list:** A to Z under letter headers, each girl in her own dialogue-box style and font, with her initials (or contact photo) and a heart if her card got one, and a count underneath ("3 Contacts").
- **Her contact:** clicking her slides in her saved card, the same card she filled in at the end of the date, already filled in with what her hearts unlocked (type, tags or "you dont know me like that!", the heart), her number and address. "‹ Contacts" goes back.
- **The data:** each girl in the party is a `PartyMember` (her girl file, her hearts, her dating-app profile) in `PlayerManager.party`. A girl already in your contacts isn't offered by the dating app again.

This makes the party screen from [0037](0037-phone-app-overlays.md) your Contacts.

**Changed the same day:** at first Contacts opened from an app icon on the calendar. Frank: "It doesnt make much sense for contacts to appear as an app on the calendar when the calendar itself is an 'App'. For now lets just make it so anytime someone presses C they can view contacts. They can check this only during the calendar at this point." So: no icon, and the C key. Then: "Contacts should appear over the calendar in the same exact fashion a microgame appears over the date", so it opens with the open-app animation over the calendar (a slide-up stays as an option: Contact Card Style → Contacts App → Open As App off).

## Why

Frank, 2026-10-20: "The party representation will be contacts in your phone." It follows from the date ending on her New Contact card ([0052](0052-result-is-her-contact-card.md)): the card she fills in is the one you keep.

## Not chosen

A separate party screen with portraits; a list in the calendar itself; a Contacts app icon on the calendar (an app inside an app).

## Revisit when

Break-ups (a party cap of 3), the boss lineup pick and the synergy report are built. They may live in the Contacts app (e.g. deleting a contact = breaking up) or need more room than a phone screen.
