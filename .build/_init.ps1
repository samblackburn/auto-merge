Write-Host "This is the auto-merge repo.  Here are the available commands:"
Write-Host `t build -Fore Cyan
Write-Host `t merge -Fore Cyan

function global:build {
    if ($true) { Write-Host Build successful. -Fore Green }
    else { Write-Error Build failed. }
}

function global:merge ([string] $GithubApiToken, [string]$branch, [string] $revision) {
    if (-not $GithubApiToken) { throw "API token needed" }
    if (-not $branch) { throw "branch needed" }
    if (-not $revision) { throw "revision needed" }
    $owner = "samblackburn"
    $repo = "auto-merge"

    $base64token = [System.Convert]::ToBase64String([char[]]$GithubApiToken);
    $headers = @{ Authorization="Basic $base64token" };
    $searchUri = "https://api.github.com/search/issues?q=user%3A$owner+repo%3A$repo+type%3Apr+state%3Aopen+label%3Amerge-when-green+head%3A$branch"
    Write-Host "Searching with $searchUri"
    $pulls = Invoke-RestMethod -Headers $headers -Uri $searchUri
    if ($pulls.total_count -lt 1) { Write-Host "No open PRs labeled 'merge-when-green' for branch $branch. Bye!"; return; }
    $pull = $pulls.items | Select -First 1
    $pullNumber = $pull.number
    $pullDetails = Invoke-RestMethod -Headers $headers -Uri https://api.github.com/repos/$owner/$repo/pulls/$pullNumber
    $pullSha = $pullDetails.head.sha

    if (!$pullSha.StartsWith($revision, "CurrentCultureIgnoreCase")) { Write-Host "This build [$revision] isn't for the head commit, [$pullSha].  Bye!"; return; }
        
    Write-Host "Merging #$pullNumber..."
    $body = @{sha = $pullSha} | ConvertTo-Json
    Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/repos/$owner/$repo/pulls/$pullNumber/merge" -Body $body -Method PUT
}