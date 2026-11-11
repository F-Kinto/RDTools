import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: ScreenTools.scaleNum(60)
    height: ScreenTools.scaleNum(20)
    color: "#EAEAEA"
    radius: ScreenTools.scaleNum(12)

    property string leftString
    property string rightString
    property string stateString
    signal toggleLeft //左开关信号
    signal toggleRight //右开关信号

    Rectangle {
        id: rect
        width: parent.width * 0.6
        radius: parent.radius
        color: rect.state === "left"? "#CCCCCC" : ThemeColorStyle.privacy_text_color //根据状态切换背景色
        state: root.stateString
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        states: [
            State {
                name: "right"
                PropertyChanges {
                    target: rect
                    x: root.width - rect.width
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"
                NumberAnimation { property: "x"; duration: 200 }
            }
        ]

        Text {
            id: label
            anchors.centerIn: parent
            text: rect.state === "left"? root.leftString : root.rightString
            color: "white"
            font.pointSize: ScreenTools.scaleNum(10,true)
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            //点击切换状态
            if(rect.state === "left"){
                rect.state = "right";
                root.toggleRight();
            }else {
                rect.state = "left";
                root.toggleLeft();
            }
        }
    }
}
