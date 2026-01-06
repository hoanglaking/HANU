#Requires AutoHotkey v2.0
#SingleInstance Force

; Configuration
StreamPath := "Release\stream.exe"
ModelPath := "ggml-small.en.bin"
; Arguments: -t 4 (threads), --step 0 (auto), --length 10000 (10s context)
; -vth 0.6 (voice threshold)
Args := " -m " . ModelPath . " -t 4 --step 500 --length 5000 -vth 0.6 --no-timestamps"

global Exec := ""

TrayTip "Whisper Dictation", "Ready. Press Win+H to start/stop."

; Override Win+H
#h::{
    global Exec, StreamPath, Args
    
    if (Exec) {
        ; Stop Listening
        try ProcessClose(Exec.ProcessID)
        Exec := ""
        ToolTip "Dictation Stopped"
        SetTimer () => ToolTip(), -2000
        return
    }
    
    ; Start Listening
    if !FileExist(StreamPath) {
        MsgBox "Error: " StreamPath " not found."
        return
    }
    if !FileExist(ModelPath) {
        MsgBox "Error: " ModelPath " not found. Please wait for download."
        return
    }

    ToolTip "Starting Whisper..."
    
    ; Launch stream.exe
    shell := ComObject("WScript.Shell")
    ; We run via cmd to ensure path resolution, but direct execution is better for PID
    ; WScript.Shell.Exec returns a WshScriptExec object
    Exec := shell.Exec(StreamPath . Args)
    
    ToolTip "Listening... (Speak now)"
    
    ; Set a timer to read output so we don't block the UI
    SetTimer ReadOutput, 10
}

ReadOutput() {
    global Exec
    
    if (!Exec || Exec.Status != 0) {
        ; Process ended
        SetTimer ReadOutput, 0
        Exec := ""
        ToolTip "Dictation Process Ended"
        SetTimer () => ToolTip(), -2000
        return
    }

    if !Exec.StdOut.AtEndOfStream {
        ; Read line
        line := Exec.StdOut.ReadLine()
        
        ; Filter ANSI codes
        line := RegExReplace(line, "\x1B\[[0-9;]*[mK]", "")
        
        ; Remove timestamps like [00:00:00.000 --> 00:00:02.000]
        text := RegExReplace(line, "^\[.*?\]\s*", "")
        text := Trim(text)
        
        ; Ignore metadata lines or empty lines
        if (text != "" && !InStr(text, "main:") && !InStr(text, "whisper_") && !InStr(text, "detect_")) {
            ; Type it out
            SendInput "{Text}" text " "
        }
    }
}
