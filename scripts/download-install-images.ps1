# 批量下载小狼MC安装教程使用的截图到 images/install/
# 用法（在仓库根目录执行）：
#   powershell -ExecutionPolicy Bypass -File scripts\download-install-images.ps1
# 或直接双击右键"使用 PowerShell 运行"

$ErrorActionPreference = 'Stop'

# 切到仓库根目录（脚本位置的上一级）
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$OutDir = 'images\install'
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$Base = 'https://tuchuang-1256473000.cos.ap-beijing.myqcloud.com/image'

# 映射：远程文件名 -> 本地文件名
$Files = @(
    @{ Remote = 'image-20260415004425373.png'; Local = '01-install-jdk.png' }
    @{ Remote = 'image-20260415004500892.png'; Local = '02-jdk-finish.png' }
    @{ Remote = 'image-20260415004635474.png'; Local = '03-open-hmcl.png' }
    @{ Remote = 'image-20260415002252466.png'; Local = '04-create-instance.png' }
    @{ Remote = 'image-20260415002325794.png'; Local = '05-install-new.png' }
    @{ Remote = 'image-20260415002509499.png'; Local = '06-goto-install.png' }
    @{ Remote = 'image-20260415002613580.png'; Local = '07-click-install.png' }
    @{ Remote = 'image-20260415002640210.png'; Local = '08-waiting.png' }
    @{ Remote = 'image-20260415002919258.png'; Local = '09-confirm.png' }
    @{ Remote = 'image-20260415002958863.png'; Local = '10-back-home.png' }
    @{ Remote = 'image-20260415003100844.png'; Local = '11-create-account.png' }
    @{ Remote = 'image-20260415003132253.png'; Local = '12-offline-mode.png' }
    @{ Remote = 'image-20260415003616436.png'; Local = '13-enter-name.png' }
    @{ Remote = 'image-20260415003656809.png'; Local = '14-back.png' }
    @{ Remote = 'image-20260415003750762.png'; Local = '15-launch-game.png' }
    @{ Remote = 'image-20260415003849249.png'; Local = '16-multiplayer.png' }
    @{ Remote = 'image-20260415003918814.png'; Local = '17-add-server.png' }
    @{ Remote = 'image-20260415004103967.png'; Local = '18-server-info.png' }
    @{ Remote = 'image-20260415004136663.png'; Local = '19-join.png' }
)

Write-Host "将把 $($Files.Count) 张图片下载到 $OutDir\" -ForegroundColor Cyan

# 让 PowerShell 5 使用 TLS 1.2 避免握手失败
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor `
        [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls
} catch { }

$ok = 0
$fail = 0

foreach ($entry in $Files) {
    $url  = "$Base/$($entry.Remote)"
    $dest = Join-Path $OutDir $entry.Local

    if ((Test-Path $dest) -and (Get-Item $dest).Length -gt 0) {
        Write-Host "  [skip] $($entry.Local) 已存在" -ForegroundColor DarkGray
        $ok++
        continue
    }

    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        $size = (Get-Item $dest).Length
        Write-Host "  [ok]   $($entry.Local) ($size bytes)" -ForegroundColor Green
        $ok++
    } catch {
        Write-Host "  [fail] $url : $($_.Exception.Message)" -ForegroundColor Red
        if (Test-Path $dest) { Remove-Item $dest -Force }
        $fail++
    }
}

Write-Host ""
Write-Host "完成：成功 $ok / 失败 $fail" -ForegroundColor Cyan
if ($fail -gt 0) {
    Write-Host "建议：检查网络/代理后重跑，已成功的文件不会重复下载。" -ForegroundColor Yellow
    exit 1
}

Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "  git add $OutDir"
Write-Host "  git commit -m 'chore: 添加安装教程截图'"
Write-Host "  git push"
