#Requires AutoHotkey v2.0
; ==============================================================================
; HANU Library Computer Automation Script
; ==============================================================================

; Set matching behavior to "Contains" to help find windows reliably
SetTitleMatchMode(2) 

; ==============================================================================
; Windows Key Logic & Hotkey Remapping
; ==============================================================================

; 1. Block the native LWin press to prevent the Start Menu from intercepting input
$LWin::{
    return 
}

; 2. Restore Start Menu on Key Release (currently blocked)
LWin Up::{
    return 
}

; Helper function to clean up Start Menu before running command
RunClean(cmd) {
    Send("{Esc}")
    Sleep(50)
    Run(cmd)
}

; ------------------------------------------------------------------------------
; Global Hotkeys
; ------------------------------------------------------------------------------

; Win+Z: Toggle Night Light
LWin & z::{
    Send("{Esc}")
    Sleep(50)
    
    ; Open Night Light settings
    Run("ms-settings:nightlight")
    Sleep(2000)
    
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
    
    Sleep(1000)
    Run("taskkill /IM SystemSettings.exe /F",, "Hide")
}

; Win+C: Open Chrome
LWin & c::RunClean("chrome.exe")

; Win+E: Open Downloads folder (local)
LWin & e::RunClean(EnvGet("USERPROFILE") . "\Downloads")

; Win+` : Volume Mixer
LWin & `::RunClean("sndvol")

; Win+Q: Simulate Alt+F4 (Close Window)
LWin & q::{
    Send("{Esc}")
    Sleep(50)
    Send("!{F4}")
}

; ------------------------------------------------------------------------------
; Chrome Specific: Alt+Num to Ctrl+Num (Tab Switching)
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
; Cleanup: Ctrl+Alt+L
; ------------------------------------------------------------------------------
^!l::{
    result := MsgBox("Start cleanup? This will CLOSE CHROME and DELETE profiles for checked emails.", "Cleanup", 1)
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
            $content = Get-Content $localStatePath -Raw -Encoding UTF8
            $json = $content | ConvertFrom-Json
            $profiles = $json.profile.info_cache
            
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

