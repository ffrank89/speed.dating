# Speed Dating — Design Docs

These docs are the source of truth for what we're building and why. The
[Game Design Modules](https://claude.ai/artifact/T15FUyvGogi1DESKaAisvb) page
is a nicer-looking view of the same material from the first design session.
If the two disagree, this folder wins.

## The pitch

**Speed Dating** is a ~30-minute roguelike run split into chapters. You live
through a Persona 5–style calendar. On date days you swipe through 2–3 random
profiles and speed-date one of them: dialogue drawn from her pool, attribute
checks that make choices risky but never locked, and short WarioWare-style
microgames taken from moments in the date. A good date recruits her to your
party, and follow-up dates raise her Affection. Girls carry tags that stack
into Teamfight Tactics–style synergies, and your perks are Balatro-style
build-arounds. You can keep 3 girls; past that, someone gets dumped. Each
chapter ends with a life-event boss (a concert, meeting the parents,
Valentine's Day). You pick up to 3 girls and their order, then watch a Super
Auto Pets–style autobattle. You never fight yourself. Lose and the run is over.

The first build has 1 chapter, 1 boss, 3 girls with full art and about 3
art-less test girls. Nothing carries over between runs yet.

Third-party fonts, sounds and code are listed with their licences in [`CREDITS.md`](../CREDITS.md).

## How these docs are laid out

| Folder | What's in it |
|---|---|
| [`design/core-loop.md`](design/core-loop.md) | **Start here.** The run from start to finish, how every module feeds the others, and the shared code all modules use. |
| `design/<module>.md` | One file per module, all with the same four sections (below). |
| [`guides/`](guides/) | How-tos for artists and writers, no code needed (except writing a microgame's game code). [Dialogue box, fonts, voices and poses](guides/dialogue-box.md); [options, odds and scoring](guides/options-and-scoring.md); [making a microgame](guides/making-a-microgame.md); [phone apps and the open-app animation](guides/phone-apps.md); [stage hazards (the fly)](guides/stage-hazards.md); [the player's cursor](guides/cursor.md); [the result screen (getting her number)](guides/result-screen.md); [the full date (opener, exchanges, closers, what happens after)](guides/the-full-date.md); [the heart meter](guides/heart-meter.md); [your contacts (the party, press C)](guides/contacts.md); [the calendar](guides/the-calendar.md); [replacing placeholders](guides/replacing-placeholders.md). |
| [`plans/`](plans/) | Build plans for what we're working on now. Current: [first date](plans/first-date.md). |
| [`decisions/`](decisions/) | One short record per settled decision: what we chose, why, what we didn't pick, and when to revisit it. |

### Module files

| Module | File |
|---|---|
| Player Character | [`design/player.md`](design/player.md) |
| Perks | [`design/perks.md`](design/perks.md) |
| Girl Character | [`design/girls.md`](design/girls.md) |
| Date Scene (incl. microgames) | [`design/dates.md`](design/dates.md) |
| Calendar Scene (incl. Tinder screen) | [`design/calendar.md`](design/calendar.md) |
| Synergy System | [`design/synergy.md`](design/synergy.md) |
| Boss Scene | [`design/boss.md`](design/boss.md) |

Every module file follows the same pattern:

1. **Concept**: a few bullet points on what it is and why it's fun.
2. **Code needed**: in three parts:
   - *Shared functions it uses* (from [core-loop.md § Shared code](design/core-loop.md#shared-code))
   - *Shared objects it inherits or holds*
   - *Custom objects and functions* that belong to this module only

   "TBD" is fine here. It marks the spots still to design.
3. **Art needed**: each asset, and which code uses it.
4. **Systems it's part of**: which of the cross-cutting systems in
   [core-loop.md § Systems](design/core-loop.md#systems) it belongs to.

### Decision records

Records are numbered and never edited after the fact except to change their
status. When a decision changes, add a new record that says
`Supersedes NNNN`, and mark the old one `Superseded by NNNN`. That way the
history of *why* stays readable.

`docs/.gdignore` tells Godot to skip this folder, so nothing here gets
imported.
