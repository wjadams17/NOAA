Windows (Run from Administrator PowerShell): irm "https://raw.githubusercontent.com/wjadams17/NOAA/main/Benchmark Download.ps1" | iex

Windows (Run from Administrator PowerShell): $ProgressPreference = 'SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wjadams17/NOAA/main/Benchmark Download.ps1'))
