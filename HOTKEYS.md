# HANU Hotkey Reference

This document lists all available hotkeys for the HANU Library Computer Automation Script.

## Global Hotkeys

These hotkeys work across all applications. **Note:** The script automatically closes the Start Menu when you use these shortcuts.

| Hotkey | Action | Description |
|--------|--------|-------------|
| **Win+Z** | Night Light | Toggles Windows Night Light on/off |
| **Win+E** | Downloads | Opens local Downloads folder |
| **Win+C** | Chrome | Launches Google Chrome browser |
| **Win+Q** | Close Window | Simulates Alt+F4 to close the active window |
| **Win+`** | Volume Mixer | Opens Windows Volume Mixer (sndvol) |
| **Ctrl+Alt+L** | Cleanup | Runs cleanup script (closes Chrome/Zalo, deletes data) |

---

## Chrome-Specific Hotkeys

These hotkeys only work when Google Chrome is the active window:

| Hotkey | Action | Native Chrome Equivalent |
|--------|--------|--------------------------|
| **Alt+1** | Switch to Tab 1 | Ctrl+1 |
| **Alt+2** | Switch to Tab 2 | Ctrl+2 |
| **Alt+3** | Switch to Tab 3 | Ctrl+3 |
| **Alt+4** | Switch to Tab 4 | Ctrl+4 |
| **Alt+5** | Switch to Tab 5 | Ctrl+5 |
| **Alt+6** | Switch to Tab 6 | Ctrl+6 |
| **Alt+7** | Switch to Tab 7 | Ctrl+7 |
| **Alt+8** | Switch to Tab 8 | Ctrl+8 |
| **Alt+9** | Switch to Last Tab | Ctrl+9 |

> [!NOTE]
> The Chrome-specific hotkeys remap Alt+Number to Ctrl+Number within Chrome. This allows for easier one-handed tab switching.

---

## Cleanup Script Details

**Hotkey:** `Ctrl+Alt+L`

When triggered, this script:

- Prompts for confirmation before proceeding
- Closes Chrome and Zalo applications
- Deletes Chrome profiles for these emails:
  - `hoang26hoang@gmail.com`
  - `hoang26gamer@gmail.com`
  - `hoanglaking@gmail.com`
- Empties the Recycle Bin
- Exits the AutoHotkey script after completion

> [!WARNING]
> The cleanup script will permanently delete data. Always confirm you want to proceed before clicking OK.

---

## Requirements

- **AutoHotkey Version:** v2.0 or higher
- **Operating System:** Windows 10 or Windows 11
- **Applications:** Google Chrome (for hotkeys and automation)

---

## File Location

Script file: `setup_hanu.ahk`

To run the script:

1. Install AutoHotkey v2.0
2. Double-click `setup_hanu.ahk`
3. The script runs in the system tray

To stop the script:

- Right-click the AutoHotkey icon in system tray
- Select "Exit"
