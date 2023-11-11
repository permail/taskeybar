; Hotkey to show window list
Hotkey("LWin & LButton", "ShowWindowList")

; Function to show the window list
ShowWindowList() {
    MouseGetPos, mouseX, mouseY
    Gui := GuiCreate("Window List", "x" mouseX " y" mouseY)  ; Create GUI at mouse position
    ListBox := Gui.Add("ListBox", "vWindowList w200 h300")  ; Add ListBox
    
    ; Populate ListBox with open windows
    windows := WinGetList("","")
    for index, hWnd in windows {
        title := WinGetTitle("ahk_id " . hWnd)
        if (title != "")
            ListBox.Add("", title)  ; Add window title to list
    }

    ListBox.OnEvent("Select", "WindowSelected")  ; Bind selection event to function
    Gui.OnEvent("Close", Func("ExitApp"))  ; Exit script when GUI is closed
    Gui.Show()  ; Show GUI
}

; Function called when a window is selected from the list
WindowSelected(GuiCtrl) {
    selectedIndex := GuiCtrl.Value
    if (selectedIndex) {
        hWnd := windows[selectedIndex]
        WinActivate("ahk_id " . hWnd)  ; Activate selected window
        Gui.Close()  ; Close the GUI
    }
}

; Function to close the GUI and exit the script
ExitApp() {
    Gui.Close()  ; Close the GUI
    ExitApp()  ; Exit the script
}
