#Requires AutoHotkey v2.0
#SingleInstance Force

ToolTip("Offline Dictation Test Running...`nPress Win+Z to open Windows Speech Recognition.`nPress Shift+Esc to Exit.")
SetTimer () => ToolTip(), -5000

; ==============================================================================
; Windows Key Interception
; ==============================================================================
$LWin::return
LWin Up::return

; ==============================================================================
; Classic Dictation (Win+Z -> sapisvr.exe)
; ==============================================================================
LWin & z::{
    Send("{Esc}") ; Clear Start Menu
    Sleep(50)
    
    ToolTip("Launching Windows Speech Recognition...")
    SetTimer () => ToolTip(), -1000
    
    ; Launch the legacy offline speech engine
    ; -SpeechUX forces the UI to appear
    if FileExist("C:\Windows\Speech\Common\sapisvr.exe")
        Run("C:\Windows\Speech\Common\sapisvr.exe -SpeechUX")
    else
        MsgBox("Speech Recognition not found on this PC.")
}

+Esc::ExitApp
