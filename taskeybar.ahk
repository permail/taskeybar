Gui := GuiCreate()  ; Create GUI
ListBox := Gui.Add("ListBox", "vWindowList w200 h300")  ; Add ListBox

; Populate ListBox with open windows
UpdateWindowList := () => {
    ListBox.Delete()  ; Clear current list
    WinGet, windows, List  ; Retrieve list of open windows
    for index, hWnd in windows {
        title := WinGetTitle("ahk_id " . hWnd)
        if (title != "") {
            ListBox.Add(title)  ; Add window title to list
        }
    }
}

; Function called when a window is selected from the list
WindowSelected := () => {
    selectedIndex := ListBox.SelectedIndex
    if (selectedIndex) {
        hWnd := windows[selectedIndex]
        WinActivate("ahk_id " . hWnd)  ; Activate selected window
    }
}

ListBox.OnEvent("Select", WindowSelected)  ; Bind selection event to function

Gui.Show("x0 y0 h300 w200")  ; Show GUI

UpdateWindowList()  ; Initial population of window list

Hotkey("^!r", UpdateWindowList)  ; Hotkey to refresh window list

Gui.OnEvent("Close", "ExitApp")  ; Exit script when GUI is closed
