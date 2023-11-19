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
    global myGui := Gui(,"Taskeybar List of Windows")  ; Create GUI using the correct method in AHK v2
    global myListBox := myGui.Add("ListBox", "vWindowList w300 h400")  ; Add ListBox

    myGui.OnEvent("Escape", myGui_Escape)
    myListBox.OnEvent("Change", myListBox_Change)  ; Bind selection event to function
    myListBox.OnEvent("LoseFocus",myListBox_LoseFocus)
}

UpdateWindowList(){
    global windows := WinGetList()  ; Retrieve list of open windows
    myListBox.Delete()
    for index, hWnd in windows {
        windowTitle := WinGetTitle("ahk_id " . hWnd)
        if (windowTitle != "" && windowTitle != myGui.Title) {
            myListBox.Add([windowTitle]) ; Update this line
        }else{
;            myListBox.Add(["hWnd " . hWnd]) 
        }
    }

    activeWindowhWnd := WinActive("A")
    activeWindowTitle := WinGetTitle("ahk_id " . activeWindowhWnd)
    if (activeWindowTitle != ""){
        myListBox.Text := activeWindowTitle
    }
}

CloseGui(){
    myGui.Destroy()
    global guiExists := 0
}

myListBox_Change(Ctrl, *) {
    selectedIndex := Ctrl.Value
    if (selectedIndex > 0) {
        windowTitle := Ctrl.Text
        WinActivate(windowTitle)  ; Activate selected window
        CloseGui()
    }
}

myListBox_LoseFocus(Ctrl,*){
    CloseGui()
}

myGui_Escape(Gui,*){
    CloseGui()
}