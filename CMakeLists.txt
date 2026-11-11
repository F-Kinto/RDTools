cmake_minimum_required(VERSION 3.16)

project(RDTools VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Qt5
find_package(Qt5 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Svg Widgets)

# 资源文件：自有界面 / 搬运过来的 Flu 控件目录 / 图片资源 / 图标样式表
set(QML_RESOURCES
    qml.qrc
    component.qrc
    image.qrc
    style.qrc
)

add_executable(RDTools WIN32
    main.cpp
    src/Public/screentools.h
    src/Public/screentools.cpp
    src/Public/systemtools.h
    src/Public/systemtools.cpp
    src/Public/screencapture.h
    src/Public/screencapture.cpp
    src/Public/uicompat.h
    src/Public/qmlsupport.h
    src/Public/svgiconitem.h
    src/Public/svgiconitem.cpp
    ${QML_RESOURCES}
)

set_target_properties(RDTools PROPERTIES
    WIN32_EXECUTABLE ON
)

# 让 main.cpp 能以 "Public/screentools.h" 形式包含
target_include_directories(RDTools PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)

# 源码含中文注释，统一按 UTF-8 解析，避免 MSVC 按本地代码页读取导致注释吞掉代码
if (MSVC)
    target_compile_options(RDTools PRIVATE /utf-8)
endif ()

# FluentUI 是运行时 QML 模块（含插件 DLL），构建后整体拷到可执行文件同级目录
add_custom_command(TARGET RDTools POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/FluentUI
            $<TARGET_FILE_DIR:RDTools>/FluentUI
)

target_link_libraries(RDTools PRIVATE
    Qt5::Core
    Qt5::Gui
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    Qt5::Widgets
)
