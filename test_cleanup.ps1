$emailsToRemove = @('hoang26hoang@gmail.com', 'hoang26gamer@gmail.com', 'hoanglaking@gmail.com')

# MOCK DATA SETUP
$testDir = Join-Path $env:TEMP "ChromeCleanupTest"
if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
New-Item -Path $testDir -ItemType Directory -Force | Out-Null

$mockUserData = Join-Path $testDir "User Data"
New-Item -Path $mockUserData -ItemType Directory -Force | Out-Null
$mockLocalState = Join-Path $mockUserData "Local State"

# Create fake profiles
$profile1 = Join-Path $mockUserData "Profile 1"
New-Item -Path $profile1 -ItemType Directory -Force | Out-Null
Set-Content (Join-Path $profile1 "Test.txt") "Data1"

$profile2 = Join-Path $mockUserData "Profile 2"
New-Item -Path $profile2 -ItemType Directory -Force | Out-Null
Set-Content (Join-Path $profile2 "Test.txt") "Data2"

# Create Local State JSON
# Profile 1 matches an email to remove
# Profile 2 does NOT match
$jsonContent = @{
    profile = @{
        info_cache = @{
            "Profile 1" = @{ user_name = "hoang26hoang@gmail.com" };
            "Profile 2" = @{ user_name = "keepme@gmail.com" }
        }
    }
} | ConvertTo-Json -Depth 5

Set-Content $mockLocalState $jsonContent -Encoding UTF8

# START ACTUAL LOGIC (Modified variables to point to mock data)
Write-Host 'Closing apps... (Mock)'
# Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
# Stop-Process -Name zalo -Force -ErrorAction SilentlyContinue

# Chrome User Data Path
$userDataPath = $mockUserData # Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data'
$localStatePath = $mockLocalState # Join-Path $userDataPath 'Local State'

if (Test-Path $localStatePath) {
    try {
        # Read JSON with correct encoding (often UTF8)
        $content = Get-Content $localStatePath -Raw -Encoding UTF8
        $json = $content | ConvertFrom-Json
        
        # The 'profile.info_cache' object keys are the folder names (e.g. 'Profile 1')
        # The values contain 'user_name' which is the email.
        $profiles = $json.profile.info_cache
        
        # Iterate through profiles
        foreach ($folderName in $profiles.PSObject.Properties.Name) {
            $profileData = $profiles.$folderName
            $email = $profileData.user_name
            
            Write-Host "Checking profile: $folderName ($email)"

            if ($email -in $emailsToRemove) {
                $dirToRemove = Join-Path $userDataPath $folderName
                Write-Host "Found profile '$email' at '$dirToRemove'. Deleting..."
                if (Test-Path $dirToRemove) {
                    Remove-Item -LiteralPath $dirToRemove -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "Deleted."
                }
            } else {
                 Write-Host "Keeping profile '$email'."
            }
        }
    } catch {
        Write-Error "Error parsing Chrome profiles: $_"
    }
}

# Verify Results
Write-Host "`n--- Verification ---"
if (-not (Test-Path $profile1)) { Write-Host "SUCCESS: Profile 1 was deleted." } else { Write-Host "FAIL: Profile 1 still exists." }
if (Test-Path $profile2) { Write-Host "SUCCESS: Profile 2 was kept." } else { Write-Host "FAIL: Profile 2 was deleted." }
