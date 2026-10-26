# apply-patches.ps1 — 应用 HPM 社区仓库补丁（Windows 本地）
# Zephyr 补丁由同级的 Dust_Zephyr_Tree 仓库管理。
param(
  [string]$SdkEnv,
  [string]$SdkGlue,
  [string]$CherryUsb,
  [switch]$Check
)
$ErrorActionPreference = "Stop"
$Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Patches = Join-Path $Root "zephyr-patches"

if (-not $SdkEnv)  { $SdkEnv  = Join-Path $Root "../sdk_env" }
if (-not $SdkGlue) { $SdkGlue = Join-Path $Root "../sdk_glue" }

function Apply-One([string]$Repo, [string]$Patch) {
  Write-Host "==> $Patch"
  git -C $Repo apply --reverse --check $Patch 2>$null
  if ($LASTEXITCODE -eq 0) {
    Write-Host "already applied: $Patch"
    return
  }
  git -C $Repo apply --check $Patch
  if ($LASTEXITCODE -ne 0) { throw "CHECK FAIL: $Patch" }
  if ($Check) { return }
  git -C $Repo apply $Patch
  if ($LASTEXITCODE -ne 0) { throw "APPLY FAIL: $Patch" }
}

function Apply-Dir([string]$Repo, [string]$Dir) {
  $patches = Get-ChildItem -Path $Dir -Filter "*.diff" | Sort-Object Name
  if ($patches.Count -eq 0) { throw "没有找到补丁: $Dir" }
  foreach ($patch in $patches) { Apply-One $Repo $patch.FullName }
}

Apply-Dir $SdkEnv  (Join-Path $Patches "sdk_env")
Apply-Dir $SdkGlue (Join-Path $Patches "sdk_glue")
if ($CherryUsb) { Apply-Dir $CherryUsb (Join-Path $Patches "cherryusb") }

Write-Host "HPM 社区仓库补丁处理完成。"
