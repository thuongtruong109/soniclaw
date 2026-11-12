' Launch Windows Chrome with remote debugging enabled so the container can
' attach to it over the Chrome DevTools Protocol (CDP).
'
' Usage: cscript //nologo chrome.vbs   (or: make chrome)

Option Explicit

Dim shell, wmi, proc, cmd, chromePath, profileDir

Set shell = CreateObject("WScript.Shell")
Set wmi = GetObject("winmgmts:\\.\root\cimv2")

' Stop any Chrome instance already started with our debug profile.
For Each proc In wmi.ExecQuery( _
    "SELECT ProcessId FROM Win32_Process WHERE Name='chrome.exe' " & _
    "AND CommandLine LIKE '%--remote-debugging-port=9222%'")
    proc.Terminate 0
Next

' Resolve chrome.exe through the App Paths registry (it is not always on PATH).
chromePath = ""
On Error Resume Next
chromePath = shell.RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe\")
On Error GoTo 0
If chromePath = "" Then chromePath = "chrome.exe"

profileDir = shell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\chrome-debug"

cmd = """" & chromePath & """" & _
      " --remote-debugging-port=9222" & _
      " --remote-debugging-address=0.0.0.0" & _
      " --remote-allow-origins=*" & _
      " --user-data-dir=""" & profileDir & """"

shell.Run cmd, 0, False

Set wmi = Nothing
Set shell = Nothing
