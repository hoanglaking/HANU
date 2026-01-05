# HANU Hotkey Reference

This document lists all available hotkeys for the HANU Library Computer Automation Script.

## Global Hotkeys

These hotkeys work across all applications:

| Hotkey | Action | Description |
|--------|--------|-------------|
## Global Hotkeys

These hotkeys work across all applications. **Note:** The script automatically closes the Start Menu when you use these shortcuts.

| Hotkey | Action | Description |
|--------|--------|-------------|
| **Win+E** | Open My Drive | Opens Google Drive (My Drive) in browser |
| **Win+C** | Open Chrome | Launches Google Chrome browser |
| **Win+K** | Open Anki | Launches Anki flashcard application |
| **Win+`** | Volume Mixer | Opens Windows Volume Mixer (sndvol) |
| **Win+Q** | Close Window | Simulates Alt+F4 to close the active window |
| **Win+L** | Cleanup | Runs cleanup script (closes Chrome/Zalo, deletes data) |

---

## Google Drive Folder Shortcuts (A-G Layout)

Quick access to specific Drive folders using the left-hand home row:

| Hotkey | Folder | Description |
|--------|--------|-------------|
| **Win+A** | Teach | Opens 'Teach' folder |
| **Win+S** | Research | Opens 'Research' folder |
| **Win+D** | Test | Opens 'Test' folder |
| **Win+F** | Philosophy | Opens 'Philosophy' folder (Filosophy) |
| **Win+V** | Writing | Opens 'Writing' folder (Viết) |

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

## Automated Startup Tasks

When the script runs, it automatically performs these tasks:

1. ✅ **Enable Night Light** - Turns on Windows Night Light feature
2. ✅ **Download Anki** - Downloads Anki installer from GitHub (version 25.09)
3. ✅ **Download Zalo** - Downloads Zalo PC messenger installer
4. ✅ **Install Anki** - Automatically installs Anki with default settings
5. ✅ **Install Zalo** - Automatically installs Zalo messenger

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
