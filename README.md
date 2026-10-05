Windows (PowerShell - Run as Administrator): irm "https://github.com/wjadams17/NOAA/releases/latest/download/Benchmark.Download.ps1" | iex

Windows (PowerShell - Run as Administrator): $ProgressPreference = 'SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/wjadams17/NOAA/releases/latest/download/Benchmark.Download.ps1'))
