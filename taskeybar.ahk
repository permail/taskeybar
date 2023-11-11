; Auto-execute section
Gui := GuiCreate("Window List")
ListBox := Gui.Add("ListBox", "vWindowList w200 h300")
Gui.Show("x0 y0 h300 w200")
UpdateWindowList()

; Function to update the window list
UpdateWindowList() {
    ListBox.DeleteAll()
    windows := WinGetList()
    for index, hWnd in windows {
        title := WinGetTitle("ahk_id " . hWnd)
        if (title != "")
            ListBox.Add(hWnd, title)
    }
}

; Bind the ListBox Select event to a function
ListBox.OnEvent("Select", "WindowSelected")

; Function called when a window is selected from the list
WindowSelected(Control) {
    hWnd := Control.Value
    if (hWnd != "")
        WinActivate("ahk_id " . hWnd)
}

; Hotkey to refresh the window list
Hotkey("^!r", "UpdateWindowList")

; Function to handle GUI close event
GuiClose() {
    ExitApp()
}
Gui.OnEvent("Close", "GuiClose")
