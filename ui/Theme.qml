pragma Singleton
import QtQuick 2.15

// 全局主题：颜色取自 ThemeColor.css，字体统一 微软雅黑 10pt
// 通过 import "ui" 后以 Theme.xxx 访问（需配合同目录 qmldir 声明为单例）
QtObject {
    // ===== 字体 =====
    readonly property string fontFamily: "微软雅黑"
    readonly property int fontSize: 10 // 字号（pt）

    // ===== 背景 =====
    readonly property color mainBgColor: "#E5F5FF"  // 主背景
    readonly property color rectColor: "#F5F7FA"    // 除主背景外的矩形
    readonly property color listBgColor: "#FFFFFF"  // 列表 / 卡片常规背景
    readonly property color hoverBgColor: "#E5F5FF" // 悬浮背景

    // ===== 文本 =====
    readonly property color titleTextColor: "#1D1F21" // 标题
    readonly property color textColor: "#6D7682"      // 内容 / 描述
    readonly property color noteTextColor: "#989EA6"  // 注释 / 次要文本

    // ===== 主题色与边框 =====
    readonly property color themeColor: "#0099FF" // 文本主题色 / 选中
    readonly property color errorColor: "#FF4A4A" // 报错
    readonly property color borderColor: "#CAD2DD" // 常规边框
}
