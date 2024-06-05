# Configuration
$organization = "YOUR_ORG"
$project = "YOUR_PROJECT"
$pat = "YOUR_PERSONAL_ACCESS_TOKEN"
$templatePath = "C:\path\to\your\pull_request_template.md"

# Read the template content
$templateContent = Get-Content -Raw -Path $templatePath

# Base64 encode the PAT for HTTP Basic Auth
$encodedPat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

# Function to get all repositories
function Get-Repos {
    $url = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=6.0"
    $headers = @{
        Authorization = "Basic $encodedPat"
    }

    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    return $response.value
}

# Function to create or update pull_request_template.md
function Upload-Template($repoId) {
    $templatePath = "pull_request_template.md"
    $url = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoId/pushes?api-version=6.0"
    $headers = @{
        Authorization = "Basic $encodedPat"
        Content-Type  = "application/json"
    }

    # Get the latest commit ID of the main branch
    $branchUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoId/refs?filter=heads/main&api-version=6.0"
    $branchResponse = Invoke-RestMethod -Uri $branchUrl -Headers $headers -Method Get
    $latestCommitId = $branchResponse.value[0].objectId

    # Create the push object
    $pushData = @{
        refUpdates = @(@{
            name       = "refs/heads/main"
            oldObjectId = $latestCommitId
        })
        commits = @(@{
            comment = "Add pull request template"
            changes = @(@{
                changeType = "add"
                item       = @{
                    path = $templatePath
                }
                newContent = @{
                    content     = $templateContent
                    contentType = "rawtext"
                }
            })
        })
    } | ConvertTo-Json -Depth 4

    # Push the template to the repository
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $pushData
    if ($response -ne $null) {
        Write-Output "Template uploaded to repo $repoId"
    } else {
        Write-Output "Failed to upload template to repo $repoId"
    }
}

# Get all repositories and upload the template
$repos = Get-Repos
foreach ($repo in $repos) {
    Upload-Template -repoId $repo.id
}
