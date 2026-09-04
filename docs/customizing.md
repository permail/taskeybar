# Customizing Taskeybar From Source

Taskeybar is intentionally a single-script tool. If you want behavior that is
too specific for the public default, editing the script is often the simplest
path.

The main script is [taskeybar.ahk](../taskeybar.ahk).

## Common Tweaks

The current script keeps most UI values as class constants near the top of
`TaskeybarPopup` and the input codes near the top of `TaskeybarApp`. That is
the intended place for small behavior changes.

Common examples:

- startup text and popup titles
  `StartupTitle`, `StartupCopyright`, `WindowTitle`
- default geometry
  `DefaultWindowWidth`, `DefaultWindowHeight`,
  `MinimumWindowWidth`, `MinimumWindowHeight`
- mouse placement
  `MouseFilterOffsetY`
- first keyboard fallback position
  `KeyboardFallbackLeftFrameAdjustment`, `KeyboardFallbackY`
- layout dimensions
  `LayoutMargin`, `FuzzyWidth`, `HelpWidth`, `FilterHeight`,
  `MinimumControlWidth`, `MinimumListHeight`

## Hotkeys

The shipped defaults are:

- `LWin & LButton`
- `^#Space`

If you want different triggers, edit the hotkey bindings at the bottom of
`taskeybar.ahk`.

Taskeybar does not currently provide an in-app hotkey configuration dialog.
That keeps the distributed binary simple and avoids adding persistent config
storage for a feature that is easy to change in source.

## Filter Behavior

The two built-in filter modes live in `MatchesFilter()`.

If you want a different matching strategy, this is the place to change it. For
example:

- case-sensitive matching
- only process-name matching
- regex-based matching
- score-based fuzzy ranking instead of the current in-order check

## State Persistence

Taskeybar currently keeps runtime state in memory only. That includes:

- size
- filter text
- `Fuzzy` state
- keyboard-triggered position

No on-disk config or history file is written. If you want settings to survive
restarts, you would need to add explicit file-backed persistence.

## What Not To Expect

Taskeybar is intentionally not trying to become:

- a shell replacement
- a taskbar skinning framework
- a full tiling or window management system
- a universal settings-heavy launcher

If your desired behavior moves in that direction, it is usually better to keep
Taskeybar narrow and fork your own variant than to overload the shared default.
