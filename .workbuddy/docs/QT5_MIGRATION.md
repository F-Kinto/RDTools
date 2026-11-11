# Qt5.15.2 迁移指南

> 从 Qt6 语法迁移到 Qt5.15.2 的完整清单

## 1. CMakeLists.txt 迁移

### 需要修改的项

| Qt6 写法 | Qt5.15.2 写法 | 说明 |
|----------|--------------|------|
| `find_package(Qt6 REQUIRED COMPONENTS ...)` | `find_package(Qt5 REQUIRED COMPONENTS ...)` | 包名 Qt6→Qt5 |
| `qt_standard_project_setup()` | 删除 | Qt6 专有，Qt5 不需要 |
| `qt_add_executable(...)` | `add_executable(...)` | Qt5 用标准 CMake 命令 |
| `qt_add_qml_module(...)` | `.qrc` 资源文件 | Qt5 不支持 qml module |
| `Qt6::Core` 等 | `Qt5::Core` 等 | 链接目标改名 |
| `set(CMAKE_AUTOMOC ON)` | 需手动添加 | Qt5 需要显式启用 AUTOMOC |

### Qt5.15.2 CMakeLists.txt 模板
```cmake
cmake_minimum_required(VERSION 3.16)

project(RDTools VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# Qt5
find_package(Qt5 REQUIRED COMPONENTS Core Gui Quick Widgets)

# 资源文件
set(QML_RESOURCES
    qml.qrc
)

add_executable(RDTools WIN32
    main.cpp
    ${QML_RESOURCES}
)

set_target_properties(RDTools PROPERTIES
    WIN32_EXECUTABLE ON
)

target_link_libraries(RDTools PRIVATE
    Qt5::Core
    Qt5::Gui
    Qt5::Quick
    Qt5::Widgets
)
```

## 2. QML 导入语法迁移

### 需要修改的项

| Qt6 写法 | Qt5.15.2 写法 |
|----------|--------------|
| `import QtQuick` | `import QtQuick 2.15` |
| `import QtQuick.Controls` | `import QtQuick.Controls 2.15` |
| `import QtQuick.Layouts` | `import QtQuick.Layouts 1.15` |

### 影响的文件
- Main.qml
- ui/BigIconButtonGrid.qml
- ui/SmallIconButtonGrid.qml
- ui/TextButtonList.qml
- ui/GridLayoutContainer.qml

## 3. main.cpp 迁移

### 需要修改的项

| Qt6 写法 | Qt5.15.2 写法 |
|----------|--------------|
| `u"qrc:/RDTools/Main.qml"_qs` | `QStringLiteral("qrc:/qml/Main.qml")` |
| (无需额外 include) | `#include <QQuickStyle>` |

### Qt5.15.2 main.cpp 模板
```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::Round);
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QGuiApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
```

## 4. 资源文件 (qml.qrc)

Qt5 不支持 `qt_add_qml_module`，需要手动创建 `.qrc` 文件：

```xml
<RCC>
    <qresource prefix="/">
        <file>qml/Main.qml</file>
        <file>qml/ui/BigIconButtonGrid.qml</file>
        <file>qml/ui/SmallIconButtonGrid.qml</file>
        <file>qml/ui/TextButtonList.qml</file>
        <file>qml/ui/GridLayoutContainer.qml</file>
    </qresource>
</RCC>
```

> 注意: QML 文件可保持在项目根目录或 ui/ 目录，
> .qrc 中的路径需与实际文件路径一致。

## 5. 迁移检查清单
- [ ] CMakeLists.txt: Qt6 → Qt5
- [ ] 添加 set(CMAKE_AUTOMOC ON)
- [ ] 删除 qt_standard_project_setup()
- [ ] qt_add_executable → add_executable
- [ ] 删除 qt_add_qml_module，创建 qml.qrc
- [ ] Qt6:: → Qt5:: 链接目标
- [ ] main.cpp: u"..."_qs → QStringLiteral("...")
- [ ] 所有 QML 文件: 添加版本号导入
- [ ] 验证 QQuickStyle 在 Qt5 中的可用性
