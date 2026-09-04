# Contributing

Taskeybar is a small Windows utility. Keep changes narrow and easy to verify on
a normal Windows desktop.

## Development Setup

Install AutoHotkey v2 from https://www.autohotkey.com/ and run the script from
the repository root:

```powershell
& 'C:\Program Files\AutoHotkey\v2\AutoHotkey.exe' taskeybar.ahk
```

The repository does not require a package manager, build system, or generated
source step.

## Manual Verification

Before publishing a release or merging behavior changes, verify the common
desktop flow:

- Start Taskeybar from source.
- Confirm that the startup message appears.
- Press `Win+Left Mouse Button` and confirm that visible windows appear near
  the pointer.
- Press `Ctrl+Win+Space` and confirm that visible windows appear again without
  using the mouse.
- Click a listed window with the mouse and confirm that it activates
  immediately.
- Select a listed window with the keyboard and confirm that `Enter` activates
  it.
- Type into the filter box and confirm that exact substring matching updates
  the list live.
- Turn on `Fuzzy` and confirm that in-order character matching updates the list
  live.
- Press `Ctrl+C` and confirm that the selected line is copied to the
  clipboard.
- Select a window, press `Delete`, and confirm that it receives a normal close
  request rather than having its process terminated. Confirm that Taskeybar
  stays open and selects the next entry at the same list position.
- Filter down to several windows from one application and confirm that repeated
  presses of `Delete` close them in sequence without reopening Taskeybar.
- Repeat the `Delete` check with an editor containing unsaved changes and
  confirm that its save prompt appears and can cancel closing.
- Click the `?` button and confirm that the keyboard help appears as a modal
  dialog owned by Taskeybar.
- Resize the window, close it, reopen it, and confirm that the current size is
  reused while the script keeps running.
- Move a keyboard-triggered popup, close it by clicking another window, and
  confirm that the next keyboard trigger reopens at the new position.
- Open the list again and close it with `Esc`.
- Open the list again and close it with the window `X`.
- Confirm that Taskeybar does not appear in `Alt+Tab` during normal use.
- Start Taskeybar a second time and confirm that `#SingleInstance Force`
  replaces the previous instance cleanly.

If a change affects sorting or filtering, test with multiple windows from the
same executable and at least one empty-title or utility window.

## Release Notes

Release binaries should be attached to GitHub releases. Do not commit generated
`.exe` files to the repository.

For a standard AutoHotkey v2 installation, build a release binary with Ahk2Exe:

```powershell
$repo = Resolve-Path .
New-Item -ItemType Directory -Force release | Out-Null
Push-Location 'C:\Program Files\AutoHotkey\Compiler'
.\Ahk2Exe.exe /in "$repo\taskeybar.ahk" /out "$repo\release\taskeybar.exe" /bin 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
Pop-Location
```

The compiler directives beside the runtime `version` value copy that version
into the executable's file and product metadata. Keep the changelog release
heading and runtime version aligned before building.

Keep the generated file in `release/` or another ignored local location before
uploading it to the release.

Update `CHANGELOG.md` only for user-visible changes or release-relevant
maintenance.
