if($Env:PortainerURL) {
    Write-Host "Portainer URL found in environment variable PortainerURL"
    $PortainerURL = $Env:PortainerURL
    Write-Host "Using $PortainerURL"
}
elseif ($PortainerURL) {
    Write-Host "Portainer URL found in variable PortainerURL from previous run"
    Write-Host "Using $PortainerURL"
}
else {
    Write-Host "Portainer URL not found in environment variable PortainerURL or variable PortainerURL"
    $PortainerURL = Read-Host "Please enter URL for portainer (ex. https://portainer.com)"
}

try {
    Write-Host "Testing Portainer URL $PortainerURL"
    $Response = $null
    $Response = Invoke-RestMethod -Uri $PortainerURL/api/system/status -Method Get
    Write-Host "Connected successfully to Portainer. Version: $($Response.Version)"
}
catch {
    Write-Host "Not able to connect. Make sure URL is valid."
    Exit
}

if($jwt) {
    try {
        Write-Host "Found existing jwt"

        if(($jwt.Created).AddHours(7) -gt (Get-Date)) {
            Write-Host "Token has expired or is close to expiring, time to refresh"
        }
        else {
            Write-Host "Token has not expired, confirming it is still valid"
            Invoke-WebRequest -Uri $PortainerURL/api/system/info -Method Get -Authentication Bearer -Token $jwt
        }
    }
    catch {

    }
}

if($PortainerCredential) {
    Write-Host "Portainer credential already found from previous run"

    do {
        $UseExistingCreds = Read-Host "Would you like to use $($Portainer.Username)? Y/n"
    } while (
        ($UseExistingCreds -ne 'Y') -and ($UseExistingCreds -ne 'N') -and ($UseExistingCreds -ne '')
    )
}

if(!$UseExistingCreds -or ($UseExistingCreds -eq 'N')) {
    $PortainerCredential = Get-Credential -Message "Enter Portainer username and password"
}

$jwt = [PSCustomObject]@{
  Token = (Invoke-RestMethod  -Method Post `
                              -Uri $PortainerURL/api/auth `
                              -Body $(@{username = $PortainerCredential.UserName; password = $PortainerCredential.Password | ConvertFrom-SecureString -AsPlainText} | ConvertTo-Json) `
                              -ContentType 'application/json').jwt | ConvertTo-SecureString -AsPlainText
  Created = Get-Date
}