### FILE: src/dashboard.php
<?php
/**
 * M365 SaaS Engine Dashboard for Remote Help
 */
$endpoint = 'https://graph.microsoft.com/beta/deviceManagement/remoteHelpSessions';
$body = ['sessionType' => 'unattended', 'startTime' => date('c', strtotime('-24 hours'))];

$data = $ms->graphCall($endpoint, $_SESSION['ms_access_token'], 'GET', $body);
$sessionCount = count($data['value'] ?? []);

echo render_premium_card('Active Unattended Sessions', (string)$sessionCount, '+5%', 'up', '🌐', 75);
?>

### FILE: scripts/Detect-RemoteHelp.ps1
<#
.SYNOPSIS
    Detection script for Intune Win32 App deployment.
.DESCRIPTION
    Checks the registry for the presence of the Remote Help installation version.
.EXAMPLE
    .\Detect-RemoteHelp.ps1
.NOTES
    Author:      Souhaiel Morhag
    Company:     MSEndpoint.com
    Blog:        https://msendpoint.com
    Academy:     https://app.msendpoint.com/academy
    LinkedIn:    https://linkedin.com/in/souhaiel-morhag
    GitHub:      https://github.com/Msendpoint
    License:     MIT
#>
try {
    $Path = "HKLM:\SOFTWARE\Microsoft\Remote Help"
    $Version = Get-ItemProperty -Path $Path -Name "Version" -ErrorAction SilentlyContinue
    if ($Version) {
        Write-Host "Remote Help is installed: $($Version.Version)"
        exit 0
    } else {
        Write-Error "Remote Help not detected."
        exit 1
    }
} catch {
    Write-Error "Error checking registry: $($_.Exception.Message)"
    exit 1
}

### FILE: scripts/Get-RemoteHelpSessions.ps1
<#
.SYNOPSIS
    Retrieves Remote Help session metadata via Microsoft Graph.
.DESCRIPTION
    Uses the SaaS Engine to query deviceManagement/remoteHelpSessions.
.NOTES
    Author:      Souhaiel Morhag
    Company:     MSEndpoint.com
    Blog:        https://msendpoint.com
    Academy:     https://app.msendpoint.com/academy
    LinkedIn:    https://linkedin.com/in/souhaiel-morhag
    GitHub:      https://github.com/Msendpoint
    License:     MIT
#>
function Get-RemoteHelpSessions {
    param([string]$HelperUPN)
    
    $endpoint = "deviceManagement/remoteHelpSessions"
    $body = @{
        sessionType = "unattended"
        helperUpn = $HelperUPN
    }
    
    try {
        return $ms->graphCall($endpoint, $_SESSION['ms_access_token'], 'GET', $body)
    } catch {
        throw "Failed to retrieve Remote Help sessions: $($_.Exception.Message)"
    }
}