#Requires AutoHotkey v2.0-a

Hotkey("LWin & LButton", Func("ShowWindowList"))

ShowWindowList() {
    Gui := GuiCreate()  ; Create GUI
    ListBox := Gui.Add("ListBox", "vWindowList w200 h300")  ; Add ListBox
    Gui.OnEvent("Close", Func("ExitApp"))  ; Exit script when GUI is closed

    ; Initialize variables for MouseGetPos
    xpos := "", ypos := ""
    MouseGetPos(&xpos, &ypos)

    ; Populate ListBox with open windows
    windows := WinGetList()  ; Retrieve list of open windows
    for index, hWnd in windows {
        title := WinGetTitle("ahk_id " . hWnd)
        if (title != "") {
            ListBox.Add("", title)  ; Add window title to list
        }
    }

    ListBox.OnEvent("Select", Func("WindowSelected"))  ; Bind selection event to function
    Gui.Show("x" . xpos . " y" . ypos . " h300 w200")  ; Show GUI at mouse position
}

WindowSelected(Control) {
    selectedIndex := Control.SelectedIndex
    if (selectedIndex) {
        hWnd := windows[selectedIndex]
        WinActivate("ahk_id " . hWnd)  ; Activate selected window
        Control.Gui.Close()  ; Close the GUI
    }
}

ExitApp() {
    ExitApp()
}
