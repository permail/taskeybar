#Requires AutoHotkey v2.0-a
#SingleInstance Force

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

    ListBox.OnEvent("Change", myListBox_Change)  ; Bind selection event to function

    CoordMode "Mouse", "Screen"
    MouseGetPos(&xpos, &ypos)
    myGui.Show("x" . xpos . " y" . ypos . " AutoSize")  ; Show GUI at mouse position
}

myListBox_Change(Ctrl, *) {
    selectedIndex := Ctrl.Value
    if (selectedIndex > 0) {
        windowText := Ctrl.Text()

        hWnd := windows.Get(selectedIndex)
        WinActivate("ahk_id " . hWnd)  ; Activate selected window
        Ctrl.Gui.Close()  ; Close the GUI
    }
}