#Requires AutoHotkey v2.0

ids := WinGetList(,, "Program Manager")
report := "==== WINDOW LIST ====`n"

for this_id in ids {
    try {
        title := WinGetTitle(this_id)
        winClass := WinGetClass(this_id)
        process := WinGetProcessName(this_id)
        
        ; Filter out empty titles to keep it clean, unless it's likely the target
        if (title != "") {
             report .= "Title: " . title . "`n"
             report .= "Class: " . winClass . "`n"
             report .= "Process: " . process . "`n"
             report .= "--------------------------------`n"
        }
    }
}

A_Clipboard := report
MsgBox(report, "Window List (Copied to Clipboard)")
