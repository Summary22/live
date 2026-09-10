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
  ok "$GH_USER.github.io 直接返回 200（未重定向）"
elif echo "$LOC" | grep -q "$DOMAIN"; then
  warn "$GH_USER.github.io 仍 301 重定向到 $DOMAIN"
  info "这是博客仓库设置了 Custom domain 所致"
  info "DNS 配好后会自动恢复正常；若不想用该域名，去 Pages 设置里清空 Custom domain"
else
  info "HTTP $CODE ${LOC:+→ $LOC}"
fi

# ---------- 5. HTTPS 证书 ----------
section "5. HTTPS 证书"
CERT=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null)
if [ -n "$CERT" ]; then
  echo "$CERT" | sed 's/^/     /'
  echo "$CERT" | grep -qi "github" && ok "证书由 GitHub 签发" || warn "证书签发方不是 GitHub（可能未启用 Enforce HTTPS）"
else
  warn "无法获取证书（DNS 未生效或 HTTPS 未启用）"
fi

# ---------- 6. 本地文件 ----------
section "6. 本地仓库状态"
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
