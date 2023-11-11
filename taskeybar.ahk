; Create the GUI
Gui := GuiCreate()
Gui.Add("ListBox", "vWindowList w200 h300", "")
Gui.Show("x0 y0 h300 w200")

; Function to refresh the window list
UpdateWindowList := () => {
    GuiControlGet, ListBox, % "WindowList"
    ListBox.Delete()  ; Clear the ListBox
    WinGet, windows, List  ; Get the list of windows
    Loop, % windows {
        thisID := windows%A_Index%
        WinGetTitle, thisTitle, % "ahk_id " thisID
        if (thisTitle != "")  ; Add non-empty titles to the list
            ListBox.Add(thisTitle)
    }
}

; Function to handle window selection
ListBox.OnEvent("Select", Func("SelectWindow"))
SelectWindow := () => {
    GuiControlGet, CurrentSelection, % "WindowList"
    WinGet, windows, List
    Loop, % windows {
        thisID := windows%A_Index%
        WinGetTitle, thisTitle, % "ahk_id " thisID
        if (thisTitle = CurrentSelection) {
            WinActivate, % "ahk_id " thisID
            break
        }
    }
}

; Hotkey to refresh the window list
Hotkey("^!r", UpdateWindowList)

; Initial refresh of the window list
UpdateWindowList()

; Exit the script when the GUI is closed
Gui.OnEvent("Close", Func("ExitApp"))
