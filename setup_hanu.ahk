#Requires AutoHotkey v2.0
; ==============================================================================
; HANU Library Computer Automation Script
; ==============================================================================

; Set matching behavior to "Contains" to help find windows reliably (e.g. "anki-console.exe")
SetTitleMatchMode(2) 

; ------------------------------------------------------------------------------
; Startup Section: Auto-Execute when script runs
; ------------------------------------------------------------------------------

; 1. Turn on Night Light
ToolTip("Turning on Night Light...")
Run("ms-settings:nightlight")
Sleep(2000) ; Wait for Settings window to open

; specific logic for Win10 vs Win11
; Windows 11 is build 22000 or greater
osBuild := StrSplit(A_OSVersion, ".")[3]

if (Integer(osBuild) >= 22000) {
    ; Windows 11
    Send("{Tab 3}") 
    Sleep(200)
    Send("{Enter}")
} else {
    ; Windows 10
    Send("{Enter}")
}

Sleep(1000) ; Give it a moment to register
Run("taskkill /IM SystemSettings.exe /F",, "Hide")
ToolTip() ; Clear ToolTip

; 2. Download Anki and Zalo via Chrome
; ------------------------------------------------------------------------------
ToolTip("Opening Chrome for Downloads...")
; A. Zalo
Run("chrome.exe https://zalo.me/download/zalo-pc")

; B. Anki
Run("chrome.exe https://github.com/ankitects/anki/releases/download/25.09/anki-launcher-25.09-windows.exe")

; C. Open Chrome Downloads Manager (to monitor progress)
; Using Ctrl+J is more reliable than the command line for opening Downloads in the same window
if WinWait("ahk_exe chrome.exe",, 5) {
    WinActivate("ahk_exe chrome.exe")
    Sleep(500)
    Send("^j")
} else {
    Run("chrome.exe chrome://downloads")
}

ToolTip("Waiting for installers to download...")
downloadsDir := EnvGet("USERPROFILE") . "\Downloads"

; Cleanup old installers to ensure we pick the new one
Loop Files downloadsDir . "\anki-*-windows*.exe"
    try FileDelete(A_LoopFileFullPath)

; ------------------------------------------------------------------------------
; 3. Install Anki (Automated)
; ------------------------------------------------------------------------------

; Wait for file to appear in Downloads (Poll for 30 seconds)
ankiPath := ""
Loop 30 {
    Loop Files downloadsDir . "\anki-*-windows*.exe" 
    {
        ; Check if it's a partial download
        if !FileExist(A_LoopFileFullPath . ".crdownload") && !FileExist(A_LoopFileFullPath . ".part")
        {
            ankiPath := A_LoopFileFullPath
            break 2
        }
    }
    Sleep(1000)
}

if (ankiPath != "") {
    ToolTip("Launching Anki Installer...")
    ; Give it a slight moment to finalize write
    Sleep(2000)
    Run(ankiPath)
    
    ; Step 1: Security Warning
    ToolTip("Watching for Anki Security Warning (2s)...")
    if WinWait("Security Warning ahk_exe anki-launcher-25.09-windows.exe",, 2) {
        ToolTip("Handling Anki Security Warning...")
        WinActivate("Security Warning ahk_exe anki-launcher-25.09-windows.exe")
        Send("!r") ; Alt+R (Run)
    }
        
    ; Step 2: Installation Folder
    ; Using specific title and class for better detection
    ToolTip("Waiting for Anki Setup Wizard...")
    if WinWait("Anki Setup: Installation Folder ahk_class #32770",, 20) {
        ToolTip("Installing Anki...")
        WinActivate("Anki Setup: Installation Folder ahk_class #32770")
        Sleep(500)
        Send("{Enter}") ; Click Install
    }
    
    ; Step 3: Console & Post-Install Configuration
    ToolTip("Waiting for Anki Console (Loading components)...")
    if WinWait("anki-console.exe",, 30) {
        WinActivate("anki-console.exe")
        if WinWaitActive("anki-console.exe",, 5) {
            ToolTip("Console active. Waiting 1s for input...")
            Sleep(1000) ; 1s wait as requested
            Send("{Enter}")
        }
        
        languageHandled := false
        confirmationHandled := false
        
        Loop 600 { 
            counter := A_Index
            ToolTip("Monitoring Post-Install (" . counter . "/600s)...")
            
            ; 1. Language Selection
            if (!languageHandled && WinExist("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")) {
                ToolTip("Handling Anki Language Selection...")
                WinActivate("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")
                if WinWaitActive("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe",, 5) {
                    Sleep(1000)
                    Send("{Enter}")
                    languageHandled := true
                    WinWaitClose("ahk_id " . WinExist("A"),, 5) 
                    continue
                }
            }
            
            ; 2. Confirmation Box
            if (languageHandled && !confirmationHandled && WinExist("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")) {
                ToolTip("Handling Anki Confirmation Box...")
                WinActivate("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")
                if WinWaitActive("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe",, 5) {
                    Sleep(1000)
                    Send("y")
                    Sleep(2000)
                    if WinExist("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe") {
                        Send("!y")
                        Sleep(2000)
                    }
                    if !WinExist("Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")
                        confirmationHandled := true
                }
            }
            
            ; 3. Console Cleanup (if it says "You can close this window")
            if WinExist("anki-console.exe") {
                try {
                    winText := WinGetText("anki-console.exe")
                    if InStr(winText, "You can close this window") {
                        Run("taskkill /IM anki-console.exe /F",, "Hide")
                    }
                }
            }

            ; 4. Success Condition
            if (confirmationHandled || WinExist("User 1 - Anki ahk_class Qt691QWindowIcon ahk_exe pythonw.exe")) {
                ToolTip("Anki Installation Complete!")
                Sleep(2000)
                break
            }
            Sleep(1000)
        }
    }
    
} else {
    ToolTip("Anki installer not found. Skipping...")
    Sleep(2000)
}
ToolTip() ; Clear ToolTip


