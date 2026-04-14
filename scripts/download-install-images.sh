#!/usr/bin/env bash
# 批量下载小狼MC安装教程使用的截图到 images/install/
# 用法：在仓库根目录下执行
#   bash scripts/download-install-images.sh
# 需要：curl

set -e

cd "$(dirname "$0")/.." || exit 1
OUT_DIR="images/install"
mkdir -p "$OUT_DIR"

BASE="https://tuchuang-1256473000.cos.ap-beijing.myqcloud.com/image"

# 格式：<远程文件名> <保存为>
FILES=(
  "image-20260415004425373.png 01-install-jdk.png"
  "image-20260415004500892.png 02-jdk-finish.png"
  "image-20260415004635474.png 03-open-hmcl.png"
  "image-20260415002252466.png 04-create-instance.png"
  "image-20260415002325794.png 05-install-new.png"
  "image-20260415002509499.png 06-goto-install.png"
  "image-20260415002613580.png 07-click-install.png"
  "image-20260415002640210.png 08-waiting.png"
  "image-20260415002919258.png 09-confirm.png"
  "image-20260415002958863.png 10-back-home.png"
  "image-20260415003100844.png 11-create-account.png"
  "image-20260415003132253.png 12-offline-mode.png"
  "image-20260415003616436.png 13-enter-name.png"
  "image-20260415003656809.png 14-back.png"
  "image-20260415003750762.png 15-launch-game.png"
  "image-20260415003849249.png 16-multiplayer.png"
  "image-20260415003918814.png 17-add-server.png"
  "image-20260415004103967.png 18-server-info.png"
  "image-20260415004136663.png 19-join.png"
)

echo "将把 ${#FILES[@]} 张图片下载到 $OUT_DIR/"

ok=0
fail=0
for entry in "${FILES[@]}"; do
  remote="${entry%% *}"
  local="${entry##* }"
  url="$BASE/$remote"
  dest="$OUT_DIR/$local"

  if [[ -s "$dest" ]]; then
    echo "  [skip] $local 已存在"
    ok=$((ok+1))
    continue
  fi

  if curl -fsSL --max-time 30 -o "$dest" "$url"; then
    size=$(wc -c < "$dest")
    echo "  [ok]   $local ($size bytes)"
    ok=$((ok+1))
  else
    echo "  [fail] $url"
    rm -f "$dest"
    fail=$((fail+1))
  fi
done

echo
echo "完成：成功 $ok / 失败 $fail"
if (( fail > 0 )); then
  echo "建议：检查网络或代理设置后重跑。已成功的文件不会重复下载。" >&2
  exit 1
fi

echo "下一步：git add $OUT_DIR && git commit -m 'chore: 添加安装教程截图' && git push"

# 下载后走哪种压缩流程
echo ""
if [[ "${WEBP:-0}" == "1" ]]; then
  if [[ -x scripts/convert-install-images-to-webp.sh ]]; then
    echo "WEBP=1：转换为 WebP..."
    bash scripts/convert-install-images-to-webp.sh || \
      echo "（WebP 转换失败，PNG 仍保留。）"
  fi
else
  if [[ -x scripts/optimize-install-images.sh ]]; then
    echo "自动压缩 PNG（如缺 ImageMagick/Pillow 会跳过）..."
    bash scripts/optimize-install-images.sh 2>/dev/null || \
      echo "（跳过：未安装 ImageMagick 或 Pillow。）"
    echo ""
    echo "提示：想要更小的体积可以跑 WebP 转换："
    echo "  bash scripts/convert-install-images-to-webp.sh"
  fi
fi
