/*********************************************************************
File : CustomCalendar.qml
Module : Edit
Authors: guangnan
date : 2023/08/23 16:00
Ver : 1.0.0
History:
guangnan 2023/08/23 1.0.0 build this module
********************************************************************/
import QtQuick 2.0
import QtQuick.Controls 1.4
import ScreenTools 1.0
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import ConfigureManager 1.0
import FluentUI 1.0
import Component.Dialog 1.0
import Component.FluComponent 1.0
import Component.FluButton 1.0

Item {
    id:root
    signal timeSelected(string beginTime, string endTime)
    signal clickOk()
    signal close()
    signal selectData(var date);
    signal confirmData(string date2);
    property string currentSelectDate: ""
    property string selectDateItem: currentSelectDate
    // 边框以及鼠标悬浮点击颜色属性
    property color borderColor:  ThemeColorStyle.border_nor_color
    property int borderWidth: 0
    property color hoverBgColor: ThemeColorStyle.list_bg_hover_color
    property color selectedBgColor: ThemeColorStyle.data_bg_select_color
    property color normalBgColor: ThemeColorStyle.list_bg_nor_color
    property color normalColor:ThemeColorStyle.list_text_nor_color
    property color disableColor:ThemeColorStyle.list_text_disable_color
    property color hoverColor:ThemeColorStyle.list_text_hover_color
    property color selectColor:ThemeColorStyle.data_text_select_color

    property string beginTime:""
    property string endTime:""
    property int leftPadding: 24
    width: 308
    height: 356

    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    DropShadow {
        anchors.fill: background // 让阴影填充背景矩形
        source: background      // 阴影效果作用于背景矩形
        radius: 8               // 阴影的模糊半径
        samples: 16             // 阴影的质量，值越高越平滑
        color: ThemeColorStyle.border_nor_color      // 阴影颜色，80是透明度
        horizontalOffset: 3     // 水平偏移
        verticalOffset: 3       // 垂直偏移
    }
    
    // 创建一个可视的背景矩形，原来的根Rectangle的属性都移到这里
    Rectangle {
        anchors.fill: parent
        id: background
        radius: 2
        color: normalBgColor
        border.color: "#F0F2F5"   // 引用根元素的属性
        border.width: 1   // 引用根元素的属性
        clip: true  // 限制子组件显示范围

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 创建一个标题栏
            RowLayout {
                Layout.preferredWidth: parent.width - leftPadding * 2
                Layout.preferredHeight: 290
                spacing: 10

                

                ColumnLayout {
                    width: parent.width / 2
                    Layout.fillHeight: true

                    // 标题
                    Text {
                        text: qsTr("Start time")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        Layout.leftMargin: 24
                        font.family: ScreenTools.fontFamily
                        font.pointSize: 10
                        color: ThemeColorStyle.title_text_nor_color
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    FluCusTimePicker {
                        id: beginPicker
                        Layout.leftMargin: 24
                        onSelectData:{
                            beginTime = date1.toString();
                            if(!pickerTimer.running)
                                pickerTimer.start()
                        }

                        Connections {
                            target: root
                            function onClickOk() {
                                beginPicker.updateDate()
                            }
                        }
                    }
                }

                ColumnLayout {
                    width: parent.width / 2
                    Layout.fillHeight: true

                    // 标题
                    Text {
                        text: qsTr("End time")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        Layout.rightMargin: 24
                        font.family: ScreenTools.fontFamily
                        font.pointSize: 10
                        color: ThemeColorStyle.title_text_nor_color
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    FluCusTimePicker {
                        id: endPicker
                        Layout.rightMargin: 24
                        onSelectData:{
                            endTime = date1.toString();
                            if(!pickerTimer.running)
                                pickerTimer.start()
                        }

                        Connections {
                            target: root
                            function onClickOk() {
                                endPicker.updateDate()
                            }
                        }
                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#E7E7E7"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                FluCustomIconButton {
                    buttonWidth: 68
                    buttonHeight:28
                    pressedColor:hoverColor
                    normalColor:ThemeColorStyle.cancelBtn_bg_color
                    textNormalColor: ThemeColorStyle.cancelBtn_text_color
                    textDisableColor:textNormalColor
                    borderNormalColor : ThemeColorStyle.border_nor_color
                    text: qsTr("Cancel")
                    onClicked: {
                        root.close()
                    }
                }
                
                // 确定按钮
                FluCustomIconButton {
                    buttonWidth: 68
                    buttonHeight: 28
                    borderNormalColor : ThemeColorStyle.border_checked_color
                    text: qsTr("OK")
                    onClicked: {
                        root.clickOk()
                    }
                }

                Item{
                    Layout.fillHeight: true
                    width: 24
                }
            }
        }
    }

    Timer {
        id: pickerTimer
        interval:50
        repeat:false
        running: false
        onTriggered: {
            timeIsInvalid()
            running: false
            pickerTimer.stop()
        }
    }

    FluToastTip{
        id: tooltip
        maxWidth: parent.width - 24
        infoType: 2
    }

    function timeIsInvalid() { 
        if(beginTime >= endTime)
        {
            // 起始时间必须小于结束时间
            tooltip.showTips(qsTr("The end time must be later than the start time"))
            return
        }
        root.timeSelected(root.beginTime, root.endTime)
        root.close()
    }
}