#!/usr/bin/env bash
# ============================================================
#  视频转 GIF / 动图 WebP
#  用法：bash to-gif.sh <视频文件> [输出名] [宽度] [时长秒] [帧率] [起始秒]
#  示例：bash to-gif.sh ~/Desktop/直播切片.mp4 探店 480 4 12 2
#        → 从第 2 秒开始截 4 秒，480px 宽，12fps
# ============================================================
set -e

INPUT="$1"
if [ -z "$INPUT" ]; then
  cat << 'USAGE'
╔══════════════════════════════════════════════════════════╗
║  视频转 GIF / 动图 WebP                                  ║
╚══════════════════════════════════════════════════════════╝

用法:
  bash to-gif.sh <视频文件> [输出名] [宽度] [时长秒] [帧率] [起始秒]

参数说明（都可省略，用默认值）:
  输出名    默认取视频文件名
  宽度      默认 480    （微信表情建议 240，网页配图 640）
  时长秒    默认 3      （GIF 每多 1 秒体积翻倍，务必短！）
  帧率      默认 14     （10~15 足够，再高只增体积）
  起始秒    默认 0      （从视频第几秒开始截）

示例:
  bash to-gif.sh 直播切片.mp4                    # 全默认
  bash to-gif.sh 探店.mp4 tan-dian 320 5 12 3    # 320px/5秒/12fps/从第3秒
USAGE
  exit 1
fi

[ -f "$INPUT" ] || { echo "❌ 文件不存在: $INPUT"; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo "❌ 需要 ffmpeg，请先 brew install ffmpeg"; exit 1; }

NAME="${2:-$(basename "${INPUT%.*}")}"
WIDTH="${3:-480}"
DURATION="${4:-3}"
FPS="${5:-14}"
START="${6:-0}"

OUTDIR="$(cd "$(dirname "$0")" && pwd)/gif"
mkdir -p "$OUTDIR"
GIF="$OUTDIR/$NAME.gif"
WEBP="$OUTDIR/$NAME.webp"
PALETTE="/tmp/_toGif_palette_$$.png"
FRAMEDIR="/tmp/_toGif_frames_$$"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  转换开始                                        ║"
echo "╚══════════════════════════════════════════════════╝"
echo "  输入:   $INPUT"
echo "  输出名: $NAME"
echo "  参数:   ${WIDTH}px / ${DURATION}s / ${FPS}fps / 从第 ${START}s 开始"

DUR_TOTAL=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$INPUT" 2>/dev/null | cut -d. -f1)
echo "  源视频: ${DUR_TOTAL}s"

if [ "$START" -ge "$DUR_TOTAL" ] 2>/dev/null; then
  echo "  ⚠️ 起始秒(${START})超过视频长度(${DUR_TOTAL})，已改为从 0 开始"
  START=0
fi

# ── 1. 生成 GIF（两遍调色板法，画质远好于直接转）──
echo ""
echo "▶ [1/2] 生成 GIF..."
mkdir -p "$FRAMEDIR"

ffmpeg -y -loglevel error -ss "$START" -t "$DURATION" -i "$INPUT" \
  -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos,palettegen=stats_mode=diff" \
  "$PALETTE"

ffmpeg -y -loglevel error -ss "$START" -t "$DURATION" -i "$INPUT" -i "$PALETTE" \
  -lavfi "fps=$FPS,scale=$WIDTH:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" \
  "$GIF"

echo "  ✅ $(basename "$GIF")  →  $(du -h "$GIF" | cut -f1)"

# ── 2. 生成动图 WebP（体积通常只有 GIF 的 1/5）──
echo ""
echo "▶ [2/2] 生成动图 WebP..."
if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q libwebp_anim; then
  # ffmpeg 直接支持
  ffmpeg -y -loglevel error -ss "$START" -t "$DURATION" -i "$INPUT" \
    -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos" \
    -c:v libwebp_anim -lossless 0 -q:v 75 -loop 0 -an "$WEBP"
  echo "  ✅ $(basename "$WEBP")  →  $(du -h "$WEBP" | cut -f1)"
elif python3 -c "import PIL" 2>/dev/null; then
  # 用 ffmpeg 导帧 + Pillow 合成
  ffmpeg -y -loglevel error -ss "$START" -t "$DURATION" -i "$INPUT" \
    -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos" "$FRAMEDIR/f%04d.png"
  python3 - "$FRAMEDIR" "$WEBP" "$FPS" << 'PYEOF'
import sys, glob, os
from PIL import Image
framedir, out, fps = sys.argv[1], sys.argv[2], int(sys.argv[3])
files = sorted(glob.glob(os.path.join(framedir, 'f*.png')))
if not files:
    print('  ❌ 没有导出的帧'); sys.exit(1)
frames = [Image.open(f).convert('RGBA') for f in files]
frames[0].save(out, save_all=True, append_images=frames[1:],
               duration=int(1000/fps), loop=0, quality=75, method=6)
print(f'  ✅ {os.path.basename(out)}  →  {os.path.getsize(out)/1024:.0f} KB  ({len(frames)} 帧)')
PYEOF
else
  echo "  ⚠️ 跳过（ffmpeg 无 webp 编码器，且未安装 Pillow）"
fi

rm -rf "$FRAMEDIR" "$PALETTE"

# ── 3. 报告 ──
echo ""
echo "──────────────────────────────────────────────────"
echo "  📊 体积对比"
echo "──────────────────────────────────────────────────"
SRC_SIZE=$(stat -f%z "$INPUT" 2>/dev/null || stat -c%s "$INPUT" 2>/dev/null)
printf "  %-24s %10s\n" "源视频" "$(du -h "$INPUT" | cut -f1)"
for f in "$GIF" "$WEBP"; do
  [ -f "$f" ] || continue
  printf "  %-24s %10s\n" "$(basename "$f")" "$(du -h "$f" | cut -f1)"
done
echo ""
echo "  📁 输出目录: $OUTDIR"
echo ""
echo "  💡 体积太大？依次尝试："
echo "     1) 缩短时长（最有效，时长翻倍体积翻倍）"
echo "     2) 降低宽度（480 → 320）"
echo "     3) 降低帧率（14 → 10）"
echo ""
