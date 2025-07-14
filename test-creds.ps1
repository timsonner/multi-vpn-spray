# Install-Module -Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
$username = "<username>"
$password = ConvertTo-SecureString "<password>" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)
Connect-ExchangeOnline -Credential $credential
