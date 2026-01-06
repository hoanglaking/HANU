# HANU - Automation for Restricted Computers

Automation setup for specialized keyboards and portable dictation.

## ⚠️ Important: Large Model File

Due to GitHub's file size limits, the high-accuracy whisper model is **not** included in the repository.

If you are setting this up on a new computer (especially frozen library computers), you must:

1.  Download the model: [ggml-small.en.bin (465MB)](https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin)
2.  Place it in the `mic_portable/` directory.

The scripts will not work without this file.

## Usage

-   Main Setup: Run `setup_hanu.ahk`
-   Portable Dictation: Run `mic_portable/simple_dictation.ahk` (See [mic_portable/README.txt](file:///mic_portable/README.txt) for details)
