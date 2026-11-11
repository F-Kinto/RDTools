import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import FluentUI 1.0
import Component.FluComponent 1.0

Item {
    id: timeBtn
    width: ScreenTools.scaleNum(338)
    height: ScreenTools.scaleNum(36)
    property string startTime: "00:00"
    property string endTime: "23:59"
    property bool down: false

    function reset(){
        timeBtn.down = false
        timeBtn.startTime = "00:00"
        timeBtn.endTime = "23:59"
        startTxt.color = "#999999"
        endTxt.color = "#999999"
        timePickerDialog.resetTime()
    }

    Rectangle {
        anchors.fill: parent
        border.color: timeBtn.down ? ThemeColorStyle.border_checked_color : ThemeColorStyle.border_nor_color
        border.width: timeBtn.down ? 2 : 1
        radius: ScreenTools.scaleNum(4)
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0
        Item {
            width: ScreenTools.scaleNum(8)
        }

        Text {//按下状态
            id: startTxt
            Layout.alignment: Qt.AlignVCenter
            text: timeBtn.startTime
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(12, true)
            color: ThemeColorStyle.text_nor_color
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }

        Item {
            width: ScreenTools.scaleNum(39)
        }

        Rectangle{ 
            height: ScreenTools.scaleNum(2)
            width: ScreenTools.scaleNum(8)
            color: ThemeColorStyle.text_nor_color
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            width: ScreenTools.scaleNum(20)
        }

        Text {//按下状态
            id: endTxt
            Layout.alignment: Qt.AlignVCenter
            text: timeBtn.endTime
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(12, true)
            color: ThemeColorStyle.text_nor_color
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        FluCustomSvg{
            imageWidth: ScreenTools.scaleNum(24)
            imageHeight: ScreenTools.scaleNum(24)
            Layout.alignment: Qt.AlignVCenter
            sourceImage: CommonImageStyle.time_schedule_img
            fillColorFirst: timePickerDialog.visible || hovered ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.text_nor_color
        }

        Item {
            width: ScreenTools.scaleNum(12)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            timeBtn.down = !timeBtn.down;
            if (timeBtn.down) {
                timePickerDialog.open();
            } else {
                timePickerDialog.close();
                
            }
        }
    }

    TimePickerDialog {
        id: timePickerDialog
        x: 0
        y: timeBtn.height + ScreenTools.scaleNum(8)
        onTimeSelected: function(startHour, startMinute, endHour, endMinute) {
            timeBtn.startTime = `${startHour.toString().padStart(2, '0')}:${startMinute.toString().padStart(2, '0')}`;
            timeBtn.endTime = `${endHour.toString().padStart(2, '0')}:${endMinute.toString().padStart(2, '0')}`;
            endTxt.color = ThemeColorStyle.title_text_nor_color;
            startTxt.color = ThemeColorStyle.title_text_nor_color;
            console.log("startTime:", timeBtn.startTime,"endTime:", timeBtn.endTime);
        }
        onVisibleChanged: {
            if (!timePickerDialog.visible && timeBtn.down) {
                timeBtn.down = false;
            }
        }
    }
}
