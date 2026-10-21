# 0049: Screens open like iPhone apps

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [core-loop.md](../design/core-loop.md), [calendar.md](../design/calendar.md), [dates.md](../design/dates.md), [0037](0037-phone-app-overlays.md), [0048](0048-microgame-framework.md)

## Decision

One shared animation, `AppLauncher` (an autoload), opens screens the way an iPhone opens an app: the app's icon grows from where the player tapped (or a given rectangle, e.g. the Start button or the picked option bubble) to fill the screen with the app's launch screen while the screen behind zooms and dims, the change happens underneath, then the launch screen fades. Closing shrinks the app back into its icon.

It's used for the dating app, the calendar, starting a date, microgames (open from the picked bubble, close back into it) and, once it exists, the boss fight.

Each app is a file in `data/apps/` (`AppInfo`: icon, tile colour, launch colour or image, launch icon size, optional sounds). The motion is one shared file, `data/app_transition_style.tres` (`AppTransitionStyle`: timings, easing, icon size and roundness, default origin, screen insets and corner for a future phone screen, an optional device frame, how the screen behind zooms and dims, default sounds). Placeholder icons are our existing icons until app art exists.

## Why

The game is framed as the player's phone; opening everything like an app ties the screens together and reads instantly. Keeping the look per app and the motion in one file means app art, iPhone art and timing can all change without code.

## Not chosen

A separate animation per screen; drawing the new screen inside the growing tile (the launch screen does the same job and works for scene changes and overlays alike); a blur on the screen behind (a dim and zoom for now).

## Revisit when

The phone becomes a device drawn on screen (use the Screen insets and Device Frame), or loading a scene takes long enough to need a real loading screen.

## Note (2026-10-21)

The phone is now drawn on screen ([0058](0058-phone-and-real-life.md)): apps open inside its screen (**Open Into Phone**), and going into a date is phone down rather than an app opening.
