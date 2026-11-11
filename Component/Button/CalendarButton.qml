import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import ScreenTools 1.0
import Component.FluComponent 1.0

Item {
    id:root

    signal selectDate(var date);

    property bool btnEnable: true
    property bool bDeviceObjChange: true
    property string curSelectDateStr: ""
    property alias _calendarBtn : calendarBtn

    FluCustomSvg{
        id: calendarBtn
        imageWidth: ScreenTools.scaleNum(24)
        imageHeight: ScreenTools.scaleNum(24)
        Layout.alignment: Qt.AlignVCenter
        // topPadding: -2
        tooltipText: qsTr("Date")
        sourceImage: CommonImageStyle.date_img
        fillColorFirst: getToolButtonColor(btnEnable, calendarPopup.opened, pressed, hovered)
        toolTipVisible: true
        onClicked: {
            var isOpen = calendarPopup.opened
            if(isOpen){
                calendarPopup.close()
            }else{
                if (root.bDeviceObjChange) {
                    if(!curSelectDateStr.length)
                        selectCalendarLoader.item.onCurrentSelectDate();

                    root.bDeviceObjChange = false;
                }
                calendarPopup.open()
                selectCalendarLoader.item.dateModel.setIsShowSelectDateMode(false);
                selectCalendarLoader.item.dateModel.setShowSelectDateList([]);
                selectCalendarLoader.item.dateModel.updateCalendar();
                selectCalendarLoader.item.visible=true;
            }
        }
    }

    Popup {
        id:calendarPopup
        x: - width / ScreenTools.scaleNum(2)
        y: calendarBtn.y + calendarBtn.height + ScreenTools.scaleNum(10)
        padding: 0 // 移除内边距
        modal: true
        background: null
        Loader{
            id:selectCalendarLoader
            source:"qrc:/Component/Edit/CustomCalendar.qml"

            onStatusChanged: {
                if(status == Loader.Ready){
                    item.confirmData.connect(function(date){ calendarPopup.close(); root.selectDate(date); });
                }
            }
        }
        
        Overlay.modal: Rectangle {
            color: "transparent"
        }

        closePolicy: Popup.CloseOnPressOutside
    }

    function getToolButtonColor(is_enable, is_checked, is_pressed, is_hovered){
        if(!is_enable){
            return ThemeColorStyle.tool_button_disable_color 
        }
        if(is_checked){
            return ThemeColorStyle.tool_button_active_color
        }
        if(is_pressed){
            return ThemeColorStyle.tool_button_press_color
        }
        if(is_hovered){
            return ThemeColorStyle.tool_button_hover_color
        }
        return ThemeColorStyle.tool_button_nor_color
    }
}
