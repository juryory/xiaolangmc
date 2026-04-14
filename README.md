# 小狼MC服务器 - 官网项目文档

## 服务器地址

| 服务 | 地址 |
|------|------|
| 官网首页 | mc.udfj.top |
| BlueMap 3D 地图 | mc.udfj.top:8100 |

---

## 项目概览

小狼MC服务器的官方静态网站，由三个独立页面组成，统一使用 `css/style.css` 与 `js/main.js`。暗色主题、响应式布局、移动端友好。

---

## 文件结构

```
xiaolangmc/
├── index.html        # 首页：英雄区 + 服务特色 + 入口卡 + 新人必读
├── commands.html     # 玩家命令大全（家、传送、互动、经济、圈地、多世界、地皮、其他、速查、注意）
├── admin.html        # 管理员手册（图形化版本）
├── ADMIN.md          # 管理员手册（Markdown 版本，与 admin.html 内容同步）
├── css/
│   └── style.css     # 全局样式（被三个 HTML 共用）
├── js/
│   └── main.js       # 全局交互（粒子、导航、滚动高亮、复制等）
└── README.md         # 本文档
```

> 历史变迁：原本所有玩家命令都在 `index.html`，后拆出 `commands.html` 让首页轻量化。管理员手册作为新增内容，单独成页。

---

## 三个页面的职责

### 1. `index.html` — 首页 / 总览

| 区块 | 说明 |
|------|------|
| 顶部导航 | 服务特色 / 玩家手册 / 命令大全 / 3D 地图 / 管理员手册 |
| 英雄区 | 服务器名 + 地址（点击复制） + BlueMap 链接 + 两个 CTA 按钮 |
| `#features` 服务特色 | 12 张卡片，介绍 18 个核心插件提供的能力 |
| `#entries` 从这里开始 | 6 张大卡片，跳转到 commands.html 各分区或外链 |
| 新人必读 | 4 条最重要的注意事项 |
| 页脚 | 玩家命令 / 地图 / 管理员手册 / 复制服务器地址 |

### 2. `commands.html` — 玩家命令大全

| 分区 ID | 标题 | 内容 |
|---------|------|------|
| `#home-teleport` | 家与传送 | sethome / home / delhome / spawn / back / warp |
| `#player-interact` | 玩家互动 | tpa(here)(accept)(deny) / msg / r / list / afk / mail / seen / ignore / hat / me |
| `#economy` | 经济 | balance / pay / baltop |
| `#land-claim` | 圈地保护 (GriefPrevention) | 4 步圈地教程 + trust 系列分级权限 + subdivideclaim |
| `#worlds` | 多世界 (Multiverse) | mv list / mvtp / BlueMap |
| `#plots` | 地皮世界 (PlotSquared) | 4 步领地皮教程 + 12 个 plot 命令 |
| `#other` | 其他实用命令 | help / rules / motd / kit / menu / ping |
| `#quick-ref` | 常见场景速查 | "我想……" 对照表 |
| `#warnings` | 注意事项 | 8 条玩家须知 |

### 3. `admin.html` / `ADMIN.md` — 管理员手册

两份文件**保持内容一致**（一份图形化，一份纯文本，按需查阅）。包含：

1. 插件清单与版本（18 个）
2. LuckPerms 权限组结构、节点示例、临时权限
3. EssentialsX 管理命令（封禁、踢人、禁言、监狱、隐身、给物、修复、经济）
4. Multiverse 多世界（创建、导入、修改属性、重新生成）
5. 保护类（GP / WorldGuard / PlotSquared）
6. FastAsyncWorldEdit（//wand //set //replace //schem 等）
7. CoreProtect（inspect / lookup / rollback / restore / purge）
8. BlueMap（reload / fullrender / purge / 反代建议）
9. Chunky 区块预生成
10. DeluxeMenus 调试
11. spark 性能监控
12. PlugManX 插件热重载
13. 日常运维节奏（每日 / 每周 / 每月 / 备份策略）
14. 应急处置（熊孩子破坏 / 卡顿 / 崩溃 / 数据回档）

---

## 服务器装载的插件（18 个）

| 插件 | 用途 |
|------|------|
| EssentialsX + Chat + Spawn | 核心命令、聊天、出生点 |
| Vault | 经济/权限抽象层 |
| LuckPerms | 权限组管理 |
| PlaceholderAPI | 变量解析 |
| Multiverse-Core | 多世界管理 |
| Chunky | 区块预生成 |
| BlueMap | 3D 网页地图 |
| GriefPrevention | 玩家自助圈地 |
| WorldGuard | 管理员区域规则 |
| PlotSquared | 地皮世界 |
| CoreProtect (CE) | 行为日志、回滚 |
| FastAsyncWorldEdit | 异步创世神 |
| WESV | WorldEdit 选区可视化 |
| DeluxeMenus | GUI 菜单 |
| spark | 性能分析 |
| PlugManX | 插件热重载 |

