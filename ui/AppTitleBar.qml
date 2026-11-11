import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Component.FluButton 1.0
import RDTools.Public 1.0

// 自绘标题栏：标题 + 最小化 / 最大化还原 / 关闭按钮（按钮使用 Flu 控件）。
// 配合 Main.qml 的 frameless 窗口使用，空白区域按住即可拖动窗口。
Rectangle {
    id: root

    // 宿主窗口（Main.qml 的 ApplicationWindow）
    property var win: null
    property string titleText: ""

    readonly property bool isMaximized: win !== null
                                        && win.visibility === Window.Maximized

    height: ScreenTools.scaleNum(36)
    color: ThemeColorStyle.list_bg_nor_color
    // 圆角与外层窗口边框一致；最大化时直角，否则圆角处透出桌面
    radius: root.isMaximized ? 0 : ScreenTools.scaleNum(4)
    clip: true

    // ===== 标题文字区域：拖动窗口 / 双击切换最大化 =====
    // DragHandler / TapHandler 放在标题文字区域，避免拦截右侧按钮的鼠标事件
    Item {
        id: titleDragArea

        anchors.left: parent.left
        anchors.right: buttonRow.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        DragHandler {
            target: null
            onActiveChanged: {
                if (active && root.win !== null)
                    root.win.startSystemMove();
            }
        }

        TapHandler {
            onDoubleTapped: root.toggleMaximized()
        }
    }

    function toggleMaximized() {
        if (win === null)
            return;
        if (win.visibility === Window.Maximized)
            win.showNormal();
        else
            win.showMaximized();
    }

    // ===== 左侧标题 =====
    Text {
        anchors.left: parent.left
        anchors.leftMargin: ScreenTools.scaleNum(12)
        anchors.verticalCenter: parent.verticalCenter
        text: root.titleText
        color: ThemeColorStyle.title_text_nor_color
        font.family: ScreenTools.fontFamily
        font.pointSize: ScreenTools.scaleNum(10, true)
        font.bold: true
    }

    // ===== 右侧窗口控制按钮 =====
    Row {
        id: buttonRow
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        // 最小化
        FluCustomIconButton {
            display: Button.IconOnly
            buttonWidth: ScreenTools.scaleNum(44)
            buttonHeight: root.height
            iconSize: ScreenTools.scaleNum(14)
            sourceImgUrl: "qrc:/svgSource/image/svgSource/min_img.svg"
            normalColor: "transparent"
            iconOnlyNeedHoverBg: true
            onClicked: {
                if (root.win !== null)
                    root.win.showMinimized();
            }
        }

        // 最大化 / 还原
        FluCustomIconButton {
            display: Button.IconOnly
            buttonWidth: ScreenTools.scaleNum(44)
            buttonHeight: root.height
            iconSize: ScreenTools.scaleNum(14)
            sourceImgUrl: "qrc:/svgSource/image/svgSource/max_img.svg"
            normalColor: "transparent"
            iconOnlyNeedHoverBg: true
            onClicked: root.toggleMaximized()
        }

        // 关闭
        FluCustomIconButton {
            display: Button.IconOnly
            buttonWidth: ScreenTools.scaleNum(44)
            buttonHeight: root.height
            iconSize: ScreenTools.scaleNum(14)
            sourceImgUrl: "qrc:/svgSource/image/svgSource/close_icon.svg"
            normalColor: "transparent"
            hoverColor: ThemeColorStyle.deleteBtn_bg_color
            onClicked: {
                if (root.win !== null)
                    root.win.close();
            }
        }
    }

    // 底部分隔线，与内容区分界
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: ThemeColorStyle.border_nor_color
    }
}
