import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0

/**
 * 时间选择器弹窗 - 四列独立滑动，固定选中背景
 */
Popup {
    id: root
    
    // 属性
    property int startHour: 0
    property int startMinute: 0
    property int endHour: 23
    property int endMinute: 59
    
    // 信号
    signal timeSelected(int startHour, int startMinute, int endHour, int endMinute)
    signal canceled()
    
    width: ScreenTools.scaleNum(339)
    height: ScreenTools.scaleNum(311)
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    background: Rectangle {
        color: "white"
        radius: ScreenTools.scaleNum(8)
        border.width: 1
        border.color: "#e0e0e0"
    }

    function resetTime(){
        startHour = 0
        startMinute = 0
        endHour = 23
        endMinute = 59
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: ScreenTools.scaleNum(8)
        anchors.rightMargin: ScreenTools.scaleNum(8)
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        spacing: 0
        
        // ========== 标题行 ==========
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight:ScreenTools.scaleNum(20)
            spacing: 0
            
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Start time")
                    font.pointSize: ScreenTools.scaleNum(12,true)
                    font.family: ScreenTools.fontFamily
                    color: ThemeColorStyle.title_text_nor_color
                }
            }
            
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                Text {
                    anchors.centerIn: parent
                    text: qsTr("End time")
                    font.pointSize: ScreenTools.scaleNum(12,true)
                    font.family: ScreenTools.fontFamily
                    color: ThemeColorStyle.title_text_nor_color
                }
            }
        }

        Item{
            height: ScreenTools.scaleNum(12)
        }
        
        // ========== 选择器区域 ==========
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.scaleNum(195)
            spacing: ScreenTools.scaleNum(8)
            
            // ===== 开始时间区域 =====
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.width: 1
                border.color: ThemeColorStyle.border_nor_color
                radius: ScreenTools.scaleNum(4)
                
                // 固定选中背景（小时+冒号+分钟）
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 0
                    // x: 8
                    width: parent.width //- 16
                    height: ScreenTools.scaleNum(36)
                    color: ThemeColorStyle.privacy_text_color
                    opacity: 0.1
                    // radius: 4
                }
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    // 小时
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ListView {
                            id: startHourList
                            anchors.fill: parent
                            clip: true
                            model: 24
                            highlightMoveDuration: 200
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            preferredHighlightBegin: height / ScreenTools.scaleNum(2 - 18)
                            preferredHighlightEnd: height / ScreenTools.scaleNum(2 + 18)
                            currentIndex: root.startHour
                            
                            delegate: Item {
                                width: ListView.view.width
                                height: ScreenTools.scaleNum(36)
                                property bool isCurrent: ListView.isCurrentItem
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData < 10 ? "0" + modelData : modelData
                                    font.pointSize: ScreenTools.scaleNum(10,true)
                                    font.family: ScreenTools.fontFamily
                                    color: parent.isCurrent ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.tab_text_nor_color
                                    font.weight: parent.isCurrent ? Font.Medium : Font.Normal
                                }
                            }
                            
                            onCurrentIndexChanged: {
                                root.startHour = currentIndex
                            }
                        }
                    }
                    
                    // 冒号
                    Item {
                        Layout.preferredWidth: ScreenTools.scaleNum(20)
                        Layout.fillHeight: true
                        
                        Text {
                            anchors.centerIn: parent
                            text: ":"
                            font.pointSize: ScreenTools.scaleNum(10,true)
                            color: ThemeColorStyle.privacy_text_color
                            font.bold: true
                        }
                    }
                    
                    // 分钟
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ListView {
                            id: startMinuteList
                            anchors.fill: parent
                            clip: true
                            model: 60
                            highlightMoveDuration: 200
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            preferredHighlightBegin: height / ScreenTools.scaleNum(2 - 18)
                            preferredHighlightEnd: height / ScreenTools.scaleNum(2 + 18)
                            currentIndex: root.startMinute
                            
                            delegate: Item {
                                width: ListView.view.width
                                height: ScreenTools.scaleNum(36)
                                property bool isCurrent: ListView.isCurrentItem
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData < 10 ? "0" + modelData : modelData
                                    font.pointSize: ScreenTools.scaleNum(10, true)
                                    font.family: ScreenTools.fontFamily
                                    color: parent.isCurrent ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.tab_text_nor_color
                                    font.weight: parent.isCurrent ? Font.Medium : Font.Normal
                                }
                            }
                            
                            onCurrentIndexChanged: {
                                root.startMinute = currentIndex
                            }
                        }
                    }
                }
                
                // 上下渐变遮罩
                // Rectangle {
                //     anchors.top: parent.top
                //     width: parent.width
                //     height: 60
                //     gradient: Gradient {
                //         GradientStop { position: 0; color: "white" }
                //         GradientStop { position: 1; color: "#00ffffff" }
                //     }
                // }
                
                // Rectangle {
                //     anchors.bottom: parent.bottom
                //     width: parent.width
                //     height: 60
                //     gradient: Gradient {
                //         GradientStop { position: 0; color: "#00ffffff" }
                //         GradientStop { position: 1; color: "white" }
                //     }
                // }
            }
            
            // 中间分隔线
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: "#f0f0f0"
            }
            
            // ===== 结束时间区域 =====
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.width: 1
                border.color: ThemeColorStyle.border_nor_color
                radius: ScreenTools.scaleNum(4)
                
                // 固定选中背景（小时+冒号+分钟）
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 0
                    // x: 8
                    width: parent.width //- 16
                    height: ScreenTools.scaleNum(36)
                    color: ThemeColorStyle.privacy_text_color
                    opacity: 0.1
                    // radius: 4
                }
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    // 小时
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ListView {
                            id: endHourList
                            anchors.fill: parent
                            clip: true
                            model: 24
                            highlightMoveDuration: 200
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            preferredHighlightBegin: height / ScreenTools.scaleNum(2 - 18)
                            preferredHighlightEnd: height / ScreenTools.scaleNum(2 + 18)
                            currentIndex: root.endHour
                            
                            delegate: Item {
                                width: ListView.view.width
                                height: ScreenTools.scaleNum(36)
                                property bool isCurrent: ListView.isCurrentItem
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData < 10 ? "0" + modelData : modelData
                                    font.pointSize: ScreenTools.scaleNum(10,true)
                                    font.family: ScreenTools.fontFamily
                                    color: parent.isCurrent ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.tab_text_nor_color
                                    font.weight: parent.isCurrent ? Font.Medium : Font.Normal
                                }
                            }
                            
                            onCurrentIndexChanged: {
                                root.endHour = currentIndex
                            }
                        }
                    }
                    
                    // 冒号
                    Item {
                        Layout.preferredWidth: ScreenTools.scaleNum(20)
                        Layout.fillHeight: true
                        
                        Text {
                            anchors.centerIn: parent
                            text: ":"
                            font.pointSize: ScreenTools.scaleNum(10,true)
                            color: ThemeColorStyle.privacy_text_color
                            font.bold: true
                        }
                    }
                    
                    // 分钟
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ListView {
                            id: endMinuteList
                            anchors.fill: parent
                            clip: true
                            model: 60
                            highlightMoveDuration: 200
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            preferredHighlightBegin: height / ScreenTools.scaleNum(2 - 18)
                            preferredHighlightEnd: height / ScreenTools.scaleNum(2 + 18)
                            currentIndex: root.endMinute
                            
                            delegate: Item {
                                width: ListView.view.width
                                height: ScreenTools.scaleNum(36)
                                property bool isCurrent: ListView.isCurrentItem
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData < 10 ? "0" + modelData : modelData
                                    font.pointSize: ScreenTools.scaleNum(10, true)
                                    font.family: ScreenTools.fontFamily
                                    color: parent.isCurrent ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.tab_text_nor_color
                                    font.weight: parent.isCurrent ? Font.Medium : Font.Normal
                                }
                            }
                            
                            onCurrentIndexChanged: {
                                root.endMinute = currentIndex
                            }
                        }
                    }
                }
                
                // // 上下渐变遮罩
                // Rectangle {
                //     anchors.top: parent.top
                //     width: parent.width
                //     height: 60
                //     gradient: Gradient {
                //         GradientStop { position: 0; color: "white" }
                //         GradientStop { position: 1; color: "#00ffffff" }
                //     }
                // }
                
                // Rectangle {
                //     anchors.bottom: parent.bottom
                //     width: parent.width
                //     height: 60
                //     gradient: Gradient {
                //         GradientStop { position: 0; color: "#00ffffff" }
                //         GradientStop { position: 1; color: "white" }
                //     }
                // }
            }
        }

        Item{
            height: ScreenTools.scaleNum(16)
        }
        
        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#e5e5e5"
        }
        
        // ========== 按钮区域 ==========
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.scaleNum(52)
            spacing: 0
            
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            // 取消按钮
            Text {
                text: qsTr("Cancel")
                font.pointSize: ScreenTools.scaleNum(12,true)
                font.family: ScreenTools.fontFamily
                Layout.alignment: Qt.AlignVCenter
                color: ThemeColorStyle.cancelBtn_text_color
                
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -ScreenTools.scaleNum(10)
                    onClicked: {
                        root.canceled()
                        root.close()
                    }
                }
            }
            
            Item {
                width: ScreenTools.scaleNum(24)
                height: 1
            }
            
            // 确定按钮
            Text {
                text: qsTr("Confirm")
                font.pointSize: ScreenTools.scaleNum(12,true)
                font.family: ScreenTools.fontFamily
                Layout.alignment: Qt.AlignVCenter
                color: ThemeColorStyle.privacy_text_color
                font.weight: Font.Medium
                
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -ScreenTools.scaleNum(10)
                    onClicked: {
                        root.timeSelected(root.startHour, root.startMinute, root.endHour, root.endMinute)
                        root.close()
                    }
                }
            }
            
            Item {
                width: ScreenTools.scaleNum(24)
                height: 1
            }
        }
    }
    
    // 打开时设置初始值
    onOpened: {
        // 延迟到下一个事件循环，确保 ListView 已准备好
        Qt.callLater(function() {
            startHourList.positionViewAtIndex(startHour, ListView.Center)
            startMinuteList.positionViewAtIndex(startMinute, ListView.Center)
            endHourList.positionViewAtIndex(endHour, ListView.Center)
            endMinuteList.positionViewAtIndex(endMinute, ListView.Center)
        })
    }
}
