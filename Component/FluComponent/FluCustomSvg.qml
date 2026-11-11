import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import ScreenTools 1.0
import SvgIconItem 1.0
import VMS.Enum 1.0

FluRectangle {
    id: control
    signal clicked()
    property string sourceImage: CommonImageStyle.tab_close_img
    property int imageWidth: ScreenTools.scaleNum(16)
    property int imageHeight: ScreenTools.scaleNum(16)
    property string tooltipText: ""
    property bool toolTipVisible: false
    property bool isChecked: false
    property bool isEnabled: true
    property int svgType: VmsEnum.SvgColorTypeEnum.BorderPathColor    // 0:纯色 1:描边+path 两种颜色 2:渐变颜色
    property string fillColorFirst: "white"
    property string fillColorSecond: fillColorFirst
    property string rectPathColor: fillColorFirst
    readonly property alias hovered: mouseArea.containsMouse
    readonly property alias pressed: mouseArea.pressed
    property bool hoverEnabled: true
    property int itemWidth: 0
    property int itemHeight: 0
    property int topPadding: needBg ? 0 : 1                                       // 由于图标显示偏上无法与文字对齐，此处主动向下偏移
    // 边框背景相关
    property bool needBg: false
    property string rectBgColor: "transparent"
    property string rectBgHoverColor: ThemeColorStyle.privacy_color

    width: itemWidth > 0 ? itemWidth : imageWidth //+ ScreenTools.scaleNum(8)
    height: itemHeight > 0 ? itemHeight : imageHeight //+ ScreenTools.scaleNum(8) 

    onFillColorFirstChanged: svgItem.updateFillColor()
    onFillColorSecondChanged: svgItem.updateFillColor()
    onRectPathColorChanged: svgItem.updateFillColor()
    radius: [ScreenTools.scaleNum(4),ScreenTools.scaleNum(4),ScreenTools.scaleNum(4),ScreenTools.scaleNum(4)]
    color: {
        if(!needBg){
            return "transparent"
        }
        if (mouseArea.containsMouse) {
            return control.rectBgHoverColor
        }
        return control.rectBgColor
    }

    SvgIconItem {
        id: svgItem
        anchors.centerIn: parent
        anchors.verticalCenterOffset: control.topPadding
        source: control.sourceImage
        iconWidth: control.imageWidth
        iconHeight: control.imageHeight
        topPadding: 0

        strokeColor: "#FFFFFE"
        fillColor: "#FFFFFE"
        pathColor: "#FFFFFE"
        pathStrokeColor: "#FFFFFE"
        rectColor: "#FFFFFE"
        rectStrokeColor: "#FFFFFE"
        beginColor: "#FFFFFE"
        endColor: "#FFFFFE"

        function updateFillColor() {
            if(control.svgType === VmsEnum.SvgColorTypeEnum.BorderPathColor){
                svgItem.pathColor = control.fillColorFirst
                svgItem.pathStrokeColor = control.fillColorSecond
            }
            else if(control.svgType === VmsEnum.SvgColorTypeEnum.GradientColor){
                svgItem.beginColor = control.fillColorFirst
                svgItem.endColor = control.fillColorSecond
                svgItem.rectStrokeColor = control.fillColorFirst
            }
            else if(control.svgType === VmsEnum.SvgColorTypeEnum.RectPathColor){
                svgItem.rectColor = control.fillColorFirst
                svgItem.rectStrokeColor = control.fillColorSecond
                svgItem.pathColor = control.rectPathColor
            }
            else{
                svgItem.fillColor = control.fillColorFirst
                svgItem.strokeColor = control.fillColorSecond
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: control.hoverEnabled
        hoverEnabled: control.hoverEnabled
        onEntered: {
            tooltip.visible = toolTipVisible && tooltipText !== ""
        }
        onExited: {
            tooltip.visible = false
        }
        onClicked: {
            if(isEnabled){
                control.clicked()
            }
        }
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
