# Safe C Drive Cleanup

一个面向 Windows 的 C 盘安全缓存清理工具。它只清理可再生成的临时文件和缓存，不删除桌面、下载、文档、图片、视频、程序安装目录或其他个人资料文件。

适合用于释放 C 盘空间，尤其是 `pip`、`npm`、NVIDIA、浏览器、Adobe CameraRaw 等缓存长期积累导致系统盘变满的情况。

## 功能特点

- 清理常见 Windows 临时文件和错误报告缓存
- 清理 Python `pip` 下载缓存
- 清理 Node.js `npm` 缓存
- 清理 NVIDIA `DXCache` / `GLCache`
- 清理 Chrome / Edge 浏览器缓存和 Code Cache
- 清理 Adobe CameraRaw 缓存
- 清理资源管理器缩略图和图标缓存
- 支持预览模式，只统计不删除
- 使用路径白名单，避免误删非目标目录
- 每次运行后保存清理日志

## 清理范围

工具当前只会处理以下类型的缓存：

| 类型 | 路径示例 |
| --- | --- |
| 用户临时目录 | `%TEMP%`、`%LOCALAPPDATA%\Temp` |
| Windows 临时目录 | `%WINDIR%\Temp` |
| Windows 错误报告 | `%ProgramData%\Microsoft\Windows\WER` |
| Windows 更新下载缓存 | `%WINDIR%\SoftwareDistribution\Download` |
| 崩溃转储 | `%LOCALAPPDATA%\CrashDumps` |
| INetCache | `%LOCALAPPDATA%\Microsoft\Windows\INetCache` |
| 资源管理器缓存 | `%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db`、`iconcache_*.db` |
| pip 缓存 | `%LOCALAPPDATA%\pip\Cache` |
| npm 缓存 | `%LOCALAPPDATA%\npm-cache` |
| NVIDIA 缓存 | `%LOCALAPPDATA%\NVIDIA\DXCache`、`GLCache` |
| Chrome 缓存 | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache`、`Code Cache` |
| Edge 缓存 | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache`、`Code Cache` |
| Adobe CameraRaw 缓存 | `%LOCALAPPDATA%\Adobe\CameraRaw\Cache2` |

不会清理：

- 桌面、下载、文档、图片、视频等用户文件
- `Program Files`、`Program Files (x86)`、`Windows\System32`
- 微信、QQ、网盘、IDE、剪映等应用数据目录
- 浏览器书签、历史记录、密码、扩展程序和登录状态
- 已安装的 Python 包或 Node.js 项目依赖

## 文件说明

| 文件 | 说明 |
| --- | --- |
| `dist/SafeCDriveCleanupInstaller.exe` | Windows 安装版，可双击安装 |
| `SafeCDriveCleanup.ps1` | 核心 PowerShell 清理脚本 |
| `Install-SafeCDriveCleanup.cmd` | 安装脚本，会创建开始菜单快捷方式 |
| `SafeCDriveCleanup-Package.sed` | IExpress 打包配置 |
| `docs/README-SafeCDriveCleanup.md` | 项目说明文档副本 |

## 安装方法

### 方法一：使用安装版

下载或复制项目中的 `dist/SafeCDriveCleanupInstaller.exe`，双击运行。

安装程序会把工具安装到：

```text
%LOCALAPPDATA%\Programs\SafeCDriveCleanup
```

并在开始菜单创建以下快捷方式：

- `Run Safe C Drive Cleanup`
- `Preview Safe C Drive Cleanup`
- `Uninstall Safe C Drive Cleanup`

### 方法二：使用安装脚本

如果不想使用 `.exe` 安装器，也可以直接运行：

```cmd
Install-SafeCDriveCleanup.cmd
```

安装位置和开始菜单快捷方式与方法一相同。

### 方法三：不安装，直接运行脚本

在 PowerShell 中进入项目目录后运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SafeCDriveCleanup.ps1
```

## 使用方法

### 预览将清理的内容

预览模式只统计目标目录大小，不删除任何文件：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SafeCDriveCleanup.ps1 -DryRun
```

安装后也可以从开始菜单运行：

```text
Preview Safe C Drive Cleanup
```

### 执行清理

直接运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SafeCDriveCleanup.ps1
```

安装后也可以从开始菜单运行：

```text
Run Safe C Drive Cleanup
```

### 静默模式

如果需要在脚本或计划任务中运行，可以加上 `-Quiet`：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SafeCDriveCleanup.ps1 -Quiet
```

预览加静默：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SafeCDriveCleanup.ps1 -DryRun -Quiet
```

## 日志位置

每次运行后，日志会保存到：

```text
%LOCALAPPDATA%\SafeCDriveCleanup\Logs
```

日志包含：

- 运行时间
- 清理模式
- C 盘清理前后的可用空间
- 每个目标目录清理前后的大小
- 预计释放空间

## 卸载方法

如果通过安装器或安装脚本安装，可以从开始菜单运行：

```text
Uninstall Safe C Drive Cleanup
```

也可以手动删除：

```text
%LOCALAPPDATA%\Programs\SafeCDriveCleanup
```

以及开始菜单目录：

```text
%APPDATA%\Microsoft\Windows\Start Menu\Programs\SafeCDriveCleanup
```

## 安全说明

该工具通过固定路径白名单限制清理范围。即使脚本中的清理函数被传入其他路径，也会拒绝执行。

清理缓存后，部分软件首次启动或首次打开某些文件时可能会稍慢，因为缓存需要重新生成。例如：

- 浏览器重新生成页面缓存
- NVIDIA 重新生成着色器缓存
- Adobe CameraRaw 重新生成图片预览缓存
- `pip` / `npm` 后续安装依赖时重新下载包缓存

这些属于正常现象，不会影响系统正常使用。

## 重新打包安装器

本项目使用 Windows 自带的 IExpress 打包安装器。修改脚本后，可以在项目目录运行：

```cmd
iexpress.exe /N SafeCDriveCleanup-Package.sed
```

成功后会生成：

```text
dist\SafeCDriveCleanupInstaller.exe
```

## 系统要求

- Windows 10 或 Windows 11
- Windows PowerShell 5.1 或更高版本
- 普通用户权限即可运行大部分清理项
- 如果需要清理受保护的系统缓存，建议以管理员身份运行

## 免责声明

请在运行前确认你了解工具的清理范围。该工具只针对可再生成缓存和临时文件设计，但不同电脑的软件环境可能存在差异。建议首次使用先运行 `-DryRun` 预览。
# SafeCDriveCleanup
