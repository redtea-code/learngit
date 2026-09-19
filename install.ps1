[CmdletBinding()]
param(
    [string]$Destination,
    [string[]]$SkillNames,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillsRoot = Join-Path $repoRoot 'skills'

if (-not $Destination) {
    if ($env:CODEX_HOME) {
        $Destination = $env:CODEX_HOME
    } else {
        $Destination = Join-Path $HOME '.codex'
    }
}

if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
    throw "Missing skills directory: $skillsRoot"
}

$SkillNames = @($SkillNames | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$available = @(Get-ChildItem -LiteralPath $skillsRoot -Directory | Sort-Object Name)
if ($SkillNames) {
    $wanted = @{}
    foreach ($name in $SkillNames) { $wanted[$name] = $true }
    $selected = @($available | Where-Object { $wanted.ContainsKey($_.Name) })
    $missing = @($SkillNames | Where-Object { -not ($available.Name -contains $_) })
    if ($missing.Count -gt 0) {
        throw "Unknown skill(s): $($missing -join ', ')"
    }
} else {
    $selected = $available
}

$targetSkills = Join-Path $Destination 'skills'
New-Item -ItemType Directory -Force -Path $targetSkills | Out-Null

foreach ($skill in $selected) {
    $target = Join-Path $targetSkills $skill.Name
    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        throw "Destination already exists: $target. Re-run with -Force to replace it."
    }
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
    }
    Copy-Item -LiteralPath $skill.FullName -Destination $target -Recurse -Force
    Write-Output "Installed $($skill.Name) -> $target"
}

Write-Output "Installed $($selected.Count) skill(s) into $targetSkills"
