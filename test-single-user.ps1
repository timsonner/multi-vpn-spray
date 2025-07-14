# Modified test-creds.ps1 that accepts a username parameter
param(
    [Parameter(Mandatory=$true)]
    [string]$Username
)

Import-Module ExchangeOnlineManagement

$password = ConvertTo-SecureString "asfddasfasdfasfd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($Username, $password)

Write-Host "Testing: $Username"
try {
    Connect-ExchangeOnline -Credential $credential
    Write-Host "Success for $Username" -ForegroundColor Green
    Disconnect-ExchangeOnline -Confirm:$false
} catch {
    Write-Host "Failed for $Username" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}
