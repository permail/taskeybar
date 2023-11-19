#Requires AutoHotkey v2.0-a
#SingleInstance Force

LWin & LButton::ShowWindowList()

ShowWindowList() {
    myGui := Gui()  ; Create GUI using the correct method in AHK v2
    myListBox := myGui.Add("ListBox", "vWindowList w300 h400")  ; Add ListBox

    windows := WinGetList()  ; Retrieve list of open windows
    for index, hWnd in windows {
        windowTitle := WinGetTitle("ahk_id " . hWnd)
        if (windowTitle != "") {
            myListBox.Add([windowTitle]) ; Update this line
        }
    }

    activeWindowTitle := WinGetTitle("ahk_id " . WinActive)
    if (activeWindowTitle != ""){
        myListBox.Text := activeWindowTitle
    }

    myListBox.OnEvent("Change", myListBox_Change)  ; Bind selection event to function

    CoordMode "Mouse", "Screen"
    MouseGetPos(&xpos, &ypos)
    myGui.Show("x" . xpos . " y" . ypos . " AutoSize")  ; Show GUI at mouse position
}

myListBox_Change(Ctrl, *) {
    selectedIndex := Ctrl.Value
    if (selectedIndex > 0) {
        windowTitle := Ctrl.Text
        WinActivate(windowTitle)  ; Activate selected window
;        Ctrl.Gui.Close()  ; Close the GUI
    }
}