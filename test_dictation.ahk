#Requires AutoHotkey v2.0
#SingleInstance Force

ToolTip("Dictation Test Running...`nPress Win+Z to launch Dictation (Win+H).`nPress Shift+Esc to Exit.")
SetTimer () => ToolTip(), -5000

; ==============================================================================
; Windows Key Interception
; ==============================================================================
$LWin::return
LWin Up::return

; ==============================================================================
; Dictation Test (Win+Z -> Win+H)
; ==============================================================================
LWin & z::{
    Send("{Esc}") ; Clear Start Menu
    Sleep(50)
    
    ; Sending Win+H (Standard Windows Dictation shortcut)
    ; We use SendEvent for potential better compatibility with system UIs
    SendEvent("#h")
    
    ToolTip("Sent Win+H (Dictation)")
    SetTimer () => ToolTip(), -1000
}

+Esc::ExitApp
