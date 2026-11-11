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
import Component.FluComponent 1.0
import FluentUI 1.0

// 将根元素从 Rectangle 改为 Item，作为一个无形的容器
Item {
    id:root
    signal selectData(var date);
    signal confirmData(var date);
    property string currentSelectDate: ""
    property var dateModel: (dispatchManagerIsNull && DispatchManager.deviceObj && DispatchManager.deviceObj.playBackCalendarListModel) ? DispatchManager.deviceObj.playBackCalendarListModel : null
    property var dayNamelist: [qsTr("Sun"),qsTr("Mon"),qsTr("Tue"),qsTr("Wen"),qsTr("Thur"),qsTr("Fri"),qsTr("Sat")]
    property string selectDateItem: currentSelectDate
    property color dateSelectBgColor: ThemeColorStyle.data_bg_select_color
    property color borderColor:  ThemeColorStyle.border_nor_color
    property int borderWidth: 0
    width: ScreenTools.scaleNum(320)
    height: ScreenTools.scaleNum(427)
    z: 10  // 设置 z 值

    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    // 添加 DropShadow 效果
    DropShadow {
        anchors.fill: background                        // 让阴影填充背景矩形
        source: background                              // 阴影效果作用于背景矩形
        radius: ScreenTools.scaleNum(10)                // 阴影的模糊半径
        samples: ScreenTools.scaleNum(16)               // 阴影的质量，值越高越平滑
        color: "#80000000"                            // 阴影颜色，80是透明度
        horizontalOffset: ScreenTools.scaleNum(4)       // 水平偏移
        verticalOffset: ScreenTools.scaleNum(4)         // 垂直偏移
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
                Layout.preferredHeight: ScreenTools.scaleNum(63)
                Layout.fillWidth: true
                radius: ScreenTools.scaleNum(8)
                RowLayout{
                    anchors.fill: parent
                    spacing: 0
                    Item{
                        Layout.preferredWidth: ScreenTools.scaleNum(20)
                        Layout.fillHeight: true
                    }
                    Label {
                        id:showYearLabel
                        objectName: "showYearLabel"
                        text: dateModel && dateModel.currentYear
                        Layout.alignment: Qt.AlignVCenter
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        color: ThemeColorStyle.list_text_nor_color
                        font.family: ScreenTools.fontFamily
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode:Text.WrapAnywhere
                    }
                    Item{
                        width: ScreenTools.scaleNum(8);
                        Layout.fillHeight: true
                    }
                    Label {
                        text: "/"
                        Layout.alignment: Qt.AlignVCenter
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        color: ThemeColorStyle.list_text_nor_color
                        font.family: ScreenTools.fontFamily
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode:Text.WrapAnywhere
                    }
                    Item{
                        width: ScreenTools.scaleNum(8);
                        Layout.fillHeight: true
                    }
                    Label {
                        id:showMonthLabel
                        objectName: "showMonthLabel"
                        text: dateModel && dateModel.stringMonthToInt(dateModel.currentMonth)
                        Layout.alignment: Qt.AlignVCenter
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        color: ThemeColorStyle.list_text_nor_color
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
                        id:showPreBg
                        property color bgColor: ThemeColorStyle.list_bg_nor_color
                        property bool isSelect: false
                        width: ScreenTools.scaleNum(32)
                        height: ScreenTools.scaleNum(32)
                        color: bgColor
                        radius:ScreenTools.scaleNum(16)
                        Layout.alignment: Qt.AlignVCenter
                        clip: true // 限制子元素绘制范围
                        FluCustomSvg{
                            objectName: "preImg"
                            imageWidth: ScreenTools.scaleNum(16)
                            imageHeight: ScreenTools.scaleNum(16)
                            anchors.centerIn: parent
                            sourceImage: CommonImageStyle.list_arrow_right_img
                            rotation: ConfigureManager.isRTLLayout ? 0 : 180
                            fillColorFirst: ThemeColorStyle.tab_text_nor_color
                            hoverEnabled: false
                        }
                        MouseArea{
                            objectName: "preMa"
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                dateModel.showPreviousMonth();

                            }
                            onPressed: {
                                showPreBg.bgColor=ThemeColorStyle.border_nor_color;
                            }

                            onEntered: {
                                showPreBg.bgColor=ThemeColorStyle.list_bg_hover_color;
                            }
                            onExited: {
                                showPreBg.bgColor=ThemeColorStyle.list_bg_nor_color;
                            }
                            onReleased: {
                                showPreBg.bgColor=ThemeColorStyle.list_bg_hover_color;
                            }

                        }
                    }
                    Rectangle{
                        id:currentRectBg
                        property color testShowColor: ThemeColorStyle.list_text_nor_color
                        property color bgColor: ThemeColorStyle.list_bg_nor_color
                        property bool isSelect: false
                        implicitWidth:Math.max(ScreenTools.calculateTextWidth(backTodayLabel.text) + ScreenTools.scaleNum(12), ScreenTools.scaleNum(32))
                        height: ScreenTools.scaleNum(32)
                        //radius:currentRectBg.isSelect?16:0
                        radius:ScreenTools.scaleNum(16)
                        color: currentRectBg.bgColor
                        clip: true // 限制子元素绘制范围
                        Label {
                            id:backTodayLabel
                            objectName: "backTodayLabel"
                            text: qsTr("Today")
                            anchors.centerIn: parent
                            font.pointSize: ScreenTools.scaleNum(10, true)
                            color:currentRectBg.testShowColor
                            font.family: ScreenTools.fontFamily
                            verticalAlignment:Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode:Text.WrapAnywhere
                        }
                        MouseArea   {
                            objectName: "todayMa"
                            anchors.fill: parent
                            hoverEnabled: true
                            onPressed: {
                                currentRectBg.isSelect=true;
                                currentRectBg.bgColor=ThemeColorStyle.list_bg_hover_color;
                                currentRectBg.testShowColor=dateSelectBgColor;
                            }
                            onClicked: {
                                root.onCurrentSelectDate();
                            }
                            onEntered: {
                                currentRectBg.isSelect=true;
                                currentRectBg.bgColor=ThemeColorStyle.list_bg_hover_color;
                                currentRectBg.testShowColor=ThemeColorStyle.list_text_nor_color;
                            }
                            onExited: {
                                currentRectBg.isSelect=false;
                                currentRectBg.bgColor=ThemeColorStyle.list_bg_nor_color;
                                currentRectBg.testShowColor=ThemeColorStyle.list_text_nor_color;
                            }
                            onReleased: {
                                currentRectBg.isSelect=true;
                                currentRectBg.bgColor=ThemeColorStyle.list_bg_hover_color;
                                currentRectBg.testShowColor=ThemeColorStyle.list_text_nor_color;
                            }
                        }
                    }

                    Rectangle{
                        id:showNextBg
                        property color bgColor: ThemeColorStyle.list_bg_nor_color
                        width: ScreenTools.scaleNum(32)
                        height: ScreenTools.scaleNum(32)
                        Layout.alignment: Qt.AlignVCenter
                        color: bgColor
                        radius:ScreenTools.scaleNum(16)
                        clip: true // 限制子元素绘制范围
                        FluCustomSvg{
                            objectName: "nextImg"
                            imageWidth: ScreenTools.scaleNum(16)
                            imageHeight: ScreenTools.scaleNum(16)
                            anchors.centerIn: parent
                            sourceImage: CommonImageStyle.list_arrow_right_img
                            rotation: ConfigureManager.isRTLLayout ? 180 : 0
                            fillColorFirst: ThemeColorStyle.tab_text_nor_color
                            hoverEnabled: false
                        }
                        MouseArea{
                            objectName: "nextMa"
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                dateModel.showNextMonth();
                            }
                            onPressed: {
                                showNextBg.bgColor=ThemeColorStyle.border_nor_color;
                            }

                            onEntered: {
                                showNextBg.bgColor=ThemeColorStyle.list_bg_hover_color;
                            }
                            onExited: {
                                showNextBg.bgColor=ThemeColorStyle.list_bg_nor_color;
                            }
                            onReleased: {
                                showNextBg.bgColor=ThemeColorStyle.list_bg_hover_color;
                            }

                        }
                    }
                    Item{
                        width: ScreenTools.scaleNum(16);
                        Layout.fillHeight: true
                    }
                }
            }
            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#E7E7E7"
            }
            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.scaleNum(44)
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
                                color: ThemeColorStyle.list_text_nor_color
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
                                objectName: "date_" + columnRect.theRowIndex + "_" + index
                                property color testShowColor: ThemeColorStyle.list_text_nor_color
                                property color bgColor: ThemeColorStyle.list_bg_nor_color
                                property string dateFormat: showYearLabel.text+"-"+dateModel.stringMonthToInt(dateModel.currentMonth)+"-"+(parseInt(model.modelData.dateString)>=1 && parseInt(model.modelData.dateString)<=9 ?"0"+model.modelData.dateString:model.modelData.dateString)
                                property bool isSelect: selectDateItem==dateFormat;
                                property bool isHover: false
                                property bool isToday: model.modelData.isToday

                                width: ScreenTools.scaleNum(40)
                                height: ScreenTools.scaleNum(40)
                                radius: (isHover || isSelect) && model.modelData.isEnable ?ScreenTools.scaleNum(20):0
                                color: isSelect && model.modelData.isEnable ?dateSelectBgColor:isHover && model.modelData.isEnable?bgColor:ThemeColorStyle.list_bg_nor_color
                                clip: true // 限制子元素绘制范围
                                Label {
                                    objectName: "dateLabel"
                                    text: model.modelData.dateString
                                    anchors.centerIn: parent
                                    font.pointSize: ScreenTools.scaleNum(10, true)
                                    color: model.modelData.isToday && !isSelect?dateSelectBgColor:isSelect && model.modelData.isEnable?ThemeColorStyle.list_bg_nor_color:model.modelData.isEnable?ThemeColorStyle.list_text_nor_color:ThemeColorStyle.list_text_disable_color
                                    font.family: ScreenTools.fontFamily
                                    verticalAlignment:Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode:Text.WrapAnywhere
                                }
                                Rectangle{
                                    width: ScreenTools.scaleNum(6)
                                    height: ScreenTools.scaleNum(6)
                                    radius: ScreenTools.scaleNum(3)
                                    color: "red" // dateSelectBgColor
                                    visible: model.modelData.hasVideo && !isSelect
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                MouseArea{
                                    objectName: "dateMa"
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if(!model.modelData.isEnable)
                                            return;
                                        if(selectDateItem==dateFormat)
                                            return;
                                        if(isFutureDate(dateFormat))
                                            return;
                                        selectDateItem= dateFormat;
                                        itemBg.isHover=false;
                                        itemBg.bgColor=ThemeColorStyle.list_bg_nor_color;      
                                        let dateStringFormat= parseInt(model.modelData.dateString)>=1 && parseInt(model.modelData.dateString)<=9 ?"0"+model.modelData.dateString:model.modelData.dateString;
                                        let dateString=showYearLabel.text+"-"+dateModel.stringMonthToInt(dateModel.currentMonth)+"-"+dateStringFormat;
                                        let date = new Date(dateString);
                                        root.selectData(date)
                                    }
                                    onEntered: {
                                        if (isSelect || itemBg.isHover) // 避免重复赋值
                                            return;
                                        itemBg.isHover=true;
                                        itemBg.bgColor=ThemeColorStyle.list_bg_hover_color;
                                    }
                                    onExited: {
                                        if (isSelect || !itemBg.isHover) // 避免重复赋值
                                            return;
                                        itemBg.isHover=false;
                                        itemBg.bgColor=ThemeColorStyle.list_bg_nor_color;
                                    }

                                }
                            }
                        }
                    }
                }
            }

            FluButton {
                id: btn
                Layout.preferredWidth: ScreenTools.scaleNum(78)
                Layout.preferredHeight: ScreenTools.scaleNum(28)
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Confirm")
                textColor: "#FFFFFF"
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
                background: FluControlBackground{
                    implicitWidth: ScreenTools.scaleNum(78)
                    implicitHeight: ScreenTools.scaleNum(28)
                    radius: 4
                    opacity: btn.hovered ? 0.7 : 1
                    shadow: !btn.pressed
                    color: "#0099FF"
                    FluFocusRectangle{
                        visible: root.activeFocus
                        radius:4
                    }
                }
                onClicked: {
                    if (selectDateItem !== "") {
                        let date = new Date(selectDateItem);
                        root.confirmData(date);
                    }
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
}
