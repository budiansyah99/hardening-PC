Write-Host " "
Write-Host " "
Write-Host "--WINDOWS DEFENDER--"
# Check Windows Defender service status
$serviceStatus = Get-Service -Name "WinDefend"
Write-Host "Windows Defender Service Status: $($serviceStatus.Status)"

# Get Windows Defender status summary
$mpStatus = Get-MpComputerStatus
Write-Host "Antimalware Service Enabled: $($mpStatus.AMServiceEnabled)"
Write-Host "Antispyware Enabled: $($mpStatus.AntispywareEnabled)"
Write-Host "Antivirus Enabled: $($mpStatus.AntivirusEnabled)"
Write-Host "Real-Time Protection Enabled: $($mpStatus.RealTimeProtectionEnabled)"
Write-Host "Network Inspection System Enabled: $($mpStatus.NISEnabled)"
Write-Host "Behavior Monitor Enabled: $($mpStatus.BehaviorMonitorEnabled)"

# Get Windows Defender definitions update status
$mpSignature = Get-MpComputerStatus
Write-Host "Antivirus Signature Version: $($mpSignature.AntivirusSignatureVersion)"
Write-Host "Antivirus Signature Last Updated: $($mpSignature.AntivirusSignatureLastUpdated)"
Write-Host " "
Write-Host " "
# Check overall firewall status
Write-Host "Firewall Status for Each Profile:"
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize


# Define the RDP port
$rdpPort = 3389

# Check if there are any inbound firewall rules allowing the RDP port
$firewallRules = Get-NetFirewallRule | Where-Object {
    ($_.Direction -eq 'Inbound') -and
    (Get-NetFirewallPortFilter -AssociatedNetFirewallRule $_ | Where-Object { $_.LocalPort -eq $rdpPort })
}

if ($firewallRules) {
    Write-Host "RDP port ($rdpPort) is allowed by the following inbound firewall rules:" -ForegroundColor Green
    $firewallRules | Select-Object Name, Enabled, Action | Format-Table -AutoSize
} else {
    Write-Host "No inbound firewall rules found for RDP port ($rdpPort)." -ForegroundColor Red
}
# Function to get the current Windows version
function Get-CurrentWindowsVersion {
    $versionInfo = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    [PSCustomObject]@{
        ProductName = $versionInfo.ProductName
        CurrentVersion = $versionInfo.ReleaseId
        BuildNumber = $versionInfo.CurrentBuildNumber
    }
}

# Function to check for pending updates
function Check-PendingUpdates {
    $updates = Get-WmiObject -Class "Win32_QuickFixEngineering" | Sort-Object -Property InstalledOn -Descending
    if ($updates) {
        $latestUpdate = $updates[0]
        [PSCustomObject]@{
            Description = $latestUpdate.Description
            InstalledOn = $latestUpdate.InstalledOn
            HotFixID = $latestUpdate.HotFixID
        }
    } else {
        [PSCustomObject]@{
            Description = "No recent updates found."
            InstalledOn = ""
            HotFixID = ""
        }
    }
}

# Function to compare the installed date with today
function Compare-UpdateDate {
    param (
        [datetime]$UpdateDate
    )
    
    $today = Get-Date
    $timeDifference = $today - $UpdateDate

    if ($timeDifference.Days -eq 0) {
        return "The update was installed today."
    } elseif ($timeDifference.Days -lt 1) {
        return "The update was installed within the last 24 hours."
    } else {
        return "The update was installed $($timeDifference.Days) days ago."
    }
}
Write-Host " "
Write-Host " "
Write-Host "--WINDOWS UPDATE PENDING--"

# Check for last updates
$pendingUpdates = Check-PendingUpdates
Write-Host "`nMost Recent Applied Update:"
Write-Host "Description: $($pendingUpdates.Description)"
Write-Host "Installed On: $($pendingUpdates.InstalledOn)"
Write-Host "HotFix ID: $($pendingUpdates.HotFixID)"

# Compare the installed date with today
if ($pendingUpdates.InstalledOn) {
    $updateDate = [datetime]$pendingUpdates.InstalledOn
    $dateComparison = Compare-UpdateDate -UpdateDate $updateDate
    Write-Host $dateComparison
} else {
    Write-Host "`nNo recent update date available for comparison."
}

# Import the PSWindowsUpdate module
Import-Module PSWindowsUpdate

# Check for pending updates
$pendingUpdates = Get-WindowsUpdate -AcceptAll -IgnoreReboot

if ($pendingUpdates) {
    Write-Host "Pending Updates:"
    $pendingUpdates | Format-Table -Property KB, Title, Size, Status
} else {
    Write-Host "No pending updates found."
}
Write-Host " "
Write-Host " "
Write-Host "--CHECKING TIMEZONE--"
# Get the current time zone information
$currentTimeZone = Get-TimeZone

# Define the desired time zone
$desiredTimeZone = "(UTC+07:00) Bangkok, Hanoi, Jakarta"

# Display the current time zone
Write-Host "Current Time Zone:"
Write-Host "Id: $($currentTimeZone.Id)"
Write-Host "Display Name: $($currentTimeZone.DisplayName)"
Write-Host "Standard Name: $($currentTimeZone.StandardName)"
Write-Host "Daylight Name: $($currentTimeZone.DaylightName)"

# Check if the current time zone matches the desired time zone
if ($currentTimeZone.DisplayName -eq $desiredTimeZone) {
    Write-Host "`nThe current time zone is set to Jakarta."
} else {
    Write-Host "`nThe current time zone is not set to Jakarta."
}
Write-Host " "
Write-Host " "
Write-Host "--CHECKING HOSTNAME--"
# Get the current hostname
$currentHostname = $env:COMPUTERNAME

# Define the default Windows hostname pattern (e.g., "WIN-XXXXX")
$defaultPattern = "^WIN-[A-Z0-9]{5,}$"

# Check if the current hostname matches the default pattern
if ($currentHostname -match $defaultPattern) {
    Write-Host "The hostname is still using the default format: $currentHostname , please change it as per requested"
} else {
    Write-Host "The hostname has been changed from the default format."
    Write-Host "Current hostname: $currentHostname"
}
Write-Host " "
Write-Host " "
Write-Host "--CHECKING USER--"
# Define the new user's details
$newUsername = "user"
$newPassword = "P@ssw0rd#2024"  # Make sure to use a strong password
$newFullName = "User"
$newDescription = "Description of the new user"

# Check if the user already exists
$user = Get-LocalUser -Name $newUsername -ErrorAction SilentlyContinue
if ($null -ne $user) {
    Write-Host "User '$newUsername' already exists. Please share it to customer, dont share Administrator account"
} else {
    # Create the new user
    $securePassword = ConvertTo-SecureString $newPassword -AsPlainText -Force
    New-LocalUser -Name $newUsername -Password $securePassword -FullName $newFullName -Description $newDescription -PasswordNeverExpires -UserMayNotChangePassword

    Write-Host "User '$newUsername' has been created."

    # Add the new user to the local Administrators group
    Add-LocalGroupMember -Group "Administrators" -Member $newUsername

    Write-Host "User '$newUsername' has been added to the local Administrators group."
}