# 极简工时 Lite

一款轻量级的工时记录与统计 App，基于 Flutter 开发。

## 功能

- **记录工时**：记录每天的上下班时间，自动计算工时
- **收入统计**：设置时薪后，自动计算每日/每周/每月收入
- **工作热力图**：直观展示过去 15 周的工作强度分布
- **统计分析**：按周/月查看工时柱状图，包括总计、日均、达标天数
- **数据导出**：一键导出 CSV 格式的工时记录，可通过系统分享发送
- **深色模式**：跟随系统主题，自动切换深色/浅色模式

## 技术栈

- **Flutter** + **Riverpod**（状态管理）
- **GoRouter**（路由与底部导航）
- **fl_chart**（图表）
- **Hive**（本地数据持久化）
- **share_plus**（数据导出分享）

## 构建

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

打包 APK：

```bash
flutter build apk --release
```
