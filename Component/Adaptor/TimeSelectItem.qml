import QtGraphicalEffects 1.0
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import ScreenTools 1.0
import ConfigureManager 1.0
import Component.FluButton 1.0

Item {
    id: root
    width: ScreenTools.scaleNum(388)
    height: ScreenTools.scaleNum(210)
    property string dateTime: Qt.formatDateTime(new Date(), "yyyy-MM-dd");
    property bool isSwitchTime: false
    property bool nextEnable: false
    property bool leftEnable: true
    property bool loadFinished: false
    property string showEmptyText: qsTr("No recordings found")

    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    signal cancleClick();
    signal saveClick(string startTime, string endTime);
    signal switchDateTime(string dateTime);    

    // 添加日期处理函数
    function switchToDate(days) {
        // 将当前日期字符串转换为 Date 对象
        var currentDate = new Date(dateTime);
    
        // 添加或减去指定天数
        currentDate.setDate(currentDate.getDate() + days);
        
        let today = new Date()
        today.setHours(0, 0, 0, 0);
        let curData = currentDate;
        curData.setHours(0, 0, 0, 0);

        if(curData > today){
            console.log("Cannot switch to future dates");
            nextEnable = false;
            return;
        }

        nextEnable = true;
        // 格式化为 YYYY-MM-DD 字符串
        var year = currentDate.getFullYear();
        var month = (currentDate.getMonth() + 1).toString().padStart(2, '0');
        var day = currentDate.getDate().toString().padStart(2, '0');
        
        // 更新日期显示
        dateTime = year + "-" + month + "-" + day;
        switchDateTime(dateTime);
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#FFFFFF"
        radius: ScreenTools.scaleNum(8)
        border.width: 1
        border.color: ThemeColorStyle.border_nor_color
    }

    ColumnLayout {
        width: parent.width - ScreenTools.scaleNum(2)
        height: parent.height - ScreenTools.scaleNum(2)
        anchors.centerIn: parent
        spacing: 0
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        Item{
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.scaleNum(48)
            
            Label{
                text: qsTr("Select Time")
                font.pointSize: ScreenTools.scaleNum(14,true)
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.scaleNum(20)
                anchors.verticalCenter: parent.verticalCenter
                font.family: ScreenTools.fontFamily
            }
            RowLayout{
                anchors.right: parent.right
                anchors.rightMargin: ScreenTools.scaleNum(20)
                anchors.verticalCenter: parent.verticalCenter
                spacing: ScreenTools.scaleNum(12)
                FluCustomIconButton{
                    id:prevBtn
                    display: Button.IconOnly
                    width: ScreenTools.scaleNum(32)
                    height: ScreenTools.scaleNum(32)
                    iconSize: ScreenTools.scaleNum(20)
                    iconOnlyNeedHoverBg: true
                    rotation: ConfigureManager.isRTLLayout ? 0 : 180
                    sourceImgUrl: CommonImageStyle.list_arrow_right_img
                    textBtnHoverColor: ThemeColorStyle.privacy_text_color
                    onClicked:{
                        switchToDate(-1);
                    }
                }

                Label{
                    text: dateTime
                    font.pointSize: ScreenTools.scaleNum(14,true)
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                    font.family: ScreenTools.fontFamily
                }

                FluCustomIconButton{
                    id:nextBtn
                    display: Button.IconOnly
                    width: ScreenTools.scaleNum(32)
                    height: ScreenTools.scaleNum(32)
                    iconSize: ScreenTools.scaleNum(20)
                    iconOnlyNeedHoverBg: true
                    rotation: ConfigureManager.isRTLLayout ? 180 : 0
                    sourceImgUrl: CommonImageStyle.list_arrow_right_img
                    textBtnHoverColor: ThemeColorStyle.privacy_text_color
                    onClicked:{
                        switchToDate(1);
                    }
                }
            }
           
        }

        Rectangle{
            Layout.fillWidth: true
            height: 1
            color: "#E7E7E7"
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.scaleNum(84)
           
            RowLayout {
                anchors.fill: parent
                height: ScreenTools.scaleNum(36)
                spacing: 0
                Item {
                    Layout.preferredWidth: ScreenTools.scaleNum(24)
                }

                TimeFilterBtn{
                    id: timeBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.scaleNum(36)
                }
                Item {
                    Layout.preferredWidth: ScreenTools.scaleNum(24)
                }
            }
        }

        Rectangle{
            Layout.fillWidth: true
            height: 1
            color: "#E7E7E7"
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.scaleNum(48)
            spacing: 0

            Item {
                width: ScreenTools.scaleNum(16)
            }

            FluCustomIconButton {
                id: resetBtn
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Math.max(ScreenTools.calculateTextWidth(resetBtn.text,resetBtn.font.pointSize, false, false) + ScreenTools.scaleNum(14), ScreenTools.scaleNum(64))
                Layout.preferredHeight:ScreenTools.scaleNum(32)
                font.pointSize: ScreenTools.scaleNum(12, true)
                iconSize: ScreenTools.scaleNum(16)
                display: Button.TextBesideIcon
                textNormalColor: ThemeColorStyle.privacy_text_color
                borderWidth: 0
                sourceImgUrl: CommonImageStyle.refresh_img
                text: qsTr("Reset")
                onClicked: {
                    timeBtn.reset();
                }
            }

            Item {
                Layout.fillWidth: true
            }

            FluCustomIconButton {
                id: cancelBtn
                Layout.alignment: Qt.AlignRight
                buttonWidth: Math.max(ScreenTools.calculateTextWidth(cancelBtn.text) + ScreenTools.scaleNum(14),ScreenTools.scaleNum(80))
                buttonHeight: ScreenTools.scaleNum(34)
                font.pointSize: ScreenTools.scaleNum(10, true)
                textNormalColor: ThemeColorStyle.cancelBtn_text_color
                normalColor: ThemeColorStyle.cancelBtn_bg_color
                borderWidth : 1
                text: qsTr("Cancel")
                onClicked: {
                    cancleClick();
                }
            }
            
            Item {
                width: ScreenTools.scaleNum(10)
            }
            
            // 确定按钮
            FluCustomIconButton {
                id: saveBtn
                buttonWidth: Math.max(ScreenTools.calculateTextWidth(saveBtn.text) + ScreenTools.scaleNum(14),ScreenTools.scaleNum(80))
                buttonHeight: ScreenTools.scaleNum(34)
                textNormalColor: ThemeColorStyle.okBtn_text_color
                normalColor: ThemeColorStyle.okBtn_bg_color
                borderWidth : 0
                text: qsTr("OK")
                onClicked: {
                    // 转化为平台格式 hh:mm:ss
                    saveClick(timeBtn.startTime + ":00", timeBtn.endTime + ":00");
                }
            }

            Item {
                width: ScreenTools.scaleNum(16)
            }
        }
    }
}
