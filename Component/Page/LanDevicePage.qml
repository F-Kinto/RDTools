/*********************************************************************
File : LanSearchPage.qml
Module : DeviceManager
Authors: guangnan
date : 2023/07/12 16:00
Ver : 1.0.0
History:
guangnan 2023/07/12 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtGraphicalEffects 1.15
import QtQml 2.15
import Component.Login 1.0
import ScreenTools 1.0
import Component.Edit 1.0
import Component.Button 1.0
import Component.FluButton 1.0
import Component.FluComponent 1.0
import VMS.Enum 1.0
import ConfigureManager 1.0
import InformationNotifier 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import DeviceMessage 1.0
import QtQuick.Window 2.15

// Independent window modal pop-up
Rectangle {
    property int addSuccessCount: 0
    property int addFailCount: 0
    property int minWidthLimit: ScreenTools.scaleNum(800)
    property int minHeightLimit: ScreenTools.scaleNum(500)
    property int rescanWidth: ScreenTools.scaleNum(104)
    property int layoutSpacing: ScreenTools.scaleNum(6)
    property real lanMargin: ScreenTools.scaleNum(24)
    property int listInnerWidth: width - lanMargin * 2
    property int currentSelectCount: 0

    id: dialog
    objectName: "lanDevicePage"
    width: ScreenTools.scaleNum(1340)
    height: ScreenTools.scaleNum(726)
    color: "#FFFFFF"
    radius: ScreenTools.isWin7System ? 0 : ScreenTools.scaleNum(12)
    clip: !ScreenTools.isWin7System

    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"
        radius: ScreenTools.scaleNum(12)
        ColumnLayout{
            anchors.fill: parent
            spacing: ScreenTools.scaleNum(16)

            FluCustomLable{
                id: statuText
                objectName: "statuText"
                currentTextColor: ThemeColorStyle.title_text_nor_color
                Layout.fillWidth: true
                Layout.leftMargin: dialog.lanMargin
                Layout.topMargin: ScreenTools.scaleNum(20)
                height: ScreenTools.scaleNum(32)
                currentBackgroundColor: "transparent"
                text: qsTr("LAN Device")
                borderWidth: 0
                alignValue: Text.AlignLeft
                fontSize: ScreenTools.scaleNum(12, true)
                isBold: true
            }
            

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.leftMargin: dialog.lanMargin
                Layout.rightMargin: dialog.lanMargin

                Rectangle {
                    id: outerRect
                    anchors.fill: parent
                    radius:ScreenTools.scaleNum(12)
                    color: "#FFFFFF"
                    border.color: "#EDEFF2"
                    border.width: 1
                    visible: lanDeviceView.count
                    clip: true
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: outerRect.width
                            height: outerRect.height
                            radius: outerRect.radius
                        }
                    }

                    ColumnLayout{
                        anchors.fill: parent
                        anchors.margins: 1
                        
                        clip: true
                        // Table header
                        Rectangle {
                            id: titleBg
                            Layout.fillWidth: true
                            Layout.preferredHeight: ScreenTools.scaleNum(56)
                            color: "#F5F7FA"
                            visible: lanDeviceView.count
                            RowLayout{
                                id:titleLayout
                                anchors.fill: parent
                                spacing: dialog.layoutSpacing

                                FluCustomCheckBox {
                                    id: selectAllCheck
                                    objectName: "selectAllCheck"
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: listInnerWidth * 0.4
                                    Layout.preferredHeight: ScreenTools.scaleNum(16)
                                    size: ScreenTools.scaleNum(16)
                                    Layout.leftMargin: ScreenTools.scaleNum(16)
                                    text: qsTr("Device ID")
                                    enabled : lanDeviceView.count
                                    textColor:ThemeColorStyle.title_text_nor_color
                                    checked: lanDeviceView.count?(currentSelectCount === lanDeviceView.count):false
                                    borderDisableColor: ThemeColorStyle.border_checked_color
                                    checkedDisableColor: ThemeColorStyle.border_checked_color
                                    onClicked:{
                                        DispatchManager.deviceObj.lanDeviceList.setAllIsSelect(currentSelectCount < lanDeviceView.count);
                                        currentSelectCount = (currentSelectCount < lanDeviceView.count) ? lanDeviceView.count : 0
                                    }
                                }

                                // IP
                                Label {
                                    id:ipLabel2
                                    objectName: "ipLabel2"
                                    text: qsTr("IP")
                                    font.pointSize: ScreenTools.scaleNum(10, true)
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: listInnerWidth * 0.3
                                    horizontalAlignment: Text.AlignLeft
                                    font.family:ScreenTools.fontFamily
                                    color: ThemeColorStyle.title_text_nor_color
                                    elide: Text.ElideRight
                                    background:Rectangle{
                                        anchors.fill: parent
                                        color: "transparent"
                                    }
                                }

                                // MAC
                                Label {
                                    id:macLabel2
                                    objectName: "macLabel2"
                                    text: qsTr("MAC address")
                                    font.pointSize: ScreenTools.scaleNum(10, true)
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: listInnerWidth * 0.3
                                    horizontalAlignment: Text.AlignLeft
                                    font.family:ScreenTools.fontFamily
                                    color: ThemeColorStyle.title_text_nor_color
                                    elide: Text.ElideRight
                                }
                            }
                        }
                        
                        ListView {
                            id: lanDeviceView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: (dispatchManagerIsNull && DispatchManager.deviceObj && DispatchManager.deviceObj.lanDeviceList) ? DispatchManager.deviceObj.lanDeviceList : null
                            delegate: lanDeviceDelegate
                            clip: true
                            spacing: 0
                            flickableDirection: Flickable.AutoFlickIfNeeded
                            Component.onCompleted:{
                                currentSelectCount = DispatchManager.deviceObj.lanDeviceList.selectCount()
                            }
                            //boundsBehavior:Flickable.StopAtBound
                        } 
                    }

                }


                // Device Not Found Prompt Area
                Rectangle{
                    id:showTipsRect
                    anchors.fill: parent
                    visible: !lanDeviceView.count && !showProgressBarRect.visible
                    ColumnLayout{
                        anchors.fill: parent
                        spacing: ScreenTools.scaleNum(24)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: ScreenTools.scaleNum(24)
                        anchors.rightMargin: ScreenTools.scaleNum(24)
                        Item{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        FluCustomImageLoader{
                            id:deviceStatus
                            Layout.alignment: Qt.AlignCenter
                            normalImageUrl: CommonPngImageStyle.deviceStatus_img
                            imageWidth: ScreenTools.scaleNum(322)
                            imageHeight: ScreenTools.scaleNum(220)
                        }
                        FluCustomLable{
                            objectName: "noLanDeviceTips"
                            currentTextColor: ThemeColorStyle.title_text_nor_color
                            Layout.fillWidth: true
                            Layout.preferredHeight: ScreenTools.scaleNum(32)
                            currentBackgroundColor: "transparent"
                            text: qsTr("No device was found. Please confirm the device status")
                            borderWidth: 0
                        }
                        FluCustomIconButton {
                            id: tryAgainBtn1
                            objectName: "tryAgainBtn1"
                            Layout.alignment: Qt.AlignCenter
                            buttonWidth: rescanWidth
                            buttonHeight: ScreenTools.scaleNum(34)
                            font.pointSize: ScreenTools.scaleNum(10, true)
                            display: Button.TextBesideIcon                           
                            textNormalColor: ThemeColorStyle.okBtn_text_color
                            normalColor: ThemeColorStyle.okBtn_bg_color
                            disableColor:ThemeColorStyle.border_nor_color
                            borderWidth : 0
                            sourceImgUrl: CommonImageStyle.refresh_img
                            text: qsTr("Rescan")
                            onClicked:{
                                DispatchManager.deviceObj.startFindLanDevice();
                                showSearchProgressBar.value=0;
                                scanLanDeviceTimer.count=0;
                                scanLanDeviceTimer.start();
                            }
                        }
                        Item{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }

                // Search progress bar area (This progress bar is displayed during the device scan timer operation)
                Rectangle{
                    id:showProgressBarRect
                    anchors.fill: parent
                    visible: false
                    states: State {
                        when:scanLanDeviceTimer.running
                        PropertyChanges { target: showProgressBarRect; visible: true }
                    }

                    ProgressBar{
                        id:showSearchProgressBar
                        value: 0.0
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: (143/396) * dialog.height
                        background: Rectangle {
                            implicitWidth: 0.6 * dialog.width
                            implicitHeight: ScreenTools.scaleNum(6)
                            color: ConfigureManager.isRTLLayout ? ThemeColorStyle.privacy_text_color : "#E0E0E0"
                            radius: ScreenTools.scaleNum(4)
                        }

                        // Progress bar fill area
                        contentItem: Item {
                            implicitWidth: 0.6 * dialog.width
                            implicitHeight: ScreenTools.scaleNum(6)

                            Rectangle {
                                implicitWidth: showSearchProgressBar.visualPosition * parent.width
                                implicitHeight: parent.height
                                radius: ScreenTools.scaleNum(4)
                                color: ConfigureManager.isRTLLayout ? "#E0E0E0" : ThemeColorStyle.privacy_text_color
                            }
                        }
                    }
                    Label {
                        objectName: "lanSearchingTips"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: showSearchProgressBar.bottom
                        anchors.topMargin: ScreenTools.scaleNum(24)
                        text:qsTr("Searching for LAN devices, please wait...")
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        font.family: ScreenTools.fontFamily
                        color: ThemeColorStyle.title_text_nor_color
                    }
                }
            }

            // Divider
            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#333333"
                opacity: 0.3
                visible: false
            }

            // Bottom button area
            Rectangle{
                id: bottomItem
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.scaleNum(64)
                Layout.leftMargin: dialog.lanMargin
                Layout.rightMargin: dialog.lanMargin
                Layout.bottomMargin: ScreenTools.scaleNum(16)
                color: "#FFFFFF"
                clip: true

                RowLayout{
                    anchors.fill: parent
                    spacing: ScreenTools.scaleNum(24)
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    FluCustomIconButton {
                        id: addDeviceBtn
                        objectName: "addDeviceBtn"
                        buttonWidth: rescanWidth
                        buttonHeight: ScreenTools.scaleNum(34)
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        display: Button.TextBesideIcon
                        disabled: (dispatchManagerIsNull && DispatchManager.deviceObj && DispatchManager.deviceObj.lanDeviceList) ? !DispatchManager.deviceObj.lanDeviceList.isHaveItemChecked : true
                        textNormalColor: ThemeColorStyle.okBtn_text_color
                        normalColor: ThemeColorStyle.okBtn_bg_color
                        disableColor:ThemeColorStyle.border_nor_color
                        borderWidth : disabled ? 1 : 0
                        sourceImgUrl: CommonImageStyle.add_img
                        text: qsTr("Add Now")
                        visible: lanDeviceView.count
                        onClicked: Qt.callLater(() =>{
                            if(showAddDeviceInfo.visible || addDeviceMask.visible){
                                return;
                            }
                            addDeviceMask.visible=true;
                            let resutList=DispatchManager.deviceObj.addDeviceToLanList();
                            if(resutList.length){
                                addSuccessCount=resutList[1];
                                addFailCount=resutList[0];
                                addDeviceMask.visible=false;
                                showAddDeviceInfo.visible=true;
                            }
                        });
                    }

                    FluCustomIconButton {
                        id: tryAgainBtn
                        objectName: "tryAgainBtn"
                        buttonWidth: rescanWidth
                        buttonHeight: ScreenTools.scaleNum(34)
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        display: Button.TextBesideIcon
                        textNormalColor: ThemeColorStyle.privacy_text_color
                        borderWidth: 1
                        borderNormalColor: ThemeColorStyle.border_checked_color
                        sourceImgUrl: CommonImageStyle.refresh_img
                        text: qsTr("Rescan")
                        visible: lanDeviceView.count
                        onClicked:{
                            if(showAddDeviceInfo.visible || addDeviceMask.visible){
                                return;
                            }
                            DispatchManager.deviceObj.startFindLanDevice();
                            showSearchProgressBar.value=0;
                            scanLanDeviceTimer.count=0;
                            scanLanDeviceTimer.start();
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // Update the scan progress every second, and stop scanning after ten seconds.
                    Timer{
                        id:scanLanDeviceTimer
                        property int count:0
                        repeat: true
                        interval: 1*1000
                        running: false
                        onTriggered: {
                            if(++count>=10){
                                count=0;
                                // Stop the timer after ten seconds
                                scanLanDeviceTimer.stop();
                                // Call the API to stop discovering devices on the local area network.
                                DispatchManager.deviceObj.stopFindLanDevice();
                                return;
                            }
                            showSearchProgressBar.value=count/10.0;
                        }
                    }
                }
            }
        }
    }
    
    // List data proxy
    Component{
        id:lanDeviceDelegate
        Rectangle{
            id:oneItem
            width: view ? view.width : implicitWidth
            implicitHeight: msgLayout.height + (labelText.visible ? ScreenTools.scaleNum(18) : 0) + separator.height
            color: "transparent"
            property var view: ListView.view
            property var obj: model.Obj
            property var deviceMsg: obj && obj.deviceMsg ?obj.deviceMsg :null

            Item {
                anchors.fill: parent

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Equivalent to lanDeviceView.currentIndex = ...
                        oneItem.view.currentIndex = index;
                    }
                }

                ColumnLayout{
                    width: parent.width
                    spacing: 0

                    // One line of device data
                    RowLayout{
                        id:msgLayout
                        Layout.fillWidth: true
                        Layout.preferredHeight: ScreenTools.scaleNum(50)
                        spacing: dialog.layoutSpacing

                        // Checkbox + Device ID
                        FluCustomCheckBox {
                            id: addCheck
                            objectName: "addCheck_" + index
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: listInnerWidth * 0.4
                            Layout.preferredHeight: ScreenTools.scaleNum(16)
                            size: ScreenTools.scaleNum(16)
                            Layout.leftMargin: ScreenTools.scaleNum(16)
                            text: deviceMsg?deviceMsg.uid:""
                            textColor:ThemeColorStyle.title_text_nor_color
                            checked: obj ? obj.isSelect : false
                            borderDisableColor: ThemeColorStyle.border_checked_color
                            checkedDisableColor: ThemeColorStyle.border_checked_color
                            onClicked:{
                                if(obj) obj.isSelect=checked;
                                if(obj && obj.isSelect){
                                    currentSelectCount++;
                                }else{
                                    currentSelectCount--;
                                }
                            }
                        }

                        // Device IP
                        Label {
                            id:ipLabel
                            objectName: "ipLabel_" + index
                            text: deviceMsg? deviceMsg.ip:""
                            font.pointSize: ScreenTools.scaleNum(10, true)
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: listInnerWidth * 0.3
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            font.family:ScreenTools.fontFamily
                            color: ThemeColorStyle.title_text_nor_color
                        }

                        // Device MAC
                        Label {
                            id:macLabel
                            objectName: "macLabel_" + index
                            text: deviceMsg?deviceMsg.mac:""
                            font.pointSize: ScreenTools.scaleNum(10, true)
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: listInnerWidth * 0.3
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            font.family:ScreenTools.fontFamily
                            color: ThemeColorStyle.title_text_nor_color
                        }
                    }

                    // Reasons for failure
                    Label {
                        id:labelText
                        objectName: "labelText_" + index
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: ScreenTools.scaleNum(46)
                        Layout.fillWidth: true
                        height:ScreenTools.scaleNum(6)
                        text:obj? obj.errorTips.length ? qsTr("Add failed, reason for failure:%1").arg(obj.errorTips) : "" : ""
                        visible: obj && obj.errorTips.length
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        font.family: ScreenTools.fontFamily
                        color: "red"
                    }

                    Rectangle {
                        id: separator
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#EDEFF2"
                        visible: true
                    }
                }
            }
        }
    }

    // Semi-transparent mask
    Rectangle{
        id: addDeviceMask
        anchors.fill: parent
        color: "#1B2730"
        opacity: 0.6
        visible:false

        MouseArea {
            anchors.fill: parent
        }
    }

    // Adding devices
    Loader {   
        id: addDeviceLoader
        anchors.fill: parent 
        active: addDeviceMask.visible
        sourceComponent:Item {
            anchors.fill: parent
            function setProgress(val){
                addDeviceProgressBar.value = val
            }
            Rectangle {
                implicitWidth: ScreenTools.scaleNum(360)
                implicitHeight: ScreenTools.scaleNum(140)
                color: "#FFFFFF"
                anchors.centerIn: parent
                opacity: 1.0
                radius:ScreenTools.scaleNum(8)
                Column{
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: ScreenTools.scaleNum(14)
                    Label {
                        objectName: "deviceAdding"
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Adding device")
                        font.family: ScreenTools.fontFamily
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        color:ThemeColorStyle.title_text_nor_color
                    }
                    ProgressBar{
                        id:addDeviceProgressBar
                        anchors.horizontalCenter: parent.horizontalCenter
                        value: 0.0
                        background: Rectangle {
                            implicitWidth: ScreenTools.scaleNum(270)
                            implicitHeight: ScreenTools.scaleNum(6)
                            color: ConfigureManager.isRTLLayout ? ThemeColorStyle.privacy_text_color : "#E0E0E0"
                            radius: ScreenTools.scaleNum(4)
                        }

                        contentItem: Item {
                            implicitWidth: ScreenTools.scaleNum(270)
                            implicitHeight: ScreenTools.scaleNum(6)


                            Rectangle {
                                implicitWidth: addDeviceProgressBar.visualPosition * parent.width
                                implicitHeight: parent.height
                                radius: ScreenTools.scaleNum(4)
                                color: ConfigureManager.isRTLLayout ? "#E0E0E0" : ThemeColorStyle.privacy_text_color
                            }
                        }

                    }
                    Label {
                        objectName: "addingPercent"
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: String("%1%").arg(addDeviceProgressBar.value*100)
                        font.family: ScreenTools.fontFamily
                        font.pointSize: ScreenTools.scaleNum(12, true)
                        color:ThemeColorStyle.title_text_nor_color

                    }
                }
            }
        }
    }

    // Semi-transparent mask
    Rectangle{
        id:showAddDeviceInfo
        anchors.fill: parent
        opacity: 0.6
        visible:false
        color: "#1B2730"

        // Intercept mouse events
        MouseArea {
            anchors.fill: parent
        }
    }

    // Added complete
    Loader {
        id: addCompleteLoader
        anchors.fill: parent
        active: showAddDeviceInfo.visible
        sourceComponent: Item {
            anchors.fill: parent
            Rectangle{
                radius:ScreenTools.scaleNum(8)
                implicitWidth: ScreenTools.scaleNum(360)
                implicitHeight: ScreenTools.scaleNum(140)
                color: "#FFFFFF"
                anchors.centerIn: parent
                Label {
                    objectName: "addCompleted"
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Add completed")
                    font.family: ScreenTools.fontFamily
                    font.pointSize: ScreenTools.scaleNum(12, true)
                    color:ThemeColorStyle.title_text_nor_color
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: ScreenTools.scaleNum(16)
                    anchors.leftMargin: ScreenTools.scaleNum(24)
                }
                Row{
                    anchors.left: parent.left
                    anchors.leftMargin: ScreenTools.scaleNum(24)
                    anchors.top: parent.top
                    anchors.topMargin: ScreenTools.scaleNum(46)
                    spacing: ScreenTools.scaleNum(12)
                    Image {
                        source: CommonPngImageStyle.info_success24_img
                        anchors.verticalCenter: parent.verticalCenter
                        width: ScreenTools.scaleNum(18)
                        height: ScreenTools.scaleNum(18)
                    }
                    Label {
                        objectName: "addSuccessLabel"
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Add device success: %1").arg(addSuccessCount)
                        font.family: ScreenTools.fontFamily
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        color:ThemeColorStyle.text_nor_color
                    }

                }
                Row{
                    anchors.left: parent.left
                    anchors.leftMargin: ScreenTools.scaleNum(22)
                    anchors.top: parent.top
                    anchors.topMargin: ScreenTools.scaleNum(74)
                    spacing: ScreenTools.scaleNum(12)
                    FluCustomSvg{
                        imageWidth: ScreenTools.scaleNum(20)
                        imageHeight: ScreenTools.scaleNum(20)
                        Layout.alignment: Qt.AlignVCenter
                        sourceImage: CommonImageStyle.tip_error_img
                        fillColorFirst: ThemeColorStyle.privacy_error_color
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        objectName: "addFailed"
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Add device failed: %1").arg(addFailCount)
                        font.family: ScreenTools.fontFamily
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        color:ThemeColorStyle.text_nor_color
                    }

                }

                FluCustomIconButton {
                id: closeShowInfoBtn
                objectName: "closeShowInfoBtn"
                anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin:ScreenTools.scaleNum(16)
                    anchors.rightMargin: ScreenTools.scaleNum(24)
                    buttonWidth: Math.max(ScreenTools.calculateMultiTextWidth(closeShowInfoBtn.text,closeShowInfoBtn.font.pointSize, false, false) + ScreenTools.scaleNum(14), ScreenTools.scaleNum(64))
                    buttonHeight: ScreenTools.scaleNum(28)
                    font.pointSize: ScreenTools.scaleNum(10, true)
                    textNormalColor: ThemeColorStyle.okBtn_text_color
                    normalColor: ThemeColorStyle.okBtn_bg_color
                    borderWidth : 0
                    text: qsTr("OK")
                    onClicked:{
                        showAddDeviceInfo.visible=false;
                    }
                }
            }
        }
    }

    Connections{
        target: (dispatchManagerIsNull && DispatchManager.deviceObj) ? DispatchManager.deviceObj : null
        function onSignalAddDevicePercent(p){
            if(addDeviceLoader.item)
                addDeviceLoader.item.setProgress(p.toFixed(2))
        }
    }

    onVisibleChanged: {
        if(visible){
            rescanWidth = Math.max(ScreenTools.calculateMultiTextWidth(qsTr("Rescan"),qsTr("Add Now")) + ScreenTools.scaleNum(40), ScreenTools.scaleNum(104))
            DispatchManager.deviceObj.clearLanErrorTips()
            currentSelectCount = DispatchManager.deviceObj.lanDeviceList.selectCount()
        }
    }

    // 将局域网设备列表中的指定设备行滚动到可视区域
    function positionLanDeviceAtIndex(index) {
        if (index < 0 || index >= lanDeviceView.count) {
            return false
        }
        lanDeviceView.positionViewAtIndex(index, ListView.Contain)
        return true
    }
}
