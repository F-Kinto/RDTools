import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import Qt.labs.calendar 1.0
import ConfigureManager 1.0
import Component.FluComponent 1.0
import ScreenTools 1.0

FluCustomIconButton {
    id:control
    property string curDateString: Qt.formatDateTime(new Date(), "yyyy-MM-dd")
    property string curSelectData: curDateString
    //Pick案件类型  0:日期选择 1:时间选择 2:双日期选择
    property int pickerType: 0    
    text: {
        if(pickerType==0){
            return qsTr("Select date")
        }else{
            return qsTr("Start time – End time")
        } 
    }
    alignmentValue: Qt.AlignLeft
    //implicitWidth: Math.max(ScreenTools.calculateTextWidth(control.text, 12, false, false) + 40, 160)
    buttonWidth: 160

    // 背景颜色
    normalColor: "transparent"
    hoverColor: "transparent"
    pressedColor: "transparent"

    // 文本颜色
    textNormalColor: ThemeColorStyle.text_nor_color
    textBtnHoverColor: ThemeColorStyle.text_nor_color
    textBtnPressedColor: ThemeColorStyle.text_nor_color

    property var current
    signal accepted()
    signal durTimeSelected(string start, string end)
    signal cancelled()
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    onClicked: {
        popup.showPopup()
    }

    // 供外部调用，弹出选择器弹窗
    function openPopup() {
        popup.showPopup()
    }
    rightPadding: LayoutMirroring.enabled ? undefined : 36
    leftPadding: LayoutMirroring.enabled ? 36 : undefined

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        radius: ScreenTools.scaleNum(4)
        border.color: !popup.visible ? ThemeColorStyle.border_nor_color : ThemeColorStyle.border_checked_color
    }

    Item{
        id:d
        property var window : Window.window
    }
    FluCustomSvg{
        imageWidth: ScreenTools.scaleNum(16)
        imageHeight: ScreenTools.scaleNum(16)
        sourceImage: pickerType===1 ? CommonImageStyle.time_schedule_img : CommonImageStyle.date_img
        fillColorFirst: {
            if(hovered || pressed || popup.visible){
                return ThemeColorStyle.privacy_text_color
            }
            return ThemeColorStyle.text_nor_color
        }
        anchors{
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: ScreenTools.scaleNum(1)
            right: parent.right
            rightMargin: ScreenTools.scaleNum(12)
        }
        onClicked: {
            popup.showPopup() 
        }
    }

    Popup {
        id:popup
        //x: ConfigureManager.isRTLLayout ? 25 : (playBackVideoItem.width-selectCalendarLoader.item.width-25)
        y:-(selectCalendarLoader.item.height);
        modal: true
        background: null

        // 标记弹窗是否已确认选择（选择日期/时间后为true，关闭时未确认则发出cancelled信号）
        property bool _confirmed: false

        onAboutToShow: {
            _confirmed = false
        }

        onClosed: {
            if (!_confirmed) {
                control.cancelled()
            }
        }

        Loader {
            id:selectCalendarLoader
            // 不同功能调用不同的qml组件
            source:{
                if(control.pickerType==0){
                    return "qrc:/Component/Edit/FluCustomCalendar.qml"
                }else if(control.pickerType==1){
                    return "qrc:/Component/Edit/FluDurTimePicker.qml"
                }else{
                    return "qrc:/Component/Edit/FluDurDataPicker.qml"
                }
            }

            onStatusChanged: {
                if (status == Loader.Ready) {
                    selectCalendarLoader.x= popup.x;
                    selectCalendarLoader.y= popup.y;
                    item.selectData.connect(selectDate);
                    item.close.connect(handleClose);
                    item.timeSelected.connect(timeSelected);
                    //item.currentSelectDate=DispatchManager.cloudObj.userSelecTimeStr.length?DispatchManager.cloudObj.userSelecTimeStr:""
                }
            }
        }

        Overlay.modal: Rectangle {
            color: "transparent"
        }

        closePolicy: Popup.CloseOnPressOutside

        function showPopup() {
            var pos = control.mapToItem(null, 0, 0)
            if(d.window.height>pos.y+control.height+popup.height){
                popup.y = control.height - 1
            } else if(pos.y>popup.height){
                popup.y = -popup.height
            } else {
                popup.y = d.window.height-(pos.y+popup.height)
            }
            popup.open()
        }
    }

    function selectDate(date){
        popup._confirmed = true
        curSelectData = Qt.formatDateTime(date, "yyyy-MM-dd")
        control.text = curSelectData
    }

    function handleClose() {
        popup.close()
    }

    function timeSelected(start,end){
        popup._confirmed = true
        curSelectData = start + " - " + end
        text = curSelectData
        durTimeSelected(start, end)
    }
}
