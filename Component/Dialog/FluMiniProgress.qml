import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import ScreenTools 1.0

RowLayout {
    id: root
    width: 320
    height: 20

    // 属性定义
    property real progress: 1
    property int status: root.statusLoading
    property string statusText: qsTr("Loading...")

    // 状态枚举
    readonly property int statusLoading: 0
    readonly property int statusSuccess: 1
    readonly property int statusError: 2

    // 根据状态获取颜色
    readonly property color barColor: {
        switch(status) {
            case root.statusSuccess: return "#52C41A"
            case root.statusError: return "#FF4D4F"
            default: return "#1677FF"
        }
    }

    // 信号
    signal closeClicked()

    // 进度条背景
    Rectangle {
        id: progressBg
        Layout.preferredWidth: root.width - statusLoader.width - ScreenTools.scaleNum(8)
        Layout.preferredHeight: ScreenTools.scaleNum(12)
        Layout.alignment: Qt.AlignVCenter
        radius: ScreenTools.scaleNum(4)
        color: "#E8E8E8"

        // 进度条填充
        Rectangle {
            id: progressFill
            width: parent.width * root.progress
            height: parent.height
            radius: ScreenTools.scaleNum(4)
            color: root.barColor

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }

        // 加载中的流光效果
        Rectangle {
            visible: root.status === root.statusLoading && root.progress > 0 && root.progress < 1
            anchors.right: progressFill.right
            anchors.verticalCenter: progressFill.verticalCenter
            width: ScreenTools.scaleNum(30)
            height: progressFill.height
            radius: ScreenTools.scaleNum(3)
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0.4) }
            }

            SequentialAnimation on opacity {
                running: visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.3; to: 1; duration: 800 }
                NumberAnimation { from: 1; to: 0.3; duration: 800 }
            }
        }
    }

    // 状态显示区域
    Loader {
        id: statusLoader
        // Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: {
            if (root.status === root.statusLoading && root.statusText !== "") {
                return item ? item.implicitWidth : 0
            } else {
                return ScreenTools.scaleNum(20)
            }
        }
        Layout.preferredHeight: ScreenTools.scaleNum(20)
        sourceComponent: {
            if (root.status === root.statusLoading && root.statusText !== "") {
                return textComponent
            } else if (root.status === root.statusSuccess && root.progress === 1) {
                return successIconComponent
            } else if (root.status === root.statusError) {
                return closeButtonComponent
            }
            return null
        }
        
        // 确保加载器在没有内容时不会占用空间
        onLoaded: {
            if (!item) {
                Layout.preferredWidth = 0
            }
        }
    }

    // 文字状态组件
    Component {
        id: textComponent
        Text {
            text: root.statusText
            font.pointSize: ScreenTools.scaleNum(12,true)
            color: ThemeColorStyle.text_nor_color
            font.family: ScreenTools.fontFamily
            verticalAlignment: Text.AlignVCenter
        }
    }

    // 成功图标组件
    Component {
        id: successIconComponent
        Image{
            source: CommonPngImageStyle.info_success24_img
        }
    }

    // 关闭按钮组件
    Component {
        id: closeButtonComponent
        Image {
            source: CommonPngImageStyle.closeButtonUrl_img
            MouseArea {
                anchors.fill: parent
                onClicked: root.closeClicked()
            } 
        }
    }
}
