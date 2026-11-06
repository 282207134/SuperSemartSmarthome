# 验证与交付记录

验证日期：2026-11-06（Asia/Tokyo）。

## 环境

| 项目 | 实际环境 |
| --- | --- |
| 开发系统 | Windows 11 |
| Flutter / Dart | 3.47.7 stable / 3.13.5 |
| 测试设备 | 已运行的 emulator-5554，SM S908E，Android 11 / API 30，x64 |
| 截图尺寸 | 780×1688 像素，逻辑尺寸 390×844，2 倍密度 |
| 布局检查 | 33 个路由 × 2 个逻辑尺寸 × 深浅主题 = 132 组 |
| Android 工具链 | Gradle 8.14 / Android Gradle Plugin 8.13.1 / Kotlin 2.2.20 / Java 21 |

直接复用原有模拟器，没有创建 AVD、下载系统镜像或操作已连接的实体手机。截图时临时调整分辨率/密度，结束后恢复设备原配置。

## 结果

- `flutter analyze`：通过，无问题。
- `flutter test`：4 项状态与存储测试通过。
- Android 调试包：编译通过并安装、启动。
- `flutter drive` 集成验证：通过（日志含 `All tests passed.`）。
- 截图：39 张浅色 + 39 张深色；PNG 文件逐一验证可读取。
- 132 组布局检查：在现有 Android 模拟器内，约束至 390×844 / 360×800，并分别应用深浅主题，未捕获布局异常。

集成验证除逐页截图外，还实际执行首页灯光开关、进入灯光详情、模式切换、亮度拖动、空调模式与温度调整、房间选择、设备搜索/配对/完成、持久化重载、聊天问题发送与回复。测试完成后恢复演示数据，清除测试过程中添加的设备。

独立状态测试覆盖：设备/参数/主题/资料重载、房间改名后的设备迁移、空房间名与重名处理、配对去重、损坏 JSON 数据回退。

## 修正记录

检查并修复了小屏房间卡片高度不足、天气图文挤压及新设备长名称导致的溢出；首页设备卡片使用单行省略，房间卡片采用固定合理高度。已修正头像图层导出含外部阴影导致头像过小的问题，并将设备入口绑定到实际设备 id。

本机 Windows `flutter_tester` 在界面批量测试中曾出现原生进程访问异常（0xC0000005）。因此界面测试已整合进 Android 集成测试，在实际目标平台完成全部布局和交互验证；默认 `test/` 保留稳定的业务与存储测试。没有把未通过的 Windows 批量渲染结果计为通过。

Flutter 新模板的 Android 配置与本机环境存在兼容问题，已使用本机现有工具链完成构建。当前 Flutter 会提示此 Gradle/AGP/Kotlin 组合未来停止支持；当前版本仍可构建，后续升级 Flutter 时应一并升级和验证 Android 工具链。

## 截图与复现

入口：`SCREENS.md`，逐项列出原稿节点、路由或交互入口，以及浅色/深色截图。截图脚本位于 `integration_test/app_tour_test.dart`，落盘回调位于 `test_driver/screenshots.dart`。

```powershell
flutter pub get
flutter analyze
flutter test
flutter drive -d emulator-5554 --driver=test_driver/screenshots.dart --target=integration_test/app_tour_test.dart
```

脚本对当前可用模拟器执行测试；如需相同像素尺寸，可先把设备显示设为 780×1688、密度 320。布局矩阵本身无需新增模拟器。

需要局部刷新截图时可额外传入 `--dart-define=CAPTURE_ONLY=true` 和 `--dart-define=SCREENSHOT_IDS=16,30`，只更新指定序号的两套主题截图。默认不传这两个参数时执行完整截图、交互和布局验证。

## 实现边界

本次验证针对本地演示：配对与聊天为模拟流程，账号为表单演示，能耗/天气/通知为样例数据。没有验证真实设备通信、账号安全、推送送达、实际能耗准确性或云服务。未接入头像/封面上传、第三方 OAuth、语音识别和多家庭数据隔离。语言偏好可保存，英文界面未做完整翻译。

iOS 工程与图标已准备，但 Windows 无法运行 Xcode，未声明 iOS 编译、签名或模拟器测试通过。Android 正式发布前需更换发布签名。

## 整理原则

保留源码、锁文件、设计素材、39 个浅色原稿、1 个深色首页参考、78 张运行截图、截图总览和文档。清理项目内可再生的 build、build_temp、.dart_tool 及 IDE 临时文件，不清理用户的全局 Flutter / Gradle / Android 缓存，也不删除现有模拟器。
