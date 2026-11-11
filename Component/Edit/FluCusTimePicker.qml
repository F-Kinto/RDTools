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

Item {
    id:root
    signal selectData(string date1);
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
    property string textHour: "00"
    property string textMinute: "00"
    width: ScreenTools.scaleNum(120)
    height: ScreenTools.scaleNum(240)
    z: 10  // 设置 z 值

    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    // 创建一个可视的背景矩形，原来的根Rectangle的属性都移到这里
    Rectangle {
        id: background
        radius: ScreenTools.scaleNum(2)
        color: normalBgColor
        border.color: "#F0F2F5"   // 引用根元素的属性
        border.width: 1   // 引用根元素的属性
        clip: true  // 限制子组件显示范围
        anchors{
            fill: parent
        }

        RowLayout{
            id:layout_content
            spacing: 0
            width: parent.width
            height: parent.height
            Component{
                id:list_delegate
                Item{
                    height:ScreenTools.scaleNum(40)
                    width:getListView().width
                    function getListView(){
                        if(type === 0)
                            return list_view_1
                        if(type === 1)
                            return list_view_2
                    }
                    Rectangle{
                        anchors.fill: parent
                        anchors.topMargin: ScreenTools.scaleNum(2)
                        anchors.bottomMargin: ScreenTools.scaleNum(2)
                        anchors.leftMargin: ScreenTools.scaleNum(2)
                        anchors.rightMargin: ScreenTools.scaleNum(2)
                        color:  {
                            if(getListView().currentIndex === position){
                                return selectedBgColor
                            }
                            if(item_mouse.containsMouse){
                                return hoverBgColor
                            }
                            return normalBgColor
                        }
                        radius: ScreenTools.scaleNum(2)
                        MouseArea{
                            id:item_mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                getListView().currentIndex = position
                                if(type === 0){
                                    textHour = model
                                }
                                if(type === 1){
                                    textMinute = model
                                }
                            }
                        }
                        FluText{
                            text:model
                            color: getListView().currentIndex === position ? selectColor : normalColor
                            anchors.centerIn: parent
                            font.pointSize: ScreenTools.scaleNum(10)
                            font.family: ScreenTools.fontFamily
                        }
                    }
                }
            }
            ListView{
                id:list_view_1
                Layout.preferredWidth: parent.width / 2 - 2
                Layout.preferredHeight: parent.height-2 
                Layout.alignment: Qt.AlignVCenter
                boundsBehavior:Flickable.StopAtBounds
                preferredHighlightBegin: height / 2 - ScreenTools.scaleNum(18)
                preferredHighlightEnd: height / 2 + ScreenTools.scaleNum(18)
                highlightMoveDuration: 200
                model: generateArray(0,23)
                clip: true
                delegate: FluLoader{
                    property var model: modelData
                    property int type:0
                    property int position:index
                    sourceComponent: list_delegate
                }
            }
            Rectangle{
                Layout.preferredWidth: 1
                Layout.preferredHeight: parent.height
                color: "#F0F2F5"
            }
            ListView{
                id:list_view_2
                Layout.preferredWidth: parent.width / 2 - ScreenTools.scaleNum(2)
                Layout.preferredHeight: parent.height-ScreenTools.scaleNum(2)
                Layout.alignment: Qt.AlignVCenter
                model: generateArray(0,59)
                clip: true
                preferredHighlightBegin: height / 2 - ScreenTools.scaleNum(18)
                preferredHighlightEnd: height / 2 + ScreenTools.scaleNum(18)
                highlightMoveDuration: 200
                boundsBehavior:Flickable.StopAtBounds
                delegate: FluLoader{
                    property var model: modelData
                    property int type:1
                    property int position:index
                    sourceComponent: list_delegate
                }
            }
        }
    }

    function generateArray(start, n) {
        var arr = [];
        for (var i = start; i <= n; i++) {
            arr.push(i.toString().padStart(2, '0'));
        }
        return arr;
    }

    function updateDate()
    {
        selectData(textHour + ":" + textMinute + ":00")
    }
}