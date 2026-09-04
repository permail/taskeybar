/*
Copyright (C) 2023-2026 PerMail

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#Requires AutoHotkey v2.0
#SingleInstance Force

class TaskeybarState {
    __New() {
        this.lastFilterText := ""
        this.lastFuzzyValue := 0
        this.lastPreferredWindowHwnd := 0
        this.hasKeyboardPosition := false
        this.lastKeyboardX := 0
        this.lastKeyboardY := 0
        this.lastWindowWidth := 0
        this.lastWindowHeight := 0
    }
}

class WindowCatalog {
    static GetSortedRows() {
        rows := []

        for hWnd in WinGetList() {
            windowTitle := WinGetTitle("ahk_id " . hWnd)
            if (windowTitle = "") {
                continue
            }

            processName := WinGetProcessName("ahk_id " . hWnd)
            itemText := windowTitle . " (" . processName . ")"
            sortKey := processName . " - " . windowTitle
            rows.Push({
                sortKey: sortKey,
                hWnd: hWnd,
                itemText: itemText
            })
        }

        if (rows.Length = 0) {
            return []
        }

        sortedRows := []
        for row in rows {
            insertAt := sortedRows.Length + 1
            loop sortedRows.Length {
                if (StrCompare(row.sortKey, sortedRows[A_Index].sortKey, false) < 0) {
                    insertAt := A_Index
                    break
                }
            }
            sortedRows.InsertAt(insertAt, row)
        }

        return sortedRows
    }

    static MatchesFilter(itemText, filterText, fuzzyEnabled) {
        if (filterText = "") {
            return true
        }

        if (!fuzzyEnabled) {
            return InStr(itemText, filterText, false)
        }

        searchPos := 1
        for char in StrSplit(filterText) {
            foundPos := InStr(itemText, char, false, searchPos)
            if (!foundPos) {
                return false
            }
            searchPos := foundPos + 1
        }

        return true
    }
}

class TaskeybarPopup {
    static WindowTitle := "Taskeybar Window List"
    static DefaultWindowWidth := 448
    static DefaultWindowHeight := 420
    static MinimumWindowWidth := 280
    static MinimumWindowHeight := 220
    static InitialFilterWidth := 236
    static InitialListWidth := 300
    static InitialListHeight := 400
    static ListHorizontalExtent := 4000
    static MouseFilterOffsetY := 48
    static KeyboardFallbackY := 0
    static KeyboardFallbackLeftFrameAdjustment := 7
    static LayoutMargin := 8
    static FuzzyWidth := 60
    static HelpWidth := 28
    static FilterHeight := 23
    static MinimumControlWidth := 120
    static MinimumListHeight := 80
    static TriggerMouse := "mouse"
    static TriggerKeyboard := "keyboard"

    __New(app, state) {
        this.app := app
        this.state := state
        this.triggerKind := TaskeybarPopup.TriggerKeyboard
        this.preferredHwnd := 0
        this.rows := []
        this.isClosing := false
        this.isRefreshing := false
        this.isSuppressingSelectionAction := false
        this.isVisible := false
        this.pendingCloseHwnd := 0
        this.pendingCloseIndex := 0
        this.pendingCloseChecksRemaining := 0
        this.pendingCloseTimer := ObjBindMethod(this, "CheckPendingClose")

        this.gui := Gui(
            Format(
                "+Resize +ToolWindow -MaximizeBox -MinimizeBox +MinSize{}x{}",
                TaskeybarPopup.MinimumWindowWidth,
                TaskeybarPopup.MinimumWindowHeight
            ),
            TaskeybarPopup.WindowTitle
        )
        this.filterEdit := this.gui.Add("Edit", Format("vFilterText w{}", TaskeybarPopup.InitialFilterWidth))
        this.fuzzyCheck := this.gui.Add("Checkbox", "vFuzzy x+8 yp+2", "Fuzzy")
        this.helpButton := this.gui.Add("Button", "x+8 yp-2 w28 h23", "?")
        this.listBox := this.gui.Add(
            "ListBox",
            Format(
                "vWindowList xm y+8 w{} h{} HScroll{}",
                TaskeybarPopup.InitialListWidth,
                TaskeybarPopup.InitialListHeight,
                TaskeybarPopup.ListHorizontalExtent
            )
        )

        this.gui.OnEvent("Escape", ObjBindMethod(this, "Close"))
        this.gui.OnEvent("Close", ObjBindMethod(this, "Close"))
        this.gui.OnEvent("Size", ObjBindMethod(this, "HandleGuiSize"))
        this.filterEdit.OnEvent("Change", ObjBindMethod(this, "FilterWindowList"))
        this.fuzzyCheck.OnEvent("Click", ObjBindMethod(this, "FilterWindowList"))
        this.helpButton.OnEvent("Click", ObjBindMethod(this, "ShowHelp"))
        this.listBox.OnEvent("Change", ObjBindMethod(this, "HandleListBoxChange"))

    }

    Show(triggerKind, preferredHwnd) {
        this.triggerKind := triggerKind
        this.preferredHwnd := preferredHwnd
        this.RestoreUiState()
        this.UpdateWindowList()
        position := this.GetPosition()
        targetWidth := this.GetTargetWidth()
        targetHeight := this.GetTargetHeight()
        this.UpdateLayout(targetWidth, targetHeight)
        this.gui.Show(Format("x{} y{} w{} h{}", position.x, position.y, targetWidth, targetHeight))
        this.isVisible := true
        WinActivate("ahk_id " . this.gui.Hwnd)
        this.filterEdit.Focus()
    }

    GetTargetWidth() {
        return (this.state.lastWindowWidth > 0 ? this.state.lastWindowWidth : TaskeybarPopup.DefaultWindowWidth)
    }

    GetTargetHeight() {
        return (this.state.lastWindowHeight > 0 ? this.state.lastWindowHeight : TaskeybarPopup.DefaultWindowHeight)
    }

    RestoreUiState() {
        this.isRefreshing := true
        this.filterEdit.Text := this.state.lastFilterText
        this.fuzzyCheck.Value := this.state.lastFuzzyValue
        this.isRefreshing := false
    }

    UpdateWindowList(fallbackSelectedIndex := 1) {
        allRows := WindowCatalog.GetSortedRows()
        this.rows := []
        this.listBox.Delete()
        selectedIndex := 0
        visibleIndex := 0
        filterText := this.filterEdit.Text
        fuzzyEnabled := this.fuzzyCheck.Value

        for row in allRows {
            hWnd := row.hWnd
            itemText := row.itemText

            if (hWnd = this.gui.Hwnd) {
                continue
            }

            if (!WindowCatalog.MatchesFilter(itemText, filterText, fuzzyEnabled)) {
                continue
            }

            this.rows.Push(row)
            visibleIndex += 1
            this.listBox.Add([itemText])

            if (this.preferredHwnd != 0 && this.preferredHwnd = hWnd) {
                selectedIndex := visibleIndex
            }
        }

        if (this.rows.Length > 0) {
            this.isSuppressingSelectionAction := true
            try {
                this.listBox.Value := (
                    selectedIndex != 0
                        ? selectedIndex
                        : Min(Max(fallbackSelectedIndex, 1), this.rows.Length)
                )
            } finally {
                this.isSuppressingSelectionAction := false
            }
        }
    }

    FilterWindowList(*) {
        if (this.isRefreshing || this.isClosing) {
            return
        }

        this.RememberUiState()
        this.preferredHwnd := this.GetSelectedHwnd()
        this.UpdateWindowList()
    }

    HandleListBoxChange(*) {
        if (this.isRefreshing || this.isSuppressingSelectionAction || this.isClosing) {
            return
        }

        this.ActivateSelectedWindow()
    }

    HandleGuiSize(guiObj, minMax, width, height) {
        if (this.isClosing || !this.isVisible || guiObj != this.gui) {
            return
        }

        if (minMax = 1 || width <= 0 || height <= 0) {
            return
        }

        this.UpdateLayout(width, height)

        if (minMax = 0) {
            this.state.lastWindowWidth := width
            this.state.lastWindowHeight := height
        }
    }

    UpdateLayout(width, height) {
        margin := TaskeybarPopup.LayoutMargin
        fuzzyWidth := TaskeybarPopup.FuzzyWidth
        helpWidth := TaskeybarPopup.HelpWidth
        filterHeight := TaskeybarPopup.FilterHeight
        filterWidth := Max(TaskeybarPopup.MinimumControlWidth, width - (margin * 4) - fuzzyWidth - helpWidth)
        listTop := margin + filterHeight + margin
        listWidth := Max(TaskeybarPopup.MinimumControlWidth, width - (margin * 2))
        listHeight := Max(TaskeybarPopup.MinimumListHeight, height - listTop - margin)

        this.filterEdit.Move(margin, margin, filterWidth, filterHeight)
        this.fuzzyCheck.Move(margin + filterWidth + margin, margin + 2, fuzzyWidth)
        this.helpButton.Move(margin + filterWidth + margin + fuzzyWidth + margin, margin, helpWidth, filterHeight)
        this.listBox.Move(margin, listTop, listWidth, listHeight)
    }

    HandleKeyDown(wParam, hwnd) {
        if (this.isClosing) {
            return
        }

        if (
            hwnd = this.filterEdit.Hwnd
            || hwnd = this.listBox.Hwnd
            || hwnd = this.fuzzyCheck.Hwnd
            || hwnd = this.helpButton.Hwnd
        ) {
            if (GetKeyState("Ctrl", "P") && wParam = TaskeybarApp.VkC) {
                this.CopySelectedWindowText()
                return 0
            }

            if (wParam = TaskeybarApp.VkDelete) {
                this.CloseSelectedWindow()
                return 0
            }

            if (wParam = TaskeybarApp.VkDown) {
                this.MoveSelection(1)
                return 0
            }

            if (wParam = TaskeybarApp.VkUp) {
                this.MoveSelection(-1)
                return 0
            }
        }

        if ((hwnd = this.filterEdit.Hwnd || hwnd = this.listBox.Hwnd) && wParam = TaskeybarApp.VkEnter) {
            this.ActivateSelectedWindow()
            return 0
        }
    }

    MoveSelection(step) {
        if (this.rows.Length = 0) {
            return
        }

        selectedIndex := this.listBox.Value
        if (selectedIndex <= 0) {
            selectedIndex := 1
        } else {
            selectedIndex += step
        }

        if (selectedIndex < 1) {
            selectedIndex := 1
        } else if (selectedIndex > this.rows.Length) {
            selectedIndex := this.rows.Length
        }

        this.isSuppressingSelectionAction := true
        try {
            this.listBox.Value := selectedIndex
        } finally {
            this.isSuppressingSelectionAction := false
        }
    }

    ActivateSelectedWindow() {
        hWnd := this.GetSelectedHwnd()
        if (hWnd = 0) {
            return
        }

        this.state.lastPreferredWindowHwnd := hWnd
        WinActivate("ahk_id " . hWnd)
        this.Close()
    }

    CopySelectedWindowText() {
        itemText := this.GetSelectedItemText()
        if (itemText = "") {
            return
        }

        A_Clipboard := itemText
    }

    CloseSelectedWindow() {
        hWnd := this.GetSelectedHwnd()
        selectedIndex := this.listBox.Value
        if (hWnd = 0) {
            return
        }

        targetSelector := "ahk_id " . hWnd
        if (!WinExist(targetSelector)) {
            this.preferredHwnd := 0
            this.UpdateWindowList()
            return
        }

        try {
            WinActivate(targetSelector)
        } catch TargetError {
            this.preferredHwnd := 0
            this.UpdateWindowList(selectedIndex)
            return
        }

        try {
            WinClose(targetSelector)
        } catch TargetError {
            this.preferredHwnd := 0
            this.UpdateWindowList(selectedIndex)
            WinActivate("ahk_id " . this.gui.Hwnd)
            this.filterEdit.Focus()
            return
        }

        this.pendingCloseHwnd := hWnd
        this.pendingCloseIndex := selectedIndex
        this.pendingCloseChecksRemaining := 300
        SetTimer(this.pendingCloseTimer, 100)
    }

    CheckPendingClose() {
        if (this.pendingCloseHwnd = 0) {
            SetTimer(this.pendingCloseTimer, 0)
            return
        }

        if (WinExist("ahk_id " . this.pendingCloseHwnd)) {
            this.pendingCloseChecksRemaining -= 1
            if (this.pendingCloseChecksRemaining <= 0) {
                this.pendingCloseHwnd := 0
                SetTimer(this.pendingCloseTimer, 0)
            }
            return
        }

        selectedIndex := this.pendingCloseIndex
        this.pendingCloseHwnd := 0
        this.pendingCloseIndex := 0
        this.pendingCloseChecksRemaining := 0
        SetTimer(this.pendingCloseTimer, 0)

        this.state.lastPreferredWindowHwnd := 0
        this.preferredHwnd := 0
        this.UpdateWindowList(selectedIndex)
        if (this.isVisible) {
            WinActivate("ahk_id " . this.gui.Hwnd)
            this.filterEdit.Focus()
        }
    }

    ShowHelp(*) {
        this.gui.Opt("+OwnDialogs")
        MsgBox(
            "Type to filter the window list.`n`n"
                . "Keyboard shortcuts:`n"
                . "Up / Down: Move the selection`n"
                . "Enter: Activate the selected window`n"
                . "Delete: Close the selected window; keep this list open`n"
                . "Ctrl+C: Copy the selected line`n"
                . "Esc: Close Taskeybar without switching`n`n"
                . "Fuzzy matching:`n"
                . "The typed characters must appear in the same order, but other characters may appear between them.",
            "Taskeybar Help",
            "OK Iconi"
        )
    }

    Close(*) {
        if (this.isClosing) {
            return true
        }

        this.isClosing := true
        this.RememberPosition()
        this.RememberUiState()
        try {
            this.isVisible := false
            this.gui.Hide()
        } finally {
            this.isClosing := false
        }

        return true
    }

    RememberPosition() {
        guiSelector := "ahk_id " . this.gui.Hwnd
        if (!WinExist(guiSelector)) {
            return
        }

        WinGetPos(&windowX, &windowY, , , guiSelector)
        if (this.triggerKind = TaskeybarPopup.TriggerKeyboard) {
            this.state.hasKeyboardPosition := true
            this.state.lastKeyboardX := windowX
            this.state.lastKeyboardY := windowY
        }
    }

    RememberUiState() {
        this.state.lastFilterText := this.filterEdit.Text
        this.state.lastFuzzyValue := this.fuzzyCheck.Value
    }

    GetPosition() {
        if (this.triggerKind = TaskeybarPopup.TriggerMouse) {
            return this.GetMouseAnchoredPosition()
        }

        return this.GetKeyboardAnchoredPosition()
    }

    GetMouseAnchoredPosition() {
        targetWidth := this.GetTargetWidth()
        CoordMode "Mouse", "Screen"
        MouseGetPos(&xpos, &ypos)
        monitorArea := this.GetMonitorWorkAreaFromPoint(xpos, ypos)
        targetX := xpos - (targetWidth // 2)
        targetY := Max(monitorArea.top, ypos - TaskeybarPopup.MouseFilterOffsetY)
        maxX := monitorArea.right - targetWidth

        if (targetX < monitorArea.left) {
            targetX := monitorArea.left
        } else if (targetX > maxX) {
            targetX := maxX
        }

        return { x: targetX, y: targetY }
    }

    GetKeyboardAnchoredPosition() {
        if (this.state.hasKeyboardPosition) {
            return { x: this.state.lastKeyboardX, y: this.state.lastKeyboardY }
        }

        CoordMode "Mouse", "Screen"
        MouseGetPos(&xpos, &ypos)
        monitorArea := this.GetMonitorWorkAreaFromPoint(xpos, ypos)
        return {
            ; The visible left edge sits a few pixels to the right of the
            ; requested x-position because of the window frame.
            x: monitorArea.left - TaskeybarPopup.KeyboardFallbackLeftFrameAdjustment,
            y: monitorArea.top + TaskeybarPopup.KeyboardFallbackY
        }
    }

    GetMonitorWorkAreaFromPoint(xpos, ypos) {
        loop MonitorGetCount() {
            MonitorGetWorkArea(A_Index, &left, &top, &right, &bottom)
            if (xpos >= left && xpos < right && ypos >= top && ypos < bottom) {
                return { left: left, top: top, right: right, bottom: bottom }
            }
        }

        MonitorGetWorkArea(1, &left, &top, &right, &bottom)
        return { left: left, top: top, right: right, bottom: bottom }
    }

    GetSelectedRow() {
        selectedIndex := this.listBox.Value
        if (selectedIndex <= 0 || selectedIndex > this.rows.Length) {
            return ""
        }

        return this.rows[selectedIndex]
    }

    GetSelectedHwnd() {
        row := this.GetSelectedRow()
        if (row = "") {
            return 0
        }

        return row.hWnd
    }

    GetSelectedItemText() {
        row := this.GetSelectedRow()
        if (row = "") {
            return ""
        }

        return row.itemText
    }

    IsOpen() {
        return this.isVisible
    }

    GetHwnd() {
        return this.gui.Hwnd
    }
}

class TaskeybarApp {
    static StartupTitle := "Taskeybar"
    static StartupCopyright := "Copyright (C) 2023-2026 PerMail"
    static TriggerMouse := "mouse"
    static TriggerKeyboard := "keyboard"
    static WmKeyDown := 0x0100
    static WmMove := 0x0003
    static WmExitSizeMove := 0x0232
    static VkEnter := 0x0D
    static VkC := 0x43
    static VkDelete := 0x2E
    static VkUp := 0x26
    static VkDown := 0x28

    __New() {
        this.state := TaskeybarState()
        this.currentPopup := TaskeybarPopup(this, this.state)
        this.keyDownHandler := ObjBindMethod(this, "HandleKeyDown")
        this.moveHandler := ObjBindMethod(this, "HandleWindowMove")
        this.exitSizeMoveHandler := ObjBindMethod(this, "HandleExitSizeMove")
        OnMessage(TaskeybarApp.WmKeyDown, this.keyDownHandler)
        OnMessage(TaskeybarApp.WmMove, this.moveHandler)
        OnMessage(TaskeybarApp.WmExitSizeMove, this.exitSizeMoveHandler)
    }

    ShowWindowListAtMouse() {
        this.ShowWindowList(TaskeybarApp.TriggerMouse)
    }

    ShowWindowListAtKeyboard() {
        this.ShowWindowList(TaskeybarApp.TriggerKeyboard)
    }

    ShowWindowList(triggerKind) {
        preferredHwnd := this.GetPreferredWindowHwnd()
        this.currentPopup.Show(triggerKind, preferredHwnd)
    }

    GetPreferredWindowHwnd() {
        activeHwnd := WinActive("A")
        if (activeHwnd != this.currentPopup.GetHwnd()) {
            if (activeHwnd != 0) {
                this.state.lastPreferredWindowHwnd := activeHwnd
            }
            return activeHwnd
        }

        return this.state.lastPreferredWindowHwnd
    }

    HandleKeyDown(wParam, lParam, msg, hwnd) {
        if (!this.currentPopup.IsOpen()) {
            return
        }

        return this.currentPopup.HandleKeyDown(wParam, hwnd)
    }

    HandleWindowMove(wParam, lParam, msg, hwnd) {
        if (!this.currentPopup.IsOpen() || this.currentPopup.isClosing || hwnd != this.currentPopup.GetHwnd()) {
            return
        }

        this.currentPopup.RememberPosition()
    }

    HandleExitSizeMove(wParam, lParam, msg, hwnd) {
        if (!this.currentPopup.IsOpen() || this.currentPopup.isClosing || hwnd != this.currentPopup.GetHwnd()) {
            return
        }

        this.currentPopup.RememberPosition()
    }
}

version := "1.1.0"
;@Ahk2Exe-Let U_version = %A_PriorLine~U)^(.+"){1}(.+)".*$~$2%
;@Ahk2Exe-SetVersion %U_version%
;@Ahk2Exe-SetProp Name, Taskeybar
;@Ahk2Exe-SetProp Description, Keyboard-first window picker for Windows 11
;@Ahk2Exe-SetProp Copyright, Copyright (C) 2023-2026 PerMail
;@Ahk2Exe-SetProp OrigFilename, taskeybar.exe
app := TaskeybarApp()

MsgBox(
    "Taskeybar v"
        . version
        . " loaded. `nWin+LeftClick or Ctrl+Win+Space to display. `n`n"
        . TaskeybarApp.StartupCopyright,
    TaskeybarApp.StartupTitle
)

LWin & LButton::app.ShowWindowListAtMouse()
^#Space::app.ShowWindowListAtKeyboard()