详细版本见 [`ADMIN.md`](./ADMIN.md#1-插件清单与版本)。

---

## 样式说明 (`css/style.css`)

### 主题配色

| 变量 | 用途 | 色值 |
|------|------|------|
| `--bg-primary` | 页面主背景 | `#1a1a2e` |
| `--bg-secondary` | 次要背景 | `#16213e` |
| `--bg-card` | 卡片背景 | `#1e2a47` |
| `--accent` | 强调色（绿） | `#4ade80` |
| `--warning` | 警告色（橙），管理员页面主色 | `#fbbf24` |
| `--code-bg` | 代码块背景 | `#0d1117` |
| `--code-text` | 代码文字 | `#7ee787` |

### 主要组件类

| 类名 | 用途 |
|------|------|
| `.hero` / `.page-header` | 英雄区 / 子页面顶部 |
| `.features-grid` + `.feature-card` | 服务特色网格 |
| `.entry-card` | 可点击的入口卡片（跳转到子页面） |
| `.commands-grid` + `.command-card` | 玩家命令卡 |
| `.admin-command-card` | 管理员命令卡（左边框为橙色） |
| `.admin-toc` | 管理员手册侧边目录（双列） |
| `.admin-warning` | 管理员页面顶部的警示框 |
| `.plugin-category.{core,world,protect,perf,util}` | 插件分类标签 |
| `.warnings-grid` + `.warning-card` | 注意事项 |
| `.quick-ref-table` | 速查表 |
| `.info-tip` | 浅绿色提示框 |

### 响应式断点

- **768px 以下**：导航折叠为汉堡菜单、卡片单列、admin-toc 单列。
- **480px 以下**：命令示例纵向排列、表格字号缩小。

---

## 交互功能 (`js/main.js`)

被三个页面共用，所有功能在 DOMContentLoaded 时一次性初始化。

| 功能 | 函数 | 说明 |
|------|------|------|
| 粒子效果 | `createParticles()` | `#particles` 容器内的浮动粒子，仅 hero 区域有 |
| 导航菜单 | `setupNavToggle()` | 移动端汉堡菜单 |
| 滚动高亮 | `setupScrollSpy()` | 滚动时高亮当前所在分区的导航链接 |
| 回到顶部 | `setupBackToTop()` | 滚动超过 400px 显示按钮 |
| 入场动画 | `setupScrollAnimations()` | `.command-card / .step / .warning-card` 入视淡入 |
| 点击复制 | `setupCopyToClipboard()` | 点击带 `data-copy` 属性的元素，复制到剪贴板 |

---

## 如何修改

### 添加新玩家命令

在 `commands.html` 对应分区的 `<div class="commands-grid">` 内添加：

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

### 添加新管理员命令

在 `admin.html` 对应分区添加：

```html
<div class="admin-command-card">
    <div class="command-name">/命令</div>
    <div class="command-desc">说明。</div>
    <ul>
        <li><code>/命令 例子</code></li>
    </ul>
</div>
```

**同时**在 `ADMIN.md` 的对应分区追加一行表格，保持两份内容一致。

### 添加新分区

1. 在三个 HTML 顶部的 `<ul class="nav-links">` 中添加新链接（如果需要全站可见）。
2. 在对应页面 `<main>` 中添加新的 `<section id="新ID" class="section">`。
3. 按照现有分区格式填充。
4. 如果是管理员手册新分区，**`admin.html` 的 `.admin-toc` 与 `ADMIN.md` 的目录都要补一项**。

### 添加新的速查项

在 `commands.html` 的 `#quick-ref` 的 `<tbody>` 中添加新行：

```html
<tr><td>我想...</td><td><code>/命令</code></td></tr>
```

### 修改主题配色

编辑 `css/style.css` 顶部 `:root` 中的 CSS 变量即可全局生效。三个页面会同步更新。

### 修改服务器地址

需要同步修改的位置：
- `index.html` 英雄区的 `data-copy` 与 BlueMap `href`
- `commands.html` BlueMap 链接、页脚链接
- `admin.html` BlueMap 配置示例
- `README.md` 顶部的"服务器地址"表格
- `ADMIN.md` 顶部的服务地址表格

---

## 同步更新原则

**重要：后续任何修改都要保持三处文档同步。**

| 修改了 | 必须同时更新 |
|--------|-------------|
| `index.html` 结构 / 入口卡 | README "三个页面的职责" |
| `commands.html` 任何分区 | README 对应表格 |
| `admin.html` 任何分区 | `ADMIN.md` 对应章节、admin.html 顶部目录 |
| `ADMIN.md` 章节 | `admin.html` 对应分区 |
| `js/main.js` 新功能 | README "交互功能" |
| `css/style.css` 配色 / 类 | README "样式说明" |
| 服务器地址变更 | 见上一节"修改服务器地址" |
| 增/删插件 | `index.html` 服务特色、`admin.html` 插件清单、`ADMIN.md` 第 1 节、README 插件表格 |
