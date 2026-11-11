
/*********************************************************************
File : CustomCheckBox.qml
Module : Edit
Authors: guangnan
date : 2023/07/13 16:00
Ver : 1.0.0
History:
guangnan 2023/07/13 1.0.0 build this module
********************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.12
import ScreenTools 1.0
import ConfigureManager 1.0
import VMS.Enum 1.0
import Component.FluComponent 1.0
CheckBox {
    id: control
    signal clicked()
    property real boxWidth: ScreenTools.scaleNum(20)
    property real boxHeight: ScreenTools.scaleNum(20)
    property url sourceImageUrl: CommonImageStyle.checkBox_img
    property string boxText: ""
    property bool isTextShow: true
    property string fontFamily: ScreenTools.fontFamily
    property real boxSpacing: ScreenTools.scaleNum(6)
    //property real leftPadding: ScreenTools.scaleNum(2)
    property color boxRectFillColor: {
        if(control.checked){
            return ThemeColorStyle.privacy_color
        }
        if(control.hovered){
            return ThemeColorStyle.privacy_color
        }
        else{
            return "#FFFFFF"
        }
    }
    property color boxRectBorderColor: {
        if(control.checked){
            return ThemeColorStyle.privacy_text_color
        }
        if(control.hovered){
            return ThemeColorStyle.privacy_text_color
        }
        else{
            return ThemeColorStyle.border_nor_color
        }
    }
    property color boxPathColor: {
        if(control.checked){
            return ThemeColorStyle.privacy_text_color
        }
        if(control.hovered){
            return ThemeColorStyle.privacy_color
        }
        else{
            return "#FFFFFF"
        }
    }
    hoverEnabled: true
    padding: 0
    
    // RTL 设置
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    text: boxText
    checked: true
    font.pointSize: ScreenTools.scaleNum(10, true)
    font.family: fontFamily

    indicator: FluCustomSvg{
        imageWidth: boxWidth
        imageHeight: boxHeight
        anchors.verticalCenter: parent.verticalCenter
        svgType : VmsEnum.SvgColorTypeEnum.RectPathColor
        sourceImage: sourceImageUrl
        hoverEnabled: false
        fillColorFirst: boxRectFillColor
        fillColorSecond: boxRectBorderColor
        rectPathColor: boxPathColor
    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.down ? ThemeColorStyle.tab_text_nor_color : ThemeColorStyle.text_nor_color
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        
        leftPadding: control.LayoutMirroring.enabled ? undefined : control.indicator.width
        rightPadding: control.LayoutMirroring.enabled ? control.indicator.width : undefined
        
        visible: isTextShow
        elide: Text.ElideRight
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            control.clicked()
        }
    }
}
