#!/usr/bin/env bash
# ============================================================
#  域名 & GitHub Pages 配置验证工具
#  用法：bash ~/personal-site/check-domain.sh
# ============================================================

DOMAIN="noblestaspiration.net"
GH_USER="Summary22"
LIVE_PATH="live"
EXPECT_IPS="185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153"

G='\033[32m'; R='\033[31m'; Y='\033[33m'; B='\033[36m'; D='\033[2m'; N='\033[0m'
ok()   { printf "  ${G}✅${N} %s\n" "$1"; }
bad()  { printf "  ${R}❌${N} %s\n" "$1"; }
warn() { printf "  ${Y}⚠️ ${N} %s\n" "$1"; }
info() { printf "  ${D}%s${N}\n" "$1"; }
section() { printf "\n${B}═══ %s ═══${N}\n" "$1"; }

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   域名 & GitHub Pages 配置验证                   ║"
echo "╚══════════════════════════════════════════════════╝"

# ---------- 1. 域名注册状态 ----------
section "1. 域名注册状态 (.net 注册局权威数据)"
if command -v whois >/dev/null 2>&1; then
  WHOIS_OUT=$(whois -h whois.verisign-grs.com "domain $DOMAIN" 2>/dev/null)
  if [ -z "$WHOIS_OUT" ]; then
    warn "whois 查询失败或无响应（可能网络受限），无法判断"
  elif echo "$WHOIS_OUT" | grep -q "No match"; then
    bad "$DOMAIN 尚未注册 —— 需要先去注册商购买"
  else
    ok "$DOMAIN 已注册"
    echo "$WHOIS_OUT" \
      | grep -iE "Registrar:|Domain Status:|Creation Date:|Registry Expiry" \
      | head -6 | sed 's/^ */     /'
  fi
else
  warn "未安装 whois，跳过"
fi

# ---------- 2. DNS 解析 ----------
section "2. DNS 解析 (A 记录)"
RESOLVED=$(dig +short "$DOMAIN" A 2>/dev/null | sort | tr '\n' ' ' | sed 's/ $//')
if [ -z "$RESOLVED" ]; then
  bad "无 A 记录 —— DNS 尚未配置或还在生效中"
  info "应指向: $EXPECT_IPS"
else
  info "当前解析: $RESOLVED"
  MISSING=""
  for ip in $EXPECT_IPS; do
    echo "$RESOLVED" | grep -q "$ip" || MISSING="$MISSING $ip"
  done
  if [ -z "$MISSING" ]; then
    ok "4 个 GitHub Pages IP 全部配置正确"
  else
    warn "缺少以下 IP:$MISSING"
  fi
fi

echo ""
CNAME=$(dig +short "www.$DOMAIN" 2>/dev/null | tr '\n' ' ' | sed 's/ $//')
if [ -z "$CNAME" ]; then
  warn "www.$DOMAIN 无解析记录"
else
  info "www.$DOMAIN → $CNAME"
  echo "$CNAME" | grep -q "github.io" && ok "www CNAME 配置正确" || warn "www 应 CNAME 到 $GH_USER.github.io"
fi

# ---------- 3. 网站访问 ----------
section "3. 网站访问测试"
for url in "https://$DOMAIN/" "https://$DOMAIN/$LIVE_PATH/"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$url" 2>/dev/null)
  case "$code" in
    200) ok "$url → HTTP 200" ;;
    000) bad "$url → 无法连接" ;;
    301|302) warn "$url → HTTP $code 重定向到: $(curl -sI --max-time 10 "$url" 2>/dev/null | grep -i '^location:' | tr -d '\r' | cut -d' ' -f2-)" ;;
    *) warn "$url → HTTP $code" ;;
  esac
done

