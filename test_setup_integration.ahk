#Requires AutoHotkey v2.0
#SingleInstance Force

; Configuration
TestDir := A_ScriptDir . "\TEST_Whisper"
ZipUrl := "https://github.com/ggerganov/whisper.cpp/releases/latest/download/whisper-bin-x64.zip"
ModelUrl := "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin" ; Using tiny for faster test
ZipFile := TestDir . "\whisper.zip"
ModelFile := TestDir . "\ggml-tiny.en.bin"
StreamExe := TestDir . "\stream.exe"

global Exec := ""

; 1. Setup Directory
if DirExist(TestDir) {
    result := MsgBox("Test directory exists. Delete and re-download?`n" . TestDir, "Unit Test", 4)
    if (result == "Yes")
        try DirDelete(TestDir, true)
}
if !DirExist(TestDir)
    DirCreate(TestDir)

; 2. Download Files
ToolTip("UNIT TEST: Downloading Whisper Engine (3MB)...")
try {
    if !FileExist(ZipFile)
        Download(ZipUrl, ZipFile)
} catch as err {
    MsgBox("Failed to download Whisper Engine.`nIs Curl/Network available?`n" . err.Message)
    ExitApp
}

ToolTip("UNIT TEST: Downloading Whisper Model (Tiny - 75MB)...")
try {
    if !FileExist(ModelFile)
        Download(ModelUrl, ModelFile)
} catch as err {
    MsgBox("Failed to download Model.`n" . err.Message)
    ExitApp
}

; 3. Extract
ToolTip("UNIT TEST: Extracting...")
; PowerShell Expand-Archive is reliable on Win10/11
RunWait("powershell -Command ""Expand-Archive -Path '" . ZipFile . "' -DestinationPath '" . TestDir . "' -Force""",, "Hide")

; Verify Extraction
; Note: The zip often extracts into a subfolder or root depending on structure. 
; The official release usually puts stream.exe in root or Release folder.
; Let's check.
if !FileExist(StreamExe) {
    ; Check if it's in a 'Release' subfolder (common in manual builds, but let's check zip structure)
    if FileExist(TestDir . "\Release\stream.exe") {
        FileCopy(TestDir . "\Release\stream.exe", TestDir . "\stream.exe")
        FileCopy(TestDir . "\Release\ggml.dll", TestDir . "\ggml.dll")
        FileCopy(TestDir . "\Release\whisper.dll", TestDir . "\whisper.dll")
        ; Copy other DLLs if needed
    } else {
        MsgBox("Extraction failed or stream.exe not found in expected paths.`nCheck " . TestDir)
        ExitApp
    }
}

; 4. Deployment Check
if FileExist(StreamExe) && FileExist(ModelFile) {
    MsgBox("SUCCESS: Files deployed correctly!`n`nClick OK to launch a 5-second dictation test.")
} else {
    MsgBox("FAILURE: Missing files.`nExe: " . FileExist(StreamExe) . "`nModel: " . FileExist(ModelFile))
    ExitApp
}

; 5. Functional Test (Run Logic)
ToolTip("UNIT TEST: Listening for 5 seconds...")
Args := " -m " . ModelFile . " -t 4 --step 500 --length 5000 -vth 0.6 --no-timestamps"

shell := ComObject("WScript.Shell")
Exec := shell.Exec(StreamExe . Args)

startTime := A_TickCount
outputText := ""

while (A_TickCount - startTime < 8000) { ; 8 seconds total test
    if !Exec.StdOut.AtEndOfStream {
        line := Exec.StdOut.ReadLine()
        outputText .= line . "`n"
    }
    Sleep(10)
}

try ProcessClose(Exec.ProcessID)

MsgBox("TEST COMPLETE.`n`nOutput Captured:`n----------------`n" . SubStr(outputText, 1, 500) . "`n----------------`n`nIf you saw/heard nothing, that's okay (no mic input?), but the process RAN.")
ExitApp
