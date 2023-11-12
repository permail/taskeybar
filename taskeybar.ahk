#Requires AutoHotkey v2.0-a
#SingleInstance Force

global guiExists := 0
global myGui

LWin & LButton::ShowWindowList()

ShowWindowList() {
    if (guiExists == 0 ){
        CreateGui()
    }
    UpdateWindowList()
    ShowGuiAtMouse()
}

ShowGuiAtMouse(){
    CoordMode "Mouse", "Screen"
    MouseGetPos(&xpos, &ypos)
    myGui.Show("x" . xpos . " y" . ypos . " AutoSize")  ; Show GUI at mouse position
}

CreateGui(){
    global guiExists := 1
    global myGui := Gui()  ; Create GUI using the correct method in AHK v2
    global myListBox := myGui.Add("ListBox", "vWindowList w300 h400")  ; Add ListBox

    myListBox.OnEvent("Change", myListBox_Change)  ; Bind selection event to function
    myGui.OnEvent("Escape", myGui_Escape)
}

UpdateWindowList(){
    global windows := WinGetList()  ; Retrieve list of open windows
    myListBox.Delete()
    for index, hWnd in windows {
        windowTitle := WinGetTitle("ahk_id " . hWnd)
        if (windowTitle != "") {
            myListBox.Add([windowTitle]) ; Update this line
        }else{
            myListBox.Add(["hWnd " . hWnd]) 
        }
    }

    activeWindowhWnd := WinActive("A")
    activeWindowTitle := WinGetTitle("ahk_id " . activeWindowhWnd)
    if (activeWindowTitle != ""){
        myListBox.Text := activeWindowTitle
    }
}

CloseGui(){
    myGui.Close.Call()

    global guiExists := 0
}

myListBox_Change(Ctrl, *) {
;    MsgBox("global list: " . windows.Length)

    selectedIndex := Ctrl.Value
    if (selectedIndex > 0) {
        windowTitle := Ctrl.Text
        WinActivate(windowTitle)  ; Activate selected window
        CloseGui()
    }
}

myGui_Escape(Gui,*){
    CloseGui()
}