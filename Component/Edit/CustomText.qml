/*********************************************************************
File : CustomText.qml
Module : Edit
Authors: guangnan
date : 2023/07/13 16:00
Ver : 1.0.0
History:
guangnan 2023/07/13 1.0.0 build this module
********************************************************************/
import QtQuick 2.0
import QtQuick 2.15
import QtQuick.Controls 2.5
import ScreenTools 1.0
import ConfigureManager 1.0
Item{
    id:customText
    signal clicked();
    property real itemWidth: 40
    property string text: "custom text"
    property int pointSize: 10
    property color textColor:ThemeColorStyle.privacy_text_color
    property color lineColor: "blue"
    property bool isLinkText: true
    property string fontFamily: ScreenTools.fontFamily
    property alias inlineText: showText
    property int textWrapMode: Text.NoWrap
    height: itemWidth
    width: showText.width
    property int alginMode: 0//,1,2,3,其中0是居中，1，是左对齐，2是上对齐，3，是右对齐，4，是下对齐
    property int leftPad: 0
    property int rightPad: 0
    property int topPad: 0
    property int bottomPad: 0
    property bool vecCenter: false  // 用于单独设置 垂直居中
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    Text {
        id:showText
        text: customText.text
        font.pointSize: customText.pointSize
        color: customText.textColor
        anchors.horizontalCenter:alginMode == 0 ? parent.horizontalCenter : undefined
        anchors.verticalCenter:vecCenter ? parent.verticalCenter : (alginMode == 0 ?  parent.verticalCenter : undefined)
        anchors.left: alginMode == 1 ? parent.left : undefined
        anchors.right: alginMode == 3 ? parent.right : undefined
        anchors.top: alginMode == 2 ? parent.top : undefined
        anchors.bottom: alginMode == 4 ? parent.bottom : undefined
        font.family: fontFamily
        wrapMode:textWrapMode
        leftPadding: leftPad
        bottomPadding: bottomPad
        topPadding: topPad
        rightPadding: rightPad
        lineHeight: 1.2                         // 行高
        lineHeightMode: Text.ProportionalHeight
    }
    MenuSeparator {
        anchors.top: showText.bottom
        anchors.left: showText.left
        visible: isLinkText
        padding: 0
        topPadding: 0
        contentItem: Rectangle {
            implicitWidth:customText.width
            implicitHeight: 1
            color: lineColor
        }
        anchors.horizontalCenter: parent.horizontalCenter
    }
    MouseArea{
        anchors.fill: showText
        hoverEnabled: true
        cursorShape: isLinkText?containsMouse ?  Qt.PointingHandCursor : Qt.ArrowCursor:Qt.ArrowCursor
        onClicked: {
            customText.clicked();
        }
    }
}
