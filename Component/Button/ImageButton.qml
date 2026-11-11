/*********************************************************************
File : ImageButton.qml
Module : Button
Authors: guangnan
date : 2023/07/11 16:00
Ver : 1.0.0
History:
guangnan 2023/07/11 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtQuick.Controls 2.15
import ScreenTools 1.0
Rectangle {
    id:control
    signal clicked();
    property bool isHoverButton: false
    property bool isCheckedButton: false
    property url checkedButtonCheckedImage: ""
    property url checkedButtonUnCheckedImage: ""
    property bool inlineChecked: false
    property bool isChecked: inlineChecked
    property var imageWidth: ScreenTools.scaleNum(24)
    property var imageHeight: ScreenTools.scaleNum(24)
    property var hoverImage:""
    property var pressImage:hoverImage
    property var image:""
    property var disableImage: ""
    property var buttonEnable: true
    property var buttonBorderWidth: 0
    property var buttonBorderColor: "red"
    property var buttonRadius: 0
    property var buttonBgColor:"white"
    property var buttonHoverColor:"blue"
    property var buttonPressedColor:"red"
    property string toolTipText: ""
    property alias isHover: tooltip.active
    property int buttonWidth: imageWidth
    property int buttonHeight: imageHeight
    property bool toolTipVisible: false
    property int toolTipWidth: buttonWidth
    property string toolTipTextColor:"#000000"
    property string toolTipCustomColor:"#FFFFFF"
    property real toolTipOpacity: 1

    height: buttonHeight
    width: buttonWidth

    Loader {
        id: tooltip
        active: toolTipVisible && toolTipText
        sourceComponent: toolTipComponent
    
        onLoaded: {
            if (item) {
                item.visible = true
            }
        }
    }

    Component {
        id: toolTipComponent
    
        ToolTip {
            id: dynamicToolTip
            parent: Overlay.overlay
            text: toolTipText
            visible: true
            delay: 0
            font.pointSize: ScreenTools.scaleNum(10, true)
            font.family: ScreenTools.fontFamily
            margins: ScreenTools.scaleNum(6)
            padding: ScreenTools.scaleNum(6)
        
            background: Rectangle {
                color: toolTipCustomColor
                radius: ScreenTools.scaleNum(4)
                opacity: toolTipOpacity
                border.width: 1
                border.color: ThemeColorStyle.border_nor_color
            }
            contentItem: Text {
                text: dynamicToolTip.text
                font: dynamicToolTip.font
                color: toolTipTextColor  // 文本颜色，根据背景色调整
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        
            enter: null
            exit: null
        
            // 手动控制超时
            Timer {
                interval: 3000
                running: parent.visible
                onTriggered: control.toolTipVisible = false
            }
            Component.onCompleted: {
                updatePosition()
            }
        
            function updatePosition() {
                if (!parent) return;
                var globalPos = control.mapToItem(parent, 0, 0)
                x = globalPos.x + (toolTipWidth - width) / 2
                y = globalPos.y - height - ScreenTools.scaleNum(4)
                if(y < control.height)
                    y =  globalPos.y + height + ScreenTools.scaleNum(4)
            }
        }
    }

    onButtonEnableChanged:{
        if(buttonEnable)
            bgImage.source=image;
        else
            bgImage.source=disableImage;
    }
    Rectangle {
        id:buttonBg
        width: buttonWidth
        height:buttonHeight
        opacity: buttonEnable ? 1.0 : 0.3
        color: buttonBgColor
        border.width: buttonBorderWidth
        border.color: buttonBorderColor
        radius: buttonRadius
        // anchors.verticalCenter: parent.verticalCenter
        // anchors.horizontalCenter: parent.horizontalCenter
        Image {
            id:bgImage
            width: imageWidth
            height: imageHeight
            source: isCheckedButton?isChecked?checkedButtonCheckedImage:checkedButtonUnCheckedImage:image
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    MouseArea{
        anchors.fill: parent
        hoverEnabled:true
        onPressed: {
            control.toolTipVisible = false
            if(!buttonEnable)
                return;
            if(isHoverButton){
                buttonBg.color=Qt.binding(function(){return buttonPressedColor; });
                return;
            }
            if(isCheckedButton){
                inlineChecked=control.isChecked;
                inlineChecked=!inlineChecked;
                bgImage.source=Qt.binding(function(){return control.isChecked?control.checkedButtonCheckedImage:control.checkedButtonUnCheckedImage;});
                return;
            }
            bgImage.source=Qt.binding(function(){return pressImage;});
        }
        onEntered: {
            if(!buttonEnable)
                return;
            control.toolTipVisible = true
            if(isHoverButton){
                buttonBg.color=Qt.binding(function(){return buttonHoverColor; });
                return;
            }
            if(isCheckedButton){
                bgImage.source=Qt.binding(function(){return hoverImage});
                return;
            }
            bgImage.source=hoverImage;
        }
        onExited: {
            if(!buttonEnable)
                return;
            //tooltip.visible = false
            control.toolTipVisible = false
            if(isHoverButton){
                buttonBg.color=Qt.binding(function(){return buttonBgColor; });
                return;
            }
            if(isCheckedButton){
                bgImage.source=Qt.binding(function(){ return isChecked?checkedButtonCheckedImage:checkedButtonUnCheckedImage});
                return;
            }
            bgImage.source=Qt.binding(function(){return image;});
        }
        onReleased: {
            if(!buttonEnable)
                return;
            if(isHoverButton){
                buttonBg.color=Qt.binding(function(){return buttonHoverColor; });
                return;
            }
            if(isCheckedButton){
                bgImage.source=Qt.binding(function(){ return isChecked?checkedButtonCheckedImage:checkedButtonUnCheckedImage});
                return;
            }
            bgImage.source=Qt.binding(function(){return image});
        }
        onClicked: {
            if(!buttonEnable)
                return;
            if(protectRepeatClickTimer.running)
                return
            control.clicked();
            protectRepeatClickTimer.running=true
        }
    }
    Timer{
        id:protectRepeatClickTimer
        interval: 500
        repeat: false
        running: false
    }
}
