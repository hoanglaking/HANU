#Requires AutoHotkey v2.0
SetTitleMatchMode(2)

; Locate Installer
downloadsDir := EnvGet("USERPROFILE") . "\Downloads"
ankiPath := ""
Loop Files downloadsDir . "\anki-*-windows*.exe"
{
    if !FileExist(A_LoopFileFullPath . ".crdownload") && !FileExist(A_LoopFileFullPath . ".part")
    {
        ankiPath := A_LoopFileFullPath
        break
    }
}

if (ankiPath == "") {
    MsgBox("Anki installer not found in Downloads!`nPlease download it first.")
    ExitApp
}

Run(ankiPath)
ToolTip("Installer launched. Waiting for windows...")

; Step 1: Security Warning
if WinWait("Security Warning ahk_exe anki-launcher-25.09-windows.exe",, 5) {
    WinActivate("Security Warning ahk_exe anki-launcher-25.09-windows.exe")
    Send("!r") ; Alt+R
    ToolTip("Handled Security Warning")
}

; Step 2: Installation Folder
ToolTip("Waiting for 'Anki Setup'...")
; Using specific title and class for better detection
if WinWait("Anki Setup: Installation Folder ahk_class #32770",, 20) {
    WinActivate("Anki Setup: Installation Folder ahk_class #32770")
    Sleep(500)
    Send("{Enter}")
    ToolTip("Clicked Install/Enter on Anki Setup")
} else {
    MsgBox("Timed out waiting for 'Anki Setup' window.")
    ToolTip()
    ExitApp
}

; Step 3: Console
ToolTip("Waiting for 'anki-console.exe'...")
; Match by title (contains 'anki-console.exe')
if WinWait("anki-console.exe",, 30) {
    WinActivate("anki-console.exe")
    if WinWaitActive("anki-console.exe",, 5) {
        ToolTip("Console active. Waiting 7s for it to 'load'...")
        Sleep(7000) ; Increased wait for slow network/loading
        Send("{Enter}")
        ToolTip("Sent Enter to Console")
    }
    
    ; Monitor for Language/Confirmation
    languageHandled := false
    confirmationHandled := false
    
    ; Increased to 600 iterations (10 minutes) for slow network
    Loop 600 {
        counter := A_Index
        ToolTip("Monitoring for Anki Windows (" . counter . "/600 seconds)...")
        
        ; 1. Language Selection (Needs Enter)
        if (!languageHandled && WinExist("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")) {
            thisTitle := WinGetTitle("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")
            ; Sometimes the confirmation has the same title, but it's AFTER language.
            ; Language is usually the FIRST window to appear.
            ToolTip("LANGUAGE WINDOW: Sending 'Enter' to: " . thisTitle)
            WinActivate("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")
            if WinWaitActive("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe",, 5) {
                Sleep(1000)
                Send("{Enter}")
                languageHandled := true
                ToolTip("Language Handled. Waiting for window to close/refresh...")
                ; Wait up to 5s for the window to change/close before looking for the next one
                WinWaitClose("ahk_id " . WinExist("A"),, 5) 
                continue ; Go to next loop iteration to find the NEXT window
            }
        }
        
        ; 2. Confirmation Box (Needs 'y')
        ; Only look for this if language is already done
        if (languageHandled && !confirmationHandled && WinExist("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")) {
            ToolTip("CONFIRMATION BOX: Sending 'y'...")
            WinActivate("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")
            if WinWaitActive("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe",, 5) {
                Sleep(1000)
                Send("y")
                Sleep(2000) ; Wait to see if it closes
                
                if WinExist("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe") {
                    ToolTip("Still visible. Trying 'Alt+Y'...")
                    Send("!y")
                    Sleep(2000)
                }
                
                if !WinExist("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe") {
                    confirmationHandled := true
                    ToolTip("Confirmation Handled!")
                }
            }
        }
        
        ; 3. Final Check: Success
        if (confirmationHandled || WinExist("User 1 - Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")) {
            ToolTip("Anki is OPEN. SUCCESS!")
            break
        }
        
        Sleep(1000)
    }
    
    ToolTip("Finished automation loop.")
    Sleep(3000)
    ToolTip()
} else {
    MsgBox("Timed out waiting for 'anki-console.exe'.")
}
