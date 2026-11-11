/*********************************************************************
File : ReNameDialog.qml
Module : ReNameDialog
Authors: guangnan
date : 2023/07/17 16:00
Ver : 1.0.0
History:
guangnan 2023/07/17 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.2
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import Component.Edit 1.0
import Component.Button 1.0
import Component.Login 1.0
import Component.FluButton 1.0
import Component.FluComponent 1.0
import VMS.Enum 1.0
import ConfigureManager 1.0
import InformationNotifier 1.0
import QtQuick.Window 2.15
import FluentUI 1.0

FluPopup {
    id: control
    // 弹窗标题
    property string title: ""
    property bool titleBarVisible: true
    // 弹窗内容
    property string message: ""
    // 弹窗按钮
    property string neutralText: qsTr("Close")
    property string negativeText: qsTr("Cancel")
    property string positiveText: qsTr("OK")
    property color positiveColor: ThemeColorStyle.privacy_text_color
    // 弹窗按钮宽度
    property int positiveWidth: ScreenTools.scaleNum(120)
    property int neutralWidth: positiveWidth
    property int negativeWidth: positiveWidth
    // 弹窗标题栏背景颜色
    property color titleBgColor: "#EDEFF2"
    // 弹窗按钮背景颜色
    property color buttonRectBgColor: "#FFFFFF"
    property int messageTextFormart: Text.AutoText
    property int delayTime: 100
    // 显示两个按钮  false显示一个按钮
    property bool showTwoButton: true        
    // 对齐方式  Text.AlignLeft    Text.AlignRight  Text.AlignHCenter
    property int alignmentValue: Qt.AlignHCenter
    // 按钮布局是否居中对齐 
    property bool buttonLayoutCenter: true
    //关闭按钮是否可见 
    property bool closeBtnVisiable: true     
    // 底部 OK 取消 按键布局是否可见
    property bool buttonLayoutVisiable: true   
    // 字体大小
    property int fontSize: ScreenTools.scaleNum(10, true)       
    // 内容是否自定义contentDelegate, 自定义则隐藏comMessage控件
    property bool customIsContent: false     
    //文本旁边的图片 图片+文本
    property string messageImgUrl: ""
    // 左右边距
    property int leftRightMargin: ScreenTools.scaleNum(24)
    property int bottomToMargin: ScreenTools.scaleNum(16)
    property bool remindAgain: false //二次确认

    property var contentDelegate:  Component{
        Item{
        }
    }

    property Component imgComponent: ScreenTools.imageIsSvgSource(messageImgUrl) ? icon_messageComponentSvg : icon_messageComponent
    property var onNeutralClickListener
    property var onNegativeClickListener
    property var onPositiveClickListener
    //关闭按钮图片
    signal neutralClicked
    signal negativeClicked
    signal positiveClicked
    implicitWidth: ScreenTools.scaleNum(500)
    implicitHeight: Math.max(ScreenTools.scaleNum(240), layout_content.implicitHeight)
    focus: true
    Component{
        id:com_message
        Flickable{
            id:sroll_message
            contentHeight: text_message.height
            contentWidth: width
            clip: true
            boundsBehavior:Flickable.StopAtBounds
            width: parent.width
            height: message === "" ? 0 : Math.min(text_message.height,ScreenTools.scaleNum(300))
            ScrollBar.vertical: FluScrollBar {}
            RowLayout{
                id: layout_message
                anchors.fill: parent
                anchors.leftMargin: leftRightMargin
                anchors.rightMargin: leftRightMargin
                anchors.topMargin: ScreenTools.scaleNum(4)
                anchors.bottomMargin: ScreenTools.scaleNum(4)
                spacing: ScreenTools.scaleNum(8)
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }               
                Loader {
                    id: icon_message
                    sourceComponent: !!messageImgUrl ? imgComponent : null
                }
                FluText{
                    id:text_message
					objectName: "p_text_message"
                    font.family: ScreenTools.fontFamily
                    font.pointSize: control.fontSize
                    text:message
                    Layout.maximumWidth: parent.width - icon_message.width - layout_message.spacing
                    // 设置文本最小高度  窗口高度 - 下边距 - 标题栏高度 - 间距 - 按钮高度
                    Layout.minimumHeight:Math.max(control.height - bottomToMargin * 2 - ScreenTools.scaleNum(42) - (control.buttonLayoutVisiable ? ScreenTools.scaleNum(36) : 0), ScreenTools.scaleNum(60))
                    wrapMode:Text.WrapAnywhere
                    lineHeight: 1.4
                    lineHeightMode: Text.ProportionalHeight
                    horizontalAlignment: alignmentValue
                    verticalAlignment: Text.AlignVCenter
                    Layout.alignment: Qt.AlignVCenter
                }

                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }
    Rectangle {
        id:layout_content
        width: parent.width
        height: layout_column.childrenRect.height
        color: '#FFFFFF'
        radius:ScreenTools.scaleNum(4)
        ColumnLayout{
            id:layout_column
            width: parent.width

            Rectangle{
                id:titleRect
                Layout.fillWidth: true
                Layout.preferredHeight:ScreenTools.scaleNum(42)
                color: titleBgColor
                visible: titleBarVisible
                radius: ScreenTools.scaleNum(4)
                RowLayout{
                    anchors.fill: parent
                    spacing: ScreenTools.scaleNum(6)
                    Item {
                        Layout.fillHeight: true
                        width:ScreenTools.scaleNum(16)
                    }
                    Label{
                        objectName: "p_titleLabel"
                        Layout.alignment:Qt.AlignVCenter
                        font.pointSize: ScreenTools.scaleNum(12, true)
                        text: title
                        color:ThemeColorStyle.title_text_nor_color
                        font.family: ScreenTools.fontFamily
                        elide: Text.ElideRight
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                    FluCustomIconButton {
                        id: closeBtn
                        objectName: "p_closeBtn"
                        display: Button.IconOnly
                        buttonWidth: ScreenTools.scaleNum(32)
                        buttonHeight: ScreenTools.scaleNum(32)
                        iconSize: ScreenTools.scaleNum(24)
                        sourceImgUrl: CommonImageStyle.close_img
                        buttonFillColor: closeBtn.isHovered ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.text_nor_color
                        Layout.alignment:Qt.AlignVCenter
                        showHoverTip: true
                        hoverTipText: qsTr("Close")
                        visible:closeBtnVisiable
                        iconOnlyNeedHoverBg: true
                        onClicked: {
                            negativeClicked()
                            control.close()
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        width:ScreenTools.scaleNum(6)
                    }
                }
            }
            FluLoader{
                sourceComponent: com_message
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: ScreenTools.scaleNum(8)
                Layout.preferredHeight: status===Loader.Ready ? item.height : 0
                visible: !customIsContent
            }
            Item{
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            FluLoader{
                sourceComponent:control.visible ? control.contentDelegate : undefined
                Layout.fillWidth: true
                onStatusChanged: {
                    if(status===Loader.Ready){
                        Layout.preferredHeight = item.implicitHeight
                    }else{
                        Layout.preferredHeight = 0
                    }
                }
            }
            Rectangle{
                id:layout_actions
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.scaleNum(36)
                radius: ScreenTools.scaleNum(4)
                color: buttonRectBgColor
                visible: buttonLayoutVisiable
                anchors.leftMargin: leftRightMargin
                anchors.rightMargin: leftRightMargin
                RowLayout{
                    anchors.fill: parent
                    spacing: ScreenTools.scaleNum(12)
                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    FluCustomIconButton {
                        id: closeButton
						objectName: "p_closeButton"
                        buttonWidth: Math.max(ScreenTools.calculateTextWidth(closeButton.text) + ScreenTools.scaleNum(14), neutralWidth)
                        buttonHeight: ScreenTools.scaleNum(36)
                        borderRadius: ScreenTools.scaleNum(4)
                        textNormalColor: ThemeColorStyle.okBtn_text_color
                        normalColor: ThemeColorStyle.okBtn_bg_color
                        borderWidth : 0
                        text: neutralText
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        visible:!showTwoButton
                        onClicked: {
                            if(control.onNeutralClickListener){
                                control.onNeutralClickListener()
                            }else{
                                neutralClicked()
                                control.close()
                            }
                        }
                    }

                    FluCustomIconButton {
                        id: cancelBtn
                        objectName: "p_cancelBtn"
                        Layout.alignment: Qt.AlignRight
                        buttonWidth: okBtn.buttonWidth
                        buttonHeight:ScreenTools.scaleNum(36)
                        borderRadius: ScreenTools.scaleNum(4)
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        textNormalColor: ThemeColorStyle.cancelBtn_text_color
                        borderNormalColor: ThemeColorStyle.border_nor_color
                        normalColor: ThemeColorStyle.cancelBtn_bg_color
                        borderWidth : 1
                        visible: showTwoButton
                        text: negativeText
                        onClicked: {
                            negativeClicked()
                            control.close()
                        }
                    }
                    
                    // 确定按钮
                    FluCustomIconButton {
                        id: okBtn
						objectName: "p_okBtn"
                        buttonWidth: Math.max(ScreenTools.calculateMultiTextWidth(cancelBtn.text, okBtn.text) + ScreenTools.scaleNum(14),positiveWidth)
                        Layout.rightMargin: buttonLayoutCenter ? 0 : ScreenTools.scaleNum(16)
                        buttonHeight: ScreenTools.scaleNum(36)
                        borderRadius: ScreenTools.scaleNum(4)
                        textNormalColor: ThemeColorStyle.okBtn_text_color
                        normalColor: positiveColor
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        borderWidth : 0
                        text: positiveText
                        visible:showTwoButton
                        onClicked:{
                            if(!control.remindAgain)
                                control.close()
                            // 延迟到 Popup 关闭后再发出 positiveClicked 信号。
                            // 若先发信号再 close()，信号处理函数中激活 Loader / 切页面等操作
                            // 会访问即将被 close() 销毁的 Overlay 对象树，触发
                            // qqmlengine_p.h ASSERT: "e" 断言崩溃。
                            Qt.callLater(function(){
                                positiveClicked()
                            })
                        }
                    }
                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: !showTwoButton || buttonLayoutCenter
                    }
                }
            }

            Item{
                Layout.fillWidth: true
                Layout.preferredHeight: bottomToMargin
            }
        }
    }

    Component{
        id:icon_messageComponent
        FluCustomImageLoader{
            id: icon_message
            imageWidth: ScreenTools.scaleNum(24)
            imageHeight: ScreenTools.scaleNum(24)
            normalImageUrl: messageImgUrl
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Component {
        id: icon_messageComponentSvg

        FluCustomSvg{
            id:svgImage
            imageWidth: ScreenTools.scaleNum(24)
            imageHeight: ScreenTools.scaleNum(24)
            sourceImage: messageImgUrl
            fillColorFirst: positiveColor
        }
    }
}