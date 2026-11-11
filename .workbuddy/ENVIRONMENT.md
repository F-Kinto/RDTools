# RDTools 项目环境说明

## 开发环境

| 项目 | 规格 |
|------|------|
| 操作系统 | Windows 64位 |
| Qt 版本 | Qt 5.15.2 (MSVC 2019 64-bit) |
| 构建系统 | CMake >= 3.16 |
| 编译器 | MSVC 2019 (Visual Studio 2019) |
| C++ 标准 | C++17 |
| UI 语言 | QML |
| 构建类型 | Windows GUI 应用 (.exe) |

## Qt5.15.2 关键约束

### QML 导入语法
- 必须使用带版本号的导入: `import QtQuick 2.15`
- 不能使用 Qt6 的无版本导入: `import QtQuick` (不兼容)
- 控件模块: `import QtQuick.Controls 2.15`
- 布局模块: `import QtQuick.Layouts 1.15`

### CMake 构建差异
- 使用 `find_package(Qt5 ...)` 而非 `Qt6`
- 使用 `qt5_add_executable()` 而非 `qt_add_executable()`
- QML 资源通过 `.qrc` 文件管理，不使用 `qt_add_qml_module`
- 链接 `Qt5::Core`, `Qt5::Gui`, `Qt5::Quick`, `Qt5::Widgets` 等
- 不使用 `qt_standard_project_setup()` (Qt6 专有)

### C++ 代码差异
- 字符串字面量: 使用 `QStringLiteral("...")` 而非 `u"..."_qs`
- QQuickStyle 需要 `#include <QQuickStyle>` (Qt5 中需额外确认)

### 项目结构约定
```
RDTools/
├── CMakeLists.txt          # 构建配置
├── main.cpp                # C++ 入口
├── qml.qrc                 # QML 资源文件
├── Main.qml                # 主窗口
├── ui/                     # UI 组件目录
│   ├── BigIconButtonGrid.qml
│   ├── SmallIconButtonGrid.qml
│   ├── TextButtonList.qml
│   └── GridLayoutContainer.qml
├── .workbuddy/             # 项目知识图谱
│   ├── ENVIRONMENT.md      # 本文件
│   ├── KNOWLEDGE_GRAPH.md  # 知识图谱主文件
│   └── docs/               # 细分文档
└── ...
```

## 构建命令
```bash
mkdir build && cd build
cmake .. -G "Visual Studio 16 2019" -A x64 -DCMAKE_PREFIX_PATH="C:/Qt/5.15.2/msvc2019_64"
cmake --build . --config Release
```

## 运行
确保 Qt5.15.2 的 bin 目录在 PATH 中，或将所需 DLL 复制到 exe 同级目录。
