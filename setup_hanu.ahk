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
rcloneDir := A_ScriptDir . "\File"
rcloneExe := rcloneDir . "\rclone.exe"
saKeyFile := rcloneDir . "\antigravity-automation-490511-9b00c9bd8cf5.json"
gistUrl := "https://gist.githubusercontent.com/hoanglaking/0353ad65fe8e67908b4094eae1f17897/raw/60675c94bab0f530835bc9d9e4e5dd36ff4cf53f/key.json" ; REMOVED: Using inline base64 instead

; Ensure File directory exists
if !DirExist(rcloneDir) {
    DirCreate(rcloneDir)
}

; Check if we need to download dependencies
needsRclone := !FileExist(rcloneExe)
needsKey := !FileExist(saKeyFile)

if (needsRclone || needsKey) {
    ; --- Handle JSON Key (Base64 Decode) ---
    if (needsKey) {
        b64Key := "ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAiYW50aWdyYXZpdHktYXV0b21hdGlvbi00OTA1MTEiLAogICJwcml2YXRlX2tleV9pZCI6ICI5MWEwN2Q5OGM1NjBmM2IxNTJhMGNkZmEzNmUxMTkyOTBhNjg2MDBlIiwKICAicHJpdmF0ZV9rZXkiOiAiLS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tXG5NSUlFdkFJQkFEQU5CZ2txaGtpRzl3MEJBUUVGQUFTQ0JLWXdnZ1NpQWdFQUFvSUJBUUNXYW5RVlNKVHZlVUMwXG5HUkJSbGtVd0ZNZDVWeU5WT2J5VEF0a3J4UzUrNVVDREd0djVPSWdnTHU5T20vaFJndC80RlJsbzVSNXlzNXdiXG41VUV1TVZ6MkRBZk5tYTZFYWVFaDFKbTRXaGIxME9BdTZEYUFIalkwVDJTSG5OOEptZ05xbEFONyt0QjRCMkM3XG4vYVNUc0daRTJEOGxuWGwwMnNHVXNBcDVQQUpIdDdPZ0RSU0lmaGdURFFTS2VhbUx5bmhnaXZ4Z0RzT2EzOE1yXG5NY3pJTDhVelQ3NVI2NGNEV0w3VVQ0QlRTamdRT2MxM3FTWlJMMzVHMktFYlhNMEx1dlVhTW1HQ0ZaY2pmR2ZMXG41QlBJTU10Qlk3WHpBRnFRRDZaUFlwSmZWaCtMQVVJQjlyanVwTXZmVk1oUjdKU2UzcG5wM1ZiWmdUYVhVaU5aXG4vN2l1YXRHWkFnTUJBQUVDZ2dFQUFLcENESjRtZkdGcE9JWFBJSWNHbGg1NlZxb2pBWDBGdG1MU0JLMmdNK29DXG56eGZ2Y2N4ekVMd2FUVnB6K0E4a29jZTlQT05GWU54ZHRPZ0lCdC9vc2QzSEh1a2dwQ3ZJVTNVVGIzS0xnRUZiXG4wNXZkR0t5T0l0OWRGYk1XSVIvdjYzR0EzM01ZTWJCa0k4TmtWK3FCbndWZWxhUGdTNFgzcVZucHhXYlQxS2VGXG5ydTZtWW5vdldsUTRKakJwaGtqRmF2b3ZISTNSNEVDZ2VpUm1NKzFUTEhpcm1tcUQxUFAwam51cW5veTVxcTRBXG5jWnh6NUJvNk5TSUNtZExhWVhQMFFPV21CS29ESEtkT2FibG9hMExZOU9rN0hDcitxRjdVeTB1L1ZOekZzcHJ1XG52aXJ1d0NiN2F0UkFSWENSTXFjUDVmdGxhQld6dkREVVNEZ2JmTFBBelFLQmdRREZaMWYraG9xWVIxWGZ6MHRyXG5BRE5hblcxQVNrZmhOcTNNS3ZaZENNMnlQNW1HWUo1Yi93MWRBMWExQytXcGVyVTBDU0hOaUxxWWZSdlBkbUtnXG45bHlDY051UjVDRENvaldFQ01DbXRTbnVpZzdyTVgrYTJKSUY1KzBjUWhKWlUyMEt0VW5ROGI1UkFDUXY4ZGkrXG5RWHpNWUsxYTRpMXZEV1l1MkcvcFk0VCtvd0tCZ1FEREVJUEJRbmIweXNlMm85L1NyTTN3SmhSU0JFR1U5VjQ3XG5sSk83R2UrQTJLVlYyd29QMkducWk4ZFBiZk8wNkNkL2EvQWU0blVaN1dSMGV2dVJURUN0bGZkTWVMekFDUSszXG5FYy9SWnlYL0NKb0NKZWg5SXNKcjlpK2Yxbk1qQU9TdEV6NWxoVzhGcXZZczRsZGUrQ0VZWkFlUFFuV1kxYkdnXG53a3BHN3N5ZWt3S0JnQ01abGc3ZTAyUHlReld4Z1VKOFhhVStHci8wdFVVNVdMdlY0OHAxRjBZYmd1dmU0Q21SXG5kMG5UbnlaQUFFMGJVWDc0SkxlTUdVbWw3VHo5V3RvdUZCTHBpRkV2bEJlbmlnWjVHL0JJaERVeS9TWWF2Z3JGXG5lV2x0Ykw2NmpOS3ZQOU5JbXVCNUs1THhpSDJ4N2cwZVRkZDFWVDIwdThsa1E0Z08yZzlRcjhRckFvR0FjcG0yXG5Qb2wwNTlabXhQZThITUxuYnFxQWo3cnVhTHhMTTRmVHp6MnFoekZBMlpNSmMwdTYxbEJ1dFV5c3ZHRVVLM2xYXG5wbDEzWE5jcWlJQmtZZlhCbmZvWVF6WS85amFjby9wejlOdTc1L3krdG5wYy8zKzNaOFJJTUlqR05nOWxTZ1dmXG5SL2UveFQydXlhbmttT2dBVVpzYkVlQ0N4RnJ2czduUjk2QitXTDhDZ1lBWEU2aE42RkxJVUttNGRxSmM4U3pMXG5oekVXOUFwTGFVRDZrYTR6U3dYODhFOXY0UVlucWlBRzdleEVCUmE3WHVPcmFCVk1ZTnVwOHByckpKbXBibHF1XG52clFZb29vczFmYVE5eGR3VnZzSkxXTkd1dDBkVXk1U29iRW9zM002UllTYkNhT0pXSGgvQ3JvSmUwMG51OFduXG5xNmVhbmVjNndnWkM2U1h0SFpNZGl3PT1cbi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS1cbiIsCiAgImNsaWVudF9lbWFpbCI6ICJoYW51LWRyaXZlQGFudGlncmF2aXR5LWF1dG9tYXRpb24tNDkwNTExLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwKICAiY2xpZW50X2lkIjogIjEwOTU5MTczNTk1NTc3NDA4ODM3NCIsCiAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAidG9rZW5fdXJpIjogImh0dHBzOi8vb2F1dGgyLmdvb2dsZWFwaXMuY29tL3Rva2VuIiwKICAiYXV0aF9wcm92aWRlcl94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL29hdXRoMi92MS9jZXJ0cyIsCiAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvaGFudS1kcml2ZSU0MGFudGlncmF2aXR5LWF1dG9tYXRpb24tNDkwNTExLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwKICAidW5pdmVyc2VfZG9tYWluIjogImdvb2dsZWFwaXMuY29tIgp9Cg=="
        
        ; Extract base64 to file using PowerShell
        decodePsPath := A_Temp . "\decode_key.ps1"
        decodePsScript := "[IO.File]::WriteAllBytes('" . saKeyFile . "', [Convert]::FromBase64String('" . b64Key . "'))"
        if FileExist(decodePsPath)
            FileDelete(decodePsPath)
        FileAppend(decodePsScript, decodePsPath)
        RunWait("powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"" . decodePsPath . "`"",, "Hide")
    }

    ; --- Handle Rclone Download ---
    if (needsRclone) {
        psScript := "Write-Host 'Downloading HANU Dependencies...'`n"
        psScript .= "Write-Host 'Downloading Rclone Explorer...'`n"
        psScript .= "$release = Invoke-RestMethod -Uri 'https://api.github.com/repos/rclone/rclone/releases/latest'`n"
        psScript .= "$asset = $release.assets | Where-Object { $_.name -match 'windows-amd64.zip$' }`n"
        psScript .= "$downloadUrl = $asset[0].browser_download_url`n"
        psScript .= "$zipPath = Join-Path $env:TEMP 'rclone.zip'`n"
        psScript .= "$extDir = Join-Path $env:TEMP 'rclone_ext'`n"
        psScript .= "Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing`n"
        psScript .= "if (Test-Path $extDir) { Remove-Item $extDir -Recurse -Force }`n"
        psScript .= "Expand-Archive -Path $zipPath -DestinationPath $extDir -Force`n"
        psScript .= "$exePath = Get-ChildItem -Path $extDir -Filter 'rclone.exe' -Recurse | Select-Object -First 1`n"
        psScript .= "Copy-Item -Path $exePath.FullName -Destination '" . rcloneExe . "' -Force`n"
        psScript .= "Remove-Item $zipPath -Force`n"
        psScript .= "Remove-Item $extDir -Recurse -Force`n"
        
        psPath := A_Temp . "\download_hanu_deps.ps1"
        if FileExist(psPath)
            FileDelete(psPath)
        FileAppend(psScript, psPath)
        
        ; Run the download visually so the user can see progress
        RunWait("powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"" . psPath . "`"")
    }
}

; Proceed with sync if we have everything
tesolDir := EnvGet("USERPROFILE") . "\Downloads\TESOL"

if FileExist(rcloneExe) && FileExist(saKeyFile) && (!DirExist(hanuMaterialsDir) || !DirExist(tesolDir)) {
    ; Write temporary rclone config for both folders
    rcloneConf := A_Temp . "\rclone_hanu.conf"
    confContent := "[gdrive]`ntype = drive`nservice_account_file = " . saKeyFile . "`nroot_folder_id = 1hY92O6Zsjyfe5O1S3WYKlZcAI-3uTVIC`n`n"
    confContent .= "[gdrive_tesol]`ntype = drive`nservice_account_file = " . saKeyFile . "`nroot_folder_id = 1JLthZ0VAMXFN7KCfEGHOXR6mwPDKCA6H"
    
    if FileExist(rcloneConf)
        FileDelete(rcloneConf)
    FileAppend(confContent, rcloneConf)
    
    ; Run rclone syncs sequentially (download only, never delete from remote Drive)
    if !DirExist(hanuMaterialsDir)
        RunWait(rcloneExe . " copy gdrive: `"" . hanuMaterialsDir . "`" --config `"" . rcloneConf . "`"",, "Hide")
    if !DirExist(tesolDir)
        RunWait(rcloneExe . " copy gdrive_tesol: `"" . tesolDir . "`" --config `"" . rcloneConf . "`"",, "Hide")

    ; --- Extract and Cleanup ZIP Files locally ---
    zipScript := "$dirs = @('" . hanuMaterialsDir . "', '" . tesolDir . "')`n"
    zipScript .= "foreach ($dir in $dirs) {`n"
    zipScript .= "  if (Test-Path $dir) {`n"
    zipScript .= "    $zipFiles = Get-ChildItem -Path $dir -Filter '*.zip' -Recurse`n"
    zipScript .= "    foreach ($zip in $zipFiles) {`n"
    zipScript .= "      Expand-Archive -Path $zip.FullName -DestinationPath $zip.DirectoryName -Force`n"
    zipScript .= "      Remove-Item -Path $zip.FullName -Force`n"
    zipScript .= "    }`n"
    zipScript .= "  }`n"
    zipScript .= "}`n"
    
    zipPsPath := A_Temp . "\extract_hanu_zips.ps1"
    if FileExist(zipPsPath)
        FileDelete(zipPsPath)
    FileAppend(zipScript, zipPsPath)
    
    ; Run the extraction
    RunWait("powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"" . zipPsPath . "`"",, "Hide")
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
    ; RunWait("taskkill /IM Antigravity.exe /F",, "Hide") ; Commented out to prevent closing Antigravity during testing
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

