/*********************************************************************
File : DrawButton.qml
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
import QtQuick.Layouts 1.15
Rectangle{
    id:control
    signal clicked();
    signal doubleClicked()
    property real buttonRadius: ScreenTools.scaleNum(10)
    property real buttonWidth: ScreenTools.scaleNum(200)
    property real buttonHeight: ScreenTools.scaleNum(40)

    property int buttonBorderWidth: ScreenTools.scaleNum(2)
    property color buttonBorderColor: ThemeColorStyle.privacy_text_color
    property color buttonBorderHoverColor: ThemeColorStyle.privacy_text_color
    property color buttonBorderPressedColor: ThemeColorStyle.privacy_text_color
    property color buttonBorderDisableColor: ThemeColorStyle.border_nor_color
    property color buttonColor: "#FFFFFF"
    property color buttonHoverColor: ThemeColorStyle.privacy_text_color
    property color buttonDisableColor: ThemeColorStyle.text_disable_color
    property color buttonPressedColor: ThemeColorStyle.privacy_text_color
    property color buttonDisableTextColor:"white"
    property color buttonTextColor: ThemeColorStyle.text_nor_color
    property color buttonTextHoverColor: "black"
    property color buttonTextPressedColor: "red"
    property string buttonText: qsTr("Login")
    property int pointSize: ScreenTools.scaleNum(10,true)
    property string fontFamily: ScreenTools.fontFamily
    property bool isEnable: true
    property bool isCreate: false
    property bool isShowLeftImage: false
    property url leftImageHoverImage: "qrc:/general/image/general/closeBtn.png"
    property url leftImageImage: "qrc:/general/image/general/closeBtn.png"
    property url leftImagePressedImage: "qrc:/general/image/general/closeBtn.png"
    property url leftImageDisableImage: "qrc:/general/image/general/closeBtn.png"
    property real leftImageWidth: ScreenTools.scaleNum(16)
    property real leftImageHeight: ScreenTools.scaleNum(16)
    property real imageAndTextSpan: ScreenTools.scaleNum(5)
    property bool imageAndTextSpanIsShow: false

    property bool isShowRightImage: false
    property url rightImageHoverImage:""
    property url rightImageNormalImage:""
    property url rightImagePressedImage:""
    property url rightImageDisableImage: ""
    property real rightImageTextSpan:0
    property real rightImageToRightBorderSpan:0
    property real rightImageWidth: ScreenTools.scaleNum(16)
    property real rightImageHeight: ScreenTools.scaleNum(16)
    property string toolTipText: ""
    property bool isShowTips: false // 判断鼠标悬浮事件是否需要显示ToolTip文本
    property bool isHCenter: true // 判断是否水平居中对齐，主要针对宽度有限，文本很长的垂直布局的按钮
    property int buttonLeftMargin: 0
    property bool isChecked: false

    //property alias drawButtonMouseAreaObj: drawButtonMouseArea
    //property alias rightImageObj: rightImage
    property bool buttonIsVisible: true
    property string toolTipCustomColor:"#FFFFFF"
    property string toolTipTextColor:ThemeColorStyle.title_text_nor_color
    property real toolTipOpacity: 1
    property bool toolTipVisible: false

    border.width: buttonBorderWidth
    border.color: isEnable?buttonBorderColor:buttonBorderDisableColor;
    color: isEnable?buttonColor:buttonDisableColor
    implicitWidth: buttonWidth
    implicitHeight: buttonHeight
    radius: buttonRadius
    visible:buttonIsVisible

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
            font.pointSize: ScreenTools.scaleNum(10,true)
            font.family: ScreenTools.fontFamily
       
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
                x = globalPos.x + (control.width - width) / ScreenTools.scaleNum(2)
                y = globalPos.y - height - ScreenTools.scaleNum(4)
                if(y < control.height)
                    y =  globalPos.y + height
            }
        }
    }

    onIsEnableChanged: {
        //console.log("isCreate",isCreate)
        if(!isCreate)
            return;
        //console.log("isEnable", isEnable)
        color=isEnable?buttonColor:buttonDisableColor;
        text.color=isEnable?buttonTextColor:buttonDisableTextColor;
        border.color=isEnable?buttonBorderColor:buttonBorderDisableColor;
        leftImage.source=isEnable?leftImageImage:leftImageDisableImage
        rightImage.source=isEnable?rightImageNormalImage:rightImageDisableImage

    }

    RowLayout {
        anchors.fill: parent
        spacing: 0
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: isHCenter
            Layout.leftMargin: buttonLeftMargin
        }
        Item {
            Layout.alignment: Qt.AlignVCenter
            visible: isShowLeftImage
            width: isShowLeftImage ? (leftImageWidth + (imageAndTextSpanIsShow ? imageAndTextSpan : 0)) : 0
            height: isShowLeftImage ? leftImageHeight : 0
        
            Image {
                id: leftImage
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                source: leftImageImage
                width: leftImageWidth
                height: leftImageHeight
                visible: isShowLeftImage
                cache: true
                asynchronous: true
            }
        }

        Text {
            id: text
            font.pointSize: control.pointSize
            color: isEnable ? buttonTextColor : buttonDisableTextColor
            text: buttonText
            font.family: fontFamily
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            renderType: Text.NativeRendering  // 更好的渲染性能
        }
        Item {
            Layout.alignment: Qt.AlignVCenter
            visible: isShowRightImage
            width: isShowRightImage ? (rightImageTextSpan + rightImageWidth + rightImageToRightBorderSpan) : 0
            height: isShowRightImage ? rightImageHeight : 0
        
            Image {
                id: rightImage
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: rightImageNormalImage
                width: rightImageWidth
                height: rightImageHeight
                visible: isShowRightImage
                cache: true
                asynchronous: true
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    MouseArea{
        id:drawButtonMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            control.toolTipVisible = false
            if(!isEnable)
                return;
            if(delay.running)
                return;
            delay.running=true
            control.color = Qt.binding(function(){ return buttonPressedColor })
            text.color=buttonTextPressedColor;
            border.color=buttonBorderPressedColor;
            leftImage.source=leftImagePressedImage;
            rightImage.source=rightImagePressedImage;
            //务必最后发出信号， 否则触发LanSearchPage.qml中的onClicked（内部执行addDeviceToLanList后会重算isEnable）之后,onIsEnableChanged中的改色将会被立即覆盖掉
            control.clicked();
        }
        onEntered: {
            if(!isEnable)
                return;
            control.toolTipVisible = isShowTips ? true : false;
            control.color = Qt.binding(function(){ return buttonHoverColor })
            text.color= buttonTextHoverColor;
            border.color=buttonBorderHoverColor;
        }
        onExited: {
            if(!isEnable)
                return;
            control.toolTipVisible = false;
            control.color = Qt.binding(function(){ return buttonColor })
            text.color=buttonTextColor;
            border.color=buttonBorderColor;
        }
        onDoubleClicked: {
            if(!isEnable)
                return;
            control.doubleClicked();
        }
    }
    Timer{
        id:delay
        running: false
        interval: 300
        repeat: false
    }
    Component.onCompleted: {
        isCreate=true;
    }
    function refresh(){
        control.color=buttonColor;
        text.color=buttonTextColor;
        border.color=buttonBorderColor;
        leftImage.source=leftImageImage
        rightImage.source=rightImageNormalImage;
    }
}
