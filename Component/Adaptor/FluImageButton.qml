import QtQuick 2.12
import QtQuick.Controls 2.12
import ScreenTools 1.0
Button{
    id:control
    property string normalImage: ""
    property string hoveredImage: ""
    property string pushedImage: ""

    property string tipText: ""
    background: Item{
        implicitHeight: control.height
        implicitWidth: control.width
        BorderImage {
            anchors.fill: parent
            source: control.hovered ? (control.pressed ? control.pushedImage : control.hoveredImage ) : control.normalImage
        }
    }

    ToolTip {
        id: toolTip
        text: tipText
        visible: parent.hovered && !!tipText
        font.pointSize: ScreenTools.scaleNum(10,true)
        font.family: ScreenTools.fontFamily
        background: Rectangle {
            color: "#FFFFFF"
            radius: ScreenTools.scaleNum(4)
            border.width: 1
            border.color: ThemeColorStyle.border_nor_color  
        }
    }
}
