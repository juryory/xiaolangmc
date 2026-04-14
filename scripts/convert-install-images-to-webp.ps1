# 把 images/install/ 下的 PNG 转成 WebP，并同步更新 install.html / INSTALL.md 的引用
# 用法（仓库根目录）：
#   powershell -ExecutionPolicy Bypass -File scripts\convert-install-images-to-webp.ps1
#
# 可选参数：
#   -Quality 90    WebP 质量 0-100，默认 90（截图足够清晰）
#   -Lossless      启用无损模式（体积更大但绝对不损失像素）
#   -KeepPng       转换后保留 .png（默认删除，节省仓库体积）
#   -Force         跳过"已转换"标记，强制重跑

[CmdletBinding()]
param(
    [int]$Quality = 90,
    [switch]$Lossless,
    [switch]$KeepPng,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$Dir = 'images\install'
if (-not (Test-Path $Dir)) {
    Write-Host "目录不存在：$Dir" -ForegroundColor Red
    exit 1
}

$marker = Join-Path $Dir '.webp-converted'
if ((Test-Path $marker) -and -not $Force) {
    Write-Host "已经转过 WebP（存在 $marker）。如要重跑加 -Force。" -ForegroundColor Yellow
    exit 0
}

# ---------- 定位 / 下载 cwebp.exe ----------
function Resolve-Cwebp {
    $cmd = Get-Command cwebp -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $localTool = Join-Path $PSScriptRoot '.tools\cwebp.exe'
    if (Test-Path $localTool) { return $localTool }

    $version = '1.4.0'
    $url = "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$version-windows-x64.zip"
    $zip = Join-Path $env:TEMP "libwebp-$version.zip"
    $extract = Join-Path $env:TEMP "libwebp-$version-extract"

    Write-Host "未找到 cwebp，尝试从 Google 下载 libwebp-$version-windows-x64.zip..." -ForegroundColor Cyan
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    } catch { }

    try {
        Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
    } catch {
        Write-Host "下载失败：$($_.Exception.Message)" -ForegroundColor Red
        Write-Host "解决方案（任选一）：" -ForegroundColor Yellow
        Write-Host "  1) 手动安装 cwebp：winget install Google.LibWebP  或  scoop install webp"
        Write-Host "  2) 手动下载 libwebp-windows-x64.zip，解压后把 bin\cwebp.exe 放到仓库根下的 scripts\.tools\"
        exit 1
    }

    if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $extract -Force

    $src = Join-Path $extract "libwebp-$version-windows-x64\bin\cwebp.exe"
    if (-not (Test-Path $src)) {
        Write-Host "解压后找不到 cwebp.exe: $src" -ForegroundColor Red
        exit 1
    }
    New-Item -ItemType Directory -Path (Split-Path $localTool) -Force | Out-Null
    Copy-Item -Path $src -Destination $localTool -Force

    Remove-Item $zip -ErrorAction SilentlyContinue
    Remove-Item $extract -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "  cwebp.exe 已缓存到：$localTool" -ForegroundColor Green
    return $localTool
}

$cwebp = Resolve-Cwebp

# ---------- 转换 ----------
$pngs = Get-ChildItem -Path $Dir -Filter '*.png'
if ($pngs.Count -eq 0) {
    Write-Host "$Dir 下没有 PNG，先跑 download-install-images.ps1。" -ForegroundColor Yellow
    exit 1
}

Write-Host "开始转换：$($pngs.Count) 张 PNG -> WebP（quality=$Quality, lossless=$($Lossless.IsPresent)）" -ForegroundColor Cyan

$totalBefore = 0
$totalAfter  = 0

foreach ($png in $pngs) {
    $before = $png.Length
    $totalBefore += $before

    $webp = [IO.Path]::ChangeExtension($png.FullName, '.webp')

    $cwebpArgs = @('-quiet')
    if ($Lossless) {
        $cwebpArgs += @('-lossless', '-z', '9')
    } else {
        $cwebpArgs += @('-q', "$Quality", '-m', '6')
    }
    $cwebpArgs += @($png.FullName, '-o', $webp)

    try {
        & $cwebp @cwebpArgs
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path $webp)) {
            throw "cwebp exit code $LASTEXITCODE"
        }
        $after = (Get-Item $webp).Length
        $totalAfter += $after
        $pct = if ($before -gt 0) { [Math]::Round(($before - $after) * 100.0 / $before, 1) } else { 0 }
        "{0,-30} {1,10:N0} -> {2,10:N0} ({3,5:N1}% smaller)" -f $png.Name, $before, $after, $pct | Write-Host

        if (-not $KeepPng) {
            Remove-Item $png.FullName
        }
    } catch {
        Write-Host "  [fail] $($png.Name): $($_.Exception.Message)" -ForegroundColor Red
        $totalAfter += $before
    }
}

$saved = $totalBefore - $totalAfter
$savedPct = if ($totalBefore -gt 0) { [Math]::Round($saved * 100.0 / $totalBefore, 1) } else { 0 }
Write-Host ""
Write-Host ("合计：{0:N0} bytes -> {1:N0} bytes，节省 {2:N0} bytes ({3:N1}%)" -f $totalBefore, $totalAfter, $saved, $savedPct) -ForegroundColor Cyan

# ---------- 更新 install.html / INSTALL.md 的引用 ----------
Write-Host ""
Write-Host "同步更新 install.html / INSTALL.md 的图片引用..." -ForegroundColor Cyan

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
foreach ($refFile in @('install.html', 'INSTALL.md')) {
    if (-not (Test-Path $refFile)) { continue }
    $raw = [System.IO.File]::ReadAllText((Resolve-Path $refFile), [System.Text.Encoding]::UTF8)
    $new = [regex]::Replace($raw, 'images/install/([\w\-]+)\.png', 'images/install/$1.webp')
    if ($new -ne $raw) {
        [System.IO.File]::WriteAllText((Resolve-Path $refFile), $new, $utf8NoBom)
        Write-Host "  updated $refFile" -ForegroundColor Green
    } else {
        Write-Host "  no change in $refFile" -ForegroundColor DarkGray
    }
}

# 清除旧标记
$oldMarker = Join-Path $Dir '.optimized'
if (Test-Path $oldMarker) { Remove-Item $oldMarker -Force }

Set-Content -Path $marker -Value ("webp-converted at {0} (quality={1}, lossless={2})" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Quality, $Lossless.IsPresent)

Write-Host ""
Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "  git add $Dir install.html INSTALL.md"
Write-Host "  git commit -m 'chore: 把安装教程截图转成 WebP'"
Write-Host "  git push"
