#Requires AutoHotkey v2.0-a
#SingleInstance Force

global windows := []  ; Initialize windows as a global variable

LWin & LButton::ShowWindowList()

ShowWindowList() {
    myGui := Gui()  ; Create GUI using the correct method in AHK v2
    ListBox := myGui.Add("ListBox", "vWindowList w300 h400")  ; Add ListBox

    windows := WinGetList()  ; Retrieve list of open windows
    for index, hWnd in windows {
        title := WinGetTitle("ahk_id " . hWnd)
        if (title != "") {
            ListBox.Add([title]) ; Update this line
        }
    }    

    ListBox.OnEvent("Change", WindowSelected)  ; Bind selection event to function
    myGui.OnEvent("Close", ExitApp)  ; Exit script when GUI is closed using Func("ExitApp")

    MouseGetPos(&xpos, &ypos)
    myGui.Show("x" . xpos . " y" . ypos . " AutoSize")  ; Show GUI at mouse position
}

WindowSelected(LBC, *) {
    selectedIndex := LBC.Value
    if (selectedIndex > 0) {
        hWnd := windows[selectedIndex]
        WinActivate("ahk_id " . hWnd)  ; Activate selected window
        LBC.Gui.Close()  ; Close the GUI
    }
}

ExitApp(Gui, *) {
    ExitApp 0  ; Correctly exits the script
}
