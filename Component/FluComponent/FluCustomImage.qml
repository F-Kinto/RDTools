import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import ScreenTools 1.0

Image {
    id: control
    signal clicked()
    property string normalImageUrl: ""
    property string hoverImageUrl: normalImageUrl
    property string pressedImageUrl: hoverImageUrl
    property string tooltipText: ""
    property bool toolTipVisible: false
    property bool isChecked: false
    property bool needAutoScale: false          // 是否需要自动缩放, 默认不自动缩放, 部分图片自动缩放后变得模糊
    // 点击需要
    property bool clickChangeImageEnable: false
    onIsCheckedChanged: {
        control.source = isChecked ? control.pressedImageUrl : control.normalImageUrl
    }
    source: normalImageUrl
    //anchors.centerIn: parent
    width: ScreenTools.scaleNum(16)
    height: ScreenTools.scaleNum(16)
    //sourceSize: Qt.size(width, height)
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    fillMode: needAutoScale ? Image.PreserveAspectFit : Image.Stretch
    MouseArea { 
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            if(!clickChangeImageEnable)
                 control.source = isChecked ? control.pressedImageUrl : control.hoverImageUrl
            tooltip.visible = toolTipVisible && tooltipText !== ""
        }
         onExited: {
            if(!clickChangeImageEnable)
                 control.source = isChecked ? control.pressedImageUrl : control.normalImageUrl
            tooltip.visible = false
        }
        onClicked: {
            control.clicked()
        }
    }

    function updateSourceImg(isHover){
        control.source = isChecked ? control.pressedImageUrl : isHover ? control.hoverImageUrl : control.normalImageUrl
    }

    FluTooltip {
        id: tooltip
        margins: ScreenTools.scaleNum(6)
        padding: ScreenTools.scaleNum(6)
        font.family: ScreenTools.fontFamily
        font.pointSize: ScreenTools.scaleNum(10, true)
        background: Rectangle {
            color: FluTheme.dark ? Qt.rgba(50/255,49/255,48/255,1) : Qt.rgba(1,1,1,1)
            radius: ScreenTools.scaleNum(4)
            FluShadow{
                radius: ScreenTools.scaleNum(4)
            }
        }
        text: control.tooltipText
        y: -ScreenTools.scaleNum(32)
        visible: false
    }
}
