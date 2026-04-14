# 小狼MC服务器 — 管理员手册

> 面向**服主和管理员**的运维手册。所有操作都有破坏力，下达大范围命令前请先在群里通知，并提前 `/save-all`。

| 服务 | 地址 / 端口 |
|------|-------------|
| 服务器 | `mc.udfj.top` |
| BlueMap 网页地图 | `mc.udfj.top:8100` |
| 网页版本 | [admin.html](./admin.html)（与本文档内容相同） |

---

## 目录

1. [插件清单与版本](#1-插件清单与版本)
2. [LuckPerms 权限](#2-luckperms-权限)
3. [EssentialsX 管理命令](#3-essentialsx-管理命令)
4. [Multiverse 多世界](#4-multiverse-多世界)
5. [保护类（GP / WG）](#5-保护类griefprevention--worldguard)
6. [BentoBox + AOneBlock 空岛](#6-bentobox--aoneblock-空岛)
7. [FastAsyncWorldEdit (FAWE)](#7-fastasyncworldedit-fawe)
8. [CoreProtect 行为日志](#8-coreprotect-行为日志)
9. [BlueMap 网页地图](#9-bluemap-网页地图)
10. [Chunky 区块预生成](#10-chunky-区块预生成)
11. [DeluxeMenus 菜单](#11-deluxemenus-菜单)
12. [性能监控（spark）](#12-性能监控spark)
13. [PlugManX 插件热重载](#13-plugmanx-插件热重载)
14. [日常运维节奏](#14-日常运维节奏)
15. [应急处置](#15-应急处置)

---

## 1. 插件清单与版本

| 插件 | 分类 | 用途 | 版本 |
|------|------|------|------|
| EssentialsX | 核心 | 家、传送、经济、踢人封禁等基础命令 | `2.22.0-dev+104` |
| EssentialsXChat | 核心 | 聊天频道、前缀渲染（配合 LuckPerms） | `2.22.0` |
| EssentialsXSpawn | 核心 | 主城出生点、新人首次出生位置 | `2.22.0` |
| Vault | 核心 | 经济/权限抽象层（被其他插件依赖） | — |
| LuckPerms | 核心 | 权限组管理（群组、继承、节点） | `5.5.42` |
| PlaceholderAPI | 核心 | 变量解析（聊天前缀、菜单内动态信息） | `2.12.2` |
| Multiverse-Core | 世界 | 多世界管理（创建、传送、属性配置） | `5.6.1` |
| Chunky | 世界 | 区块预生成，减少探索卡顿 | `1.4.10` |
| BlueMap | 世界 | 3D 网页地图（端口 8100） | `5.16` |
| GriefPrevention | 保护 | 金铲圈地，玩家自助保护建筑 | 最新 |
| WorldGuard | 保护 | 管理员区域规则（PVP、安全区、禁飞区） | 最新 |
| BentoBox | 世界 | 空岛玩法框架 | `3.14.1` |
| AOneBlock | 世界 | BentoBox 子模式：一格方块从虚空起步 | `1.23.0` |
| CoreProtect (CE) | 保护 | 方块/容器全程日志，可回滚 | `23.1` |
| FastAsyncWorldEdit | 工具 | 异步创世神 | `2.15.1-1300` |
| WESV | 工具 | WorldEdit 选区可视化 | `2.1.9` |
| DeluxeMenus | 工具 | GUI 菜单（依赖 PlaceholderAPI） | `1.14.1` |
| spark | 性能 | 性能分析、TPS、热点统计 | `1.10.172` |
| PlugManX | 性能 | 插件热重载/卸载 | `3.0.3` |

---

## 2. LuckPerms 权限

LuckPerms 是服务器的权限"中枢"。所有插件的命令权限都由它分配。**强烈建议优先用网页编辑器**：在控制台输入 `lp editor`，会生成一个临时网址，可视化拖拽即可。

### 建议的权限组结构

```
default   →  新人，能用 /home /sethome /tpa 等基础命令
member    →  在线满 5 小时，开放 /kit member, /nick
vip       →  付费/活跃玩家，/fly /hat /workbench
builder   →  建筑队，开放 //wand //set 等 worldedit
mod       →  助理管理，/ban /kick /tempban /vanish /co inspect
admin     →  全权管理，继承 mod + worldedit + grief + worldguard
owner     →  服主，* 节点
```

### 常用命令

| 命令 | 用途 |
|------|------|
| `/lp editor` | 打开网页编辑器（强烈推荐）。链接 30 分钟有效 |
| `/lp creategroup <组名>` | 新建权限组 |
| `/lp group <组名> permission set <节点> true` | 给某组添加权限 |
| `/lp group <组名> parent add <父组>` | 让某组继承父组所有权限 |
| `/lp user <玩家> parent set <组>` | 把玩家加入某个组（最常用） |
| `/lp user <玩家> permission settemp <节点> true 7d` | 临时权限（活动奖励、试用 VIP） |
| `/lp user <玩家> meta setprefix 100 "&6[传奇]&r "` | 单独给某玩家设置聊天前缀 |

> **节点示例：** `essentials.fly`、`worldedit.*`、`griefprevention.adminclaims`、`luckperms.editor`。完整节点可在各插件文档中查到。

---

## 3. EssentialsX 管理命令

EssentialsX 是服务器最核心的玩家命令插件，下面只列管理员相关的部分。

### 玩家管理

| 命令 | 用途 |
|------|------|
| `/ban <玩家> [原因]` | 永久封禁。封禁前最好用 `/co lookup u:玩家名` 留证 |
| `/tempban <玩家> <时长> [原因]` | 临时封禁。时长格式：`1d` `3h` `30m` |
| `/kick <玩家> [原因]` | 踢出当前会话，玩家可重连 |
| `/mute <玩家> [时长] [原因]` | 禁止公屏发言。不带时长则永久禁言 |
| `/jail <玩家> <监狱名> [时长]` | 把玩家关进监狱。先用 `/setjail <名>` 设置位置 |
| `/vanish` | 隐身。其他玩家看不见你（潜伏管理） |

### 游戏 / 物品

| 命令 | 用途 |
|------|------|
| `/gamemode 0/1/2/3 [玩家]` | 切换模式（生存/创造/冒险/旁观）。或用 `/gmc` `/gms` |
| `/give <玩家> <物品> [数量]` | 给玩家发物品 |
| `/heal [玩家]` / `/feed [玩家]` | 回血、回饱食度 |
| `/repair [hand\|all]` | 修复手中或全部装备 |
| `/eco give\|take\|set <玩家> <金额>` | 直接修改玩家余额（与 Vault 联动） |
| `/setwarp <名字>` / `/delwarp <名字>` | 创建/删除公共传送点 |
| `/setspawn` | 把当前位置设为出生点 |
| `/broadcast <消息>` | 全服公屏广播 |

---

## 4. Multiverse 多世界

推荐保留的世界：`world`(主世界) / `world_nether`(下界) / `world_the_end`(末地) / `world_resource`(资源世界，定期重置)。空岛玩法的世界（如 `AOneBlock`）由 BentoBox 自动管理，不需要手工导入到 Multiverse。

| 命令 | 用途 |
|------|------|
| `/mv create <世界名> <NORMAL\|NETHER\|END>` | 创建新世界。可加 `-s <种子>` `-g <生成器>` |
| `/mv import <世界名> <NORMAL\|NETHER\|END>` | 导入服务器目录里已有的世界文件夹 |
| `/mv remove <世界名>` | 从配置中移除（文件保留） |
| `/mv delete <世界名>` | **真删**硬盘上的世界文件夹 |
| `/mv tp [玩家] <世界名>` | 把自己（或玩家）传送到目标世界 |
| `/mv modify set <属性> <值> <世界>` | 修改世界属性（pvp、monsters、gamemode、difficulty 等） |
| `/mv regen <世界> [-s 种子]` | **重新生成世界**（资源世界周更必备） |
| `/mv setspawn` / `/mv list` / `/mv info <世界>` | 设置出生点 / 列表 / 详情 |

> **资源世界周更建议：** 每周一凌晨 4 点（提前 24 小时通知），先 `/save-all` → `/mv remove world_resource` → `/mv create world_resource NORMAL` → `/chunky world world_resource start` → `/bluemap fullrender world_resource`。

---

## 5. 保护类（GriefPrevention / WorldGuard）

两个保护插件分工：
- **GriefPrevention**：玩家自助圈地（金铲子）
- **WorldGuard**：管理员定义全局规则区域（PVP / 安全区 / 禁飞区）

空岛玩法的保护逻辑由 BentoBox 自身处理，参见第 6 章。

### 5.1 GriefPrevention（玩家圈地）管理

| 命令 | 用途 |
|------|------|
| `/adminclaims` | 切换为**管理员圈地模式**，圈出的地是"管理员领地" |
| `/abandonallclaims <玩家>` | 放弃某玩家的所有圈地（清退离服/违规玩家） |
| `/deleteclaim` | 删除当前位置的圈地（强制） |
| `/adjustbonusclaimblocks <玩家> <数量>` | 奖励/扣除玩家的圈地额度 |
| `/restorenature` | 手持金铲，把选区还原为自然地形 |

### 5.2 WorldGuard（管理员区域规则）

**创建区域：**
```
//wand                   ← 拿到 WorldEdit 木斧
左/右键各点一个角         ← 选区
/rg define spawn         ← 定义为 "spawn" 区域
```

**常用标志：**

| 标志 | 用途示例 |
|------|---------|
| `pvp deny` | 主城禁止 PVP |
| `build deny` | 禁止建造 |
| `use deny` | 禁止开门、按按钮 |
| `mob-spawning deny` | 禁止刷怪 |
| `invincible allow` | 区域内无敌 |
| `fly allow` | 允许飞行 |
| `greeting "&a欢迎来到主城"` | 进入提示 |
| `farewell "&7再见！"` | 离开提示 |

```
/rg flag spawn pvp deny
/rg flag spawn greeting "&a欢迎来到主城"
/rg addmember spawn Steve
/rg setpriority spawn 10
/rg flag __global__ pvp deny -w world   ← 整个世界禁 PVP
```

**⚙️ 出生点 200 格安全区（当前配置）**

以出生点为中心，半径 200 格的 WorldGuard 区域，禁止刷怪 + 禁止 PVP。重现步骤：

```
//pos1 ~-200,~-100,~-200
//pos2 ~200,~320,~200
/rg define spawn_safe
/rg flag spawn_safe mob-spawning deny
/rg flag spawn_safe pvp deny
/rg setpriority spawn_safe 5
```

> `mob-spawning deny` 只拦自然刷新，**刷怪笼 / 生怪蛋** 仍能正常工作。

| 命令 | 用途 |
|------|------|
| `/rg list` / `/rg info <区域>` / `/rg remove <区域>` | 列出 / 查看 / 删除 |
| `/rg addmember <区域> <玩家>` | 添加成员 |
| `/rg addowner <区域> <玩家>` | 添加管理者 |
| `/rg setpriority <区域> <数字>` | 优先级（子区域应高于父区域） |

---

## 6. BentoBox + AOneBlock 空岛

**BentoBox 3.14.1** 是空岛玩法的核心框架，**AOneBlock 1.23.0** 是它的子模式（GameModeAddon），实现"一格方块"玩法。BentoBox 自身不带玩法，所有玩法都由 GameModeAddon 提供。

### 6.1 BentoBox 框架命令

| 命令 | 用途 |
|------|------|
| `/bentobox` 或 `/bbox` | 查看框架状态、版本与已加载的 Addon 列表 |
| `/bentobox version` | 查看 BentoBox 与所有 Addon 的版本号（升级前必看） |
| `/bentobox reload` | 重新加载所有 Addon 配置文件 |
| `/bentobox catalog` | 在线查看官方 Addon 目录 |
| `/bentobox locale <语言>` | 切换 BentoBox 显示语言（`zh-CN` 简体中文） |

### 6.2 AOneBlock 管理命令

> AOneBlock 的管理命令默认前缀是 `/aob admin`（玩家用 `/oneblock`）。如果改了 `aoneblock.yml` 中的 `commands`，请以服务器实际为准。

| 命令 | 用途 |
|------|------|
| `/aob admin` | 查看管理子命令一览 |
| `/aob admin tp <玩家>` | 传送到指定玩家的空岛 |
| `/aob admin delete <玩家>` | **删除**玩家的空岛（不可逆） |
| `/aob admin reset <玩家>` | 重置玩家的空岛（账户保留） |
| `/aob admin setspawn` | 设置当前位置为空岛世界的大厅出生点 |
| `/aob admin range set <玩家> <格数>` | 单独修改玩家的空岛保护半径 |
| `/aob admin team add <岛主> <玩家>` | 手动把玩家加入某岛主的队伍 |
| `/aob admin reload` | 仅重新加载 AOneBlock 配置 |
| `/aob admin phases` | 查看 / 调整 OneBlock 阶段配置（草原/海洋/下界等） |

### 6.3 关键文件位置

| 路径 | 用途 |
|------|------|
| `plugins/BentoBox/config.yml` | 框架全局配置 |
| `plugins/BentoBox/addons/AOneBlock-1.23.0.jar` | Addon 本体 |
| `plugins/BentoBox/addons/AOneBlock/config.yml` | AOneBlock 配置 |
| `plugins/BentoBox/addons/AOneBlock/phases/` | 阶段定义（YAML，可自定义） |
| `plugins/BentoBox/database/` | 玩家与岛屿数据（JSON / YAML / MySQL 可选） |

> **升级 BentoBox / AOneBlock 注意：** 主版本号变化（如 3.x → 4.x）通常会改 schema，**先备份 `BentoBox/database/` 整个目录**，并在测试服跑一遍。

---

## 7. FastAsyncWorldEdit (FAWE)

异步 WorldEdit，操作大范围地形不会卡服。**只给 builder/admin 组开放权限**，新人误用 `//set bedrock` 可能整片重开。

| 命令 | 用途 |
|------|------|
| `//wand` | 获得选区工具（默认木斧）。左键选起点，右键选终点 |
| `//pos1` / `//pos2` / `//hpos1` / `//hpos2` | 用脚下/视线指定选区角点 |
| `//expand <数量> [方向]` | 扩展选区。`//expand vert` 上下扩到天地（清山必备） |
| `//set <方块>` | 填充选区。常用 `//set air` 整块清空 |
| `//replace <旧> <新>` | 替换方块。`//replace stone diamond_ore` |
| `//copy` / `//cut` / `//paste` | 复制 / 剪切 / 粘贴 |
| `//rotate <角度>` / `//flip` | 旋转 / 翻转剪贴板 |
| `//schem save <名>` / `//schem load <名>` / `//schem list` | 保存 / 载入示意图 |
| `//undo` / `//redo` | 撤销 / 重做 |
| `//cyl` / `//sphere` / `//pyramid <方块> <半径>` | 圆柱体 / 球体 / 金字塔（加 `-h` 空心） |
| `/we limit <数量>` | 设置当前会话最大改动方块数（防误操作） |

> **WESV** 会自动在选区周围显示发光粒子边框，所见即所得，无需配置。

---

## 8. CoreProtect 行为日志

服务器上发生的所有方块、容器、聊天事件都被 CoreProtect 记录。**处理纠纷时务必先查日志，再做决定。**

### 检查模式

```
/co inspect   ← 进入检查模式（也可用 /co i）
左键空气 → 查看方块放置/破坏记录
右键容器 → 查看物品出入记录
/co i         ← 再次输入退出
```

### 复杂查询 `/co lookup`

| 参数 | 含义 |
|------|------|
| `u:玩家名` | 指定玩家 |
| `t:7d` / `t:2h` | 时间范围 |
| `r:30` | 半径 |
| `a:block` / `a:item` / `a:chat` / `a:command` / `a:kill` | 行为类型 |
| `b:diamond_ore` | 指定方块 |

```
/co lookup u:Steve t:1d a:block r:50
```
查 Steve 一天内在身边 50 格的所有方块操作。

### 回滚与恢复

| 命令 | 用途 |
|------|------|
| `/co rollback <参数>` 或 `/co rb <参数>` | 回滚行为。**先 lookup 确认范围再 rb** |
| `/co restore <参数>` | 把已回滚的操作重新应用 |
| `/co purge t:<时长>` | 清理超过指定时长的旧日志（每月跑一次） |

> **范例处置：** 玩家 A 报告被偷 → 到现场 → `/co i` 右键被偷的箱子 → 看见 B 在 14:32 拿走了 32 颗钻石 → 关闭 inspect → `/co rb u:B t:1d a:item` 回滚 → 通知双方 → 视情况封禁 B。

---

## 9. BlueMap 网页地图

BlueMap 在端口 `8100` 上运行 HTTP Web 服务。配置文件位于 `plugins/BlueMap/`。

| 命令 | 用途 |
|------|------|
| `/bluemap` | 显示插件状态、地图列表 |
| `/bluemap reload` | 重新加载配置 |
| `/bluemap freeze <地图ID>` | 冻结地图渲染（节省 CPU） |
| `/bluemap fullrender <地图ID>` | **整张地图重新渲染**。资源世界重置后必做 |
| `/bluemap purge <地图ID>` | 清空该地图的所有渲染数据 |

> **对外暴露建议：** 用 Caddy 做 HTTPS 反代到 `127.0.0.1:8100`，关闭 8100 直接公网。Caddy 配置示例：
>
> ```
> map.udfj.top {
>     reverse_proxy 127.0.0.1:8100
> }
> ```

---

## 10. Chunky 区块预生成

Chunky 在后台异步预生成区块。**新世界创建后必跑一次**。

| 命令 | 用途 |
|------|------|
| `/chunky world <世界名>` | 设置目标世界 |
| `/chunky center <X> <Z>` | 设置预生成中心点 |
| `/chunky radius <数字>` | 设置半径（方块）。主世界 `5000`，下界 `2000`，资源世界 `3000` |
| `/chunky shape <square\|circle>` | 形状 |
| `/chunky start` / `pause` / `continue` / `cancel` | 控制任务（重启后用 `continue` 续传） |
| `/chunky quiet 30` | 广播频率（秒），避免刷屏 |

> **建议节奏：** 新建世界 → `/chunky world XX` → `center 0 0` → `radius 5000` → `shape square` → `start`。预生成期间玩家可游玩，但 TPS 可能略降。

---

## 11. DeluxeMenus 菜单

DeluxeMenus 用 YAML 文件定义 GUI 菜单，依赖 **PlaceholderAPI**。所有菜单文件放在 `plugins/DeluxeMenus/gui_menus/`。

| 命令 | 用途 |
|------|------|
| `/dm reload` | 重新加载所有菜单配置（编辑 YAML 后必须执行） |
| `/dm open <菜单名> [玩家]` | 给指定玩家打开菜单 |
| `/dm list` | 列出已加载的所有菜单 |
| `/papi list` | 查看所有可用的 PlaceholderAPI 变量 |

> **菜单调试：** 把出错的菜单文件重命名为 `.bak`，`/dm reload` 后看控制台报错，再修正语法。常见错误是 YAML 缩进或 `commands:` 列表写法。

---

## 12. 性能监控（spark）

spark 是 Paper / Spigot 服性能分析的事实标准。

| 命令 | 用途 |
|------|------|
| `/spark tps` | 查看 TPS（5s/10s/1m/5m/15m）。低于 **18** 就要关注 |
| `/spark health` | 一键体检：CPU、内存、TPS、MSPT |
| `/spark profiler` | 启动性能分析。默认采样 30 秒，结束后自动上传到 spark.lucko.me |
| `/spark profiler --timeout 60 --thread *` | 采样 60 秒、所有线程 |
| `/spark gc` | 查看 GC 状况 |
| `/spark heapsummary` | 查看堆内存对象占用，定位内存泄漏 |

> **定位高占用区块：** `/spark profiler` → 让玩家正常游玩 30 秒 → 打开生成的网页 → 看 `Tick > entityTick` 或 `worldTick` 下的世界/区块占比。配合 `/co lookup` 查谁在那刷怪塔/红石。

---

## 13. PlugManX 插件热重载

PlugManX 让你**不重启服务器**就能加载/卸载/重载插件。核心插件（LuckPerms、Vault、PlaceholderAPI）热重载可能造成依赖断裂，谨慎使用。

| 命令 | 用途 |
|------|------|
| `/plugman list` | 列出所有插件及加载状态 |
| `/plugman load <插件名>` | 加载新放进 plugins/ 的插件 |
| `/plugman unload <插件名>` | 卸载插件 |
| `/plugman reload <插件名>` | 重新加载插件（插件本身要支持） |
| `/plugman info <插件名>` | 查看插件作者、版本、依赖、命令列表 |

> **升级插件正确流程：** 下载新 jar → `/plugman unload 插件名` → 替换文件 → `/plugman load 插件名` → 看控制台。若插件持有大量缓存（如 LuckPerms、CoreProtect），仍建议**滚动重启**而不是热重载。

---

## 14. 日常运维节奏

### 每日

- 查看 `/spark tps`、`/spark health`，TPS < 18 时启动 profiler 分析。
- 处理 `/co lookup` 中的可疑行为（破坏类、命令类）。
- 响应群里玩家反馈、补发被偷物品、复原被破坏建筑。

### 每周

- **周一凌晨**资源世界重置（提前 24 小时广播）：
  ```
  /save-all
  /mv remove world_resource
  /mv create world_resource NORMAL
  /chunky world world_resource start
  /bluemap fullrender world_resource
  ```
- 检查插件更新（PaperMC、EssentialsX、LuckPerms 等），用 PlugManX 滚动升级。
- `/lp editor` 检查权限组是否需要调整。

### 每月

- 清理 CoreProtect 旧日志：`/co purge t:60d`。
- 清理长期未上线玩家的空岛：`/aob admin delete <玩家>`（先 `/seen` 确认 90+ 天未上线再删）。
- 检查 BlueMap 渲染目录大小（`plugins/BlueMap/web/`）。
- 异地备份整服 `world*` 与 `plugins/`。

### 备份策略示例

```cron
# 凌晨 4 点全量打包到 /backup
0 4 * * * cd /opt/mc && tar czf /backup/mc-$(date +\%F).tar.gz \
  --exclude='world*/region' world world_nether world_the_end plugins
# region 太大，单独 rsync
0 5 * * * rsync -a /opt/mc/world/region/ /backup/region/world/
```

---

## 15. 应急处置

### 15.1 熊孩子大范围破坏

1. `/ban 玩家名 大范围破坏` — 先封号止损。
2. `/co lookup u:玩家名 t:1d a:block` — 查看破坏范围。
3. `/co rb u:玩家名 t:1d r:200 a:block` — 半径 200 内回滚（按实际范围调整）。
4. 若涉及容器盗窃：`/co rb u:玩家名 t:1d a:item`。
5. 群里通报，让被害玩家确认是否完全复原。

### 15.2 服务器卡顿 / TPS 暴跌

1. `/spark tps` 确认 TPS。
2. `/spark profiler --timeout 60` 录制 60 秒。
3. 查看报告中的 **worldTick → 哪个区块**，定位元凶（一般是怪物刷新塔、红石机器、飞行物）。
4. 必要时 `/co lookup` 看那块地是谁的，私聊提醒/拆除。

### 15.3 服务器无响应 / 崩溃

1. SSH 上服务器，`tail -200 logs/latest.log` 看最后输出。
2. 若有 Stack Trace，复制到群里 / 提 Issue。
3. 检查内存：`free -h`。OOM 是常见崩溃原因。
4. 启动脚本里 Xms/Xmx 默认 4G，玩家多时建议 **6-8G**。
5. 恢复后用 `/save-all`、`/save-on` 确保保存正常。

### 15.4 数据回档

1. **先 `/save-off && /save-all`**（关闭自动保存避免覆盖）。
2. `stop` 关服。
3. 从 `/backup/` 解包对应日期的存档替换 `world*`。
4. 启动服务器，群里通告回档时间点。

---

> **沟通原则：** 无论什么应急事件，**先在群里发"管理员处理中，请稍候"**，再动手。让玩家知道事情有人在管，比快速解决更能稳定情绪。

> **网页版本：** 本手册同步维护了图形化的 [admin.html](./admin.html)，内容一致，方便手机端查阅。
