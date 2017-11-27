Write-Host This is the auto-merge repo.  Here are the available commands:
Write-Host `t build -Fore Cyan
Write-Host `t merge -Fore Cyan

function global:build {
    if ($true) { Write-Host Build successful. -Fore Green }
    else { Write-Error Build failed. }
}

function global:merge ([string] $GithubApiToken) {
    if (-not $GithubApiToken) { throw "API token needed" }

    $owner = "samblackburn"
    $repo = "auto-merge"
    $branch = "add-readme"


    $base64token = [System.Convert]::ToBase64String([char[]]$GithubApiToken);
    $headers = @{ Authorization="Basic $base64token" };
    $pulls = Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/search/issues?q=user%3A$owner+repo%3A$repo+type%3Apr+state%3Aopen+label%3Amerge-when-green+head%3A$branch"
    if ($pulls.total_count -lt 1) { Write-Host "No PRs for this branch. Bye!"; return; }
    $pull = $pulls.items | Select -First 1
    $pullNumber = $pull.number
    $pullUrl = $pull.html_url
    Write-Host "Merging #$pullNumber..."
    Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/repos/$owner/$repo/pulls/$pullNumber/merge" -Method PUT
}