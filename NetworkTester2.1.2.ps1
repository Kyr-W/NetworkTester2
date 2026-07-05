# NetworkTester2 - simple network connectivity test menu
# NetworkTester2.0.1 - added "Please wait..." message
# NetworkNester2.1.0 - added New-PSDrive to the Network Shared folder test
# NetworkTester2.1.1 - Fixed a bug that prevented a report from being generated for HTTP and Network share connectivity tests
# NetworkTester2.1.2 - added ipconfig /all menu option

function Save-TestReport {
    param(
        [string]$Prefix,
        [string]$Target,
        [string[]]$Lines
    )

    $safeTarget = ($Target -replace '[\\/:]', '_') -replace '[^a-zA-Z0-9_\.\-]', ''
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outFile = "${Prefix}_${safeTarget}_${timestamp}.txt"

    $Lines | Tee-Object -FilePath $outFile

    Write-Host "`nResults saved to $outFile"
}

Write-Host "Select a test to run:"
Write-Host "1. MLLP connection (Ping + Test-NetConnection)"
Write-Host "2. HTTP/HTTPS connection (Test-NetConnection + curl GET/POST)"
Write-Host "3. Network share folder (Test-Path + New-PSDrive)"
Write-Host "4. IP configuration (ipconfig /all)"
$choice = Read-Host "Enter 1, 2, 3, or 4"

if ($choice -eq "1") {

    $targetIP = Read-Host "Enter target IP address"
    $port = Read-Host "Enter target port"

    Write-Host "`nPlease wait, running tests..."

    $report = @(
        "MLLP Connection Test - $(Get-Date)"
        "Target: $targetIP`:$port"
        ""
        "--- PING ---"
        (ping $targetIP)
        ""
        "--- Test-NetConnection ---"
        (Test-NetConnection -ComputerName $targetIP -Port $port | Out-String)
    )

    Save-TestReport -Prefix "MLLP_Test" -Target "${targetIP}_${port}" -Lines $report
}
elseif ($choice -eq "2") {

    $url = Read-Host "Enter the URL (include http:// or https://)"
    $uri = [System.Uri]$url

    Write-Host "`nPlease wait, running tests..."

    $report = @(
        "HTTP/HTTPS Connection Test - $(Get-Date)"
        "Target: $url"
        ""
        "--- Test-NetConnection ---"
        (Test-NetConnection -ComputerName $uri.Host -Port $uri.Port | Out-String)
        ""
        "--- curl.exe GET ---"
        (curl.exe -X GET $url 2>&1 | Out-String)
        ""
        "--- curl.exe POST ---"
        (curl.exe -X POST $url 2>&1 | Out-String)
    )

    Save-TestReport -Prefix "HTTP_Test" -Target $uri.Host -Lines $report
}
 elseif ($choice -eq "3") {

    $path = Read-Host "Enter the network share path (e.g. \\server\share)"
    $needsAuth = Read-Host "Does this share require credentials? (Y/N)"

    $reportLines = @(
        "Network Share Test - $(Get-Date)"
        "Target: $path"
        ""
        "--- Test-Path ---"
    )

    if ($needsAuth -eq "Y" -or $needsAuth -eq "y") {
        $driveName = "NetTest"

        try {
            $cred = Get-Credential -Message "Enter credentials for $path"
            if (-not $cred) {
                throw "Credential prompt was cancelled."
            }

            Write-Host "`nPlease wait, running tests..."
            New-PSDrive -Name $driveName -PSProvider FileSystem -Root $path -Credential $cred -ErrorAction Stop | Out-Null
            $reportLines += "Authentication succeeded."
            $reportLines += (Test-Path "${driveName}:\" | Out-String)
        }
        catch {
            $reportLines += "Authentication or connection failed: $($_.Exception.Message)"
        }
        finally {
            if (Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue) {
                Remove-PSDrive -Name $driveName
            }
        }
    }
    else {
        Write-Host "`nPlease wait, running tests..."
        $reportLines += (Test-Path $path | Out-String)
    }

    Save-TestReport -Prefix "Share_Test" -Target $path -Lines $reportLines
}
elseif ($choice -eq "4") {

    Write-Host "`nPlease wait, running tests..."

    $report = @(
        "IP Configuration Test - $(Get-Date)"
        ""
        "--- ipconfig /all ---"
        (ipconfig /all | Out-String)
    )

    Save-TestReport -Prefix "IPConfig_Test" -Target $env:COMPUTERNAME -Lines $report
}
else {
    Write-Host "Invalid selection. Please enter 1, 2, 3, or 4."
}

Read-Host "`nPress Enter to exit"
