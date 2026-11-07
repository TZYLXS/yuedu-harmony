# yuedu-harmony · 阅读（鸿蒙客户端）

把 [FnReader](https://github.com/TZYLXS/FnReader)（飞牛 fnOS 上的 Legado 书源阅读器）的**接入方式**做成一个 HarmonyOS 原生客户端：服务器地址 + 访问令牌填一次，就能在鸿蒙手机 / 平板 / 2in1 上读书架、看正文、同步进度，并把整座书库一键桥接给老安卓的「阅读」APK。

> 说明：本仓库是**独立第三方客户端**，与 `mgz0227/legado-Harmony` 的官方 HAP 无关（官方鸿蒙版闭源，仓库仅分发安装包）。本项目只提供客户端与接入能力，不附带任何书籍内容，也不内置书源站点。

## 三种接入方式

服务端（FnReader / 飞牛「阅读」）对外提供三套入口，本客户端全部接上：

| 接入 | 入口 | 用途 |
| --- | --- | --- |
| 手机接入 API | `/api/m/*`（`X-Api-Token` 或 `?token=`） | 书架、搜索、目录、正文、封面、进度上报 |
| Legado 书源桥 | `/api/m/booksource` → `legado://import/bookSource?src=…` | 一键生成书源导入链接，安卓 4.4–5.1 装 yuedu-android4 直连书库 |
| WebDAV | `/dav/`（`/dav/books/` 只读、`/dav/backup/` 读写） | 挂进文件管理器，或接「阅读」的备份与恢复 |

完整接口字段、示例与排错见 [docs/接入说明.md](docs/接入说明.md)。

## 功能

- **书架**：`GET /api/m/shelf`，按最近阅读排序，显示读到第几章、封面（服务端代理，已处理防盗链）
- **阅读**：目录 + 正文分页加载，上一章 / 下一章、字号调节、阅读进度自动上报 `POST /api/m/progress`
- **接入页**：把三种接入方式的地址实时生成，一键复制；书源导入链接直接可粘进「阅读」APK 的网络导入
- **设置页**：服务器地址（可省略 `http://`）、访问令牌，保存到本地 Preferences，带「检查连接」调用 `/api/m/info`

## 目录结构

```
yuedu-harmony/
├── AppScope/                     应用级配置与图标
├── build-profile.json5           工程级构建配置（compatibleSdkVersion 5.0.0(12)）
├── hvigorfile.ts / hvigor/       hvigor 构建入口
├── entry/                        入口 HAP 模块
│   ├── src/main/module.json5     能力声明、INTERNET 权限
│   ├── src/main/ets/
│   │   ├── entryability/EntryAbility.ets
│   │   ├── common/ApiClient.ets        /api/m/* 客户端
│   │   ├── common/LegadoBridge.ets     legado:// 书源桥
│   │   ├── common/WebDavHelper.ets     WebDAV 地址助手
│   │   ├── common/ServerStore.ets      地址与令牌持久化
│   │   ├── model/Models.ets            服务端返回结构
│   │   ├── pages/Index.ets             书架 / 接入 / 设置
│   │   ├── pages/Reader.ets            阅读页
│   │   └── view/ShelfView.ets、AccessView.ets、SettingsView.ets
│   └── src/main/resources/       字符串、颜色、页面清单、图标
├── docs/                         接入说明、构建与发版
└── CHANGELOG.md
```

## 快速开始

1. 在飞牛 NAS 上装好 FnReader（`legado-web.fpk`），打开「阅读」→ 设置 → 手机接入，记下**访问令牌**
2. 用 DevEco Studio 打开本工程（`File → Open` 选根目录），等待 hvigor sync
3. 连接鸿蒙设备或模拟器，`Run 'entry'`
4. 应用内「设置」填 `http://<NAS IP>:1122` 与令牌 → 保存 → 检查连接
5. 「书架」拉书单，「接入」复制 `legado://` 链接给老安卓设备

命令行构建（需装好 DevEco Studio 与其自带 hvigor / ohpm）：

```bash
hvigorw clean --no-daemon
hvigorw assembleHap --mode module -p product=default --no-daemon
# 产物：entry/build/default/outputs/default/entry-default-signed.hap
```

更多细节见 [docs/构建与发版.md](docs/构建与发版.md)。

## 版本

- 当前：`1.0.0`（见 [CHANGELOG.md](CHANGELOG.md)）
- Release 里挂源码包（`yuedu-harmony-<version>-source.zip`）；HAP 需本机 DevEco Studio 编译后另行上传，仓库不提交构建产物

## 免责声明

本项目只提供阅读工具与接入实现，不提供、不分发任何书籍内容，不内置盗版站点。请自行确认所用书源与内容的合法性。

## License

[Apache-2.0](LICENSE)
