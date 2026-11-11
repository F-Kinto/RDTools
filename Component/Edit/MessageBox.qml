/*********************************************************************
File : MessageBox.qml
Module : Edit
Authors: guangnan
date : 2023/08/01 16:00
Ver : 1.0.0
History:
guangnan 2023/08/01 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtQml 2.15
import Component.Login 1.0
import ScreenTools 1.0
import Component.Button 1.0
import VMS.Enum 1.0
import ConfigureManager 1.0
import InformationNotifier 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

ModalPage {
    id: dialog
    objectName: "messageBox"
    signal sendCmd(real cmd,var sender); //关闭： 1 取消: 1 确定： 2
    property int contentFontSize: ScreenTools.scaleNum(10, true)
    property int contentHeight: ScreenTools.scaleNum(10)
    property var contentHorizontalAlign: Text.AlignHCenter
    property bool sureButtonVisible: true
    property bool cancelButtonVisible: true
    property bool sureButtonEnabled: true
    property bool cancelButtonEnabled: true
    property string sureButtonText: qsTr("OK")
    property string cancelButtonText: qsTr("Cancel")
    property string showContent:qsTr("Error")
    property var notifierType:null;
    property string title: qsTr("Prompt")
    property int offsetMargin:1
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true


    width: ScreenTools.scaleNum(384)
    height: ScreenTools.scaleNum(216)
    windowTitleSize: ScreenTools.scaleNum(12, true)
    windowTitle:title
    titleBarBgColor: "#F1F1F2"
    closeBtnBgColor: "transparent"
    colseBtnHoverColor: "#EEEEEE"
    colseBtnPressedColor: "red"
    closeButtonUrl: CommonPngImageStyle.closeButtonUrl_img
    hoverButtonUrl: CommonPngImageStyle.hoverButtonUrl_img
    pressedButtonUrl: CommonPngImageStyle.pressedButtonUrl_img
    closeImgWidth: ScreenTools.scaleNum(24)
    closeImgHeight: ScreenTools.scaleNum(24)
    titleVisiable: true
    logoVisiable: false
    titleColor: "#0F0F0F"
    closeBtnVisiable:true
    rectRadius: 0
    modelMargin: offsetMargin

    Component {
        id: customContent

        Rectangle {
            anchors.fill: parent
            width: parent.width
            color: "#FFFFFF"
            radius:rectRadius
            ColumnLayout{
                anchors.fill: parent
                spacing: 0
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label {
                        id: contentLabel
                        objectName: "contentLabel"
                        text:showContent
                        font.pointSize: contentFontSize
                        color: "#010101"
                        width: parent.width-ScreenTools.scaleNum(100)
                        height: contentHeight
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family:ScreenTools.fontFamily
                        horizontalAlignment:contentHorizontalAlign
                        wrapMode:Text.WrapAnywhere
                        lineHeight: 1.4                         // 行高
                        lineHeightMode: Text.ProportionalHeight
                    }
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.scaleNum(50)
                    RowLayout{
                        anchors.fill: parent
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                        }

                        // 计算文本宽度，按钮宽度自适应
                        TextMetrics {
                            id: textMetrics
                            font.family: ScreenTools.fontFamily
                            font.pointSize:ScreenTools.scaleNum(10, true)
                            text: sureButtonText
                        }
                        TextMetrics {
                            id: texCanceltMetrics
                            font.family: ScreenTools.fontFamily
                            font.pointSize:ScreenTools.scaleNum(10, true)
                            text: cancelButtonText
                        }

                        DrawButton{
                            id:confirmedBtn
							objectName: "confirmedBtn"
                            buttonRadius: ScreenTools.scaleNum(4)
                            Layout.preferredWidth: Math.max(ScreenTools.scaleNum(64), textMetrics.width + ScreenTools.scaleNum(16))  // 宽度设置为 文本宽度 + 边距(6)  最小宽度为64
                            Layout.preferredHeight: ScreenTools.scaleNum(32)
                            Layout.alignment: Qt.AlignVCenter
                            buttonBorderWidth: 0
                            buttonDisableColor: ThemeColorStyle.button_disable_bg_color
                            isEnable:sureButtonEnabled
                            buttonBorderColor: ThemeColorStyle.border_checked_color
                            buttonColor:ThemeColorStyle.okBtn_bg_color;
                            buttonHoverColor: ThemeColorStyle.okBtn_bg_color
                            buttonPressedColor: ThemeColorStyle.okBtn_bg_color

                            buttonTextColor: ThemeColorStyle.okBtn_text_color
                            buttonTextHoverColor: ThemeColorStyle.okBtn_text_color
                            buttonTextPressedColor: ThemeColorStyle.okBtn_text_color
                            buttonDisableTextColor:ThemeColorStyle.text_disable_color
                            visible:notifierType?(notifierType==InformationNotifier.EgenerateType || notifierType==InformationNotifier.EokType):sureButtonVisible

                            buttonText: sureButtonText
                            pointSize: ScreenTools.scaleNum(10, true)
                            onClicked:{
                                sendCmd(2,dialog);
                                dialog.close();
                            }


                        }
                        Item {
                            Layout.preferredWidth: ScreenTools.scaleNum(40)
                            Layout.fillHeight: true
                            visible: cancelBtn.visible && confirmedBtn.visible
                        }
                        DrawButton{
                            id:cancelBtn
                            objectName: "cancelBtn"
                            buttonRadius: ScreenTools.scaleNum(4)
                            Layout.preferredWidth: Math.max(ScreenTools.scaleNum(64), texCanceltMetrics.width + ScreenTools.scaleNum(16))  // 宽度设置为 文本宽度 + 边距(6)
                            Layout.preferredHeight: ScreenTools.scaleNum(32)
                            Layout.alignment: Qt.AlignVCenter
                            buttonBorderWidth: 0
                            buttonDisableColor:ThemeColorStyle.button_disable_bg_color

                            buttonBorderColor: ThemeColorStyle.border_checked_color
                            buttonColor:ThemeColorStyle.cancelBtn_bg_color;
                            buttonHoverColor: ThemeColorStyle.cancelBtn_bg_color
                            buttonPressedColor: ThemeColorStyle.cancelBtn_bg_color
                            isEnable:cancelButtonEnabled
                            buttonTextColor: ThemeColorStyle.cancelBtn_text_color
                            buttonTextHoverColor: ThemeColorStyle.cancelBtn_text_color
                            buttonTextPressedColor: ThemeColorStyle.cancelBtn_text_color
                            buttonDisableTextColor: ThemeColorStyle.text_disable_color
                            visible:notifierType?(notifierType==InformationNotifier.EgenerateType || notifierType==InformationNotifier.EcancelType):cancelButtonVisible

                            buttonText: cancelButtonText
                            pointSize: ScreenTools.scaleNum(10, true)
                            onClicked:{
                                sendCmd(1,dialog);
                                dialog.close();
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.scaleNum(6)
                }
            }

        }
    }

    onCloseButtonClicked: {
        sendCmd(1,dialog);
        dialog.close();
    }

    function calculateTextHeight(){
        Qt.callLater(function() {
            contentHeight = ScreenTools.calculateMultiLineHeight(showContent,ScreenTools.scaleNum(10, true),width-ScreenTools.scaleNum(100))
            height = Math.max(contentHeight + ScreenTools.scaleNum(90), ScreenTools.scaleNum(216))
        })
    }

    onVisibleChanged: {
        if(visible){
            calculateTextHeight()
        }
    }
}