; ------------------------------------------------------------------------------
; 4. Install Zalo (Automated)
; ------------------------------------------------------------------------------

; Wait for file to appear in Downloads (Poll for 30 seconds)
zaloPath := ""
Loop 30 {
    Loop Files downloadsDir . "\ZaloSetup*.exe" 
    {
        if !FileExist(A_LoopFileFullPath . ".crdownload") && !FileExist(A_LoopFileFullPath . ".part")
        {
            zaloPath := A_LoopFileFullPath
            break 2
        }
    }
    Sleep(1000)
}

if (zaloPath != "") {
    ToolTip("Launching Zalo Installer...")
    Sleep(2000) ; finalize write
    Run(zaloPath)
    
    ; Step 1: Security Warning
    ToolTip("Watching for Zalo Security Warning (2s)...")
    if WinWait("Open File - Security Warning ahk_class #32770",, 2) {
        ToolTip("Handling Zalo Security Warning...")
        WinActivate("Open File - Security Warning ahk_class #32770")
        if WinWaitActive("Open File - Security Warning ahk_class #32770",, 5) {
            Send("!r") ; Alt+R (Run)
        }
    }
    
    ; Step 2: Language Selection Dialog
    ToolTip("Watching for Zalo Language Selection...")
    if WinWait("Installer Language ahk_class #32770",, 10) {
        ToolTip("Handling Zalo Language Selection...")
        WinActivate("Installer Language ahk_class #32770")
        if WinWaitActive("Installer Language ahk_class #32770",, 5) {
            Sleep(500)
            Send("{Enter}") ; Accept default language (Tiếng Việt)
        }
    }
    
    ToolTip("Zalo Installation triggered.")
    Sleep(2000)
    ; Zalo usually installs automatically after this and launches itself.
} else {
    ToolTip("Zalo installer not found. Skipping...")
    Sleep(2000)
}
ToolTip() ; Final Clear

; ==============================================================================
; 5. Windows Key Logic & Hotkey Remapping
; ==============================================================================

; 1. Block the native LWin press to prevent the Start Menu from intercepting input
; We must use the hook ($) to prevent self-triggering if we were sending #, but here we just block.
$LWin::{
    return 
}

; 2. Restore Start Menu on Key Release
; Since the system forces the Start Menu on KeyDown anyway in this environment,
; we do NOT need to send Ctrl+Esc here (it would just toggle it closed).
LWin Up::{
    return 
}

; Helper function to clean up Start Menu before running command
RunClean(cmd) {
    Send("{Esc}")
    Sleep(50)
    Run(cmd)
}

; Win+C: Open Chrome
LWin & c::RunClean("chrome.exe")

; Win+E: Open My Drive (Replaces Explorer)
LWin & e::RunClean("https://drive.google.com/drive/my-drive")

