/*********************************************************************
File : CanSelectButton.qml
Module : Button
Authors: guangnan
date : 2023/07/11 16:00
Ver : 1.0.0
History:
guangnan 2023/07/11 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import ScreenTools 1.0
import QtQuick.Controls 2.15
Button {
    id:control
    property var buttonWidth:ScreenTools.scaleNum(40)
    property var buttonHeight:ScreenTools.scaleNum(40)
    property var buttonText: "ButtonText"
    property var buttonTextSelectColor: "white"
    property var buttonTextUnSelectColor:"black"
    property var buttonUnSelectColor: "white"
    property var buttonSelectColor: "blue"
    property var buttonBorderWidth: 1
    property var buttonBorderColor: "gray"
    property var buttonRadius: 1
    property var buttonFontPointSize: ScreenTools.scaleNum(10)
    property var buttonFontFamily: "微软雅黑"
    property var buttonEnable: true
    property var buttonChecked: false
    property bool bIsLineVisiable: false
    property real lineHeight: ScreenTools.scaleNum(2)
    property color lineSelectColor: "red"
    enabled: buttonEnable
    checkable:false
    contentItem: Rectangle{
        anchors.fill: parent
        color: "transparent"
        Text {
            id:buttonTextObj
            text: buttonText
            font.pointSize: buttonFontPointSize
            font.family: buttonFontFamily
            opacity: buttonEnable ? 1.0 : 0.3
            color: buttonChecked ? buttonTextSelectColor : buttonTextUnSelectColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MenuSeparator {
            anchors.bottom: parent.bottom
            anchors.left: buttonTextObj.left
            visible: bIsLineVisiable && buttonChecked
            padding: 0
            topPadding: 0
            contentItem: Rectangle {
                implicitWidth:buttonTextObj.width
                implicitHeight: lineHeight
                color: lineSelectColor
            }
        }
    }

    background: Rectangle {
        implicitWidth: buttonWidth
        implicitHeight:buttonHeight
        opacity: buttonEnable ? 1.0 : 0.3
        color: buttonChecked ? buttonSelectColor : buttonUnSelectColor
        border.width: buttonBorderWidth
        border.color: buttonBorderColor
        radius: buttonRadius
    }

}
