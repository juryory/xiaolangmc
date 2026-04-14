#!/usr/bin/env bash
# 压缩 images/install/ 下的 PNG：按比例缩到最大宽 1200px，再重新编码以减小体积
# 用法（在仓库根目录执行）：
#   bash scripts/optimize-install-images.sh            # 默认最大宽 1200
#   bash scripts/optimize-install-images.sh 960        # 自定义最大宽
#   FORCE=1 bash scripts/optimize-install-images.sh    # 忽略 .optimized 标记重跑
# 依赖（按优先级任选其一）：imagemagick (mogrify) / python3 + Pillow

set -e
cd "$(dirname "$0")/.." || exit 1

DIR="images/install"
MAX_WIDTH="${1:-1200}"

if [[ ! -d "$DIR" ]]; then
  echo "目录不存在：$DIR" >&2
  exit 1
fi

if [[ -f "$DIR/.optimized" && "${FORCE:-0}" != "1" ]]; then
  echo "已经优化过（$DIR/.optimized 存在）。如果要重跑：FORCE=1 bash $0"
  exit 0
fi

shopt -s nullglob
files=( "$DIR"/*.png )
if (( ${#files[@]} == 0 )); then
  echo "$DIR 下没有 PNG，先跑 download-install-images.sh 下载图片。" >&2
  exit 1
fi

echo "开始优化：目标最大宽度 = ${MAX_WIDTH}px，共 ${#files[@]} 张"

# 选后端
BACKEND=""
if command -v mogrify >/dev/null 2>&1; then
  BACKEND="magick"
elif command -v python3 >/dev/null 2>&1 && python3 -c "import PIL" 2>/dev/null; then
  BACKEND="pillow"
else
  echo "未找到可用后端。请安装其中之一：" >&2
  echo "  - ImageMagick：apt install imagemagick / brew install imagemagick" >&2
  echo "  - Pillow：    pip install Pillow" >&2
  exit 1
fi
echo "使用后端：$BACKEND"

total_before=0
total_after=0

for f in "${files[@]}"; do
  before=$(wc -c < "$f")
  total_before=$((total_before + before))

  case "$BACKEND" in
    magick)
      mogrify -resize "${MAX_WIDTH}x>" -strip "$f"
      ;;
    pillow)
      python3 - "$f" "$MAX_WIDTH" <<'PY'
import sys
from PIL import Image
path, max_w = sys.argv[1], int(sys.argv[2])
im = Image.open(path)
w, h = im.size
if w > max_w:
    new_h = int(round(h * max_w / w))
    im = im.resize((max_w, new_h), Image.LANCZOS)
im.save(path, format='PNG', optimize=True)
PY
      ;;
  esac

  after=$(wc -c < "$f")
  total_after=$((total_after + after))
  if (( before > 0 )); then
    pct=$(( (before - after) * 100 / before ))
  else
    pct=0
  fi
  printf "  %-30s %10d -> %10d (%3d%%)\n" "$(basename "$f")" "$before" "$after" "$pct"
done

saved=$((total_before - total_after))
if (( total_before > 0 )); then
  saved_pct=$(( saved * 100 / total_before ))
else
  saved_pct=0
fi
echo ""
printf "合计：%d bytes -> %d bytes，节省 %d bytes (%d%%)\n" \
  "$total_before" "$total_after" "$saved" "$saved_pct"

date '+optimized at %Y-%m-%d %H:%M:%S by optimize-install-images.sh (max-width='"$MAX_WIDTH"')' \
  > "$DIR/.optimized"

echo ""
echo "下一步："
echo "  git add $DIR"
echo "  git commit -m 'chore: 压缩安装教程截图'"
echo "  git push"
