Gui := GuiCreate()  ; Create GUI
ListBox := Gui.Add("ListBox", "vWindowList w200 h300")  ; Add ListBox

; Populate ListBox with open windows
FuncUpdateWindowList := Func("UpdateWindowList")
UpdateWindowList() {
    ListBox.Delete()  ; Clear current list
    windows := WinGetList("","")  ; Retrieve list of open windows
    for index, hWnd in windows {
        title := WinGetTitle("ahk_id " . hWnd)
        if (title != "")
            ListBox.Add("", title)  ; Add window title to list
    }
}

; Function called when a window is selected from the list
FuncWindowSelected := Func("WindowSelected")
WindowSelected() {
    selectedIndex := ListBox.SelectedIndex
    if (selectedIndex) {
        hWnd := windows[selectedIndex]
        WinActivate("ahk_id " . hWnd)  ; Activate selected window
    }
}

ListBox.OnEvent("Select", FuncWindowSelected)  ; Bind selection event to function

Gui.Show("x0 y0 h300 w200")  ; Show GUI

FuncUpdateWindowList.Call()  ; Initial population of window list

Hotkey("^!r", FuncUpdateWindowList)  ; Hotkey to refresh window list

Gui.OnEvent("Close", Func("ExitApp"))  ; Exit script when GUI is closed
