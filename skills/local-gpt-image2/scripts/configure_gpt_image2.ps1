param(
    [string]$ConfigDir,
    [switch]$PassThru
)

$ErrorActionPreference = "Stop"

$skillRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$codexHome = if ([string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
    Join-Path $env:USERPROFILE '.codex'
} else {
    $env:CODEX_HOME
}

$candidateRoots = @()
if (-not [string]::IsNullOrWhiteSpace($ConfigDir)) {
    $candidateRoots += $ConfigDir
}
$candidateRoots += Join-Path (Get-Location).Path 'gen_config'
$candidateRoots += Join-Path $skillRoot 'gen_config'
$candidateRoots += Join-Path $codexHome 'gen_config'
$candidateRoots += Join-Path $env:USERPROFILE '.codex\gen_config'
$candidateRoots = @($candidateRoots | Select-Object -Unique)

$configRoot = $candidateRoots | Where-Object {
    (Test-Path -LiteralPath (Join-Path $_ 'config-gpt-image2.toml')) -and
    (Test-Path -LiteralPath (Join-Path $_ 'auth-gpt-image2.json'))
} | Select-Object -First 1

if ([string]::IsNullOrWhiteSpace([string]$configRoot)) {
    throw "No usable gen_config folder was found. Put config-gpt-image2.toml and auth-gpt-image2.json in gen_config, or pass -ConfigDir."
}

$configPath = Join-Path $configRoot 'config-gpt-image2.toml'
$authPath = Join-Path $configRoot 'auth-gpt-image2.json'
$configText = Get-Content -Raw -LiteralPath $configPath
$baseMatch = [regex]::Match($configText, '(?m)^base_url\s*=\s*"([^"]+)"')
if (-not $baseMatch.Success) {
    throw "base_url was not found in the provider configuration."
}

$baseUrl = $baseMatch.Groups[1].Value.TrimEnd('/')
if ($baseUrl -notmatch '/v1$') {
    $baseUrl = "$baseUrl/v1"
}

$auth = Get-Content -Raw -LiteralPath $authPath | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace([string]$auth.OPENAI_API_KEY)) {
    throw "OPENAI_API_KEY was not found in the provider authentication file."
}

$env:OPENAI_API_KEY = [string]$auth.OPENAI_API_KEY
$env:OPENAI_BASE_URL = $baseUrl

if ($PassThru) {
    [pscustomobject]@{
        ConfigRoot = [string]$configRoot
        BaseUrl = $baseUrl
        ApiKeyLoaded = $true
    }
}
