# Taskeybar
A minimalist's replacement for a vertical taskbar that Windows 11 does not feature but its predecessors did.

## Usage
After pressing the key-and-mouse combination Win+LeftMouseButton, taskeybar shows a list of visible windows. This list mimicks a vertical Windows taskbar. Each line displays the window title and program name of one window. The windows are sorted by their .exe name and window title, in order to have a stable order for each activation and at the same time have windows of the same program next to each other.

Click a line to activate the corresponding window. The Taskeybar window disappears, but Taskeybars stays in the background and is ready to activate again.

## Running
Run the taskeybar.exe once. A message box confirms a successful start. You can have taskeybar.exe start automatically when starting Windows or logging on, using Windows' built-in features, e.g. start menu / autostart.

## Developer Notes
Taskeybar is implemented as an [autohotkey](https://www.autohotkey.com/) [v2](https://www.autohotkey.com/v2/) script. Therefore it is quite easy to understand and adapt to your needs. Feel free to post pull requests.
