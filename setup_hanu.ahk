#Requires AutoHotkey v2.0
; ==============================================================================
; HANU Library Computer Automation Script
; ==============================================================================

; Set matching behavior to "Contains" to help find windows reliably
SetTitleMatchMode(2) 

; ==============================================================================
; INITIAL STARTUP CHECKS
; ==============================================================================

; ==============================================================================
; 1. Auto-download HANU Materials from Google Drive (background)
; ==============================================================================
hanuMaterialsDir := EnvGet("USERPROFILE") . "\Downloads\HANU Materials"
rcloneExe := A_ScriptDir . "\File\rclone.exe"
saKeyFile := A_ScriptDir . "\File\antigravity-automation-490511-f95a2bf777f6.json"

if !DirExist(hanuMaterialsDir) && FileExist(rcloneExe) && FileExist(saKeyFile) {
    ; Write temporary rclone config
    rcloneConf := A_Temp . "\rclone_hanu.conf"
    confContent := "[gdrive]`ntype = drive`nservice_account_file = " . saKeyFile . "`nroot_folder_id = 1hY92O6Zsjyfe5O1S3WYKlZcAI-3uTVIC"
    if FileExist(rcloneConf)
        FileDelete(rcloneConf)
    FileAppend(confContent, rcloneConf)
    
    ; Run rclone sync in background (non-blocking)
    Run(rcloneExe . " copy gdrive: `"" . hanuMaterialsDir . "`" --config `"" . rcloneConf . "`"",, "Hide")
}

; ==============================================================================
; 2. Auto-install Git
; ==============================================================================
gitExePath := "C:\Program Files\Git\cmd\git.exe"

if !FileExist(gitExePath) {
    gitPsScript := "
    (
    Write-Host 'Fetching latest Git installer URL from GitHub...'
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest"
    $asset = $release.assets | Where-Object { $_.name -match "64-bit\.exe`$" -and $_.name -notmatch "Portable" -and $_.name -notmatch "MinGit" -and $_.name -notmatch "pdbs" }
    $downloadUrl = $asset[0].browser_download_url
    
    $installer = Join-Path $env:TEMP 'git_installer.exe'
    Write-Host "Downloading Git from: $downloadUrl"
    
    Start-Process -FilePath 'bitsadmin.exe' -ArgumentList "/transfer ""GitDownload"" /priority foreground ""$downloadUrl"" ""$installer""" -Wait
    
    Write-Host 'Installing Git silently...'
    Start-Process -FilePath $installer -ArgumentList '/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS' -Wait
    
    Write-Host 'Configuring Git...'
    $gitCmd = 'C:\Program Files\Git\cmd\git.exe'
    if (Test-Path $gitCmd) {
        & $gitCmd config --global user.name 'Hoang'
        & $gitCmd config --global user.email 'Hoang'
    }
    )"
    
    gitPsPath := A_Temp . "\install_git_startup.ps1"
    if FileExist(gitPsPath)
        FileDelete(gitPsPath)
    FileAppend(gitPsScript, gitPsPath)
    
    ; Run Git installation visibly so the user can see the progress
    RunWait("powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"" . gitPsPath . "`"")
}

; ==============================================================================
; 3. Auto-install Antigravity (GitHub Download + wizard automation)
; ==============================================================================
antigravityExe := EnvGet("USERPROFILE") . "\AppData\Local\Programs\antigravity\Antigravity.exe"
antigravityInstaller := A_Temp . "\antigravity_setup.exe"
repoUrl := "hoanglaking/Antigravity" ; GitHub repository

; ALWAYS FRESH START: Kill existing process and delete old installer
try {
    RunWait("taskkill /IM Antigravity.exe /F",, "Hide")
}
if FileExist(antigravityInstaller)
    FileDelete(antigravityInstaller)

; Download from GitHub
antigravityPsScript := "
(
Write-Host 'Fetching latest Antigravity installer URL from GitHub...'
$repo = '" . repoUrl . "'
$release = Invoke-RestMethod -Uri `"https://api.github.com/repos/$repo/releases/latest`"
$asset = $release.assets | Where-Object { $_.name -match 'Setup\.exe$' }
$downloadUrl = $asset[0].browser_download_url

$installer = '" . antigravityInstaller . "'
Write-Host `"Downloading Antigravity from: $downloadUrl`"

Start-Process -FilePath 'bitsadmin.exe' -ArgumentList `"/transfer `"AntigravityDownload`" /priority foreground `"$downloadUrl`" `"$installer`"`" -Wait
)"

antigravityPsPath := A_Temp . "\download_antigravity.ps1"
if FileExist(antigravityPsPath)
    FileDelete(antigravityPsPath)
FileAppend(antigravityPsScript, antigravityPsPath)

RunWait("powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"" . antigravityPsPath . "`"")

if FileExist(antigravityInstaller) {
    ; Launch installer
    Run(antigravityInstaller)
    
    ; Wait for Not Admin dialog (Antigravity Setup)
    if WinWait("Antigravity Setup", "Installation Options", 15) {
        WinActivate("Antigravity Setup")
        Sleep(500)
        Send("{Enter}") ; Dismiss not admin dialog
        
        ; Wait for actual Setup wizard
        if WinWait("Antigravity Setup ", "Welcome to Antigravity Setup", 5) {
            WinActivate("Antigravity Setup ")
            Sleep(500)
            ; Press Alt+N 4 times (Next)
            Loop 4 {
                Send("!n")
                Sleep(500)
            }
            ; Press Alt+I (Install)
            Send("!i")
            
            ; Wait for finish screen
            if WinWait("Antigravity Setup ", "Completing Antigravity Setup", 60) {
                WinActivate("Antigravity Setup ")
                Sleep(500)
                Send("{Enter}") ; Finish and Launch
                
                ; Automate first-launch settings
                if WinWait("Antigravity", , 15) {
                    Sleep(2000) ; wait for UI load
                    WinActivate("Antigravity")
                    
                    Send("{Enter}")
                    Sleep(500)
                    Send("{Right 3}")
                    Sleep(3000) ; wait 3s
                    Send("{Enter}")
                    Sleep(500)
                    Send("{Down}")
                    Sleep(500)
                    Send("{Enter 2}") ; Enter -> Enter
                }
            }
        }
    }
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

; Win+` : Toggle master volume between 2 and 9
LWin & `::{
    try {
        currentVol := SoundGetVolume()
        if (currentVol > 5) {
            SoundSetVolume(2)
            ToolTip("Volume: 2%")
        } else {
            SoundSetVolume(9)
            ToolTip("Volume: 9%")
        }
        ; Hide the tooltip after 1.5 seconds
        SetTimer () => ToolTip(), -1500
    }
}

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

