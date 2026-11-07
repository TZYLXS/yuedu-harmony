# 更新日志

## v1.0.1 — 2026-11-08

用 DevEco Studio 26.0.0（HarmonyOS SDK API 26）实机编译通过后的修复版。

### 修复

- `pages/Reader.ets`：`TextAlign.Justify` 改为 `TextAlign.JUSTIFY`。原写法在 ArkTS 严格类型检查下报 `10505001 Property 'Justify' does not exist on type 'typeof TextAlign'`，导致 `assembleHap` 直接失败

### 构建

- 命令行构建已验证通过：`hvigorw --mode module -p product=default assembleHap --no-daemon` → `BUILD SUCCESSFUL`，33 tasks
- 产物 `entry-default-unsigned.hap`（约 196 KB），`ets/modules.abc` 已打入，`PackingCheck` 通过
- 剩余告警均为 deprecated API（`showToast` / `getContext` / `pushUrl` / `getParams` / `back`），不影响安装运行

### 说明

- 本版 Release 附 **未签名 HAP**，用于验证编译产物；装真机前需自行签名
- 版本号 `versionName 1.0.1`、`versionCode 1000001`

## v1.0.0 — 2026-11-08

首个版本：把 FnReader（飞牛 fnOS「阅读」）的三种接入方式合并进 HarmonyOS 客户端。

### 新增

- **手机接入 API**：`ApiClient` 对接 `/api/m/info`、`/shelf`、`/search`、`/toc`、`/content`、`/progress`、`/cover`，统一 `X-Api-Token` 鉴权与错误透出
- **书架页**：按最近阅读排序，显示进度、作者、书源名与封面（走服务端代理）
- **阅读页**：目录抽屉、上一章 / 下一章、字号调节、翻章自动上报进度
- **接入页**：三种接入地址实时生成并支持一键复制
  - `/api/m/*` 服务地址、令牌、书架 / 正文 / 搜索示例
  - Legado 书源桥：`/api/m/booksource` 地址与 `legado://import/bookSource?src=…` 导入链接
  - WebDAV：`/dav/`、`/dav/books/`、`/dav/backup/` 与账号提示
- **设置页**：服务器地址（可省略 `http://`）+ 访问令牌，Preferences 持久化，`检查连接` 调 `/api/m/info`
- **文档**：`docs/接入说明.md`（接口字段、curl 示例、`legado://` 规则、WebDAV 用法、排错表）、`docs/构建与发版.md`

### 说明

- 本版本只发布源码，不含 HAP；需用 DevEco Studio（API 12）自行编译
- 客户端为第三方实现，与 `mgz0227/legado-Harmony` 官方 HAP 无关
