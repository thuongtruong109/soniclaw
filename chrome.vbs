Set WshShell = CreateObject("WScript.Shell")
cmd = "cmd /c wmic process where ""name='chrome.exe' and CommandLine like '%--remote-debugging-port=9222%' and CommandLine like '%C:\\chrome-debug%'"" delete"
WshShell.Run cmd, 0, True
WshShell.Run """chrome.exe"" --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --remote-allow-origins=* --user-data-dir=""C:\chrome-debug"" --no-sandbox --disable-gp --disable-web-security --disable-features=VizDisplayCompositor", 0
Set WshShell = Nothing