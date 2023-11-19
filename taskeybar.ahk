#Requires AutoHotkey v2.0-a
#SingleInstance Force

global version := "0.2.0-alpha47"
msgBox("Taskeybar v" . version . " loaded.`nWin+LeftClick to display.")

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
    ; Show GUI at mouse position with previous app under the pointer,
    ; so that the user only needs to click without any prior movement.
    myGui.Show("x" . xpos-256 . " y" . ypos-48 . " AutoSize")  
}

CreateGui(){
    global guiExists := 1
    global myGui := Gui(,"Taskeybar - List of Windows") 
    global myListBox := myGui.Add("ListBox", "vWindowList w300 h400")

    myGui.OnEvent("Escape", myGui_Escape)
    myListBox.OnEvent("Change", myListBox_Change)
    myListBox.OnEvent("LoseFocus",myListBox_LoseFocus)
}

UpdateWindowList(){
    global windows := WinGetList()
    
    global namedWindows 
    namedWindows := Array()

    for index, hWnd in windows {
        windowTitle := WinGetTitle("ahk_id " . hWnd)
        if (windowTitle != "" && windowTitle != myGui.Title) {

            processName := WinGetProcessName(hWnd)
            itemText := windowTitle . " (" . processName . ")"
            itemText := windowTitle . " (" . processName . ")"
            sortby := processName . " - " . windowTitle

            stuff := sortBy . "`t" . hWnd . "`t" . itemText
            namedWindows.Push(stuff) 
        }
    }

    ; sort the named windows
    sortme := ""
    for index, stuff in namedWindows {
        if ( sortme != "" ) {
            sortme := sortme . "`n"
        }
        sortme := sortme . stuff
    }
    sorted := sort(sortme)
    namedWindows := StrSplit(sorted,"`n")

    ; update ui list 
    activeWindowhWnd := WinActive("A")
    myListBox.Delete()
    for index, stuff in namedWindows {
        stuffParts := StrSplit(stuff, "`t")
        hWnd :=  Integer(stuffParts[2])
        itemText := stuffParts[3]
        myListBox.Add([itemText])

        ; if there is an active window, pre-select that, as a visual hint
        if (activeWindowhWnd = hWnd) {
            myListBox.Text := itemText
        }
     }
}

CloseGui(){
    myGui.Destroy()
    global guiExists := 0
}

myListBox_Change(Ctrl, *) {
    global namedWindows

    selectedIndex := Ctrl.Value
    if (selectedIndex > 0) {
        stuff := namedWindows[selectedIndex]
        stuffParts := StrSplit(stuff, "`t")
        hWnd :=  Integer(stuffParts[2])
        WinActivate(hWnd) 
        CloseGui()
    }
}

myListBox_LoseFocus(Ctrl,*){
    CloseGui()
}

myGui_Escape(Gui,*){
    CloseGui()
}