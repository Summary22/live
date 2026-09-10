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

## 🎬 视频墙（静音自动循环播放）

主页含 **8 条精选短视频**，进入视口自动播放、循环、默认静音，点击可开启声音。

### 视频清单

| 文件 | 标题 | 分类 | 大小 |
|------|------|------|------|
| `videos/car-highway-sunset.mp4` | 日落公路 | 汽车 | 948K |
| `videos/car-curvy-dawn.mp4` | 晨光弯道 | 汽车 | 555K |
| `videos/car-dashboard.mp4` | 入座瞬间 | 汽车 | 984K |
| `videos/car-closeup.mp4` | 线条特写 | 汽车 | 705K |
| `videos/city-night-aerial.mp4` | 城市夜航 | 本地生活 | 1.5M |
| `videos/city-tokyo-walk.mp4` | 街头漫步 | 本地生活 | 1.4M |
| `videos/city-rainy-night.mp4` | 雨夜霓虹 | 本地生活 | 1.4M |
| `videos/city-aerial-side.mp4` | 城市轮廓 | 本地生活 | 3.1M |

合计约 13MB，全部为 **16:9 横屏、7–43 秒**，适合循环播放。

### ✅ 授权说明

全部素材来自 **[Mixkit](https://mixkit.co/)**，采用 **Mixkit Free License**：

- ✅ 免费用于商业与非商业项目
- ✅ **无需署名**
- ❌ 不可把素材本身当作素材库二次分发

### ⚠️ 自动播放的技术限制（必读）

**浏览器禁止带声音的视频自动播放** —— 这是所有现代浏览器的硬性规则，无法绕过。
所以视频默认 `muted`（静音）。页面已做这些处理：

| 机制 | 作用 |
|------|------|
| `muted + loop + playsinline` | 满足自动播放条件，iOS 上也不会强制全屏 |
| **懒加载播放** | 滚动到视口才加载并播放，离开视口立即暂停 —— 省流量、省电 |
| 切换标签页暂停 | `visibilitychange` 时全部暂停，不占用资源 |
| 点击开声音 | 点任意视频开启声音，**同时只允许一个视频有声**，避免嘈杂 |
| 自动播放被拦截兜底 | `play().catch()` 静默处理，不会报错 |

> 💡 如果你希望**完全不要声音功能**，把 `index.html` 里 8 个 `title="点击开启 / 关闭声音"` 对应的点击逻辑删掉即可。

### 换成你自己的视频

1. 把你的视频（建议 mp4 / H.264 编码、静音、5~30 秒、16:9）放进 `videos/` 目录
2. 在 `index.html` 里搜索 `data-src="./videos/`，把路径换成你的文件名
3. 同时改一下 `<b>标题</b>` 和 `<small>分类</small>`

```html
<!-- 改之前 -->
<video muted loop playsinline preload="none" data-src="./videos/car-dashboard.mp4"></video>
<span class="vc-label"><b>入座瞬间</b><small>Automotive</small></span>

<!-- 改之后 -->
<video muted loop playsinline preload="none" data-src="./videos/我的直播切片.mp4"></video>
<span class="vc-label"><b>上周探店实拍</b><small>Local Life</small></span>
```

> 📌 用你自己的直播切片是最合适的选择 —— 既有版权保障，又真正展示你的内容。
> 注意保持文件名不含空格与中文标点更稳妥（中文文件名可以，但建议用短横线英文名）。

---

## 🆕 内容模块（Hero 视频 / 数据条 / 故事 / 商务合作）

### 🎥 Hero 视频背景

首屏是一段静音循环的背景视频，已用 ffmpeg 深度压缩：

| 文件 | 规格 | 大小 |
|------|------|------|
| `videos/hero-bg.mp4` | 1280×720，无音轨，H.264 | 844 KB |
| `videos/hero-bg-mobile.mp4` | 960×540，小屏自动切换 | 410 KB |
| `videos/hero-poster.jpg` | 视频加载前显示的首帧 | 56 KB |

原始 720p 素材 **4.8MB → 压缩后 844KB（省 82%）**。压缩命令留档：

```bash
# 桌面版
ffmpeg -i 原视频.mp4 -an -c:v libx264 -crf 29 -preset slow \
  -vf "scale=1280:-2" -movflags +faststart -pix_fmt yuv420p videos/hero-bg.mp4

# 移动版
ffmpeg -i 原视频.mp4 -an -c:v libx264 -crf 31 -preset slow \
  -vf "scale=960:-2" -movflags +faststart -pix_fmt yuv420p videos/hero-bg-mobile.mp4

# 海报图（首帧）
ffmpeg -i 原视频.mp4 -vf "select=eq(n\,0)" -frames:v 1 -q:v 4 videos/hero-poster.jpg
```

关键参数：`-an` 去掉音轨、`+faststart` 支持边下边播、`crf 29` 用于背景时肉眼无损。

### 📊 数据条 ⚠️ 上线前必须改

> ⚠️ **这 4 个数字目前是占位值，必须换成你的真实数据** —— 尤其「合作商家」涉及商业诚信。

| 项目 | 占位值 |
|------|--------|
| 直播场次 | `300+` |
| 累计时长 | `800+` 小时 |
| 全网粉丝 | `5` 万 |
| 合作商家 | `30+` |

改法：搜索 `data-count`，**只改数字**：

```html
<span class="stat-num" data-count="300">0</span><span class="stat-suffix">+</span>
```

- `data-count` = 滚动目标值
- `stat-suffix` = 后缀（`+` / `万` / `%`…）
- 数字在进入视口时从 0 滚上去，改了会自动生效

### 🔔 开播提醒

因为你**开播时间不固定**，这里没做倒计时，而是一条引导关注的横幅。文案在 `<h3>` 里，4 个平台链接在 `.notify-links`。

### 📖 个人故事（About）

我按你的定位起草了一版，**刻意没有编造任何具体经历**（学历、工作、入行年份等），只表达方向和标准。

想加真实经历就在 `.about-body` 里加 `<p>` 段落；三条原则在 `.about-rules`。

### 🤝 商务合作

4 类形式：探店体验 / 新车试驾 / 专场直播 / 短视频内容。按你的选择**不公开报价**，只留邮箱入口。

「合作原则」三条按行业惯例写的，可自行增删：

```html
<ul>
  <li>产品需先体验，确认认可后才接</li>
  <li>合作内容一律明确标注为合作</li>
  <li>不接三无产品、虚假宣传与数据造假</li>
</ul>
```

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
