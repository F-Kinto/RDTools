import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import InformationNotifier 1.0
import Component.Edit 1.0
import Component.Dialog 1.0
import Component.Adaptor 1.0
import Component.FluButton 1.0
import ScreenTools 1.0
import Component.TeamManage 1.0
import ConfigureManager 1.0
import TranslatorManager 1.0
import FluentUI 1.0
import Component.FluComponent 1.0
import Component.Page 1.0
import Component.Button 1.0
import Component.FluDeviceManager 1.0
import Component.DeviceManager 1.0
import VMS.Enum 1.0

Rectangle{
    id:deviceManagerWindow
    objectName: "deviceManagerView"
    property bool deviceObjIsNull: typeof DispatchManager !== "undefined" && DispatchManager && DispatchManager.deviceObj
    property int currentPageIndex: 0
    property int videoFontSize: ScreenTools.scaleNum(10, true)
    property int deviceNumber: 0
    property string fontFamily: ScreenTools.fontFamily
    property string searchKey:""
    property int searchMode: 0
    property string curDisplayText: currentPageIndex === 0 ? qsTr("All devices") : currentPageIndex === 1 ? qsTr("Account device") : qsTr("Local device")
    property var teamIdsArray:[]
    property double lastRefreshClickMs: 0   // 上次触发刷新时间戳
    border.width: 0
    border.color: ThemeColorStyle.border_nor_color
    color:"#FFFFFF"
    radius: ScreenTools.isWin7System ? 0 : ScreenTools.scaleNum(12)
    clip: !ScreenTools.isWin7System
    width: ScreenTools.scaleNum(1340)
    height: ScreenTools.scaleNum(726)

    Component {
        id: groupPage
        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout{
                anchors.fill: parent
                spacing: ScreenTools.scaleNum(2)
                Item{
                    Layout.fillWidth: true
                    height: ScreenTools.scaleNum(16)
                }
                
                FluCustomIconButton{
                    id: allDevicesBtn
                    objectName: "allDevicesBtn"
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.scaleNum(44)
                    alignmentValue: Qt.AlignLeft
                    textBtnHoverColor: ThemeColorStyle.privacy_text_color
                    text: qsTr("All devices")
                    display: Button.TextBesideIcon
                    isChecked: deviceManagerWindow.currentPageIndex === 0
                    borderWidth: 0
                    borderRadius: 1
                    fontSize: ScreenTools.scaleNum(10, true)
                    sourceImgUrl: CommonImageStyle.device_img
                    drowSourceImgUrl:  CommonImageStyle.list_arrow_right_img
                    drowBtnIsVisible: 1
                    rotateAngle: accountBtn.visible || localBtn.visible ? 90 : 0
                    rightBorderVisible: true
                    onClicked: {
                        if(deviceManagerWindow.currentPageIndex === 0)
                            return;
                        deviceManagerWindow.currentPageIndex = 0;
                    }
                    onDrawIconClicked:{
                        accountBtn.visible = !accountBtn.visible
                        localBtn.visible = !localBtn.visible
                    }
                }
                
                FluCustomIconButton{ 
                    id: accountBtn
                    objectName: "accountBtn"
                    text: qsTr("Account device")
                    textBtnHoverColor: ThemeColorStyle.privacy_text_color
                    Layout.fillWidth: true
                    display: Button.TextBesideIcon
                    rightBorderVisible: true
                    Layout.preferredHeight: ScreenTools.scaleNum(44)
                    iconOffset: ScreenTools.scaleNum(32)
                    alignmentValue: Qt.AlignLeft
                    isChecked: deviceManagerWindow.currentPageIndex === 1
                    sourceImgUrl: CommonImageStyle.account_dev_img
                    borderWidth: 0
                    borderRadius: 1
                    fontSize: ScreenTools.scaleNum(10, true)
                    onClicked: {
                        if(deviceManagerWindow.currentPageIndex === 1)
                            return;
                        deviceManagerWindow.currentPageIndex = 1;
                    }
                }
                
                FluCustomIconButton{
                    id: localBtn
                    objectName: "localBtn"
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.scaleNum(44)
                    display: Button.TextBesideIcon
                    alignmentValue: Qt.AlignLeft
                    iconOffset: ScreenTools.scaleNum(32)
                    text: qsTr("Local device")
                    textBtnHoverColor: ThemeColorStyle.privacy_text_color
                    isChecked: deviceManagerWindow.currentPageIndex === 2
                    sourceImgUrl: CommonImageStyle.local_dev_img
                    borderWidth: 0
                    rightBorderVisible: true
                    borderRadius: 1
                    fontSize: ScreenTools.scaleNum(10, true)
                    onClicked: {
                        if(deviceManagerWindow.currentPageIndex === 2)
                            return;
                        deviceManagerWindow.currentPageIndex = 2;
                    }
                }
                
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
    
    Item{
        anchors.fill: parent
        RowLayout{
            width: parent.width
            height: parent.height
            anchors.fill: parent
            spacing: 0
            
            ColumnLayout{
                id: tabColumnLayout
                Layout.fillHeight: true
                Layout.preferredWidth: ScreenTools.scaleNum(220)
                Layout.minimumWidth: ScreenTools.scaleNum(200)
                Layout.topMargin: ScreenTools.scaleNum(16)
                spacing: 1
                visible: true

                Rectangle{
                    id: titleLabel
                    Layout.preferredHeight: ScreenTools.scaleNum(28)
                    Layout.fillWidth: true
                    Layout.leftMargin: ScreenTools.scaleNum(16)
                    Layout.rightMargin: ScreenTools.scaleNum(4)
                    color: "#FFFFFF"

                    RowLayout{
                        anchors.fill: parent
                        spacing: ScreenTools.scaleNum(4)
                        Label{
                            id: title
                            objectName: "title"
                            property int _size: {
                                if(ConfigureManager.languageType == 9 || ConfigureManager.languageType == 2 || ConfigureManager.languageType == 7)
                                    return ScreenTools.scaleNum(10, true)
                                else
                                    return ScreenTools.scaleNum(12, true)
                            }
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Device Management") //+  " (" + deviceNumber + ")"
                            font.pointSize: _size
                            height: parent.height
                            font.family: fontFamily
                            font.bold: true
                        }
                        Item{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                        FluCustomSvg {
                            objectName: "deviceManagerBackArrowSvg"
                            imageWidth: ScreenTools.scaleNum(24)
                            imageHeight: ScreenTools.scaleNum(24)
                            Layout.preferredWidth: ScreenTools.scaleNum(28)
                            Layout.preferredHeight: ScreenTools.scaleNum(28)
                            Layout.alignment: Qt.AlignVCenter
                            rotation: ConfigureManager.isRTLLayout ? 180 : 0
                            sourceImage: CommonImageStyle.dock_left_img
                            svgType: VmsEnum.SvgColorTypeEnum.PureColor
                            fillColorFirst: {
                                if (!isEnabled) return ThemeColorStyle.tool_button_disable_color
                                if (pressed) return ThemeColorStyle.tool_button_active_color
                                if (hovered) return ThemeColorStyle.tool_button_hover_color
                                return ThemeColorStyle.tool_button_nor_color
                            }
                            tooltipText: qsTr("Collapse")
                            needBg: true
                            toolTipVisible: true
                            onClicked: {
                                tabColumnLayout.visible = false
                                expandRect.visible = true
                            }
                        }
                    }
                }

                FluDeviceTeamTree{
                    id: teamTree
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    itemWidth: ScreenTools.scaleNum(200)
                    bSubTreeModel: false
                    visible:ConfigureManager.topTeamId.length
                    onSelectionChanged:{
                        teamIdsArray = teamTree.getSelectedTeamIds()
                        deviceManagerWindow.updateTableModel()
                    }
                    Component.onCompleted: {
                        teamTree.isEnabled = false
                        teamTree.initCheckState()
                    }
                }

                StackView {
                    id: stack
                    initialItem: groupPage
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    visible: !ConfigureManager.topTeamId.length
                    replaceEnter: Transition {
                        PropertyAnimation {
                            target: stack
                            property: "opacity"
                            from: 0
                            to: 1
                            duration:0
                            easing.type: Easing.InElastic;
                            easing.amplitude: 0;
                            easing.period: 0
                        }
                    }
                    replaceExit: Transition {
                        PropertyAnimation {
                            target: stack
                            property: "opacity"
                            from: 1
                            to: 0
                            duration:0
                            easing.type: Easing.OutElastic;
                            easing.amplitude: 0;
                            easing.period: 0
                        }
                    }
                }
            }

            // =========================
            // 折叠状态：展开按钮
            // =========================
            ColumnLayout {
                id: expandRect
                Layout.fillHeight: true
                Layout.preferredWidth: ScreenTools.scaleNum(14)
                visible: false
                spacing: 0

                Item { Layout.fillHeight: true }

                FluCustomSvg {
                    id: expandButton
                    objectName: "deviceManagerExpandBtn"
                    Layout.alignment: Qt.AlignHCenter
                    itemWidth: ScreenTools.scaleNum(14)
                    itemHeight: ScreenTools.scaleNum(56)
                    imageWidth: ScreenTools.scaleNum(14)
                    imageHeight: ScreenTools.scaleNum(14)
                    radius: [0,6,6,0]
                    rotation: ConfigureManager.isRTLLayout ? 180 : 0
                    rectBgColor: "#DFE2E5"
                    needBg: true
                    sourceImage: CommonImageStyle.list_arrow_right_img
                    fillColorFirst: {
                        if (!isEnabled) return ThemeColorStyle.tool_button_disable_color
                        if (pressed || hovered) return ThemeColorStyle.tool_button_active_color
                        return ThemeColorStyle.tool_button_nor_color
                    }
                    tooltipText: qsTr("Expand")
                    toolTipVisible: true
                    onClicked: {
                        tabColumnLayout.visible = true
                        expandRect.visible = false
                    }
                }
                
                Item { Layout.fillHeight: true }
            }

            Rectangle{
                id: lineRect
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                visible: tabColumnLayout.visible
                color: "#EDEFF2"
            }

            Rectangle{
                id: contentRect
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: ScreenTools.scaleNum(2)
                Layout.bottomMargin: ScreenTools.scaleNum(2)
                width: deviceManagerWindow.width - lineRect.width - (expandRect.visible ? expandRect.width : tabColumnLayout.width)
                color: "#FFFFFF"
                radius: ScreenTools.scaleNum(16)

                Rectangle{
                    anchors.fill: parent
                    color:"transparent"
                    anchors.leftMargin: ScreenTools.scaleNum(12)
                    anchors.rightMargin: ScreenTools.scaleNum(12)
                    radius: ScreenTools.scaleNum(16)

                    ColumnLayout{
                        anchors.fill: parent
                        Layout.preferredWidth: contentRect.width
                        spacing: 0

                        RowLayout{
                            id: layout
                            Layout.preferredHeight: ScreenTools.scaleNum(60)
                            Layout.maximumHeight: ScreenTools.scaleNum(60)
                            Layout.fillWidth: true
                            spacing: ScreenTools.scaleNum(12)
                            Layout.leftMargin: ScreenTools.scaleNum(8)
                            Layout.rightMargin: ScreenTools.scaleNum(8)

                            FluCombolineEdit{
                                id: searchCombo
                                objectName: "deviceManagerSearchCombo"
                                Layout.preferredWidth: ScreenTools.scaleNum(360)
                                Layout.minimumWidth: ScreenTools.scaleNum(220)
                                Layout.preferredHeight: ScreenTools.scaleNum(34)
                                property string searchText: ""
                                property int selectIndex: 0
                                isCombox: true
                                comboModel: ListModel {
                                    ListElement { text: qsTr(" All ") }
                                    ListElement { text: qsTr(" Device Name ") }
                                    ListElement { text: qsTr(" Device ID ") }
                                }
                                onCommitIndexText:{
                                    searchText = text
                                    selectIndex = index
                                    if(text.length === 0){
                                        deviceManagerWindow.searchMode = index
                                        deviceManagerWindow.searchKey = text
                                    }
                                }
                            }

                            FluCustomIconButton {
                                id: searchBtn
								objectName: "searchBtn"
                                buttonWidth: Math.max(ScreenTools.calculateTextWidth(searchBtn.text,searchBtn.font.pointSize, false, false) + ScreenTools.scaleNum(14), ScreenTools.scaleNum(64))
                                buttonHeight:ScreenTools.scaleNum(36)
                                font.pointSize: videoFontSize
                                textNormalColor: ThemeColorStyle.okBtn_text_color
                                normalColor: ThemeColorStyle.okBtn_bg_color
                                borderWidth : 0
                                text: qsTr("Search")
                                onClicked: {
                                     deviceManagerWindow.searchKey = searchCombo.searchText
                                     deviceManagerWindow.searchMode = searchCombo.selectIndex
                                     console.log("searchKey:" + deviceManagerWindow.searchKey, searchCombo.searchText)
                                }
                            }

                            FluCustomIconButton {
                                id: resetBtn
								objectName: "resetBtn"
                                buttonWidth: Math.max(ScreenTools.calculateTextWidth(resetBtn.text,resetBtn.font.pointSize, false, false) + ScreenTools.scaleNum(14), ScreenTools.scaleNum(64))
                                buttonHeight:ScreenTools.scaleNum(36)
                                font.pointSize: videoFontSize
                                textNormalColor: ThemeColorStyle.cancelBtn_text_color
                                normalColor: ThemeColorStyle.cancelBtn_bg_color
                                borderWidth : 1
                                text: qsTr("Reset")
                                onClicked: {
                                    searchCombo.resetSearch();
                                }
                            }


                            Item{
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Timer {
                                id: refreshCooldownTimer
                                interval: 5000
                                repeat: false
                                running: false
                                onTriggered: {
                                    freshBtn.isEnabled = true
                                }
                            }

                            FluCustomIconButton {
                                id: freshBtn
                                objectName: "freshBtn"
                                property bool isEnabled: true
                                buttonWidth: Math.max(ScreenTools.calculateTextWidth(freshBtn.text,freshBtn.font.pointSize) + ScreenTools.scaleNum(44), ScreenTools.scaleNum(64))
                                buttonHeight:ScreenTools.scaleNum(36)
                                display: Button.TextBesideIcon
                                textNormalColor: ThemeColorStyle.okBtn_bg_color
                                borderWidth: 1
                                borderNormalColor: ThemeColorStyle.border_checked_color
                                sourceImgUrl: CommonImageStyle.refresh_img
                                text: qsTr("Fresh")
                                onClicked: {
                                    // 检查是否正在扫描LAN设备，如果是则直接返回（防抖）
                                    if (DispatchManager.deviceObj.isLanScanning || !freshBtn.isEnabled) {
                                        DispatchManager.deviceObj.sendTipToastMessage(VmsEnum.TipToastType.eRequestFrequently);
                                        return;
                                    }

                                    var nowMs = Date.now()
                                    if((nowMs - deviceManagerWindow.lastRefreshClickMs) < 5000)
                                        return

                                    deviceManagerWindow.lastRefreshClickMs = nowMs
                                    freshBtn.isEnabled = false
                                    refreshCooldownTimer.stop()
                                    refreshCooldownTimer.start()

                                    DispatchManager.deviceObj.handleRefreshDeviceList(true);
                                }
                            }

                            FluCustomIconButton {
                                id: addBtn
								objectName: "addBtn"
                                buttonWidth: Math.max(ScreenTools.calculateTextWidth(addBtn.text,addBtn.font.pointSize, false, false) + ScreenTools.scaleNum(40), ScreenTools.scaleNum(98))
                                buttonHeight:ScreenTools.scaleNum(36)
                                font.pointSize: videoFontSize
                                display: Button.TextBesideIcon
                                textNormalColor: ThemeColorStyle.privacy_text_color
                                borderWidth: 1
                                borderNormalColor: ThemeColorStyle.border_checked_color
                                sourceImgUrl: CommonImageStyle.add_img
                                text: qsTr("Add device")
                                onClicked: {
                                    generalLoader.source=""
                                    generalLoader.source="qrc:/Component/FluDeviceManager/FluLanSearchPage.qml"
                                }
                            }
                        }

                        Rectangle{
                            id: tableView
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            visible: deviceManagerWindow.deviceNumber > 0
                            FluDeviceTableView{
                               id: configDataTable
                               anchors.fill: parent
                               nameKeyword: deviceManagerWindow.searchKey
                               currentPageIndex: deviceManagerWindow.currentPageIndex
                               searchMode: deviceManagerWindow.searchMode
                               Component.onCompleted: {
                                    tableView.updateManagerModel()
                                }
                            }
                            function updateManagerModel(){
                                if (!configDataTable.tabelModel && DispatchManager.deviceObj && DispatchManager.deviceObj.deviceManagerModel)
                                {
                                    configDataTable.tabelModel = DispatchManager.deviceObj.deviceManagerModel;
                                }
                                if (configDataTable.tabelModel) {
                                    if (configDataTable.tabelModel.setClassification){
                                        configDataTable.tabelModel.setClassification(curDisplayText, true);
                                    }
                                }
                            }
                        }

                        Rectangle{
                            id: emptyRect
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            visible: deviceManagerWindow.deviceNumber === 0
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
                                    normalImageUrl: CommonPngImageStyle.deviceStatus_img
                                    Layout.alignment: Qt.AlignCenter
                                    imageWidth: ScreenTools.scaleNum(322)
                                    imageHeight: ScreenTools.scaleNum(220)
                                }
                                FluCustomLable{
                                    objectName: "noDeviceLabel"
                                    currentTextColor: ThemeColorStyle.tab_text_nor_color
                                    Layout.fillWidth: true
                                    visible: InformationNotifier.isLogin
                                    Layout.preferredHeight: ScreenTools.scaleNum(32)
                                    currentBackgroundColor: "transparent"
                                    text: deviceManagerWindow.searchKey.length ? qsTr("No relevant device found.") : qsTr("No devices added yet~")
                                    borderWidth: 0
                                }
                                RowLayout{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: ScreenTools.scaleNum(32)
                                    spacing: ScreenTools.scaleNum(0)
                                    visible: !InformationNotifier.isLogin
                                    Item{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                    FluCustomLable{
                                        id: loginText
                                        objectName: "loginText"
                                        currentTextColor: ThemeColorStyle.tab_text_nor_color
                                        Layout.preferredWidth: ScreenTools.calculateTextWidth(loginText.text) + ScreenTools.scaleNum(12)
                                        visible: !InformationNotifier.isLogin
                                        Layout.preferredHeight: ScreenTools.scaleNum(32)
                                        currentBackgroundColor: "transparent"
                                        text: qsTr("You are not logged in yet, please log in first")
                                        borderWidth: 0
                                    }
                                    FluCustomIconButton {
                                        id: loginBtn
                                        objectName: "loginBtn"
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: ScreenTools.calculateTextWidth(loginBtn.text) + ScreenTools.scaleNum(12)
                                        Layout.preferredHeight:ScreenTools.scaleNum(32)
                                        textNormalColor: ThemeColorStyle.privacy_text_color
                                        borderWidth: 0
                                        borderNormalColor: ThemeColorStyle.border_checked_color
                                        text: qsTr("Login")
                                        onClicked: {
                                            if(ScreenTools.isQiaoAn){
                                                FluRouter.navigate("/login")
                                            }
                                            if(ScreenTools.isLianXiang){
                                                DispatchManager.loginObj.signalLoginOperate(VmsEnum.LoginType.eNotLogin);
                                            }
                                        }
                                    }
                                    Item{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                }

                                Item{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 3000
        repeat:true
        running: false
        onTriggered: {
            tableView.updateManagerModel()
            configDataTable.updateModelData()
        }
    }

    Connections {
        target: deviceObjIsNull ? DispatchManager.deviceObj.deviceManagerModel : null
        function onDeviceCountChanged(){
            tableView.updateManagerModel()
            configDataTable.updateModelData()
            if(DispatchManager.deviceObj.deviceManagerModel.getRowCount() === 0){
                configDataTable.resetToFirstPage();
            }  
            deviceNumber = ConfigureManager.topTeamId.length ? teamTree.totalNumber : configDataTable.totalNumber
            if(teamTree && InformationNotifier.isLogin)
            {
                teamTree.isEnabled = true
            }
        }
        function onSignalMainModelChanged(isOnlineType){
            if(teamTree && InformationNotifier.isLogin && isOnlineType)
            {
                teamTree.isEnabled = false
                teamTree.initCheckState()
            }
            else
            {
                configDataTable.filterTableByModel()
            }
        }
    }

    // 监听登录状态变化，退出登录时重置分类选择和搜索条件
    Connections {
        target: InformationNotifier
        function onIsLoginChanged() {
            // 重置分类选择为"全部设备"，确保切换账号后分类状态一致
            if (deviceManagerWindow.currentPageIndex !== 0) {
                deviceManagerWindow.currentPageIndex = 0
            }
            deviceManagerWindow.searchKey = ""
            deviceManagerWindow.searchMode = 0
            deviceManagerWindow.teamIdsArray = []
            searchCombo.resetSearch()
        }
    }

    function updateTableModel(){
        configDataTable.updateTeamIdsArray(teamIdsArray)
        
    }
    function resetToFirstPage() {
        configDataTable.resetToFirstPage()
    }

    Component.onCompleted: {
        if(teamTree){
            deviceNumber = ConfigureManager.topTeamId.length ? teamTree.totalNumber : configDataTable.totalNumber
        }
    }   
    Component.onDestruction: {
        //关闭页后重置标识
        isShowdeviceManager = 0;
    }

}//Window

