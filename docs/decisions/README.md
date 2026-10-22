# Decision records

Each record: what we chose, why, what we didn't pick, and when to revisit. Never rewrite a record; add a new one that supersedes it.

| # | Decision | Status |
|---|---|---|
| [0001](0001-commercial-roguelike-scope.md) | Target: a small commercial roguelike | Accepted |
| [0002](0002-dating-and-battle-linked.md) | Core: dating feeds battle (Persona 5–style) | Accepted |
| [0003](0003-chapters-with-life-event-bosses.md) | Run structure: chapters ending in life-event bosses | Accepted |
| [0004](0004-run-length-30-min.md) | Run length: about 30 minutes | Accepted |
| [0005](0005-five-actions-per-chapter.md) | Days per chapter: about 5 actions | Accepted |
| [0006](0006-boss-visible-from-day-one.md) | Boss visibility: shown from the chapter's first day | Accepted |
| [0007](0007-boss-type-matchups.md) | Boss match-ups: types first, special rules later | Accepted |
| [0008](0008-lineup-autobattle.md) | Fight format: pick 3 and their order, Super Auto Pets–style lineup | Superseded by 0030 |
| [0009](0009-player-never-fights.md) | The player never fights | Accepted |
| [0010](0010-loss-ends-run.md) | Losing a boss ends the run | Accepted |
| [0011](0011-recruit-then-follow-ups.md) | Relationships: first date recruits, follow-ups raise Affection | Accepted |
| [0012](0012-failed-first-date-gone.md) | A failed first date means she's gone for the run | Accepted |
| [0013](0013-random-profiles-with-unlocks.md) | Girl offers: 2–3 random profiles, some gated | Accepted |
| [0014](0014-party-cap-six-break-ups.md) | Party cap 6; break up to make room | Superseded by 0029 |
| [0015](0015-date-variety.md) | Date variety: pooled first dates, written follow-ups | Accepted |
| [0016](0016-risky-attribute-checks.md) | Attribute checks are risky, not locked | Accepted |
| [0017](0017-microgames-from-date-moments.md) | Microgames come from moments in the date | Accepted |
| [0018](0018-dialogue-manager-addon.md) | Dialogue is written in the Dialogue Manager addon's format | Accepted |
| [0019](0019-tag-threshold-synergy.md) | Girl–girl synergy: shared tags at thresholds | Accepted |
| [0020](0020-player-girl-synergy.md) | Player–girl synergy: Affection + preference match + perks | Accepted |
| [0021](0021-perks-as-build-arounds.md) | Perks are build-arounds with hooks | Accepted |
| [0022](0022-items-flavor-only.md) | Items are flavor only in the first build | Accepted |
| [0023](0023-no-meta-progression-yet.md) | No carry-over between runs in the first build | Accepted |
| [0024](0024-first-build-content.md) | First build content: 3 art girls, ~3 test girls, 1 chapter, 1 boss | Accepted |
| [0025](0025-runstate-replaces-playermanager.md) | RunState autoload replaces PlayerManager | Accepted, not built yet |
| [0026](0026-girldata-partymember-split.md) | Girls are GirlData (.tres) + PartyMember (per run) | Accepted |
| [0027](0027-one-date-score.md) | One score per date | Accepted |
| [0028](0028-markdown-docs-in-repo.md) | Design docs live in the repo as Markdown | Accepted |
| [0029](0029-party-cap-three.md) | Party cap 3; break up to make room | Accepted |
| [0030](0030-front-vs-boss-fight.md) | Fight: up to 3 girls in order, front girl vs boss | Accepted |
| [0031](0031-first-boss-thanksgiving.md) | First build's boss: Thanksgiving | Accepted |
| [0032](0032-four-girl-types.md) | Girls have one of 4 types, separate from tags | Accepted |
| [0033](0033-type-barks-no-abilities.md) | First build: type crit/fumble lines instead of unique abilities | Accepted |
| [0034](0034-boss-full-illustration.md) | Bosses are full illustrations; girls fight as pixel sprites | Accepted |
| [0035](0035-fight-fiction-tbd.md) | The fight is literal for now; what it represents is TBD | Accepted |
| [0036](0036-day-costs.md) | Actions cost different numbers of days | Accepted |
| [0037](0037-phone-app-overlays.md) | Tinder and the party screen are phone apps over the calendar | Accepted, amended by 0058, 0060 |
| [0038](0038-first-date-slice-first.md) | Build the first date before anything else | Accepted |
| [0039](0039-animalese-voice.md) | Girls 'speak' with Animalese-style letter sounds | Accepted |
| [0040](0040-risk-shown-chance.md) | Options above your attribute show a % chance | Accepted |
| [0041](0041-split-ends-first.md) | Split Ends is the first girl built | Accepted |
| [0042](0042-per-girl-dialogue-style.md) | Each girl styles her own dialogue box | Accepted |
| [0043](0043-shared-option-style.md) | The player's options share one look | Amended by 0047 |
| [0044](0044-date-scoring-formula.md) | How options score | Accepted |
| [0045](0045-microgames-overlay-handmade.md) | Microgames are overlays on the date, built by hand | Accepted |
| [0046](0046-microgame-replaces-roll.md) | A microgame replaces the roll | Accepted |
| [0047](0047-floating-option-bubbles.md) | Options are floating bubbles that pop out above her head | Accepted |
| [0048](0048-microgame-framework.md) | How the microgame framework works (library, difficulty, frame, input, F6) | Accepted |
| [0049](0049-open-like-an-iphone-app.md) | Screens open like iPhone apps (one shared, modular animation) | Accepted |
| [0050](0050-stage-hazards.md) | Stage hazards: things that turn up mid-date (the fly) | Accepted |
| [0051](0051-player-cursor.md) | The player's cursor is a swappable style (Godot logo placeholder) | Accepted |
| [0052](0052-result-is-her-contact-card.md) | The date's result is her filling in your Contacts (or not) | Accepted |
| [0053](0053-full-date-flow.md) | A first date: opener, 5 exchanges (2 microgames), one of 3 closers; then party or gone, and back to the calendar | Accepted |
| [0054](0054-party-is-your-contacts.md) | Your party is your phone's Contacts (press C on the calendar) | Accepted, amended by 0068 |
| [0055](0055-calendar-revamp.md) | The calendar: a chapter strip in dialogue-box style, today's choices, the rest X'd out | Accepted, amended by 0059 |
| [0056](0056-heart-meter-and-closing-her-card.md) | A heart meter on dates (a ring per heart, her colour); the player closes her card | Accepted |
| [0057](0057-action-cursor.md) | The action cursor (S) for stage hazards | Accepted |
| [0058](0058-phone-and-real-life.md) | On your phone (intro, dating app, calendar, Contacts, her card, microgames) or real life (dates, boss, hazards): one shared phone, phone down / up | Accepted |
| [0059](0059-three-day-calendar.md) | The calendar shows three days, Balatro-style; the player's style decides its look; stats are a Profile app | Accepted |
| [0060](0060-switching-apps.md) | Contacts (C) and Profile (P) by key with a debug note, switching like the iPhone's app switcher; choices are plain boxes | Accepted, amended by 0062 and 0068 |
| [0061](0061-f5-music-and-clean-up.md) | F5 plays the game and the window scales; a new music system; girls are only girl files; old code removed, every picture kept | Accepted |
| [0062](0062-recent-apps-order.md) | The app switcher remembers the order you used apps in, like an iPhone; back goes to the app before | Accepted |
| [0063](0063-attributes-one-to-nine.md) | The player's attributes go from 1 to 9 (one scale file); training +1, checks 1–9 | Accepted, amended by 0064 |
| [0064](0064-stats-are-data.md) | Stats are data: the first four plus S.P.E.C.I.A.L., each switchable on or off; no skills | Accepted |
| [0065](0065-stat-slow-motion.md) | A stat can slow a stage hazard down: the fly moves (and buzzes) in slow motion with Perception above 5 | Accepted |
| [0066](0066-fly-annoys-her.md) | A hazard sitting on her for a second annoys her: the date stops, she gets angry and says ".....ew", the date loses points | Accepted, amended by 0067 |
| [0067](0067-annoyances-are-files.md) | How she reacts when annoyed is its own file (`data/annoyances/`); a hazard points at one; not in dialogue yet | Accepted |
| [0068](0068-one-key-for-apps.md) | One key, W, flips through the phone's apps (Contacts, Profile, back to the calendar) instead of C and P | Accepted |
| [0069](0069-no-one-left-gives-days-back.md) | With no one left on the dating app, Back to the calendar gives the date's 2 days back | Accepted |
| [0070](0070-stats-hub.md) | A stats hub beside the phone; training flies the stat's picture into it, the hub swallows it and the number goes up | Accepted |
| [0071](0071-fly-paths-safe-to-edit.md) | The fly's paths are safe to move, stretch and turn: handles in their middle, any Path2D in the scene counts, unusable paths skipped with a warning | Accepted |
| [0072](0072-synergy-streams-and-hub-names.md) | Synergy (for now: shared tags) shown in Contacts as a stream of sprites between two girls, stronger with more; the stats hub shows a stat's name on hover | Accepted |
