#Require AhkVersion 2

; Hotkey to show window list
Hotkey("LWin & LButton", Func("ShowWindowList"))

; Function to show the window list
ShowWindowList() {
    MouseGetPos(mouseX, mouseY)
    Gui := GuiCreate()  ; Create GUI
    ListBox := Gui.Add("ListBox", "vWindowList w200 h300")  ; Add ListBox
    Gui.OnEvent("Close", Func("ExitApp"))  ; Exit script when GUI is closed

    ; Populate ListBox with open windows
    windows := WinGetList()  ; Retrieve list of open windows
    for index, hWnd in windows {
        title := WinGetTitle("ahk_id " . hWnd)
        if (title != "") {
            ListBox.Add("", title)  ; Add window title to list
        }
    }

    ListBox.OnEvent("Select", Func("WindowSelected"))  ; Bind selection event to function
    Gui.Show("x" . mouseX . " y" . mouseY . " h300 w200")  ; Show GUI at mouse position
}

; Function called when a window is selected from the list
WindowSelected(Control) {
    selectedIndex := Control.SelectedIndex
    if (selectedIndex) {
        hWnd := windows[selectedIndex]
        WinActivate("ahk_id " . hWnd)  ; Activate selected window
        Control.Gui.Close()  ; Close the GUI
    }
}

; Function to handle GUI close event
ExitApp() {
    ExitApp()
}
