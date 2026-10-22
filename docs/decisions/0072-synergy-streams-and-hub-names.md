# 0072: Synergy streams in Contacts (shared tags); stat names on hover in the stats hub

- **Status:** Accepted
- **Date:** 2026-10-22
- **Affects:** [0019](0019-tag-threshold-synergy.md), [0054](0054-party-is-your-contacts.md), [0070](0070-stats-hub.md), [contacts.md](../guides/contacts.md), [stats.md](../guides/stats.md)

## Decision

- **Synergy, for now, is shared tags.** Two girls get one point for each
  tag they both have: traits whose **Kind** is `tag`, with matching
  titles, ignoring case. Which kinds count is a setting (**Counted
  Kinds**).
- **Contacts shows it as a stream.** For each two girls on the list with
  synergy, a stream of sprites flows between their photos, bowing out to
  the right, half each way. More points make it stronger: more sprites,
  bigger, faster, more solid, bowing out further (up to **Max Points**).
  It sits over the rows and scrolls with them.
- **The stream's look and the score are one data file**, `data/synergy.tres`
  (the ContactsApp node's **Synergy**).
- **Each tag streams its own sprites**, so the stream shows the kind of
  synergy. **Tag Sprites** maps a tag's title to its SpriteFrames. Smoker
  uses the cigarette packs already in `assets/cig_gif/`, which weren't used
  anywhere. Girls sharing two tags get a mix. A tag without its own uses its
  trait's **Icon**, or else the Godot logo (Punk, for now). Sprites are sized
  by their drawn part, so art with empty space around it isn't tiny.
- **Smokey has a placeholder tag, Smoker**, shared with Split Ends, so
  Contacts' test list (F6: Split Ends and Smokey) shows a stream.
- **The stats hub shows a stat's name** in a little tag above it when the
  mouse rests on it (**Names → Name On Hover**), in the player's style.
  This replaces Godot's tooltip, which was tiny at the game's size.

## Why

Frank, 2026-10-22: "Make it when you hover over the stat icon in the stats
page it says the stat's name. In contacts i think we should hold synergy
representations. If the girls have a synergy score we should send a stream
of some sprite frames between them. The stream should become stronger the
higher their synergy is. The synergy calculation for now should just be if
they share tags." Then: "The icon should be specific to the type of synergy
they have".

## Not chosen

- **Tag thresholds** (2 of a tag → a bonus, as in [0019](0019-tag-threshold-synergy.md)):
  later, with the synergy report. For now it's just a count of shared tags.
- **Only tags she has revealed** (her card hides tags at 0 hearts): it
  counts all of them for now.
- **Making new sprite art:** existing art (the cigarette packs) or the
  Godot logo stands in until real frames exist.
- **One stream per shared tag** (several streams between the same two
  girls): one stream with each tag's sprites mixed in reads as one bond.

## Revisit when

The synergy report and boss bonuses are built, tags become their own data
(with icons), or the party grows past a handful (the streams would
crowd).
