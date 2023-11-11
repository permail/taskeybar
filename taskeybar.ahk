#Persistent
#NoEnv
SetBatchLines(-1)

; Create the GUI
Gui := GuiCreate("Windows List")
Gui.Add("ListBox", "vWindowList gSelectWindow w200 h300")
Gui.OnEvent("Close", "GuiClose")
Gui.Show("x0 y0 h300 w200")

; Function to refresh the window list
RefreshWindowList := () => {
    global Gui
    WindowList := Gui.WindowList
    WindowList.Delete()
    windows := WinGetList()
    for each, id in windows
    {
        thisTitle := WinGetTitle("ahk_id " . id)
        if (thisTitle != "")
            WindowList.Add("", thisTitle)
    }
}

; Function to handle window selection
SelectWindow := () => {
    global Gui
    CurrentSelection := Gui.WindowList.Value
    windows := WinGetList()
    for each, id in windows
    {
        thisTitle := WinGetTitle("ahk_id " . id)
        if (thisTitle = CurrentSelection)
        {
            WinActivate("ahk_id " . id)
            break
        }
    }
}

; Hotkey to refresh the window list
Hotkey("^!r", RefreshWindowList)

GuiClose := () => {
    ExitApp()
}

; Initial refresh of the window list
RefreshWindowList()
