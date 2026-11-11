import QtQuick 2.15
import QtQuick.Controls 2.15
import ScreenTools 1.0

// 全屏提示/退出UI（挂载在 Overlay.overlay）
Item {
    signal sendCmd()
    signal rightClicked(real globalX, real globalY)

    property bool tipVisible: false
    property string fontFamily: "YaHei"

    id: contorl
    parent: fullScreenHost
    anchors.fill: parent
    visible: mainWindowRoot.isItemShowFullScreen
    z: 1000000
    enabled: visible

    // 全屏覆盖层接收右键事件并转发，使 DynamicPage 的右键菜单可在全屏下唤起。
    // 左键不拦截，底部控制条区域有自己的 MouseArea。
    MouseArea {
        anchors.fill: parent
        enabled: contorl.visible
        acceptedButtons: Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                contorl.rightClicked(mouse.x, mouse.y)
            }
        }
    }

    // =========================
    // 1) 文本：全屏时显示3s后隐藏
    // =========================
    Timer {
        id: tipAutoHideTimer
        interval: 3000
        repeat: false
        onTriggered: fullScreenOverlayUi.tipVisible = false
    }

    Text {
        id: messageText
        anchors.centerIn: parent
        visible: contorl.tipVisible
        text: qsTr("Press ESC to exit full-screen mode")
        font.pointSize: ScreenTools.scaleNum(16, true)
        font.family: fontFamily
        color: "white"
    }

    // =========================
    // 2) 底部横条：默认仅显示横条
    //    鼠标移入横条 -> 展开按钮，保持3s
    // =========================
    property bool controlsVisible: false

    Timer {
        id: controlsAutoHideTimer
        interval: 3000
        repeat: false
        onTriggered: contorl.controlsVisible = false
    }

    function showControlsHold3s() {
        contorl.controlsVisible = true
        controlsAutoHideTimer.restart()
    }

    // 底部区域（横条 + 展开后的按钮）
    Item {
        id: bottomBarArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: contorl.controlsVisible ? ScreenTools.scaleNum(56) : ScreenTools.scaleNum(10)

        // 横条（始终存在，用于触发显示）
        Rectangle {
            id: bottomHandle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: ScreenTools.scaleNum(10)
            color: "#000000"
            opacity: 0.35

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: contorl.showControlsHold3s()
                onPositionChanged: contorl.showControlsHold3s()
                onClicked: contorl.showControlsHold3s()
            }
        }

        // 展开后的按钮容器（默认隐藏，显示保持3s）
        Item {
            id: controlsPane
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: bottomHandle.top
            height: ScreenTools.scaleNum(46)
            visible: contorl.controlsVisible
            opacity: contorl.controlsVisible ? 1 : 0

            // 可选：按钮区域背景
            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.20
                visible:false
            }

            MouseArea {
                // 鼠标在按钮区域内移动也续命3s
                anchors.fill: parent
                hoverEnabled: true
                onEntered: contorl.showControlsHold3s()
                onPositionChanged: contorl.showControlsHold3s()
            }

            Button {
                id: exitFullScreenButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Exit full screen")
                opacity: 0.9

                onClicked: {
                    contorl.sendCmd()
                }

                background: Rectangle {
                    radius: ScreenTools.scaleNum(6)
                    color: "#000000"
                    opacity: 0.35
                }
                contentItem: Text {
                    text: exitFullScreenButton.text
                    color: "white"
                    anchors.centerIn: parent
                    font.pointSize: ScreenTools.scaleNum(12, true)
                    font.family: fontFamily
                }
            }
        }
    }

    // 进入全屏时：提示显示3s，按钮默认收起（仅横条）
    onVisibleChanged: {
        if (visible) {
            // 文本提示 3s
            tipVisible = true
            tipAutoHideTimer.restart()

            // 控件收起
            controlsVisible = false
            controlsAutoHideTimer.stop()
        } else {
            tipVisible = false
            controlsVisible = false
            tipAutoHideTimer.stop()
            controlsAutoHideTimer.stop()
        }
    }
}
