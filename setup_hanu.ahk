#Requires AutoHotkey v2.0
; ==============================================================================
; HANU Library Computer Automation Script
; ==============================================================================

; Set matching behavior to "Contains" to help find windows reliably
SetTitleMatchMode(2) 

; ==============================================================================
; INITIAL STARTUP CHECKS
; ==============================================================================

; Check if .NET Framework 4.8 is installed (Release value 528040 for .NET 4.8)
; DeepFreeze/Fresh PCs will lack this, so we silently install it in the background.
try {
    netRelease := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full", "Release")
} catch {
    netRelease := 0
}

if (netRelease < 528040) {
    dotnetScript := "
    (
    Write-Host 'Checking .NET Framework...'
    $url = 'https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/b09e17b8f04719fa99df9b307ec3c306/ndp48-x86-x64-allos-enu.exe'
    $installer = Join-Path $env:TEMP 'ndp48-offline.exe'
    
    if (-not (Test-Path $installer)) {
        Write-Host 'Downloading .NET Framework 4.8 Offline Installer...'
        Start-Process -FilePath 'bitsadmin.exe' -ArgumentList "/transfer ""Net48Download"" /priority foreground ""$url"" ""$installer""" -Wait -WindowStyle Hidden
    }
    
    Start-Process -FilePath $installer -ArgumentList '/quiet /norestart' -Wait
    )"

    dotnetPsPath := A_Temp . "\install_dotnet48_startup.ps1"
    if FileExist(dotnetPsPath)
        FileDelete(dotnetPsPath)
    FileAppend(dotnetScript, dotnetPsPath)
    
    ; Run installation hidden and completely in the background without blocking the rest of the AHK script
    Run("powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"" . dotnetPsPath . "`"",, "Hide")
}

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
; Chrome and Explorer Specific: Alt+W to Ctrl+W (Close Tab)
; ------------------------------------------------------------------------------
#HotIf WinActive("ahk_exe chrome.exe") or WinActive("ahk_exe explorer.exe")
!w::Send("^w")
#HotIf

; ==============================================================================
; TAB SWITCHING OPTIONS (Uncomment the option you prefer)
; ==============================================================================

; --- OPTION 2: Alt+Tab -> Tab Switch ONLY in Chrome ---
#HotIf WinActive("ahk_exe chrome.exe")
!Tab::Send("^{Tab}")
!+Tab::Send("^+{Tab}")
<#Tab::AltTab
<#+Tab::Send("!+{Tab}")
#HotIf

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

; ------------------------------------------------------------------------------
; Force Restart restricted PC: Ctrl+Alt+R
; ------------------------------------------------------------------------------
^!r::{
    result := MsgBox("FORCE RESTART the computer? This bypasses UI restrictions to force reboot.", "Restart", 4)
    if (result == "No")
        return

    ; Attempt 1: Native AHK Shutdown (2 = Reboot, 4 = Force. 2+4=6)
    Shutdown(6)
    
    Sleep(2000)
    
    ; Attempt 2: Command line fallback if the direct API call is blocked
    Run("shutdown.exe /r /t 0 /f",, "Hide")
}

