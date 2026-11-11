import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import Qt.labs.calendar 1.0
import ScreenTools 1.0
import ConfigureManager 1.0
import Component.FluComponent 1.0

Rectangle {
    property date from: new Date(1970, 0, 1)
    property date to: new Date(2126, 11, 31)
    property var current
    signal accepted()
    signal selectData(var date);
    signal confirmData(string date2);
    signal updateIndex(int newIndex)
    property string currentSelectDate: ""
    property var dayNamelist: [qsTr("Mon"),qsTr("Tue"),qsTr("Wen"),qsTr("Thur"),qsTr("Fri"),qsTr("Sat"),qsTr("Sun")]
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
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    width: ScreenTools.scaleNum(312)
    height: todayIsVisible ? ScreenTools.scaleNum(388) : ScreenTools.scaleNum(348)
    z: 10  // 设置 z 值
    
    id:control

    CalendarModel {
        id:calender_model
        from: control.from
        to: control.to
        property string curYear:""
        property string curMonth:""
    }
    Item{
        id:d
        property var window : Window.window
        property date displayDate: {
            if(control.current){
                return control.current
            }
            return new Date()
        }
        property date toDay : new Date()
        signal nextButton
        signal previousButton
        signal nextYearButton
        signal previousYearButton
    }
    Rectangle{
        anchors.fill: parent
        id:container
        implicitWidth: parent.width
        implicitHeight: parent.height
        ColumnLayout  {
            anchors.fill: parent
            spacing: 0
            Item{
                Layout.preferredHeight: ScreenTools.scaleNum(8)
                Layout.fillWidth: true
            }
            Rectangle{
                Layout.preferredHeight: ScreenTools.scaleNum(40)
                Layout.fillWidth: true
                radius: ScreenTools.scaleNum(8)
                RowLayout{
                    anchors.fill: parent
                    spacing: ScreenTools.scaleNum(6)
                    Item{
                        Layout.preferredWidth: ScreenTools.scaleNum(6)
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
                                d.previousYearButton()
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
                                d.previousButton()
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

                    Label {
                        id:showDataLabel
                        text: calender_model.curYear + " - " + calender_model.curMonth
                        Layout.alignment: Qt.AlignVCenter
                        font.pointSize: ScreenTools.scaleNum(12, true)
                        font.bold: true
                        color: normalColor
                        font.family: ScreenTools.fontFamily
                        verticalAlignment:Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode:Text.WrapAnywhere
                    }

                    Rectangle{
                        id:showNextBg
                        property color bgColor: normalBgColor
                        width: ScreenTools.scaleNum(32)
                        height: ScreenTools.scaleNum(32)
                        Layout.alignment: Qt.AlignVCenter
                        color: bgColor
                        radius: ScreenTools.scaleNum(16)
                        clip: true
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
                                d.nextButton()
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
                        clip: true
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
                                d.nextYearButton()
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
                        Layout.preferredWidth: ScreenTools.scaleNum(6)
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
                        Layout.preferredWidth: ScreenTools.scaleNum(12)
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
                                font.pointSize: 10
                                color: normalColor
                                font.family: "Microsoft YaHei UI"
                                verticalAlignment:Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode:Text.WrapAnywhere
                            }
                        }
                    }

                    Item{
                        Layout.fillHeight: true
                        Layout.preferredWidth: ScreenTools.scaleNum(12)
                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#E7E7E7"
            }
            
            Item{
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: ScreenTools.scaleNum(252)
                RowLayout{ 
                    anchors.fill: parent
                    Item{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                    StackView{
                        id:stack_view
                        Layout.preferredWidth: ScreenTools.scaleNum(280)
                        Layout.preferredHeight: ScreenTools.scaleNum(252)
                        initialItem: com_page_one
                    }

                    Component{
                        id:com_page_one
                        ListView{
                            id:listview
                            property bool isCompleted: false
                            width:ScreenTools.scaleNum(280)
                            height: ScreenTools.scaleNum(252)
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            clip: true
                            boundsBehavior: ListView.StopAtBounds
                            spacing: 0
                            highlightMoveDuration: 100
                            currentIndex: -1
                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AlwaysOff  // 永远不显示
                                interactive: false  // 禁止交互
                            }
                            // 禁用鼠标滚轮
                            interactive: false  // 禁止用户交互（包括滚轮、拖动等）
                            onCurrentIndexChanged:{
                                if(isCompleted){
                                    var month = calender_model.monthAt(currentIndex)
                                    var year = calender_model.yearAt(currentIndex)
                                    d.displayDate = new Date(year,month,1)
                                }
                            }
                            Component.onCompleted: {
                                listview.model = calender_model
                                listview.highlightMoveDuration = 0
                                currentIndex  = calender_model.indexOf(d.displayDate)
                                timer_delay.restart()
                                isCompleted = true
                                updateYearMonth()
                            }
                            Timer{
                                id:timer_delay
                                interval: 100
                                onTriggered: {
                                    listview.highlightMoveDuration = 100
                                }
                            }
                            Connections{
                                target: d
                                function onNextButton(){
                                    listview.currentIndex = Math.min(listview.currentIndex+1,listview.count-1)
                                    updateYearMonth()
                                }
                                function onPreviousButton(){
                                    listview.currentIndex = Math.max(listview.currentIndex-1,0)
                                    updateYearMonth()
                                }
                                function onNextYearButton(){
                                    listview.currentIndex = Math.min(listview.currentIndex+12,listview.count-12)
                                    updateYearMonth()
                                }
                                function onPreviousYearButton(){
                                    listview.currentIndex = Math.max(listview.currentIndex-12,0)
                                    updateYearMonth()
                                }
                            }
                            Connections{
                                target: control
                                function onUpdateIndex(index){
                                    listview.currentIndex = index
                                    updateYearMonth()
                                }
                            }
                            
                            delegate: MonthGrid {
                                id: grid
                                width: listview.width
                                height: listview.height
                                month: model.month
                                year: model.year
                                spacing: 0
                                locale: FluApp.locale
                                delegate: FluControl {
                                    required property bool today
                                    required property int year
                                    required property int month
                                    required property int day
                                    required property int visibleMonth
                                    id: control_delegate
                                    visibleMonth: grid.month
                                    implicitHeight: ScreenTools.scaleNum(36)
                                    implicitWidth: ScreenTools.scaleNum(36)
                                    Rectangle{
                                        width: ScreenTools.scaleNum(36)
                                        height: ScreenTools.scaleNum(36)
                                        radius: width/2
                                        color: {
                                            if(month !== grid.month){
                                                return normalBgColor
                                            }
                                            if(selectRect.visible){
                                                return selectedBgColor
                                            }
                                            if(control_delegate.hovered){
                                                return hoverBgColor
                                            }
                                            return normalBgColor
                                        }
                                        anchors.centerIn: parent

                                        Rectangle{
                                            width: ScreenTools.scaleNum(6)
                                            height: ScreenTools.scaleNum(6)
                                            radius: ScreenTools.scaleNum(4)
                                            color: selectedBgColor
                                            visible: today && !selectRect.visible
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 1
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                    Rectangle{
                                        id: selectRect
                                        width: ScreenTools.scaleNum(40)
                                        height: ScreenTools.scaleNum(40)
                                        border.width: 0
                                        anchors.centerIn: parent
                                        radius: width/2
                                        border.color: "transparent"
                                        color: selectedBgColor
                                        visible: {
                                            if(control.current){
                                                var y = control.current.getFullYear()
                                                var m = control.current.getMonth()
                                                var d =  control.current.getDate()
                                                if(y === year && m === month && d === day){
                                                    return true
                                                }
                                                return false
                                            }
                                            return false
                                        }
                                    }
                                    FluText{
                                        text: day
                                        anchors.centerIn: parent
                                        color: {
                                            if(month !== grid.month){
                                                return disableColor
                                            }
                                            if(selectRect.visible){
                                                return selectColor
                                            }
                                            if(today || control_delegate.hovered){
                                                return hoverColor
                                            }
                                            return normalColor
                                        }
                                        font.pointSize: ScreenTools.scaleNum(10)
                                        font.family: ScreenTools.fontFamily
                                    }
                                    onClicked: {
                                        // 已选中或者点击的是未来的日期
                                        if(isFutureDate(new Date(year,month,day)) || selectRect.visible)
                                        {
                                            return
                                        }
                                        control.current = new Date(year,month,day)
                                        control.accepted()
                                        setCurrentDate()
                                    }
                                }
                                background: Item {
                                    x: grid.leftPadding
                                    y: grid.topPadding
                                    width: grid.availableWidth
                                    height: grid.availableHeight
                                }
                            }

                            function updateYearMonth(){
                                var month = (currentIndex % 12) + 1 > 12 ? 1 : (currentIndex % 12) + 1
                                calender_model.curYear = d.displayDate.toLocaleString(FluApp.locale, "yyyy")
                                calender_model.curMonth = month < 10 ? "0" + month : month
                            }
                        }
                    }
                    Item{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
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
                    implicitWidth:Math.max(ScreenTools.calculateTextWidth(backTodayLabel.text) +ScreenTools.scaleNum(12), ScreenTools.scaleNum(32))
                    Layout.topMargin: ScreenTools.scaleNum(8)
                    radius:ScreenTools.scaleNum(16)
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
                            onCurrentSelectDate();
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
    
        FluShadow{
            visible: shadowVisible
            radius: ScreenTools.scaleNum(6)
        }
    }

    function setCurrentDate(){
        updateCurDate(control.current)
    }

    function onCurrentSelectDate() {
        updateCurDate(new Date())
        selectData(currentSelectDate)
    }

    function showDeviceCalendar(dateStr) {
        updateCurDate(dataStr)
    }

    function updateCurDate(dataStr)
    {
        var today = new Date(dataStr)
        var todayYear = today.getFullYear()
        var todayMonth = today.getMonth()
        var todayDay = today.getDate()
        control.current = today
        currentSelectDate = todayYear + "-" + (("0" + (todayMonth + 1)).slice(-2)) + "-" + ("0" + todayDay).slice(-2)
        d.displayDate = new Date(todayYear, todayMonth, 1)
        updateIndex(calender_model.indexOf(d.displayDate))
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

    function updateDate()
    {
        confirmData(currentSelectDate)
    }

    onVisibleChanged: {
        if(!visible && control.current)
        {
            updateCurDate(control.current)
        }
    }
}
