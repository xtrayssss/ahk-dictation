# 🎙️ AHK Dictation

[English](README-EN.md) · [Русский](README.md)

Lightweight voice dictation for Windows 10: press a hotkey, speak, and the text is typed wherever your cursor is — terminal, browser, or any editor.

Nothing heavy sits in memory: transcription happens in the cloud (Groq / Whisper).

## How it works

```
Ctrl+Alt+D  →  ffmpeg records a WAV from your microphone
Ctrl+Alt+D  →  sent to Groq Whisper → the text is typed into the focused window
```

- **Stack:** AutoHotkey v2 (hotkey listener, ~5–10 MB of RAM) + ffmpeg (dshow, 16 kHz mono WAV) + the built-in `curl.exe`.
- **No Python, no SDKs** — on purpose.
- The hotkey is bound by scan code (`^!SC020::`), so it works in any keyboard layout.
- The Whisper prompt is tuned for mixed Russian/tech speech.

## Requirements

- Windows 10, AutoHotkey **v2**.
- [`ffmpeg.exe`](https://www.gyan.dev/ffmpeg/builds/) (the script points to the yt-dlp build path).
- A Groq API key.

## Setup

1. Put an `openai_key.txt` file with your key next to the script (format — `gsk_...`):
   ```
   gsk_your_key_here
   ```
   See `openai_key.txt.example` as a template. The key file is covered by `.gitignore`.
2. Check the `MIC` line — put your exact microphone name there. List devices:
   ```bat
   ffmpeg -hide_banner -list_devices true -f dshow -i dummy
   ```
3. Run:
   ```bat
   AutoHotkey64.exe dictate.ahk
   ```

## Usage

| Keys | Action |
|---|---|
| `Ctrl+Alt+D` | first press — start recording, second — stop and transcribe |
| `Ctrl+Alt+E` | **Cancel** the current recording (delete WAV, send nothing) |
| (recording) | the text is typed into the active window when done |

Recording is stopped with a real console `Ctrl+C` (`GenerateConsoleCtrlEvent`) so ffmpeg flushes the WAV header — the API never gets a broken file.

## Settings (top of the script)

| Variable | What it does |
|---|---|
| `MIC` | microphone name for dshow (`audio="..."`) |
| `FFMPEG` | path to `ffmpeg.exe` |
| Whisper model | `whisper-large-v3-turbo` (faster) in the `curl` line; swap for `whisper-large-v3` |
| `prompt=...` | Whisper hint with tech terms (Claude Code, git, Python, API, GitHub) |

## License

MIT.