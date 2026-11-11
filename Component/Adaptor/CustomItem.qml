import QtQuick 2.15
import QtQuick.Window 2.15
import ScreenTools 1.0

Item {
    property alias bg: rect
    property bool showIcon: true
    Rectangle {
        id: rect
        anchors.fill: parent
        color: ThemeColorStyle.text_nor_color
    }

    Loader {
        id: icon_loader
        z: 999
        active: showIcon
        anchors.top: parent.top
        anchors.topMargin: ScreenTools.scaleNum(8)
        anchors.right: parent.right
        anchors.rightMargin: ScreenTools.scaleNum(8)
        sourceComponent: icon_component
    }

    Component {
        id: icon_component
        Image {
            source: CommonPngImageStyle.qiaoan_icon_img
            width: ScreenTools.scaleNum(50)
            height: ScreenTools.scaleNum(22)
        }
    }
}
