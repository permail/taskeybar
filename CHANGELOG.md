# Changelog

## v1.1.0 - 2026-09-04

- Add `Delete` to request a normal close of the selected window while
  preserving application save prompts and cancellation. Taskeybar stays open
  and keeps the next matching window selected for repeated closing.
- Add a compact in-app `?` help dialog for keyboard controls and filtering.

## v1.0.0 - 2026-04-13

- Add a second fixed trigger: `Ctrl+Win+Space` opens Taskeybar without using
  the mouse.
- Add live filtering with exact substring matching by default and a `Fuzzy`
  toggle for in-order character matching.
- Add keyboard-first list control: arrow keys move the selection and `Enter`
  activates the selected window.
- Make mouse clicks activate the selected window immediately.
- Add `Ctrl+C` to copy the selected window line to the clipboard.
- Make the list window resizable and keep the current size, filter text,
  `Fuzzy` state, and keyboard-triggered position while Taskeybar is running.
- Keep a horizontal scrollbar available for long window titles.
- Reopen the keyboard-triggered popup at the last position you left it, even
  when closing by switching to another window.
- Require stable AutoHotkey v2 instead of an AutoHotkey v2 alpha runtime.
- Simplify close and reopen behavior so Taskeybar hides and reopens reliably
  without dropping its hotkeys.
- Open the mouse-triggered popup near the pointer while keeping the keyboard
  trigger independent from mouse placement.
- Keep Taskeybar out of `Alt+Tab` during normal use.
- Reuse the popup window between activations so repeated keyboard opens do not
  flash the UI.
- Clean up repository documentation, contributor guidance, and shipped
  screenshots for a public release-ready repository.
- Remove the personal email address from the runtime notice and use a public
  copyright line instead.

## v0.2.0 - 2023-11-19

- Show a popup to confirm loading, display the version, and show the usage hint.
- Sort the window list by process name and then window title.
- Highlight the currently active window in the list.

## v0.1.0 - 2023-11-11

- Show a list of windows.
- Activate a window when the user clicks it in the list.
- Close the window list when the user presses `Esc` or clicks away.
- Keep Taskeybar itself out of the window list.
- Use the query order from Windows, showing windows from last active first.

## v0.0.0 - 2023-11-11

- Start the project with semantic versioning and a changelog.
