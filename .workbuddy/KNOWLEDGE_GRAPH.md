# RDTools 知识图谱

## 项目概览
- **项目名称**: RDTools (研发工具集)
- **项目路径**: `C:/AgentProject/RDTools/`
- **技术栈**: C++17 + QML (QtQuick.Controls 2.15) + CMake
- **目标平台**: Windows 64位
- **Qt版本**: 5.15.2 (MSVC2019 64-bit)

## 架构设计
```
ApplicationWindow (Main.qml)
├── 左侧 ColumnLayout (2/3 宽度)
│   ├── BigIconButtonGrid (2/3 高度) - 20个大图按钮(100x100)
│   └── SmallIconButtonGrid (1/3 高度) - 20个小图按钮(56x56)
└── TextButtonList (1/3 宽度) - 20个文本按钮(高度28px)
```

## 布局比例
| 模块 | 宽度占比 | 高度占比 | 按钮尺寸 | 数量 |
|------|---------|---------|---------|------|
| BigIconButtonGrid | 2/3 | 2/3 | 100x100 | 20 |
| SmallIconButtonGrid | 2/3 | 1/3 | 56x56 | 20 |
| TextButtonList | 1/3 | 100% | 高度28px | 20 |
| 总窗口 | 1344x756 | - | - | 60 |

## 配色方案 (Catppuccin Mocha Dark)
| 用途 | 色值 |
|------|------|
| 主背景 | #1e1e2e |
| 左面板背景 | #181825 |
| 小图面板背景 | #11111b |
| 按钮默认色 | #1e1e2e |
| 按钮悬停色 | #313244 |
| 边框悬停色 | #89b4fa |
| 图标默认色 | #45475a |
| 图标悬停色 | #89b4fa |
| 文字主色 | #cdd6f4 |

## 功能模块清单

### 模块1: 大图功能按钮 (BigIconButtonGrid)
> 网络与系统管理工具集
- 设备扫描, 网络拓扑, 远程控制, 文件传输, 系统信息
- 进程管理, 端口扫描, 日志查看, 性能监控, 任务调度
- 备份恢复, 安全审计, 配置同步, 版本更新, 权限管理
- 告警中心, 数据导出, 脚本执行, 环境检测, 诊断工具

### 模块2: 小图功能按钮 (SmallIconButtonGrid)
> 实用工具集
- 截图, 录屏, 剪贴板, 计算器, 时钟
- 天气, 颜色, 编码, 哈希, 二维码
- 翻译, 对比, 搜索, 替换, 格式化
- 压缩, 加密, 解密, 校验, 清理

### 模块3: 文本功能按钮 (TextButtonList)
> 设置与系统工具
- 设置, 帮助文档, 关于, 检查更新, 反馈
- 快捷键, 主题切换, 语言切换, 导出日志, 导入配置
- 重置布局, 全屏模式, 最小化到托盘, 开机自启, 代理设置
- 数据清理, 缓存管理, 插件管理, 开发者选项, 退出

## 组件设计模式
- **GridLayoutContainer**: 通用网格容器，通过 `buttonType`("big"/"small") 区分大小图样式
- **ScrollView + Grid + Repeater**: 滚动网格布局模式
- **Column + Repeater**: 垂直列表模式
- 所有按钮: hover 效果 + 点击日志输出 + 圆角4px

## 变更历史

### 2026-11-04: 项目初始化
- 创建项目结构 (CMakeLists.txt, main.cpp, Main.qml)
- 实现3模块布局: 大图网格 + 小图网格 + 文本列表
- 网格列数自适应: 根据面板宽度动态计算
- 统一 Catppuccin Mocha Dark 主题配色

### 2026-11-04: Qt6→Qt5.15.2 迁移完成
- **CMakeLists.txt**: Qt6→Qt5, 删除 qt_standard_project_setup/qt_add_qml_module, 改用 add_executable + .qrc
- **main.cpp**: `u"..."_qs` → `QStringLiteral("...")`, 资源路径改为 `qrc:/qml/Main.qml`, 添加高DPI支持
- **qml.qrc**: 新建资源文件, 使用 alias 映射 QML 文件到 qml/ 路径前缀
- **5个QML文件**: import 语句全部添加版本号 (QtQuick 2.15, QtQuick.Controls 2.15, QtQuick.Layouts 1.15)

## 待办/规划
- [x] 迁移到 Qt5.15.2 语法 ✅
- [x] 创建 qml.qrc 资源文件 ✅
- [ ] 各功能模块的实际逻辑实现
- [ ] 图标资源替换 (当前为文字占位)
- [ ] 全局快捷键系统
- [ ] 主题切换功能
- [ ] 国际化 (中/英)

## 详细文档索引
- [环境说明](./ENVIRONMENT.md)
- [Qt5迁移指南](./docs/QT5_MIGRATION.md)
