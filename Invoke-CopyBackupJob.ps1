# Jenkins config
$jenkinsUrl = "https://opsci.o9solutions.com/job/copy-backup/buildWithParameters"
$username = "Siddhartha.Pati" # replace with your Jenkins username if needed
$apiToken = "11859145753d214b609b2bc49ea825ce33" # your API token

# Parameters
$nodeLabel = "aws"
$sourceProfile = "o9prod-preprod-o9solutions-ue1"
$destinationProfile = "aws-prod-tmobileinfra-ue1"

# Encode auth header

$pair = "$($username):$($apiToken)"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [Convert]::ToBase64String($bytes)
$authHeader = "Basic $base64"

Write-Host "`n=== Jenkins Copy-Backup Job Trigger with API Token ===`n"

while ($true) {
    $id = Read-Host "Enter ID (or 'exit' to quit)"
    if ($id -eq "exit") { break }
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "ID cannot be empty."
        continue
    }

    $queryParams = @{
        NodeLabel = $nodeLabel
        SourceProfile = $sourceProfile
        DestinationProfile = $destinationProfile
        Id = $id
    }

    $queryString = ($queryParams.GetEnumerator() | ForEach-Object {
        [uri]::EscapeDataString($_.Key) + "=" + [uri]::EscapeDataString($_.Value)
    }) -join "&"

    $fullUrl = "$jenkinsUrl`?$queryString"
    Write-Host "Triggering job for ID: $id"
    Write-Host "URL: $fullUrl"

    try {
        Invoke-WebRequest -Uri $fullUrl -Headers @{ Authorization = $authHeader } -Method Get -UseBasicParsing
        Write-Host "✅ Triggered job for ID: $id`n"
    } catch {
        Write-Host "❌ Failed to trigger job for ID: $id"
        Write-Host $_.Exception.Message
    }
}
