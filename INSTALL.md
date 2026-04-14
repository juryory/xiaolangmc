# 小狼MC 服务器 · 新人安装教程

> 面向**零基础玩家**的入服手册。按照下面的四个步骤，大约 10 分钟即可进入游戏。
> 服务器地址：`mc.udfj.top` ｜ 网页地图：[mc.udfj.top:8100](http://mc.udfj.top:8100)
> 网页版教程：[install.html](./install.html)（图文风格一致，手机看更清楚）

---

## 一、环境配置

### 1. 安装 JDK（Java 运行环境）

双击 `01-先安装我-microsoft-jdk-25-windows-x64.msi` 开始安装前置环境。

![安装 JDK](images/install/01-install-jdk.png)

### 2. 一直下一步完成安装

一路点 **Next** 直到显示 *Completed*。

![完成 JDK 安装](images/install/02-jdk-finish.png)

### 3. 打开 HMCL 启动器

安装完 JDK 后，双击 `02-再运行我-HMCL-3.12.2.exe` 打开启动器。

![打开 HMCL](images/install/03-open-hmcl.png)

---

## 二、游戏安装

### 1. 点击"创建游戏实例"

![创建游戏实例](images/install/04-create-instance.png)

### 2. 点击"安装新游戏"

![安装新游戏](images/install/05-install-new.png)

### 3. 搜索游戏版本 `1.21.11`

### 4. 点击"前往安装"

![前往安装](images/install/06-goto-install.png)

### 5. 点击"安装"

![点击安装](images/install/07-click-install.png)

### 6. 等待安装完成

![等待安装完成](images/install/08-waiting.png)

### 7. 安装完成后点击"确定"

![确定完成](images/install/09-confirm.png)

### 8. 回到主页

![回到主页](images/install/10-back-home.png)

---

## 三、创建账户

### 1. 点击"创建账户"

![创建账户](images/install/11-create-account.png)

### 2. 选择"离线模式"

![选择离线模式](images/install/12-offline-mode.png)

> ⚠️ **离线模式的账户不安全，容易被别人冒用。** 也可以选择使用 [LittleSkin](https://littleskin.cn/auth/register) 站点认证登录，安全性更高。

### 3. 输入用户名（建议使用英文）

### 4. 点击"登录"

![输入用户名并登录](images/install/13-enter-name.png)

### 5. 点击"返回"

![返回](images/install/14-back.png)

---

## 四、登录游戏

### 1. 点击"启动游戏"

![启动游戏](images/install/15-launch-game.png)

### 2. 点击"多人游戏"

![多人游戏](images/install/16-multiplayer.png)

### 3. 点击"添加服务器"

![添加服务器](images/install/17-add-server.png)

### 4. 填写服务器信息

- 服务器名称：`小狼MC`
- 服务器地址：`mc.udfj.top`
- 点击"完成"

![填写服务器信息](images/install/18-server-info.png)

### 5. 双击加入游戏

![加入游戏](images/install/19-join.png)

---

## 🎉 进服之后

第一次进服建议先做这几件事：

1. 输入 `/rules` 查看服务器规则。
2. 找到主城的新手引导板，或直接看 [玩家命令大全](./commands.html)。
3. 建好家之后**立刻圈地保护**：手持金铲左键点一个角、右键点对角，详见 [圈地教程](./commands.html#land-claim)。
4. 试试空岛玩法：输入 `/oneblock` 或 `/is` 创建你的一格方块空岛。
5. 遇到任何问题：群里 @管理员 或在游戏里 `/msg 管理员名 内容`。

---

## 🛠 下载教程里的截图

本教程所用截图放在 `images/install/` 目录下。如果你 clone 下来后该目录为空，按你的系统选一条命令执行：

**Windows（PowerShell）：**

```powershell
powershell -ExecutionPolicy Bypass -File scripts\download-install-images.ps1
```

**Linux / macOS / Git Bash：**

```bash
bash scripts/download-install-images.sh
```

两个脚本功能相同，会自动从图床拉取全部 19 张图并按步骤命名保存，下载完**自动压缩到最大宽度 1200px**。已存在的文件会被跳过。

如果图片已经下好只想压缩，单独跑：

```powershell
# Windows PowerShell（无需外部依赖）
powershell -ExecutionPolicy Bypass -File scripts\optimize-install-images.ps1
```

```bash
# Linux / macOS（需要 ImageMagick 或 Pillow）
bash scripts/optimize-install-images.sh
```
