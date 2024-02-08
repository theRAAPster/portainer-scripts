# $headers = @{}
# $headers.Add("X-API-Key", "ptr_")

# Set portainer
$api = "https://portainer.local.raaps.net/api"

$target = "dockerserv2"
$name = "wrapperr"

$endpointId = (Invoke-RestMethod -Method GET -Uri $api/endpoints?search=$target -Headers $headers).Id

$stacks = Invoke-RestMethod -Method GET -Uri $api/stacks -Headers $headers

$stack = $stacks | Where-Object { $_.EndpointId -eq $endpointId -and $_.Name -eq $name }

$body = @{
  autoUpdate = $stack.AutoUpdate
  env = $stack.Env
  repositoryAuthentication = $true
  repositoryGitCredentialID = $stack.GitConfig.Authentication.GitCredentialID
  repositoryReferenceName = "refs/heads/master"
  tlsskipVerify = $false
}

Invoke-RestMethod -Method Post `
                  -Uri $api/stacks/$($stack.Id)/git?endpointId=$endpointId `
                  -Headers $headers `
                  -Body $($body | ConvertTo-Json) `
                  -ContentType 'application/json'