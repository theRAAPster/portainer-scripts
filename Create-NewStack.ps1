# $headers = @{}
# $headers.Add("X-API-Key", "ptr_")

# Invoke-RestMethod -Method GET -Uri https://portainer.local.raaps.net/api/stacks -Headers $headers

$api = "https://portainer.local.raaps.net/api"

$target = "dockerserv2"
$name = "duplicacy"

$endpointId = (Invoke-RestMethod -Method GET -Uri $api/endpoints?search=$target -Headers $headers).Id

$body = @{
  autoUpdate = @{
    forcePullImage = $true
    forceUpdate = $false
    interval = "5m0s"
  }
  composeFile = "$name/docker-compose.yaml"
  env = @(
    @{
      name = "DOCKER_VOLUMES"
      value = "/home/jason/docker/"
    },
    @{
      name = "URL"
      value = "$name.local.raaps.net"
    }
  )
  fromAppTemplate = $false
  name = "$name"
  repositoryAuthentication = $true
  repositoryGitCredentialID = 2
  repositoryReferenceName = "refs/heads/dockerserv2"
  repositoryURL = "https://github.com/theRAAPster/dockers"
  supportRelativePath = $false
  tlsskipVerify = $false
}

#$body | ConvertTo-Json
Invoke-RestMethod -Method POST `
                  -Uri $api/stacks/create/standalone/repository?endpointId=$endpointId `
                  -Headers $headers `
                  -Body $($body | ConvertTo-Json) `
                  -ContentType 'application/json'