; Win+K: Open Anki (Overwrites "Cast")
LWin & k::{
    Send("{Esc}")
    Sleep(50)
    if FileExist(EnvGet("LOCALAPPDATA") . "\Programs\Anki\anki.exe")
        Run(EnvGet("LOCALAPPDATA") . "\Programs\Anki\anki.exe")
    else if FileExist(EnvGet("ProgramFiles") . "\Anki\anki.exe")
        Run(EnvGet("ProgramFiles") . "\Anki\anki.exe")
    else
        MsgBox("Anki executable not found. Please install it first.")
}

; Win+` : Volume Mixer
LWin & `::RunClean("sndvol")

; Drive Folders - Mapped to easy access keys A-G
; Teach
LWin & a::RunClean("https://drive.google.com/drive/folders/1yfOkFPtZX2cZIwhcdyQRZikiQEfna__J")

; Research
LWin & s::RunClean("https://drive.google.com/drive/folders/1Yw1C1PbqIfDBiLgkjo_NCousBuRui72p?usp=drive_link")

; Test (Replaces Desktop)
LWin & d::RunClean("https://drive.google.com/drive/folders/1m4YYqxZPpiG-oV98g5BgZDBvM8G2Ol0l?usp=drive_link")

; Writing (Viết)
LWin & v::RunClean("https://drive.google.com/drive/folders/1PhhWGdU3qHuNxntlv6TNliUUaVh5Oi7y?usp=drive_link")

; Philosophy (Filosophy)
LWin & f::RunClean("https://drive.google.com/drive/folders/1c6Em2kdr-TqCptmq-az3jmxBNGvOdK0D?usp=drive_link")

; Win+Q: Simulate Alt+F4 (Overwrites "Search")
LWin & q::{
    Send("{Esc}")
    Sleep(50)
    Send("!{F4}")
}


; ------------------------------------------------------------------------------
; Chrome Specific: Alt+Num to Ctrl+Num
; ------------------------------------------------------------------------------
#HotIf WinActive("ahk_exe chrome.exe")
!1::Send("^1")
!2::Send("^2")
!3::Send("^3")
!4::Send("^4")
!5::Send("^5")
!6::Send("^6")
!7::Send("^7")
!8::Send("^8")
!9::Send("^9")
#HotIf


; ------------------------------------------------------------------------------
; Cleanup: Win+L (Overwrites "Lock Screen")
; ------------------------------------------------------------------------------
LWin & l::{
    Send("{Esc}")
    Sleep(50)
    
    result := MsgBox("Start cleanup? This will CLOSE CHROME/ZALO and DELETE profiles for checked emails.", "Cleanup", 1)
    if (result == "Cancel")
        return

    cleanupScript := "
    (
    $emailsToRemove = @('hoang26hoang@gmail.com', 'hoang26gamer@gmail.com', 'hoanglaking@gmail.com')
    
    Write-Host 'Closing apps...'
    Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
    Stop-Process -Name zalo -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    # Chrome User Data Path
    $userDataPath = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data'
    $localStatePath = Join-Path $userDataPath 'Local State'

    if (Test-Path $localStatePath) {
        try {
            # Read JSON with correct encoding (often UTF8)
            $content = Get-Content $localStatePath -Raw -Encoding UTF8
            $json = $content | ConvertFrom-Json
            
            # The 'profile.info_cache' object keys are the folder names (e.g. 'Profile 1')
            # The values contain 'user_name' which is the email.
            $profiles = $json.profile.info_cache
            
            # Iterate through profiles
            foreach ($folderName in $profiles.PSObject.Properties.Name) {
                $profileData = $profiles.$folderName
                $email = $profileData.user_name
                
                if ($email -in $emailsToRemove) {
                    $dirToRemove = Join-Path $userDataPath $folderName
                    Write-Host "Found profile '$email' at '$dirToRemove'. Deleting..."
                    if (Test-Path $dirToRemove) {
                        Remove-Item -LiteralPath $dirToRemove -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        } catch {
            Write-Error "Error parsing Chrome profiles: $_"
        }
    }

    Write-Host 'Emptying Recycle Bin...'
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue

    Write-Host 'Cleanup Complete. You can close this window.'
    Start-Sleep -Seconds 3
    )"
    
    ; Write to temp file
    cleanupPsPath := A_Temp . "\chrome_cleanup.ps1"
    if FileExist(cleanupPsPath)
        FileDelete(cleanupPsPath)
    FileAppend(cleanupScript, cleanupPsPath)

    RunWait("powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"" . cleanupPsPath . "`"")
    
    if FileExist(cleanupPsPath)
        FileDelete(cleanupPsPath)
    
    MsgBox("Cleanup finished. Script will now exit.")
    ExitApp()
}

