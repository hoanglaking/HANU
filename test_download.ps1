$ErrorActionPreference = 'Stop'

# URLs
$zaloUrl = 'https://zalo.me/download/zalo-pc'

# Paths
$tempDir = $env:TEMP
$ankiInstaller = Join-Path $tempDir 'anki_setup.exe'
$zaloInstaller = Join-Path $tempDir 'zalo_setup.exe'

try {
    # 1. Get Anki Link (Scrape apps.ankiweb.net)
    Write-Host 'Fetching Anki download link from apps.ankiweb.net...'
    $web = Invoke-WebRequest -Uri "https://apps.ankiweb.net" -UseBasicParsing -UserAgent "Mozilla/5.0"
    
    # Regex to find the download link in the HTML content
    # Looking for href="https://github.com/.../anki-*-windows-qt6.exe" or similar redirection
    # Actually, apps.ankiweb.net usually links to GitHub releases, but explicitly.
    
    # Let's match any .exe link that contains "anki" and "windows"
    # Matches href="..." content.
    if ($web.Content -match 'href="([^"]*anki-[^"]*windows-[^"]*qt6[^"]*\.exe)"') {
        $ankiUrl = $matches[1]
    } elseif ($web.Content -match 'href="([^"]*anki-[^"]*windows-[^"]*\.exe)"') {
        $ankiUrl = $matches[1]
    }
    
    if (-not $ankiUrl) {
         # Fallback search for ANY .exe link that looks like Anki
         Write-Warning "Specific pattern not found. Searching for any 'anki*.exe' link..."
         if ($web.Content -match 'href="([^"]*anki[^"]*\.exe)"') {
             $ankiUrl = $matches[1]
         }
    }

    if (-not $ankiUrl) {
        throw "Could not find Anki download link on apps.ankiweb.net"
    }

    # 2. Download Anki
    Write-Host "Downloading Anki from $ankiUrl ..."
    # Invoke-WebRequest -Uri $ankiUrl -OutFile $ankiInstaller
    Write-Host "(Dry Run) Would download Anki to $ankiInstaller"
    
    # 3. Download Zalo
    Write-Host "Downloading Zalo from $zaloUrl ..."
    # Invoke-WebRequest -Uri $zaloUrl -OutFile $zaloInstaller -UserAgent 'Mozilla/5.0'
    Write-Host "(Dry Run) Would download Zalo to $zaloInstaller"

    # 4. Run Installers
    Write-Host 'Starting installers...'
    # Start-Process $ankiInstaller
    # Start-Process $zaloInstaller
    Write-Host "(Dry Run) Would start installers"
} catch {
    Write-Error $_.Exception.Message
}
