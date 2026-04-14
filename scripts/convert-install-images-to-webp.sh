#!/usr/bin/env bash
# 把 images/install/ 下的 PNG 转成 WebP，并同步更新 install.html / INSTALL.md 的引用
# 用法（仓库根目录）：
#   bash scripts/convert-install-images-to-webp.sh              # 默认 q=90
#   QUALITY=80 bash scripts/convert-install-images-to-webp.sh   # 自定义质量
#   LOSSLESS=1 bash scripts/convert-install-images-to-webp.sh   # 无损模式
#   KEEP_PNG=1 bash scripts/convert-install-images-to-webp.sh   # 保留 png
#   FORCE=1    bash scripts/convert-install-images-to-webp.sh   # 忽略 .webp-converted 标记
#
# 依赖：cwebp（Debian/Ubuntu：apt install webp；macOS：brew install webp；Arch：pacman -S libwebp）

set -e
cd "$(dirname "$0")/.." || exit 1

DIR="images/install"
QUALITY="${QUALITY:-90}"
[[ -d "$DIR" ]] || { echo "目录不存在：$DIR" >&2; exit 1; }

if [[ -f "$DIR/.webp-converted" && "${FORCE:-0}" != "1" ]]; then
  echo "已经转过 WebP（$DIR/.webp-converted 存在）。重跑：FORCE=1 bash $0"
  exit 0
fi

if ! command -v cwebp >/dev/null 2>&1; then
  cat >&2 <<'EOF'
未找到 cwebp。请按你的系统安装：
  Debian/Ubuntu:  sudo apt install webp
  macOS (Homebrew): brew install webp
  Arch Linux:     sudo pacman -S libwebp
EOF
  exit 1
fi

shopt -s nullglob
pngs=( "$DIR"/*.png )
if (( ${#pngs[@]} == 0 )); then
  echo "$DIR 下没有 PNG。先跑 download-install-images.sh。" >&2
  exit 1
fi

echo "开始转换：${#pngs[@]} 张 PNG -> WebP（quality=$QUALITY, lossless=${LOSSLESS:-0}）"

total_before=0
total_after=0

for png in "${pngs[@]}"; do
  before=$(wc -c < "$png")
  total_before=$((total_before + before))
  webp="${png%.png}.webp"

  if [[ "${LOSSLESS:-0}" == "1" ]]; then
    cwebp -quiet -lossless -z 9 "$png" -o "$webp"
  else
    cwebp -quiet -q "$QUALITY" -m 6 "$png" -o "$webp"
  fi

  if [[ -s "$webp" ]]; then
    after=$(wc -c < "$webp")
    total_after=$((total_after + after))
    pct=$(( (before - after) * 100 / (before == 0 ? 1 : before) ))
    printf "  %-30s %10d -> %10d (%3d%% smaller)\n" "$(basename "$png")" "$before" "$after" "$pct"
    if [[ "${KEEP_PNG:-0}" != "1" ]]; then
      rm "$png"
    fi
  else
    echo "  [fail] $(basename "$png")" >&2
    total_after=$((total_after + before))
  fi
done

saved=$((total_before - total_after))
pct_total=0
(( total_before > 0 )) && pct_total=$(( saved * 100 / total_before ))
echo ""
printf "合计：%d bytes -> %d bytes，节省 %d bytes (%d%%)\n" \
  "$total_before" "$total_after" "$saved" "$pct_total"

echo ""
echo "同步更新 install.html / INSTALL.md 的图片引用..."

# macOS 与 GNU sed 的 -i 语法不同，做兼容处理
sed_inplace() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

for f in install.html INSTALL.md; do
  if [[ -f "$f" ]]; then
    if grep -q "images/install/[A-Za-z0-9_-]*\.png" "$f"; then
      sed_inplace 's|images/install/\([A-Za-z0-9_-]*\)\.png|images/install/\1.webp|g' "$f"
      echo "  updated $f"
    else
      echo "  no change in $f"
    fi
  fi
done

rm -f "$DIR/.optimized"
date '+webp-converted at %Y-%m-%d %H:%M:%S (quality='"$QUALITY"', lossless='"${LOSSLESS:-0}"')' > "$DIR/.webp-converted"

echo ""
echo "下一步："
echo "  git add $DIR install.html INSTALL.md"
echo "  git commit -m 'chore: 把安装教程截图转成 WebP'"
echo "  git push"
