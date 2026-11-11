import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import RDTools.Public 1.0
import "ui"

ApplicationWindow {
    id: root

    // ===== 分辨率适配 =====
    // 窗口尺寸由 ScreenTools 按屏幕分辨率 / DPI 换算（设计基准 1344x756），
    // 小屏时再乘 rectWidthScale / rectHeightScale 做补偿
    width: ScreenTools.scaleNum(ScreenTools.screenWidth) * ScreenTools.rectWidthScale
    height: ScreenTools.scaleNum(ScreenTools.screenHeight) * ScreenTools.rectHeightScale
    minimumWidth: ScreenTools.scaleNum(640)
    minimumHeight: ScreenTools.scaleNum(480)
    visible: true
    title: "RDTools"
    // 窗口本体透明，圆角背景与描边分别由 windowBg / windowBorder 绘制
    color: "transparent"
    // 全局默认字体：微软雅黑 10pt（子控件未单独设置字体时自动继承）
    font.family: Theme.fontFamily
    font.pointSize: ScreenTools.scaleNum(Theme.fontSize, true)
    // 去掉系统默认标题栏，改用自绘 AppTitleBar（空白区域可拖动窗口）
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.NoDropShadowWindowHint

    // ===== 跨屏拖动适配 =====
    property real initialWidth: -1
    property real initialHeight: -1
    property real lastScreenDpr: -1
    property real screenDpr: Screen.devicePixelRatio

    // 拖到不同 DPI 的显示器上时按新屏可用区域重新匹配尺寸，并保证窗口留在屏内
    onScreenDprChanged: {
        if (screenDpr < 0)
            return;
        if (lastScreenDpr < 0) {
            // 首次求值：仅记录基准
            lastScreenDpr = screenDpr;
            return;
        }
        if (screenDpr > 0 && screenDpr !== lastScreenDpr
                && visibility !== Window.Maximized) {
            root.fitWindowToScreen();
            Qt.callLater(root.fitWindowToScreen);
        }
        lastScreenDpr = screenDpr;
    }

    function fitWindowToScreen() {
        if (initialWidth <= 0 || visibility === Window.Maximized)
            return;
        var newWidth = Math.min(initialWidth, Screen.desktopAvailableWidth);
        var newHeight = Math.min(initialHeight, Screen.desktopAvailableHeight);
        // 以当前左上角为锚收缩/放大，超出新屏的部分拉回屏内
        var newX = Math.max(Screen.virtualX,
                            Math.min(x, Screen.virtualX + Screen.width - newWidth));
        var newY = Math.max(Screen.virtualY,
                            Math.min(y, Screen.virtualY + Screen.height - newHeight));
        x = newX;
        y = newY;
        width = newWidth;
        height = newHeight;
    }

    Component.onCompleted: {
        // 记录启动逻辑尺寸，作为跨屏恢复的基准
        if (initialWidth <= 0) {
            initialWidth = width;
            initialHeight = height;
        }
    }

    // ===== 圆角窗口背景（图片） =====
    Rectangle {
        id: windowBg

        anchors.fill: parent
        z: 0
        // 最大化时直角，否则圆角处会透出桌面
        radius: (visibility === Window.Maximized) ? 0 : ScreenTools.scaleNum(4)
        color: "transparent"
        clip: true

        Image {
            anchors.fill: parent
            source: "qrc:/app/image/app/sliderBg9.png"
            fillMode: Image.Stretch
            smooth: true
        }
    }

    // ===== 最外层 1px 描边 =====
    Rectangle {
        id: windowBorder

        anchors.fill: parent
        z: 200
        radius: (visibility === Window.Maximized) ? 0 : ScreenTools.scaleNum(4)
        color: "transparent"
        border.width: 1
        border.color: Theme.borderColor
        visible: visibility !== Window.Maximized
    }

    // ===== 自绘标题栏（可拖动窗口） =====
    AppTitleBar {
        id: appTitleBar

        z: 100
        titleText: root.title
        win: root
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    // ===== 主体内容：2×2 网格，4 个分类模块 =====
    GridLayout {
        anchors.top: appTitleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: ScreenTools.scaleNum(16)
        anchors.leftMargin: ScreenTools.scaleNum(16)
        anchors.rightMargin: ScreenTools.scaleNum(16)
        anchors.bottomMargin: ScreenTools.scaleNum(16)
        rowSpacing: ScreenTools.scaleNum(16)
        columnSpacing: ScreenTools.scaleNum(16)
        rows: 2
        columns: 2

        // 左上：网络工具（大图标）
        BigIconButtonGrid {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.55
            Layout.preferredHeight: parent.height * 0.5
        }

        // 右上：办公日常（小图标）
        SmallIconButtonGrid {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.5
            moduleTitle: "办公日常"
            smallIcons: [
                "截图", "录屏", "剪贴板", "计算器", "时钟",
                "天气", "颜色", "二维码", "翻译", "搜索",
                "清理", "数据导出", "导入配置", "导出日志", "对比"
            ]
        }

        // 左下：开发工具（小图标）
        SmallIconButtonGrid {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.55
            Layout.preferredHeight: parent.height * 0.5
        }

        // 右下：实用查询（文本列表）
        TextButtonList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.5
        }
    }

    // ===== 截屏选区覆盖层 =====
    ScreenCaptureOverlay {
        id: screenCaptureOverlay
    }

    Connections {
        target: ScreenCapture
        function onCaptureStarted() { screenCaptureOverlay.show() }
        function onCaptureFinished() { screenCaptureOverlay.hide() }
        function onCaptureCancelled() { screenCaptureOverlay.hide() }
    }
}
