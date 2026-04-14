# 小狼MC服务器 - 官网项目文档

## 服务器地址

| 服务 | 地址 |
|------|------|
| 官网 | mc.udfj.top |
| 3D 地图 (Dynmap) | mc.udfj.top:8100 |

---

## 项目概览

这是小狼MC服务器的官方静态网站，主要功能是为玩家提供**服务器命令指南**。网站采用单页面设计，暗色主题风格，支持移动端响应式布局。

---

## 文件结构

```
xiaolangmc/
├── index.html          # 主页面（单页应用，所有内容都在这里）
├── css/
│   └── style.css       # 全局样式（暗色主题、响应式布局、动画）
├── js/
│   └── main.js         # 交互逻辑（粒子效果、导航、滚动动画）
└── README.md           # 本文档
```

---

## 页面结构

`index.html` 由以下区块组成，从上到下依次排列：

### 1. 顶部导航栏 (`<nav class="navbar">`)
- 左侧：Logo + "小狼MC" 文字
- 右侧：各分区的锚点链接
- 移动端：折叠为汉堡菜单
- 滚动时自动高亮当前所在分区

### 2. 英雄区域 (`<header class="hero">`)
- 大标题："小狼MC服务器 - 玩家命令指南"
- 欢迎描述文字
- **服务器信息区**（`.server-info`）：
  - 🎮 服务器地址 `mc.udfj.top`（点击自动复制到剪贴板）
  - 🗺️ 3D 地图 `mc.udfj.top:8100`（点击在新标签打开）
- "开始探索"按钮（跳转到第一个命令分区）
- 背景粒子动画效果

### 3. 命令分区 (`<main>` 内的各 `<section>`)

| 序号 | 分区 ID | 标题 | 内容 |
|------|---------|------|------|
| 1 | `#home-teleport` | 家与传送 | sethome, home, delhome, spawn, back, warp |
| 2 | `#player-interact` | 玩家互动 | tpa, tpahere, tpaccept, tpdeny, msg, r, list, afk |
| 3 | `#economy` | 经济 | balance/bal, pay |
| 4 | `#land-claim` | 圈地保护 (GriefPrevention) | 圈地步骤 + abandonclaim, trust, untrust, claimslist |
| 5 | `#other` | 其他实用命令 | help, rules, motd |
| 6 | `#quick-ref` | 常见场景速查 | 表格形式的命令速查 |
| 7 | (无 ID) | 注意事项 | 4 条重要提醒 |

### 4. 页脚 (`<footer class="footer">`)
- 简单的一句话页脚

### 5. 全局组件
- **回到顶部按钮**：滚动超过 400px 后显示

---

## 样式说明 (`css/style.css`)

### 主题配色
| 变量 | 用途 | 色值 |
|------|------|------|
| `--bg-primary` | 页面主背景 | `#1a1a2e` (深蓝黑) |
| `--bg-secondary` | 次要背景 | `#16213e` |
| `--bg-card` | 卡片背景 | `#1e2a47` |
| `--accent` | 强调色 | `#4ade80` (绿色) |
| `--warning` | 警告色 | `#fbbf24` (黄色) |
| `--code-bg` | 代码块背景 | `#0d1117` |
| `--code-text` | 代码文字 | `#7ee787` |

### 响应式断点
- **768px 以下**：导航折叠、卡片单列、英雄区域高度缩小
- **480px 以下**：命令示例纵向排列、表格字号缩小

---

## 交互功能 (`js/main.js`)

| 功能 | 函数 | 说明 |
|------|------|------|
| 粒子效果 | `createParticles()` | 英雄区域的浮动粒子，移动端减少数量 |
| 导航菜单 | `setupNavToggle()` | 移动端汉堡菜单开关 |
| 滚动高亮 | `setupScrollSpy()` | 滚动时高亮当前所在分区的导航链接 |
| 回到顶部 | `setupBackToTop()` | 滚动超过 400px 显示按钮 |
| 入场动画 | `setupScrollAnimations()` | 卡片滚动进入视口时淡入上移 |
| 点击复制 | `setupCopyToClipboard()` | 点击带 `data-copy` 属性的元素，将内容复制到剪贴板并显示"已复制"反馈 |

---

## 如何修改

### 添加新命令
在 `index.html` 对应分区的 `<div class="commands-grid">` 内添加：

```html
<div class="command-card">
    <div class="command-name">/命令名</div>
    <div class="command-desc">命令说明。</div>
    <div class="command-examples">
        <div class="example"><code>/命令名 参数</code><span>示例说明</span></div>
    </div>
    <div class="command-note">可选的备注信息</div>
</div>
```

### 添加新分区
1. 在导航栏 `<ul class="nav-links">` 中添加新链接
2. 在 `<main>` 中添加新的 `<section id="新ID" class="section">`
3. 按照现有分区格式填充内容

### 添加新的速查项
在 `#quick-ref` 的 `<tbody>` 中添加新行：

```html
<tr><td>我想...</td><td><code>/命令</code></td></tr>
```

### 修改主题配色
编辑 `css/style.css` 顶部 `:root` 中的 CSS 变量即可全局生效。

### 修改服务器地址
在 `index.html` 英雄区域的 `.server-info` 块中修改：
- 服务器地址：改 `data-copy` 属性和文本内容
- 3D 地图：改 `href` 属性和文本内容

同时也要更新本文档顶部的"服务器地址"表格。

---

## 同步更新原则

**重要：后续任何修改都要保持网站和本文档同步。**

- 修改 `index.html` 的结构/分区 → 更新本文档"页面结构"章节
- 添加/修改 `js/main.js` 的功能 → 更新本文档"交互功能"章节
- 修改配色/样式变量 → 更新本文档"样式说明"章节
- 更换服务器地址 → 同时更新网站和本文档顶部的地址表
