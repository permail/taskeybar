; Ensure the script stays running
Persistent := true
SetBatchLines(-1)

; Create the GUI
Gui := GuiCreate("Windows List")
Gui.Add("ListBox", "vWindowList w200 h300", "").OnEvent("Select", Func("SelectWindow"))
Gui.Show("x0 y0 h300 w200")

; Function to refresh the window list
RefreshWindowList := () => {
    WindowList := Gui.WindowList
    WindowList.DeleteAll()
    windows := WinGetList("","")
    for each, id in windows {
        thisTitle := WinGetTitle("ahk_id " . id)
        if (thisTitle != "")
            WindowList.Add("", thisTitle)
    }
}

; Function to handle window selection
SelectWindow := (Control) => {
    CurrentSelection := Control.Value
    windows := WinGetList("","")
    for each, id in windows {
        thisTitle := WinGetTitle("ahk_id " . id)
        if (thisTitle = CurrentSelection) {
            WinActivate("ahk_id " . id)
            break
        }
    }
}

; Hotkey to refresh the window list
Hotkey("^!r", Func("RefreshWindowList"))

; Initial refresh of the window list
RefreshWindowList()

; Exit the script when the GUI is closed
Gui.OnEvent("Close", () => ExitApp())

return
