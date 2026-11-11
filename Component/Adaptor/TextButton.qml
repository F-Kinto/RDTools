import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Component.Edit 1.0
import ScreenTools 1.0

Button {
    id: root
    property color btnColor: "blue"
    property color hoverColor: "lightgray"
    property color defaultBgColor: "blue"
    property int btnRadius: ScreenTools.scaleNum(4)
    property string btnText: ""
    property color btnTextColor: "black"
    property bool needToolTip: false
    property bool isDefaultBg: false
    property real btnOpacity: 1
    property int btnWidth: ScreenTools.scaleNum(80)
    property int btnHeight: ScreenTools.scaleNum(36)
    signal btnClicked()

    implicitWidth: btnWidth
    implicitHeight: btnHeight
    hoverEnabled: true
    font.pointSize: ScreenTools.scaleNum(10,true)
    font.family: "Microsoft YaHei UI"
    Layout.alignment: Qt.AlignHCenter
    
    background: Rectangle {
        id: bg
        color: hovered ? hoverColor : (isDefaultBg ?  defaultBgColor : btnColor)
        radius: btnRadius
        opacity: btnOpacity
    }

    contentItem: Text {
        text: btnText // 使用父级 Button 的 text 属性
        font: parent.font   // 可以继承字体设置
        color: btnTextColor       // 设置文本颜色为红色
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            timer.restart();
        }
        onPressedChanged: {
            root.opacity = pressed ? 0.6 : 1;
        }

    }

    Timer { //添加点击事件防抖
        id: timer
        interval: 200
        repeat: false
        onTriggered: {
            btnClicked();
        }
    }

    
    ToolTip {
        id: toolTip
        text: btnText
        visible: parent.hovered && needToolTip
        background: Rectangle {
            color: "#EEE"  
            border.width: 0      
        }
    }
}
