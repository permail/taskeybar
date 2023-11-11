#Requires AutoHotkey v2.0-a
#SingleInstance Force

global windows := []  ; Initialize windows as a global variable

LWin & LButton::ShowWindowList()

ShowWindowList() {
    myGui := Gui()  ; Create GUI using the correct method in AHK v2
    ListBox := myGui.Add("ListBox", "vWindowList w200 h300")  ; Add ListBox

    xpos := "", ypos := ""
    MouseGetPos(&xpos, &ypos)

    windows := WinGetList()  ; Retrieve list of open windows
    for index, hWnd in windows {
        title := WinGetTitle("ahk_id " . hWnd)
        if (title != "") {
            ListBox.Add(title)  ; Update this line
        }
    }    

    ListBox.OnEvent("Select", Func("WindowSelected"))  ; Bind selection event to function
    myGui.OnEvent("Close", Func("ExitApp"))  ; Exit script when GUI is closed using Func("ExitApp")
    myGui.Show("x" . xpos . " y" . ypos . " h300 w200")  ; Show GUI at mouse position
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
    ExitApp  ; Correctly exits the script
}
