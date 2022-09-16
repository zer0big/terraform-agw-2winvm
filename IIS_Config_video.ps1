import-module servermanager
add-windowsfeature web-server -includeallsubfeature
add-windowsfeature Web-Asp-Net45
add-windowsfeature NET-Framework-Features
New-Item -Path "C:\inetpub\wwwroot\" -Name "video" -ItemType "directory"
Set-Content -Path "C:\inetpub\wwwroot\video\Default.html" -Value "This is the video server"