# UnAmico0777 · 个人主页

> 做好每一分钟直播 —— 本地生活 · 汽车

一个**纯 HTML 单文件**的科技风个人主页。零依赖、零构建，改完直接部署。

---

## ⚠️ 重要：不要覆盖你的博客！

你的博客已经在 **`Summary22.github.io`** 这个仓库里（GitHub 一个账号只能有一个根域名站点）。

所以本主页**必须部署到另一个仓库**，最终地址是：

```
https://summary22.github.io/live/
```

两条线完全独立，互相不影响：

| 站点 | 仓库 | 地址 |
|------|------|------|
| 你的博客 | `Summary22.github.io` | `https://summary22.github.io` |
| 本主页 | `live`（新建） | `https://summary22.github.io/live/` |

> ❌ **绝对不要**把本项目 push 到 `Summary22.github.io` 仓库，那会覆盖你的博客。

---

## 🚀 本地预览

双击 `index.html` 即可。或用本地服务器：

```bash
cd ~/personal-site
python3 -m http.server 8000
# 打开 http://localhost:8000
```

---

## ✨ 已实现的科技感效果

| 效果 | 说明 |
|------|------|
| 🌌 **粒子星网背景** | Canvas 绘制，节点自动连线，鼠标靠近时向光标聚拢发光 |
| 📡 **扫描光束** | 每 9 秒自上而下扫过全屏 |
| 🔲 **透视网格** | 中心聚焦、边缘消散的科技网格底纹 |
| 💫 **霓虹光晕头像** | 字母 U + 旋转锥形光弧 + 脉冲波纹 + 双层发光 |
| ⌨️ **打字机标语** | "做好每一分钟直播" 等 4 句文案循环打印 |
| 🌈 **渐变流光标题** | 名字颜色缓慢流动变幻 |
| 🃏 **流光描边卡片** | 悬停时边框有环绕流动的光 |
| 🎯 **3D 倾斜卡片** | 鼠标在卡片上移动时轻微立体翻转 |
| 🖱️ **鼠标跟随光晕** | 柔光跟随光标缓动 |
| 📺 **ON AIR 呼吸灯** | 顶部实时状态 + 秒级时钟 |
| 📜 **滚动入场动画** | 内容块依次浮现 |
| 🌗 **深浅主题** | 默认深色，可切换并记忆选择 |

全部效果都遵循系统的「减少动效」设置，并适配手机 / 平板 / 桌面。

---

## ✏️ 需要你补充的信息

### 1️⃣ 直播间链接（最重要）

打开 `index.html`，搜索 `href="#"`，共 **4 处**（抖音 / 快手 / 微信视频号 / 百度），
把它们换成你的真实主页或直播间地址，例如：

```html
<!-- 改之前 -->
<a class="link-card is-live reveal" href="#" target="_blank" rel="noopener">

<!-- 改之后 -->
<a class="link-card is-live reveal" href="https://www.douyin.com/user/你的ID" target="_blank" rel="noopener">
```

> 💡 首屏那个「进入直播间」按钮目前指向页面内的 `#links` 锚点。
> 如果你想让它直达主平台直播间，把它的 `href="#links"` 换成你的直播地址即可。

### 2️⃣ 可选：其他内容微调

| 想改什么 | 在哪改 |
|----------|--------|
| 打字机循环的 4 句文案 | `<script>` 第 2 段，`var lines = [...]` |
| 头像字母 | `<div class="avatar">U</div>` |
| 个人介绍 | `<p class="hero-sub">...</p>` |
| 直播方向卡片文案 | `.topics` 区域两张 `article` |
| 三条信条 | `.creed` 区域 |
| **整体配色** | `<style>` 顶部 `:root { --cyan / --violet / --magenta }` |
| 粒子密度 | 第 7 段脚本 `Math.floor(W * H / 15500)`（数字调大＝粒子变少） |

---

## 🌐 部署到 GitHub Pages

### 步骤 1：新建仓库

GitHub 右上角 `+` → **New repository**

- **仓库名**：`live`
- 可见性：**Public**
- ❌ 不要勾选 "Add a README file"
- 点 **Create repository**

### 步骤 2：推送

```bash
cd ~/personal-site

git remote add origin https://github.com/Summary22/live.git
git branch -M main
git push -u origin main
```

认证方式二选一：
- **Personal Access Token**（推荐）：[github.com/settings/tokens](https://github.com/settings/tokens) 生成后当密码用
- **SSH**：`ssh-keygen -t ed25519 -C "very_will@163.com"`，把 `~/.ssh/id_ed25519.pub` 贴到 GitHub → Settings → SSH keys

### 步骤 3：开启 Pages

仓库 → **Settings** → **Pages**：

- Source：**Deploy from a branch**
- Branch：**main**，目录 **/ (root)**
- 点 **Save**

等 1~2 分钟，访问 👉 **`https://summary22.github.io/live/`**

---

## 🔄 以后怎么更新

```bash
cd ~/personal-site
# 修改 index.html ...
git add .
git commit -m "更新主页"
git push
```

约 1 分钟后自动生效。

---

## 💡 关于免费域名（现状）

| 方案 | 域名 | 状态 |
|------|------|------|
| GitHub Pages 子路径 | `summary22.github.io/live/` | ✅ 本次采用，永久免费 + HTTPS |
| Cloudflare Pages | `项目名.pages.dev` | ✅ 国内访问通常更快 |
| Vercel / Netlify | `项目名.vercel.app` | ✅ 部署体验最好 |
| ~~Freenom (.tk/.cf/.gq)~~ | —— | ❌ 2023 年 7 月已全面失效 |

**想要更好看的域名**：买个 `.com`（约 60–80 元/年），在 Pages → Custom domain 里填上即可，
代码一行都不用改。也可以考虑 `unamico0777.com` 这类与你名字一致的域名。
