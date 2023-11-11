#Persistent
#NoEnv
SetBatchLines, -1

; Create the GUI
Gui, Add, ListBox, vWindowList gSelectWindow w200 h300, 
Gui, Show, x0 y0 h300 w200, Windows List

; Function to refresh the window list
RefreshWindowList() {
    GuiControl,, WindowList,  ; Clear the ListBox
    WinGet, windows, List  ; Get the list of windows
    Loop, %windows%
    {
        thisID := windows%A_Index%
        WinGetTitle, thisTitle, ahk_id %thisID%
        if (thisTitle != "")  ; Add non-empty titles to the list
            GuiControl,, WindowList, %thisTitle%
    }
}

; Function to handle window selection
SelectWindow:
GuiControlGet, CurrentSelection,, WindowList
WinGet, windows, List
Loop, %windows%
{
    thisID := windows%A_Index%
    WinGetTitle, thisTitle, ahk_id %thisID%
    if (thisTitle = CurrentSelection) {
        WinActivate, ahk_id %thisID%
        break
    }
}
return

; Hotkey to refresh the window list
^!r::  ; Ctrl+Alt+R
RefreshWindowList()
return