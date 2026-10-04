# Run as Administrator
# .\script.ps1
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# irm "https://raw.githubusercontent.com/wjadams/noaa/main/benchmark_download.ps1" | iex

$folder = "C:\NOAA"
$baseUrl = "https://geodesy.noaa.gov/pub/DS_ARCHIVE/ShapeFiles/"

# Create destination folder
New-Item -ItemType Directory -Force -Path $folder | Out-Null

Write-Host ""
Write-Host "NOAA State Shapefile Downloader" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Get NOAA directory listing
Write-Host "Reading NOAA directory..." -ForegroundColor Cyan

try {
    $page = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing
}
catch {
    Write-Host "Unable to access NOAA." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit
}

# Extract the actual ZIP filenames from NOAA's directory
$files = [regex]::Matches(
    $page.Content,
    '(?i)href="([^"]+\.zip)"'
) | ForEach-Object {
    $_.Groups[1].Value
}

# Keep only the lowercase .zip version.
# This prevents downloading both MA.zip and MA.ZIP.
$files = $files |
    Where-Object { $_ -cmatch '\.zip$' } |
    Sort-Object -Unique

# Exclude the complete datasheet archive
$files = $files |
    Where-Object { $_ -ne "all_datasheets.zip" }

Write-Host ""
Write-Host "Found $($files.Count) ZIP files." -ForegroundColor Yellow
Write-Host ""

# Show what will be downloaded
foreach ($file in $files) {
    Write-Host "  $file"
}

Write-Host ""
$answer = Read-Host "Download all of these files? (Y/N)"

if ($answer -notmatch '^[Yy]$') {
    Write-Host "Download cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Starting downloads..." -ForegroundColor Green
Write-Host ""

$success = 0
$failed = 0

foreach ($file in $files) {

    $url = $baseUrl + $file
    $destination = Join-Path $folder $file

    # Don't download a file that already exists
    if (Test-Path $destination) {
        Write-Host "[SKIP] $file already exists." -ForegroundColor DarkGray
        continue
    }

    Write-Host "[DOWNLOAD] $file" -ForegroundColor Cyan

    try {
        Invoke-WebRequest `
            -Uri $url `
            -OutFile $destination `
            -UseBasicParsing

        Write-Host "           Complete" -ForegroundColor Green
        $success++
    }
    catch {
        Write-Host "           FAILED" -ForegroundColor Red
        Write-Host "           $($_.Exception.Message)" -ForegroundColor Red

        # Remove incomplete file if one was created
        if (Test-Path $destination) {
            Remove-Item $destination -Force
        }

        $failed++
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "Download finished." -ForegroundColor Green
Write-Host "Successful: $success" -ForegroundColor Green
Write-Host "Failed:     $failed" -ForegroundColor Red
Write-Host ""
Write-Host "Files are located in:" -ForegroundColor Yellow
Write-Host $folder -ForegroundColor Yellow
Write-Host ""
