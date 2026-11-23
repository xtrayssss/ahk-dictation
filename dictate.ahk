#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

MIC := "Микрофон (High Definition Audio Device)"   ; ← вставь своё имя микрофона
FFMPEG := "D:\Applications\yt-dlp\yt-dlp_win\ffmpeg.exe"
KEY := Trim(FileRead(A_ScriptDir "\openai_key.txt"))   ; тут лежит твой ключ gsk_...
WAV := A_Temp "\dictate.wav"
OUT := A_Temp "\dictate.txt"
pid := 0
savedWin := 0
savedControl := 0

^!SC020:: {   ; Ctrl+Alt+D
    global pid, savedWin, savedControl
    if !pid {
        savedWin := WinGetID("A")
        try savedControl := ControlGetFocus("ahk_id " savedWin)
        try FileDelete(WAV)
        Run(Format('"{}" -y -loglevel quiet -f dshow -i audio="{}" -ar 16000 -ac 1 "{}"', FFMPEG, MIC, WAV), , "Hide", &pid)
        ToolTip("● запись")
    } else {
        DllCall("AttachConsole", "UInt", pid)
        DllCall("SetConsoleCtrlHandler", "Ptr", 0, "Int", 1)
        DllCall("GenerateConsoleCtrlEvent", "UInt", 0, "UInt", 0)
        ProcessWaitClose(pid, 3)
        DllCall("FreeConsole")
        DllCall("SetConsoleCtrlHandler", "Ptr", 0, "Int", 0)
        pid := 0
        ToolTip("■ отправка...")
        try FileDelete(OUT)
        RunWait(Format('curl.exe -s https://api.groq.com/openai/v1/audio/transcriptions -H "Authorization: Bearer {}" -F model=whisper-large-v3-turbo -F language=ru -F response_format=text -F "prompt=Claude Code, git, Python, API, GitHub" -F "file=@{}" -o "{}"', KEY, WAV, OUT), , "Hide")
        ToolTip()
        try {
            text := Trim(FileRead(OUT, "UTF-8"))
            if text != "" {
                inserted := false
                try {
                    if savedControl {
                        ControlSetText(text, "ahk_id " savedControl)
                        inserted := true
                    } else if savedWin {
                        ControlSetText(text, "ahk_id " savedWin)
                        inserted := true
                    }
                }
                if !inserted {
                    ; fallback: clipboard + paste
                    ClipSave := ClipboardAll()
                    A_Clipboard := text
                    ClipWait 2
                    Send "^v"
                    Sleep 150
                    A_Clipboard := ClipSave
                }
            }
            try FileDelete(WAV)
        }
        savedWin := 0
        savedControl := 0
    }
}

^!SC012:: {   ; Ctrl+Alt+E — отмена записи (SC012 = E)
    global pid, savedWin, savedControl
    if pid {
        DllCall("AttachConsole", "UInt", pid)
        DllCall("SetConsoleCtrlHandler", "Ptr", 0, "Int", 1)
        DllCall("GenerateConsoleCtrlEvent", "UInt", 0, "UInt", 0)
        ProcessWaitClose(pid, 1)
        DllCall("FreeConsole")
        DllCall("SetConsoleCtrlHandler", "Ptr", 0, "Int", 0)
        pid := 0
        try FileDelete(WAV)
        try FileDelete(OUT)
    }
    savedWin := 0
    savedControl := 0
    ToolTip("✖ запись отменена")
    SetTimer () => ToolTip(), -1500
}