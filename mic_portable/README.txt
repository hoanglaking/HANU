== Whisper Portable Dictation ==

Installation:
- No installation needed! You have the files right here.

Usage:
1. Double-click "simple_dictation.ahk" to start the script.
   (You will see a green "H" icon in your system tray).

2. Open any text editor (Notepad, Word, etc.).

3. Press "Win + H" to start dictating.
   - You will see a tooltip "Listening...".
   - Speak into your microphone.
   - Text will appear automatically.

4. Press "Win + H" again to stop.

Troubleshooting:
- MISSING MODEL: The file "ggml-small.en.bin" (465MB) is not included in the Git repo. 
  If you are on a fresh computer, you MUST download it from:
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin
  and place it inside the "mic_portable" folder.

- If nothing happens, make sure your microphone is set as Default in Windows Settings.
- If it's slow, it might be the "small" model on an older CPU. We can switch to "tiny" if needed.
