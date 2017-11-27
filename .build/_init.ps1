Write-Host This is the auto-merge repo.  Here are the available commands:
Write-Host `t build -Fore Cyan
Write-Host `t merge -Fore Cyan

function global:build {
    if ($true) { Write-Host Build successful. -Fore Green }
    else { Write-Error Build failed. }
}

function global:merge ([string] $GithubApiToken) {
    if (-not $GithubApiToken) { throw "API token needed" }

}