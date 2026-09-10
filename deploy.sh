#!/usr/bin/env bash
# ============================================================
#  UnAmico0777 个人主页 · 一键部署到 GitHub Pages
#  用法：bash ~/personal-site/deploy.sh
# ============================================================
set -e
cd "$(dirname "$0")"

GH_USER="Summary22"
REPO="live"
SITE="https://${GH_USER}.github.io/${REPO}/"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║   UnAmico0777 个人主页 · 一键部署              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# ---------- 0. 安全检查：避免误推到博客仓库 ----------
CURRENT_REMOTE="$(git remote get-url origin 2>/dev/null || echo '')"
if [[ "$CURRENT_REMOTE" == *"${GH_USER}.github.io"* ]]; then
  echo "❌ 检测到 origin 指向博客仓库，为避免覆盖博客已中止。"
  echo "   当前 origin: $CURRENT_REMOTE"
  exit 1
fi

# ---------- 1. 检查 gh ----------
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ 未找到 gh（GitHub CLI）。请先安装：brew install gh"
  exit 1
fi

# ---------- 2. 登录 GitHub ----------
if gh auth status >/dev/null 2>&1; then
  echo "✅ 已登录 GitHub：$(gh api user --jq .login 2>/dev/null || echo unknown)"
else
  echo "📝 需要先登录 GitHub，接下来会："
  echo "   1) 询问登录方式 → 选 GitHub.com"
  echo "   2) 选 HTTPS 或 SSH 都可以"
  echo "   3) 选 Login with a web browser"
  echo "   4) 复制屏幕上的一次性代码，浏览器里粘贴授权"
  echo ""
  read -r -p "按回车开始登录..." _
  gh auth login
  echo ""
fi

# ---------- 3. 创建仓库并推送 ----------
echo "▶ 正在创建仓库 ${GH_USER}/${REPO} 并推送代码..."
if gh repo view "${GH_USER}/${REPO}" >/dev/null 2>&1; then
  echo "  仓库已存在，改为直接推送..."
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/${GH_USER}/${REPO}.git"
  git push -u origin main
else
  gh repo create "${REPO}" --public --source=. --remote=origin --push
fi

# ---------- 4. 开启 GitHub Pages ----------
echo ""
echo "▶ 正在开启 GitHub Pages..."
if gh api "repos/${GH_USER}/${REPO}/pages" >/dev/null 2>&1; then
  echo "  Pages 已经是开启状态，跳过。"
else
  gh api -X POST "repos/${GH_USER}/${REPO}/pages" \
    -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
    && echo "  ✅ 已开启" \
    || echo "  ⚠️ 自动开启失败，请手动：仓库 Settings → Pages → Branch 选 main → Save"
fi

# ---------- 5. 完成 ----------
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  🎉 部署完成！                                ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "  你的主页地址："
echo "    ${SITE}"
echo ""
echo "  ⏳ 首次生效需要 1~2 分钟，稍等后刷新即可。"
echo "  📦 你的博客（未受影响）："
echo "    https://${GH_USER}.github.io"
echo ""
echo "  以后更新内容只需："
echo "    cd ~/personal-site && git add -A && git commit -m \"更新\" && git push"
echo ""
