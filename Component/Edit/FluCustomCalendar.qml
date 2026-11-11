/*********************************************************************
File : FluCustomCalendar.qml
Module : Edit
Authors: guangnan
date : 2023/08/23 16:00
Ver : 1.0.0
History:
guangnan 2023/08/23 1.0.0 build this module
********************************************************************/
import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import ScreenTools 1.0
import ConfigureManager 1.0
import FluentUI 1.0
import Component.FluComponent 1.0

Item {
    id:root
    signal selectData(var date);
    signal confirmData(string date2);
    signal timeSelected(string beginTime, string endTime)
    signal clickOk()
    signal close()
    property string currentSelectDate: ""
    property var dateModel: (dispatchManagerIsNull && DispatchManager.deviceObj && DispatchManager.deviceObj.playBackCalendarListModel) ? DispatchManager.deviceObj.playBackCalendarListModel : null
    property var dayNamelist: [qsTr("Sun"),qsTr("Mon"),qsTr("Tue"),qsTr("Wen"),qsTr("Thur"),qsTr("Fri"),qsTr("Sat")]
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
    property bool shadowVisible: true
    property bool todayIsVisible: true
    width: ScreenTools.scaleNum(312)
    height: todayIsVisible ? ScreenTools.scaleNum(388) : ScreenTools.scaleNum(348)
    z: 10  // 设置 z 值

    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    // 添加 DropShadow 效果
    DropShadow {
        anchors.fill: background // 让阴影填充背景矩形
        source: background      // 阴影效果作用于背景矩形
        radius: ScreenTools.scaleNum(8)               // 阴影的模糊半径
        samples: ScreenTools.scaleNum(16)             // 阴影的质量，值越高越平滑
        color: "#6D7682"      // 阴影颜色，80是透明度
        horizontalOffset: ScreenTools.scaleNum(2)     // 水平偏移
        verticalOffset: ScreenTools.scaleNum(2)       // 垂直偏移
        visible: root.shadowVisible
    }
    
    // 创建一个可视的背景矩形，原来的根Rectangle的属性都移到这里
    Rectangle {
        id: background
        anchors.fill: parent
        radius: ScreenTools.scaleNum(8)
        color: "#FEFEFE"
        border.color: root.borderColor   // 引用根元素的属性
        border.width: root.borderWidth   // 引用根元素的属性
        clip: true  // 限制子组件显示范围

        ColumnLayout{
            id:columnLayout
            anchors.fill: parent
            anchors.margins: root.borderWidth // 引用根元素的属性
            spacing: 0
            // ... 内部所有代码保持不变 ...
            Rectangle{
                Layout.preferredHeight: ScreenTools.scaleNum(60)
                Layout.fillWidth: true
                radius: ScreenTools.scaleNum(8)
                RowLayout{
                    anchors.fill: parent
                    spacing: ScreenTools.scaleNum(6)
                    Item{
                        Layout.preferredWidth: ScreenTools.scaleNum(10)
                        Layout.fillHeight: true
                    }
                    Rectangle{
                        id:prevYear
                        property color bgColor: normalBgColor
                        width: ScreenTools.scaleNum(32)
                        height: ScreenTools.scaleNum(32)
                        Layout.alignment: Qt.AlignVCenter
                        color: bgColor
                        radius: ScreenTools.scaleNum(16)
                        clip: true // 限制子元素绘制范围
                        FluCustomSvg{
                            imageWidth: ScreenTools.scaleNum(24)
                            imageHeight: ScreenTools.scaleNum(24)
                            anchors.centerIn: parent
                            sourceImage: CommonImageStyle.list_arrow_right_img
                            rotation: ConfigureManager.isRTLLayout ? 0 : 180
                            fillColorFirst: ThemeColorStyle.tab_text_nor_color
                            hoverEnabled: false
                        }
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                dateModel.showPreviousYear();
                            }
                            onPressed: {
                                prevYear.bgColor=hoverBgColor
                            }

                            onEntered: {
                                prevYear.bgColor=hoverBgColor
                            }
                            onExited: {
                                prevYear.bgColor=normalBgColor
                            }
                        }
                    }

                    Rectangle{
                        id:showPreBg
                        property color bgColor: normalBgColor
                        property bool isSelect: false
                        width: ScreenTools.scaleNum(32)
                        height: ScreenTools.scaleNum(32)
                        color: bgColor
                        radius: ScreenTools.scaleNum(16)
                        Layout.alignment: Qt.AlignVCenter
                        clip: true // 限制子元素绘制范围
                        FluCustomSvg{
                            imageWidth: ScreenTools.scaleNum(24)
                            imageHeight: ScreenTools.scaleNum(24)
                            anchors.centerIn: parent
                            sourceImage: CommonImageStyle.list_arrow_right_img
                            rotation: ConfigureManager.isRTLLayout ? 0 : 180
                            fillColorFirst: ThemeColorStyle.tab_text_nor_color
                            hoverEnabled: false
                        }
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                dateModel.showPreviousMonth();

                            }
                            onPressed: {
                                showPreBg.bgColor=hoverBgColor
                            }

                            onEntered: {
                                showPreBg.bgColor=hoverBgColor
                            }
                            onExited: {
                                showPreBg.bgColor=normalBgColor
                            }
                        }
                    }
                    Item{
                        Layout.fillWidth: true;
                        Layout.fillHeight: true
                    }
                    Label {
                        id:showYearLabel
                        text: dateModel && dateModel.currentYear
                        Layout.alignment: Qt.AlignVCenter
                        font.pointSize: ScreenTools.scaleNum(12, true)
                        font.bold: true
                        color: normalColor
                        font.family: ScreenTools.fontFamily
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode:Text.WrapAnywhere
                    }

                    Label {
                        text: "-"
                        Layout.alignment: Qt.AlignVCenter
                        font.pointSize: ScreenTools.scaleNum(12, true)
                        font.bold: true
                        color: normalColor
                        font.family: ScreenTools.fontFamily
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode:Text.WrapAnywhere
                    }

                    Label {
                        id:showMonthLabel
                        text: dateModel && dateModel.stringMonthToInt(dateModel.currentMonth)
                        Layout.alignment: Qt.AlignVCenter
                        font.pointSize: ScreenTools.scaleNum(12, true)
                        font.bold: true
                        color: normalColor
                        font.family: ScreenTools.fontFamily
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode:Text.WrapAnywhere
                    }
                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    
                    Rectangle{
                        id:showNextBg
                        property color bgColor: normalBgColor
                        width: ScreenTools.scaleNum(32)
                        height: ScreenTools.scaleNum(32)
                        Layout.alignment: Qt.AlignVCenter
                        color: bgColor
                        radius: ScreenTools.scaleNum(16)
                        clip: true // 限制子元素绘制范围
                        FluCustomSvg{
                            imageWidth: ScreenTools.scaleNum(24)
                            imageHeight: ScreenTools.scaleNum(24)
                            anchors.centerIn: parent
                            sourceImage: CommonImageStyle.list_arrow_right_img
                            rotation: ConfigureManager.isRTLLayout ? 180 : 0
                            fillColorFirst: ThemeColorStyle.tab_text_nor_color
                            hoverEnabled: false
                        }
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                dateModel.showNextMonth();
                            }
                            onPressed: {
                                showNextBg.bgColor=hoverBgColor;
                            }

                            onEntered: {
                                showNextBg.bgColor=hoverBgColor;
                            }
                            onExited: {
                                showNextBg.bgColor=normalBgColor;
                            }
                        }
                    }

                    Rectangle{
                        id:nextYear
                        property color bgColor: normalBgColor
                        width: ScreenTools.scaleNum(32)
                        height: ScreenTools.scaleNum(32)
                        Layout.alignment: Qt.AlignVCenter
                        color: bgColor
                        radius: ScreenTools.scaleNum(16)
                        clip: true // 限制子元素绘制范围
                        FluCustomSvg{
                            imageWidth: ScreenTools.scaleNum(24)
                            imageHeight: ScreenTools.scaleNum(24)
                            anchors.centerIn: parent
                            sourceImage: CommonImageStyle.list_arrow_right_img
                            rotation: ConfigureManager.isRTLLayout ? 180 : 0
                            fillColorFirst: ThemeColorStyle.tab_text_nor_color
                            hoverEnabled: false
                        }
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                dateModel.showNextYear();
                            }
                            onPressed: {
                                nextYear.bgColor=hoverBgColor;
                            }

                            onEntered: {
                                nextYear.bgColor=hoverBgColor
                            }
                            onExited: {
                                nextYear.bgColor=normalBgColor
                            }
                        }
                    }
                    Item{
                        Layout.preferredWidth: ScreenTools.scaleNum(10)
                        Layout.fillHeight: true
                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.scaleNum(40)
                Layout.alignment: Qt.AlignVCenter
                RowLayout{
                    anchors.fill: parent
                    spacing: 0
                    Item{
                        Layout.fillHeight: true
                        Layout.preferredWidth: ScreenTools.scaleNum(20)
                    }
                    Repeater{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        model: 7
                        delegate:Rectangle{
                            width: ScreenTools.scaleNum(40)
                            height: ScreenTools.scaleNum(40)
                            Layout.alignment: Qt.AlignVCenter
                            Label {
                                text: dayNamelist[model.index]
                                anchors.centerIn: parent
                                font.pointSize: ScreenTools.scaleNum(10, true)
                                color: normalColor
                                font.family: ScreenTools.fontFamily
                                verticalAlignment:Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode:Text.WrapAnywhere
                            }
                        }
                    }

                    Item{
                        Layout.fillHeight: true
                        Layout.preferredWidth: ScreenTools.scaleNum(20)
                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#E7E7E7"
            }

            Repeater{
                id: repeaterCol
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: dateModel
                delegate: Rectangle{
                    id:columnRect
                    property var rowList: Obj
                    property var theRowIndex: model.index

                    width: ScreenTools.scaleNum(280)
                    height: ScreenTools.scaleNum(40)
                    Layout.alignment:Qt.AlignHCenter
                    RowLayout{
                        anchors.fill: parent
                        spacing: 0
                        Repeater{
                            id:repeaterRow
                            model: Obj
                            delegate: Rectangle{
                                id:itemBg
                                property color testShowColor: normalColor
                                property color bgColor: normalBgColor
                                property string dateFormat: showYearLabel.text+"-"+dateModel.stringMonthToInt(dateModel.currentMonth)+"-"+(parseInt(model.modelData.dateString)>=1 && parseInt(model.modelData.dateString)<=9 ?"0"+model.modelData.dateString:model.modelData.dateString)
                                property bool isSelect: selectDateItem==dateFormat;
                                property bool isHover: false
                                property bool isToday: model.modelData.isToday

                                width: ScreenTools.scaleNum(40)
                                height: ScreenTools.scaleNum(40)
                                radius: (isHover || isSelect) && model.modelData.isEnable ?ScreenTools.scaleNum(20):0
                                color: isSelect && model.modelData.isEnable ?selectedBgColor:isHover && model.modelData.isEnable?hoverBgColor:normalBgColor
                                clip: true // 限制子元素绘制范围
                                Label {
                                    id: itemLabel
                                    text: model.modelData.dateString
                                    anchors.centerIn: parent
                                    font.pointSize: ScreenTools.scaleNum(10, true)
                                    color: model.modelData.isToday && !isSelect?hoverColor:isSelect && model.modelData.isEnable?selectColor:model.modelData.isEnable?normalColor:disableColor
                                    font.family: ScreenTools.fontFamily
                                    verticalAlignment:Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode:Text.WrapAnywhere
                                }
                                Rectangle{
                                    width: ScreenTools.scaleNum(6)
                                    height: ScreenTools.scaleNum(6)
                                    radius: ScreenTools.scaleNum(4)
                                    color: selectedBgColor
                                    visible: model.modelData.isToday && !isSelect
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                MouseArea{
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if(!model.modelData.isEnable)
                                            return;
                                        if(selectDateItem == dateFormat)
                                            return;
                                        if(isFutureDate(dateFormat))
                                            return;
                                        selectDateItem = dateFormat;
                                        itemBg.isHover = false;
                                        itemBg.bgColor = selectedBgColor;      
                                        let dateStringFormat = parseInt(model.modelData.dateString)>=1 && parseInt(model.modelData.dateString)<=9 ?"0"+model.modelData.dateString:model.modelData.dateString;
                                        let dateString = showYearLabel.text+"-"+dateModel.stringMonthToInt(dateModel.currentMonth)+"-"+dateStringFormat;
                                        let date = new Date(dateString);
                                        root.selectData(date)
                                    }
                                    onEntered: {
                                        if (isSelect || itemBg.isHover) // 避免重复赋值
                                            return;
                                        itemBg.isHover = true;
                                        itemBg.bgColor = hoverBgColor;
                                        //itemLabel.color = hoverColor;
                                    }
                                    onExited: {
                                        if (isSelect || !itemBg.isHover) // 避免重复赋值
                                            return;
                                        itemBg.isHover = false;
                                        itemBg.bgColor = normalBgColor;
                                        //itemLabel.color = normalColor;
                                    }

                                }
                            }
                        }
                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                visible: todayIsVisible
                color: "#E7E7E7"
            }

            RowLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: todayIsVisible
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Rectangle{
                    id:currentRectBg
                    property color testShowColor: hoverColor
                    property color bgColor: normalBgColor
                    property bool isSelect: false
                    Layout.preferredHeight: ScreenTools.scaleNum(32)
                    implicitWidth:Math.max(ScreenTools.calculateTextWidth(backTodayLabel.text) + ScreenTools.scaleNum(12), ScreenTools.scaleNum(32))
                    //height: ScreenTools.scaleNum(32)
                    Layout.topMargin: ScreenTools.scaleNum(8)
                    //radius:currentRectBg.isSelect?16:0
                    radius: ScreenTools.scaleNum(16)
                    color: currentRectBg.bgColor
                    clip: true // 限制子元素绘制范围
                    visible: todayIsVisible
                    Layout.alignment: Qt.AlignVCenter
                    Label {
                        id:backTodayLabel
                        text: qsTr("Today")
                        anchors.centerIn: parent
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        color:currentRectBg.testShowColor
                        font.family: ScreenTools.fontFamily
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode:Text.WrapAnywhere
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onPressed: {
                            currentRectBg.isSelect = true;
                            currentRectBg.bgColor = hoverBgColor;
                        }
                        onClicked: {
                            root.onCurrentSelectDate();
                        }
                        onEntered: {
                            currentRectBg.isSelect = true;
                            currentRectBg.bgColor = hoverBgColor;
                        }
                        onExited: {
                            currentRectBg.isSelect=false;
                            currentRectBg.bgColor = normalBgColor;
                        }
                    }
                }

                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
            Item{
                Layout.preferredHeight: ScreenTools.scaleNum(10)
                Layout.fillWidth: true
            }
        }
    }
   function isFutureDate(dateStr) {
        let today = new Date();
        let year = today.getFullYear();
        let month = ("0" + (today.getMonth() + 1)).slice(-2);  
        let day = ("0" + today.getDate()).slice(-2);
        let currentDate = new Date(year + "-" + month + "-" + day);
        let selectDate = new Date(dateStr);
        return currentDate < selectDate;
    }
    function onCurrentSelectDate(){
        dateModel.showCurrentMonth();
        let today = new Date();
        let year = today.getFullYear();
        let month = ("0" + (today.getMonth() + 1)).slice(-2);  // 月份从0开始计数，所以要加1，并且格式化为两位数
        let day = ("0" + today.getDate()).slice(-2);
        selectDateItem = year + "-" + month + "-" + day;
        root.selectData(selectDateItem);
    }

    function showDeviceCalendar(dateStr) {
        let deviceDate=new Date(dateStr);
        let year = deviceDate.getFullYear();
        let month = ("0" + (deviceDate.getMonth() + 1)).slice(-2);
        let day = ("0" + deviceDate.getDate()).slice(-2);
        selectDateItem = year + "-" + month + "-" + day;
        //root.selectData(selectDateItem);
    }

    function showCurrentData(){
        dateModel.showCurrentMonth();
    }

    function updateDate()
    {
        confirmData(selectDateItem)
    }
}
