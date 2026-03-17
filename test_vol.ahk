#Requires AutoHotkey v2.0
try {
    vol := SoundGetVolume()
    FileAppend("Volume: " . vol, "vol_out.txt")
} catch Error as e {
    FileAppend("Error: " . e.Message, "vol_out.txt")
}
