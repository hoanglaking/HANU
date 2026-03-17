# Auto-Install Git, Antigravity & Dismiss .NET Dialog

Add three startup features to `setup_hanu.ahk` so that launching `setup_hanu.exe` on a fresh DeepFreeze PC sets up everything automatically.

> [!IMPORTANT]
> - **Git**: Installed via **winget**, which is first downloaded from GitHub (GitHub downloads work on these PCs). No local bundling needed.
> - **Antigravity**: Must be **bundled in `HANU\File\`** since it's not available via winget.
> - Microsoft CDN downloads (visualstudio.microsoft.com) return HTTP 400 on these networks, but GitHub downloads work fine.

## Proposed Changes

### [MODIFY] [setup_hanu.ahk](file:///c:/Users/Administrator/Downloads/HANU/setup_hanu.ahk)

#### 1. Auto-dismiss .NET Framework dialog (background timer)
- Add a `SetTimer` that runs every 2 seconds checking for any window with ".NET Framework" in the title
- When found, automatically close it with `WinClose`
- Placed at the top of the auto-execute section so it's active immediately

#### 2. Auto-install Git via winget
- Check if `git.exe` exists at `C:\Program Files\Git\cmd\git.exe`
- If not found:
  1. Download winget `.msixbundle` + dependencies from GitHub releases
  2. Install winget via `Add-AppxPackage`
  3. Run `winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements`
- After Git install, configure `user.name` and `user.email` to "Hoang"

#### 3. Auto-install Antigravity (wizard automation)
- Check if `Antigravity.exe` is already installed (check common install paths)
- If not found, look for `Antigravity.exe` installer in `HANU\File\`
- Launch installer, then automate the wizard using `WinWait` + `Send`:
  - Dismiss the initial "not admin" dialog (Enter)
  - Press Alt+N 4 times, then Alt+I (as documented in `antigravity setup.txt`)
  - After install, automate first-launch settings: Enter → 3× Right → wait 3s → Enter → Down → Enter → Enter
  - Stop at the Google sign-in screen

#### 4. Remove broken .NET 4.8 auto-install block
- Remove the existing `.NET 4.8 download + install` logic (lines 13–42) since it doesn't work on DeepFreeze PCs
- Replace with just the timer-based dialog dismissal

#### 5. Change Win+\` shortcut to toggle volume
- Instead of opening the volume mixer (`sndvol`), modify the `LWin & \`` hotkey to toggle the master volume.
- Use `SoundGetVolume()` and `SoundSetVolume()` to switch between volume levels 2 and 9.
- Display a brief ToolTip overlay ("Volume: 2%" or "Volume: 9%") for 1.5 seconds so the user has a visual announcement of the changed value.

## Verification Plan

### Manual Verification
1. Re-compile `setup_hanu.ahk` to `setup_hanu.exe`
2. Copy the Git installer and Antigravity installer into `HANU\File\`
3. Run `setup_hanu.exe` on a fresh DeepFreeze PC
4. Verify: Git installs silently and `git --version` works
5. Verify: Antigravity wizard is automated through to the Google sign-in screen
6. Verify: Any ".NET Framework" popup is auto-closed within 2 seconds
7. Verify: Pressing `Win+\`` toggles the system volume between 2 and 9.
