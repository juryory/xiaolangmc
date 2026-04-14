# 压缩 images/install/ 下的所有 PNG：尺寸按比例缩到最大宽 1200px，用 PNG 重新保存以减小体积
# 用法（在仓库根目录执行）：
#   powershell -ExecutionPolicy Bypass -File scripts\optimize-install-images.ps1
# 可选参数：
#   -MaxWidth 1200    最大宽度（默认 1200）
#   -Force            忽略"已优化"标记，强制重跑

[CmdletBinding()]
param(
    [int]$MaxWidth = 1200,
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

Add-Type -AssemblyName System.Drawing

$marker = Join-Path $Dir '.optimized'
if ((Test-Path $marker) -and -not $Force) {
    Write-Host "已经优化过（存在 $marker）。如果要强制重跑，加 -Force 参数。" -ForegroundColor Yellow
    Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\optimize-install-images.ps1 -Force" -ForegroundColor DarkGray
    exit 0
}

$images = Get-ChildItem -Path $Dir -Filter '*.png'
if ($images.Count -eq 0) {
    Write-Host "$Dir 下没有 PNG，先跑 download-install-images.ps1 下载图片。" -ForegroundColor Yellow
    exit 1
}

Write-Host "开始优化：目标最大宽度 = $MaxWidth px，共 $($images.Count) 张" -ForegroundColor Cyan

$totalBefore = 0
$totalAfter  = 0

foreach ($f in $images) {
    $before = $f.Length
    $totalBefore += $before

    try {
        $img = [System.Drawing.Image]::FromFile($f.FullName)
        $origW = $img.Width
        $origH = $img.Height

        if ($origW -le $MaxWidth) {
            # 尺寸已经够小，只重新编码一次（去除一些多余元数据）
            $newW = $origW
            $newH = $origH
            $resized = $false
        } else {
            $ratio = $MaxWidth / $origW
            $newW  = $MaxWidth
            $newH  = [int][Math]::Round($origH * $ratio)
            $resized = $true
        }

        $bmp = New-Object System.Drawing.Bitmap $newW, $newH
        $g   = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.DrawImage($img, 0, 0, $newW, $newH)
        $g.Dispose()
        $img.Dispose()

        # 先写到临时文件，成功后再替换
        $tmp = "$($f.FullName).tmp"
        $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()

        Move-Item -Path $tmp -Destination $f.FullName -Force
        $after = (Get-Item $f.FullName).Length
        $totalAfter += $after

        $deltaPct = if ($before -gt 0) { [Math]::Round(($before - $after) * 100.0 / $before, 1) } else { 0 }
        $tag = if ($resized) { "resize ${origW}x${origH} -> ${newW}x${newH}" } else { "recompress" }
        "{0,-30} {1,10:N0} -> {2,10:N0} ({3,5:N1}%) {4}" -f $f.Name, $before, $after, $deltaPct, $tag | Write-Host
    } catch {
        Write-Host "  [fail] $($f.Name): $($_.Exception.Message)" -ForegroundColor Red
        $totalAfter += $before
    }
}

$saved = $totalBefore - $totalAfter
$savedPct = if ($totalBefore -gt 0) { [Math]::Round($saved * 100.0 / $totalBefore, 1) } else { 0 }
Write-Host ""
Write-Host ("合计：{0:N0} bytes -> {1:N0} bytes，节省 {2:N0} bytes ({3:N1}%)" -f $totalBefore, $totalAfter, $saved, $savedPct) -ForegroundColor Cyan

# 写标记避免重复优化
Set-Content -Path $marker -Value ("optimized at {0} by optimize-install-images.ps1 (max-width={1})" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $MaxWidth)

Write-Host ""
Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "  git add $Dir"
Write-Host "  git commit -m 'chore: 压缩安装教程截图'"
Write-Host "  git push"
