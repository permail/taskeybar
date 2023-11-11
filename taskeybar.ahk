Persistent := true
SetBatchLines(-1)

Gui := GuiCreate("Windows List")
ListBox := Gui.Add("ListBox", "vWindowList w200 h300")
Gui.Show("x0 y0 h300 w200")

; Function to refresh the window list
RefreshWindowList := Func("UpdateWindowList")
UpdateWindowList := () => {
    ListBox.DeleteAll()
    windows := WinGetList()
    for index, id in windows
    {
        title := WinGetTitle("ahk_id " . id)
        if (title != "")
            ListBox.Add(id, title)
    }
}

; Function to handle window selection
SelectWindow := () => {
    selectionID := ListBox.Value
    if (selectionID != "")
        WinActivate("ahk_id " . selectionID)
}

; Bind the selection event to the list box
ListBox.OnEvent("Select", Func("SelectWindow"))

; Hotkey to refresh the window list
Hotkey("^!r", RefreshWindowList)

; Initial refresh of the window list
RefreshWindowList()

; Exit the script when the GUI is closed
Gui.OnEvent("Close", Func("ExitApp"))
