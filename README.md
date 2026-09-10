# 个人主页（Personal Site）

一个**纯 HTML 单文件**个人主页 —— 零依赖、零构建，改完直接部署。

## 🚀 本地预览

直接双击 `index.html` 用浏览器打开即可。

想用本地服务器预览（更接近线上环境）：

```bash
cd ~/personal-site
python3 -m http.server 8000
# 然后打开 http://localhost:8000
```

## ✏️ 需要修改的地方（搜索 `TODO` 就能全部找到）

| 位置 | 改什么 |
|------|--------|
| `TODO 1` | `<title>` 和 `<meta>` 里的名字、介绍 |
| `TODO 2` | 头像里的**首字**（默认是「你」），或按 CSS 注释换成真实照片 |
| `TODO 3` | 你的名字（`<h1>`） |
| `TODO 4` | 一句话介绍（职业 / slogan） |
| `TODO 5` | 自我介绍段落（建议 2~4 句） |
| `TODO 6` | 技能标签，想加就复制一行 `<span class="chip">技能</span>` |
| `TODO 7` | 社交链接的 `href`（GitHub / 邮箱 / 微信 / 博客） |
| 末尾 | 页脚署名 |

> 💡 **换配色**：只改文件顶部 `:root { ... }` 里的 `--accent-1/2/3` 三个变量，
> 整个网站的渐变、按钮、标签颜色会一起变。

### 换成真人头像

1. 把照片命名为 `avatar.jpg` 放进本目录
2. 在 `<style>` 里找到 `/* 想用真实照片？ */` 那段注释，加上：
   ```css
   background-image: url('./avatar.jpg');
   background-size: cover;
   background-position: center;
   ```
3. 删掉 HTML 里 `<div class="avatar">你</div>` 中间的那个字

### 已有功能

- ✅ 响应式（手机 / 平板 / 桌面自适应）
- ✅ 深色 / 浅色主题切换（自动跟随系统 + 记忆用户选择）
- ✅ 社交分享预览卡片（微信/微博转发时显示标题和简介）
- ✅ 零外部依赖（不加载任何 CDN 或字体，国内秒开）
- ✅ 内置无障碍与「减少动效」支持

---

## 🌐 部署到 GitHub Pages（免费，附赠免费域名）

### 步骤 1：在 GitHub 创建仓库

登录 GitHub → 右上角 `+` → **New repository**

- **仓库名填**：`你的用户名.github.io` ⚠️ 必须完全一致，这是免费域名的来源
- 可见性选 **Public**（私有仓库的 Pages 需要付费）
- **不要**勾选 "Add a README file"（本地已经有内容了）
- 点击 Create repository

### 步骤 2：推送代码

把下面的 `你的用户名` 全部替换成你的 GitHub 用户名，然后逐条执行：

```bash
cd ~/personal-site

# 关联远程仓库
git remote add origin https://github.com/你的用户名/你的用户名.github.io.git

# 推送
git branch -M main
git push -u origin main
```

推送时会要求认证：
- **推荐**：用 [Personal Access Token](https://github.com/settings/tokens) 当密码（GitHub 已不支持账号密码）
- 或者先配置 SSH key：`ssh-keygen -t ed25519 -C "你的邮箱"`，再把 `~/.ssh/id_ed25519.pub` 内容贴到 GitHub → Settings → SSH keys

### 步骤 3：开启 Pages

仓库 → **Settings** → 左侧 **Pages** →

- Source 选 **Deploy from a branch**
- Branch 选 **main**，目录选 **/ (root)**
- 点 **Save**

等 1~2 分钟，访问 👉 **`https://你的用户名.github.io`** 就能看到你的主页了！

---

## 💡 关于免费域名

| 方案 | 域名样子 | 说明 |
|------|----------|------|
| **GitHub Pages** | `你的用户名.github.io` | ✅ 最省事，永久免费，自带 HTTPS |
| Cloudflare Pages | `项目名.pages.dev` | 国内访问速度通常更好 |
| Vercel / Netlify | `项目名.vercel.app` | 部署体验最好，自动构建 |
| eu.org | `你的名字.eu.org` | 免费但审核要等几周 |
| ~~Freenom (.tk/.cf/.gq)~~ | —— | ❌ 2023 年 7 月已全面失效，别再折腾 |

**建议**：先用 `username.github.io`，等真需要了再买个 `.com`（约 60–80 元/年）绑上去 ——
在 Pages 设置里填 Custom domain 就能平滑升级，不用改任何代码。

### 绑定自己的域名（以后想升级时）

1. 域名商后台添加 CNAME 记录：`www` → `你的用户名.github.io`
2. GitHub 仓库 → Settings → Pages → Custom domain 填入你的域名
3. 勾选 **Enforce HTTPS**（等证书签发，通常几分钟到几小时）

---

## 🔄 以后怎么更新内容

```bash
cd ~/personal-site
# 编辑 index.html ...
git add .
git commit -m "更新个人主页"
git push
```

推送后 1 分钟左右自动生效，刷新页面即可看到。