# ---------- 4. GitHub Pages 重定向状态 ----------
section "4. GitHub Pages 重定向状态"
LOC=$(curl -sI --max-time 15 "https://$GH_USER.github.io/" 2>/dev/null | grep -i '^location:' | tr -d '\r' | cut -d' ' -f2-)
CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "https://$GH_USER.github.io/" 2>/dev/null)
if [ "$CODE" = "200" ]; then
  ok "$GH_USER.github.io 直接返回 200（未绑定自定义域名）"
elif echo "$LOC" | grep -q "$DOMAIN"; then
  ok "$GH_USER.github.io → 301 → $DOMAIN"
  info "自定义域名已绑定。这是 GitHub Pages 的预期行为，不是故障"
  info "跳转目标有效，两个地址都能正常打开"
else
  info "HTTP $CODE ${LOC:+→ $LOC}"
fi

# ---------- 5. HTTPS 证书 + Enforce HTTPS ----------
section "5. HTTPS 证书"
CERT=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null)
if [ -n "$CERT" ]; then
  echo "$CERT" | sed 's/^/     /'
  if echo "$CERT" | grep -q "$DOMAIN"; then
    ok "证书已签发且匹配域名"
    info "GitHub Pages 统一使用 Let's Encrypt 免费证书，签发方是 Let's Encrypt 完全正常"
  else
    warn "证书域名与 $DOMAIN 不匹配"
  fi
else
  warn "无法获取证书（DNS 未生效或 HTTPS 未启用）"
fi

echo ""
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 12 "http://$DOMAIN/" 2>/dev/null)
if [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
  ok "Enforce HTTPS 已启用（http 自动跳转 https）"
elif [ "$HTTP_CODE" = "200" ]; then
  warn "Enforce HTTPS 未启用 —— http://$DOMAIN 仍可直接访问，存在安全风险"
  info "去这里勾选 Enforce HTTPS："
  info "https://github.com/$GH_USER/$GH_USER.github.io/settings/pages"
else
  info "http 访问返回 HTTP $HTTP_CODE"
fi

# ---------- 6. 站点内容验证 ----------
section "6. 站点内容验证"
BLOG_TITLE=$(curl -s --max-time 15 "https://$DOMAIN/" 2>/dev/null | grep -oE "<title>[^<]*</title>" | head -1 | sed 's/<[^>]*>//g')
[ -n "$BLOG_TITLE" ] && ok "根域名（博客）标题: $BLOG_TITLE" || warn "根域名无标题或无法访问"

LIVE_HTML=$(curl -s --max-time 15 "https://$DOMAIN/$LIVE_PATH/" 2>/dev/null)
LIVE_TITLE=$(echo "$LIVE_HTML" | grep -oE "<title>[^<]*</title>" | head -1 | sed 's/<[^>]*>//g')
[ -n "$LIVE_TITLE" ] && ok "子路径（主页）标题: $LIVE_TITLE" || warn "主页无标题或无法访问"
for k in "UnAmico0777" "pelican-svg" "video-card"; do
  echo "$LIVE_HTML" | grep -q "$k" && info "  ✓ 含 $k" || warn "  缺少 $k"
done

# ---------- 7. 本地仓库状态 ----------
section "7. 本地仓库状态"
cd "$(dirname "$0")" 2>/dev/null || exit 0
if git rev-parse --git-dir >/dev/null 2>&1; then
  DIRTY=$(git status --porcelain | wc -l | tr -d ' ')
  [ "$DIRTY" = "0" ] && ok "工作区干净，全部已提交" || warn "有 $DIRTY 个文件未提交"
  info "当前分支: $(git branch --show-current)"
  info "远程仓库: $(git remote get-url origin 2>/dev/null || echo '未配置')"
  info "提交数: $(git rev-list --count HEAD 2>/dev/null)"
else
  warn "不是 git 仓库"
fi

echo ""
echo "──────────────────────────────────────────────────"
echo "  提示：DNS 修改后通常 10 分钟~2 小时生效。"
echo "  证书由 GitHub 自动签发，一般几分钟，最长 24 小时。"
echo "──────────────────────────────────────────────────"
echo ""
