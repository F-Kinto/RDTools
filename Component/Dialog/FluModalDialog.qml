/*********************************************************************
File : ModalPage.qml
Module : Login
Authors: guangnan
date : 2023/07/14 16:00
Ver : 1.0.0
History:
guangnan 2023/07/14 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import Component.Button 1.0
import Component.FluButton 1.0
import ScreenTools 1.0
import ConfigureManager 1.0
import FluentUI 1.0

Window {
    id: dialog
    signal sigClicked(int data);       // data: 1: close   2: OK
    property string windowTitle: qsTr("Prompt")
    /***********标题部分控件属性********/ 
    property bool titleBarIsVisiable: true                                      //标题栏是否可见
    property color titleBarBgColor: "#EDEFF2"                                 //标题栏背景颜色
    property bool logoVisiable: false                                           //logo是否可见    
    property url logoUrl: ConfigureManager.getProgramLogoUrl()                  //logo图片
    property bool closeBtnVisiable: true                                        //关闭按钮是否可见  
    property color titleColor: ThemeColorStyle.title_text_nor_color             //标题文本颜色
    property int windowTitleSize: ScreenTools.scaleNum(12, true)                //标题文本状态大小
    property bool isBackGroundVisible: true                                     //背景是否可见
    property int titleHeight: ScreenTools.scaleNum(48)                                               //标题栏高度
    property int rectRadius: ScreenTools.isWin7System ? 0 : ScreenTools.scaleNum(12)                  //圆角，Win7下禁用圆角以避免黑角问题
    property bool cancelBtnVisible: true                                        //取消按键是否可见
    property bool lineVisible: false                                            //分割线是否可见
    property string cancelBtnText: qsTr("Cancel")                               //取消按键文字
    property string okBtnText: qsTr("OK")                                       //确定按键文字
    property bool buttonLayoutCenter: true                                      //按钮布局是否居中对齐 
    property bool buttonLayoutVisiable: true                                    //底部 OK 取消 按键布局是否可见
    property bool winBorderWidth: ScreenTools.isWin7System ? 1 : 0              //边框宽度，win7系统需要1像素的边框来显示阴影
    /***********标题部分控件属性End********/ 


    /************************拖拽部分属性*******************/
    property bool dragEnabled: false                                                            //是否允许拖拽
    property bool resizeEnabled: dragEnabled && dialog.visibility !== Window.FullScreen        //是否允许调整大小
    property int resizeMargin: ScreenTools.scaleNum(5)                                                                //拖拽区域
    property bool isResizing: false                                                             //是否正在调整大小
    property bool fullScreenEnabled: dragEnabled                                                //是否允许双击放大
    /************************拖拽部分属性*******************/

    // 镜像属性
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    /************************窗口本身属性*******************/
    property int minWidthLimit: ScreenTools.scaleNum(220)
    property int minHeightLimit: ScreenTools.scaleNum(170)
    minimumWidth: minWidthLimit
    minimumHeight: minHeightLimit
    flags: Qt.SubWindow | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.WindowMinMaxButtonsHint
    modality: Qt.ApplicationModal
    color: ScreenTools.isWin7System ? '#FFFFFF' : "transparent" // Windows 7 系统不支持透明窗口，使用纯白背景
    visible: true
    /************************窗口本身属性*******************/

    Timer {
        id: resizeEndTimer
        interval: 120
        repeat: false
        onTriggered: dialog.isResizing = false
    }

    Rectangle{
        id:backGround
        anchors.margins: ScreenTools.isWin7System ? 0 : ScreenTools.scaleNum(4)  //预留边框虚影
        anchors.fill: parent
        visible: isBackGroundVisible
        color: "#FFFFFF"
        border.color: "#EDEFF2"
        border.width: winBorderWidth
        radius: rectRadius
        FluShadow{
            radius: rectRadius
            color: "#000000"
            visible: !ScreenTools.isWin7System
        }

        Rectangle {
            id: outerRect
            anchors {
                fill: parent
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                bottomMargin: winBorderWidth
            }
            radius:rectRadius
            color: "#FFFFFF"
            border.color: "#EDEFF2"
            border.width: winBorderWidth
            clip: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: outerRect.width
                    height: outerRect.height
                    radius: rectRadius
                    visible: !ScreenTools.isWin7System
                }
            }

            ColumnLayout{
                anchors.fill: parent
                anchors.margins: winBorderWidth
                spacing: 0
                Rectangle{
                    id:titleRect
                    Layout.fillWidth: true
                    Layout.preferredHeight:titleHeight
                    color: titleBarBgColor
                    visible: titleBarIsVisiable
                    radius:rectRadius
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.radius
                        color: parent.color
                    }
                    MouseArea{
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        property point clickPos: "0, 0"
                        property bool pressed: false
                        propagateComposedEvents:true
                        onPressed: {
                            if(mouse.button == Qt.LeftButton && !dialog.isResizing){
                                clickPos = Qt.point(mouseX, mouseY);
                                pressed=true;
                            }
                        }
                        onPositionChanged: {
                            if(pressed){
                                var mousePos = Qt.point(mouseX-clickPos.x, mouseY-clickPos.y);
                                dialog.setX(dialog.x+mousePos.x);
                                dialog.setY(dialog.y+mousePos.y);
                            }
                        }
                        onReleased: {
                            pressed=false;
                        }
                        onDoubleClicked: {
                            if(!fullScreenEnabled) return
                            dialog.visibility === Window.Maximized ? dialog.showNormal() : dialog.showMaximized()
                        }
                        RowLayout{
                            anchors.fill: parent
                            //Layout.alignment:Qt.AlignVCenter
                            spacing: ScreenTools.scaleNum(6)
                            Item {
                                Layout.fillHeight: true
                                width:ScreenTools.scaleNum(10)
                            }
                            FluCustomIconButton {
                                id: windowLogo
                                display: Button.IconOnly
                                buttonWidth: ScreenTools.scaleNum(24)
                                buttonHeight: ScreenTools.scaleNum(24)
                                sourceImgUrl: logoUrl
                                Layout.alignment:Qt.AlignVCenter
                                visible:logoVisiable
                            }

                            Label{
                                id:windowTitleObj
                                objectName: "windowTitleObj"
                                Layout.alignment:Qt.AlignVCenter
                                font.pointSize:windowTitleSize
                                text: windowTitle
                                color:titleColor
                                font.family: ScreenTools.fontFamily
                                elide: Text.ElideRight
                            }
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                            }

                            FluCustomIconButton {
                                id: closeBtn
                                objectName: "closeBtn"
                                display: Button.IconOnly
                                buttonWidth: ScreenTools.scaleNum(32)
                                buttonHeight: ScreenTools.scaleNum(32)
                                iconSize: ScreenTools.scaleNum(24)
                                showHoverTip: true
                                text: qsTr("Close")
                                iconOnlyNeedHoverBg: true
                                sourceImgUrl: CommonImageStyle.close_img
                                buttonFillColor: closeBtn.isHovered ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.text_nor_color
                                Layout.alignment:Qt.AlignVCenter
                                visible:closeBtnVisiable
                                onClicked: {
                                    dialog.sigClicked(1);
                                }
                            }
                            Item {
                                Layout.fillHeight: true
                                width:ScreenTools.scaleNum(6)
                            }
                        }
                    }
                }

                Loader {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    sourceComponent: customContent
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#F0F2F5"
                    visible: lineVisible
                }

                RowLayout {
                    Layout.maximumHeight: ScreenTools.scaleNum(46)
                    spacing: ScreenTools.scaleNum(16)
                    Layout.topMargin: ScreenTools.scaleNum(12)
                    visible: buttonLayoutVisiable
                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    FluCustomIconButton {
                        id: cancelBtn
                        objectName: "cancelBtn"
                        Layout.alignment: Qt.AlignRight
                        buttonWidth: okBtn.buttonWidth
                        buttonHeight:ScreenTools.scaleNum(34)
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        textNormalColor: ThemeColorStyle.privacy_text_color
                        textBtnHoverColor: ThemeColorStyle.privacy_text_color
                        hoverColor: ThemeColorStyle.button_hover_bg_color
                        borderNormalColor: ThemeColorStyle.border_checked_color
                        borderWidth : 1
                        visible: cancelBtnVisible
                        text: cancelBtnText
                        onClicked: {
                            dialog.sigClicked(1);
                        }
                    }
                    
                    // 确定按钮
                    FluCustomIconButton {
                        id: okBtn
						objectName: "okBtn"
                        buttonWidth: Math.max(ScreenTools.calculateMultiTextWidth(cancelBtn.text, okBtn.text) + ScreenTools.scaleNum(14),ScreenTools.scaleNum(120))
                        Layout.rightMargin: buttonLayoutCenter ? 0 : ScreenTools.scaleNum(16)
                        buttonHeight: ScreenTools.scaleNum(34)
                        textNormalColor: ThemeColorStyle.privacy_text_color
                        textBtnHoverColor: ThemeColorStyle.privacy_text_color
                        textBtnPressedColor: "#FFFFFF"
                        hoverColor: ThemeColorStyle.button_hover_bg_color
                        pressedColor: ThemeColorStyle.privacy_text_color
                        isCheckedColor: pressedColor
                        isChecked: true
                        borderNormalColor: ThemeColorStyle.border_checked_color
                        borderWidth : 1
                        text: okBtnText
                        onClicked:{
                            dialog.sigClicked(2);
                        }
                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: buttonLayoutCenter
                    }
                }

                Item{
                    Layout.fillWidth: true
                    Layout.preferredHeight: buttonLayoutVisiable ? ScreenTools.scaleNum(16) : 0
                    visible: buttonLayoutVisiable
                }
            }
        }


    }

    // Replace the original edge dragging implementation with system scaling and smooth back logic.
    Item {
        anchors.fill: parent

        // Left edge
        MouseArea {
            enabled: resizeEnabled
            visible: resizeEnabled
            width: resizeMargin
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                topMargin: resizeMargin
                bottomMargin: resizeMargin
            }
            cursorShape: Qt.SizeHorCursor

            // Temporary variables required for rollback
            property bool manual: false
            property real pressX: 0
            property real startW: 0
            property real startX: 0

            onPressed: {
                if (!resizeEnabled) return
                resizeEndTimer.stop()
                dialog.isResizing = true
                manual = !dialog.startSystemResize(Qt.LeftEdge)
                pressX = mouse.x
                startW = dialog.width
                startX = dialog.x
            }
            onPositionChanged: if (pressed && manual && resizeEnabled) {
                var dx = mouse.x - pressX
                if (ConfigureManager.isRTLLayout) {
                    var w = Math.max(minWidthLimit, startW + dx)
                    if (w !== dialog.width) dialog.width = w
                } else {
                    var w2 = startW - dx
                    if (w2 < minWidthLimit) {
                        dx = startW - minWidthLimit
                        w2 = minWidthLimit
                    }
                    if (w2 !== dialog.width) dialog.width = w2
                    var nx = startX + dx
                    if (nx !== dialog.x) dialog.x = nx
                }
            }
            onReleased: { manual = false; if (resizeEnabled) resizeEndTimer.restart() }
        }

        // Right edge
        MouseArea {
            enabled: resizeEnabled
            visible: resizeEnabled
            width: resizeMargin
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                topMargin: resizeMargin
                bottomMargin: resizeMargin
            }
            cursorShape: Qt.SizeHorCursor

            property bool manual: false
            property real pressX: 0
            property real startW: 0
            property real startX: 0

            onPressed: {
                if (!resizeEnabled) return
                resizeEndTimer.stop()
                dialog.isResizing = true
                manual = !dialog.startSystemResize(Qt.RightEdge)
                pressX = mouse.x
                startW = dialog.width
                startX = dialog.x
            }
            onPositionChanged: if (pressed && manual && resizeEnabled) {
                var dx = mouse.x - pressX
                if (ConfigureManager.isRTLLayout) {
                    var w = startW - dx
                    if (w < minWidthLimit) {
                        dx = startW - minWidthLimit
                        w = minWidthLimit
                    }
                    if (w !== dialog.width) dialog.width = w
                    var nx = startX + dx
                    if (nx !== dialog.x) dialog.x = nx
                } else {
                    var w2 = Math.max(minWidthLimit, startW + dx)
                    if (w2 !== dialog.width) dialog.width = w2
                }
            }
            onReleased: { manual = false; if (resizeEnabled) resizeEndTimer.restart() }
        }

        // Top edge
        MouseArea {
            enabled: resizeEnabled
            visible: resizeEnabled
            height: resizeMargin
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: resizeMargin
                rightMargin: resizeMargin
            }
            cursorShape: Qt.SizeVerCursor

            property bool manual: false
            property real pressY: 0
            property real startH: 0
            property real startY: 0

            onPressed: {
                if (!resizeEnabled) return
                resizeEndTimer.stop()
                dialog.isResizing = true
                manual = !dialog.startSystemResize(Qt.TopEdge)
                pressY = mouse.y
                startH = dialog.height
                startY = dialog.y
            }
            onPositionChanged: if (pressed && manual && resizeEnabled) {
                var dy = mouse.y - pressY
                var h = startH - dy
                if (h < minHeightLimit) {
                    dy = startH - minHeightLimit
                    h = minHeightLimit
                }
                if (h !== dialog.height) dialog.height = h
                var ny = startY + dy
                if (ny !== dialog.y) dialog.y = ny
            }
            onReleased: { manual = false; if (resizeEnabled) resizeEndTimer.restart() }
        }

        // Bottom edge
        MouseArea {
            enabled: resizeEnabled
            visible: resizeEnabled
            height: resizeMargin
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: resizeMargin
                rightMargin: resizeMargin
            }
            cursorShape: Qt.SizeVerCursor

            property bool manual: false
            property real pressY: 0
            property real startH: 0

            onPressed: {
                if (!resizeEnabled) return
                resizeEndTimer.stop()
                dialog.isResizing = true
                manual = !dialog.startSystemResize(Qt.BottomEdge)
                pressY = mouse.y
                startH = dialog.height
            }
            onPositionChanged: if (pressed && manual && resizeEnabled) {
                var dy = mouse.y - pressY
                var h = Math.max(minHeightLimit, startH + dy)
                if (h !== dialog.height) dialog.height = h
            }
            onReleased: { manual = false; if (resizeEnabled) resizeEndTimer.restart() }
        }

        // Bottom right corner
        MouseArea {
            enabled: resizeEnabled
            visible: resizeEnabled
            width: resizeMargin * 2
            height: resizeMargin * 2
            anchors { right: parent.right; bottom: parent.bottom }
            cursorShape: Qt.SizeFDiagCursor

            property bool manual: false
            property real pressX: 0
            property real pressY: 0
            property real startW: 0
            property real startH: 0
            property real startX: 0

            onPressed: {
                if (!resizeEnabled) return
                resizeEndTimer.stop()
                dialog.isResizing = true
                manual = !dialog.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
                pressX = mouse.x
                pressY = mouse.y
                startW = dialog.width
                startH = dialog.height
                startX = dialog.x
            }
            onPositionChanged: if (pressed && manual && resizeEnabled) {
                var dx = mouse.x - pressX
                var dy = mouse.y - pressY
                if (ConfigureManager.isRTLLayout) {
                    var w = startW - dx
                    if (w < minWidthLimit) {
                        dx = startW - minWidthLimit
                        w = minWidthLimit
                    }
                    if (w !== dialog.width) dialog.width = w
                    var nx = startX + dx
                    if (nx !== dialog.x) dialog.x = nx
                } else {
                    var w2 = Math.max(minWidthLimit, startW + dx)
                    if (w2 !== dialog.width) dialog.width = w2
                }
                var h = Math.max(minHeightLimit, startH + dy)
                if (h !== dialog.height) dialog.height = h
            }
            onReleased: { manual = false; if (resizeEnabled) resizeEndTimer.restart() }
        }

        // Bottom left corner
        MouseArea {
            enabled: resizeEnabled
            visible: resizeEnabled
            width: resizeMargin * 2
            height: resizeMargin * 2
            anchors { left: parent.left; bottom: parent.bottom }
            cursorShape: Qt.SizeBDiagCursor

            property bool manual: false
            property real pressX: 0
            property real pressY: 0
            property real startW: 0
            property real startH: 0
            property real startX: 0

            onPressed: {
                if (!resizeEnabled) return
                resizeEndTimer.stop()
                dialog.isResizing = true
                manual = !dialog.startSystemResize(Qt.LeftEdge | Qt.BottomEdge)
                pressX = mouse.x
                pressY = mouse.y
                startW = dialog.width
                startH = dialog.height
                startX = dialog.x
            }
            onPositionChanged: if (pressed && manual && resizeEnabled) {
                var dx = mouse.x - pressX
                var dy = mouse.y - pressY
                if (ConfigureManager.isRTLLayout) {
                    var w = Math.max(minWidthLimit, startW + dx)
                    if (w !== dialog.width) dialog.width = w
                } else {
                    var w2 = startW - dx
                    if (w2 < minWidthLimit) {
                        dx = startW - minWidthLimit
                        w2 = minWidthLimit
                    }
                    if (w2 !== dialog.width) dialog.width = w2
                    var nx = startX + dx
                    if (nx !== dialog.x) dialog.x = nx
                }
                var h = Math.max(minHeightLimit, startH + dy)
                if (h !== dialog.height) dialog.height = h
            }
            onReleased: { manual = false; if (resizeEnabled) resizeEndTimer.restart() }
        }

        // Top right corner
        MouseArea {
            enabled: resizeEnabled
            visible: resizeEnabled
            width: resizeMargin * 2
            height: resizeMargin * 2
            anchors { right: parent.right; top: parent.top }
            cursorShape: Qt.SizeBDiagCursor

            property bool manual: false
            property real pressX: 0
            property real pressY: 0
            property real startW: 0
            property real startH: 0
            property real startX: 0
            property real startY: 0

            onPressed: {
                if (!resizeEnabled) return
                resizeEndTimer.stop()
                dialog.isResizing = true
                manual = !dialog.startSystemResize(Qt.RightEdge | Qt.TopEdge)
                pressX = mouse.x
                pressY = mouse.y
                startW = dialog.width
                startH = dialog.height
                startX = dialog.x
                startY = dialog.y
            }
            onPositionChanged: if (pressed && manual && resizeEnabled) {
                var dx = mouse.x - pressX
                var dy = mouse.y - pressY
                if (ConfigureManager.isRTLLayout) {
                    var w = startW - dx
                    if (w < minWidthLimit) {
                        dx = startW - minWidthLimit
                        w = minWidthLimit
                    }
                    if (w !== dialog.width) dialog.width = w
                    var nx = startX + dx
                    if (nx !== dialog.x) dialog.x = nx
                } else {
                    var w2 = Math.max(minWidthLimit, startW + dx)
                    if (w2 !== dialog.width) dialog.width = w2
                }
                var h = startH - dy
                if (h < minHeightLimit) {
                    dy = startH - minHeightLimit
                    h = minHeightLimit
                }
                if (h !== dialog.height) dialog.height = h
                var ny = startY + dy
                if (ny !== dialog.y) dialog.y = ny
            }
            onReleased: { manual = false; if (resizeEnabled) resizeEndTimer.restart() }
        }

        // Top left corner
        MouseArea {
            enabled: resizeEnabled
            visible: resizeEnabled
            width: resizeMargin * 2
            height: resizeMargin * 2
            anchors { left: parent.left; top: parent.top }
            cursorShape: Qt.SizeFDiagCursor

            property bool manual: false
            property real pressX: 0
            property real pressY: 0
            property real startW: 0
            property real startH: 0
            property real startX: 0
            property real startY: 0

            onPressed: {
                if (!resizeEnabled) return
                resizeEndTimer.stop()
                dialog.isResizing = true
                manual = !dialog.startSystemResize(Qt.LeftEdge | Qt.TopEdge)
                pressX = mouse.x
                pressY = mouse.y
                startW = dialog.width
                startH = dialog.height
                startX = dialog.x
                startY = dialog.y
            }
            onPositionChanged: if (pressed && manual && resizeEnabled) {
                var dx = mouse.x - pressX
                var dy = mouse.y - pressY
                if (ConfigureManager.isRTLLayout) {
                    var w = Math.max(minWidthLimit, startW + dx)
                    if (w !== dialog.width) dialog.width = w
                } else {
                    var w2 = startW - dx
                    if (w2 < minWidthLimit) {
                        dx = startW - minWidthLimit
                        w2 = minWidthLimit
                    }
                    if (w2 !== dialog.width) dialog.width = w2
                    var nx = startX + dx
                    if (nx !== dialog.x) dialog.x = nx
                }
                var h = startH - dy
                if (h < minHeightLimit) {
                    dy = startH - minHeightLimit
                    h = minHeightLimit
                }
                if (h !== dialog.height) dialog.height = h
                var ny = startY + dy
                if (ny !== dialog.y) dialog.y = ny
            }
            onReleased: { manual = false; if (resizeEnabled) resizeEndTimer.restart() }
        }
    }

    onWidthChanged: {
        if (dialog.isResizing) return
    }
}
