# PowerShell script to download and install Nerd Fonts for Windows
# To run this script:
# 1. Save it as download_nerd_font.ps1
# 2. Right-click on it in Windows Explorer and select "Run with PowerShell"
# 3. If prompted about execution policy, press "Y" to continue

# Create a temporary directory
$tempDir = New-Item -ItemType Directory -Path "$env:TEMP\NerdFontInstall" -Force
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip"
$zipPath = Join-Path $tempDir "Meslo.zip"
$fontDir = Join-Path $tempDir "Meslo"

Write-Host "Downloading Meslo Nerd Font..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $fontUrl -OutFile $zipPath

# Unzip the fonts
Write-Host "Extracting fonts..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $fontDir -Force

# Get font files
$fontFiles = Get-ChildItem -Path $fontDir -Filter "*.ttf"

# Install the fonts
Write-Host "Installing fonts..." -ForegroundColor Cyan
$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
foreach ($fontFile in $fontFiles) {
    Write-Host "Installing $($fontFile.Name)..."
    $fonts.CopyHere($fontFile.FullName)
}

Write-Host "Font installation complete!" -ForegroundColor Green
Write-Host "Now, configure your Windows Terminal:" -ForegroundColor Yellow
Write-Host "1. Open Windows Terminal" -ForegroundColor White
Write-Host "2. Go to Settings (Ctrl+,) -> Profiles -> Defaults -> Appearance" -ForegroundColor White
Write-Host "3. Change Font face to 'MesloLGS NF'" -ForegroundColor White
Write-Host "4. Click Save and restart Windows Terminal" -ForegroundColor White

# Clean up
Remove-Item -Path $tempDir -Recurse -Force