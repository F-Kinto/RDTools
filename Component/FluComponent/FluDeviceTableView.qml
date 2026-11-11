import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Component.Button 1.0
import Component.FluButton 1.0
import Component.Dialog 1.0
import InformationNotifier 1.0
import ConfigureManager 1.0
import TranslatorManager 1.0
import FluentUI 1.0
import ScreenTools 1.0
import VMS.Enum 1.0
import QtGraphicalEffects 1.15

FluContentPage{
    id:root
    title: "" // qsTr("TableView")
    property int sortType: VmsEnum.TableSortTypeEnum.SortDefault
    property int allCheckState: Qt.Checked
    property string nameKeyword: ""
    property int searchMode: 0      // 0 name/id 1 name 2 id
    signal checkBoxChanged
    property bool hasTeamManager: ConfigureManager.topTeamId.length !== 0
    property int currentPageIndex: 0 // 0 全部设备 1 账号设备 2 本地设备
    property var tabelModel:null
    property int currentPageNum: 1
    property int currentPerPageNum: 10
    property int totalNumber: 0
    property var teamIdsArray:[]
    property bool isRTL: ConfigureManager.isRTLLayout
    property var deviceTypeList:[qsTr("Local device"),qsTr("Account device")]
    property int optioColumnnWidth: ScreenTools.scaleNum(240)
    property int fontSize: ScreenTools.scaleNum(10, true)

    onHasTeamManagerChanged: {
        
    }

    onCurrentPageIndexChanged: {
        // 切换分类时重置到第1页，直接赋值不触发requestPage信号
        currentPageNum = 1
        gagination.pageCurrent = 1
        filterTableByModel()
    }
    onNameKeywordChanged: {
        filterTableByModel()
    }
    onSearchModeChanged: {
        filterTableByModel()
    }

    Component.onCompleted: {
        
    }

    onSortTypeChanged: {
        if(DispatchManager && DispatchManager.deviceObj && DispatchManager.deviceObj.deviceManagerModel)
        {
            DispatchManager.deviceObj.deviceManagerModel.filterSortMode(sortType)
        }
    }

    Component{
        id:com_checbox
        Item{
            FluCheckBox{
                anchors.centerIn: parent
                checked: true === options.checked
                animationEnabled: false
                clickListener: function(){
                    if(hasTeamManager){
                        var obj = dynamicTableLoader.item.getRow(row)
                        if(obj !== null){
                            obj.checkbox = dynamicTableLoader.item.customItem(com_checbox,{checked})
                            dynamicTableLoader.item.setRow(row,obj)
                        }
                    }
                    else{
                        var obj = table_view.getRow(row)
                        if(obj !== null){
                            obj.checkbox = table_view.customItem(com_checbox,{checked})
                            table_view.setRow(row,obj)
                        }
                    }
                    root.checkBoxChanged()
                }
            }
        }
    }

    Component{
        id:deviceNameComponent
        Item{
            FluCustomSortBtn{
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                headText: qsTr("Device Name")
                itemWidth: ScreenTools.scaleNum(12)
                itemHeight: ScreenTools.scaleNum(10)
                isBold: true
                fontSize: root.fontSize
                onClickValue:{
                    if(value === 1){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortNameAsc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortNameAsc
                    }else if(value === 2){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortNameDesc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortNameDesc
                    }else{
                        root.sortType = VmsEnum.TableSortTypeEnum.SortDefault
                    }
                }
            }
        }
    }

    Component{
        id:deviceIDComponent
        Item{
            FluCustomSortBtn{
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                headText: qsTr("Device ID")
                itemWidth: ScreenTools.scaleNum(12)
                itemHeight: ScreenTools.scaleNum(10)
                isBold: true
                fontSize: root.fontSize
                onClickValue:{
                    if(value === 1){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortIDAsc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortIDAsc
                    }else if(value === 2){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortIDDesc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortIDDesc
                    }else{
                        root.sortType = VmsEnum.TableSortTypeEnum.SortDefault
                    }
                }
            }
        }
    }

    Component{
        id:departComponent
        Item{
            FluCustomSortBtn{
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                fontSize: root.fontSize
                isBold: true
                headText: qsTr("Dept.")
                itemWidth: ScreenTools.scaleNum(12)
                itemHeight: ScreenTools.scaleNum(10)
                onClickValue:{
                    if(value === 1){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortDepartAsc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortDepartAsc
                    }else if(value === 2){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortDepartDesc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortDepartDesc
                    }else{
                        root.sortType = VmsEnum.TableSortTypeEnum.SortDefault
                    }
                }
            }
        }
    }

    Component{
        id:deviceStatusComponent
        Item{
            FluCustomSortBtn{
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                fontSize: root.fontSize
                isBold: true
                headText: qsTr("Device Status")
                itemWidth: ScreenTools.scaleNum(12)
                itemHeight: ScreenTools.scaleNum(10)
                onClickValue:{
                    if(value === 1){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortStatusAsc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortStatusAsc
                    }else if(value === 2){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortStatusDesc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortStatusDesc
                    }else{
                        root.sortType = VmsEnum.TableSortTypeEnum.SortDefault
                    }
                }
            }
        }
    }

    Component{
        id:faceComponent
        Item{
            FluCustomSortBtn{
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                fontSize: root.fontSize
                isBold: true
                headText: qsTr("Face attendance")
                itemWidth: ScreenTools.scaleNum(12)
                itemHeight: ScreenTools.scaleNum(10)
                onClickValue:{
                    if(value === 1){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortFaceAsc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortFaceAsc
                    }else if(value === 2){
                        root.sortType = root.sortType === VmsEnum.TableSortTypeEnum.SortFaceDesc ? VmsEnum.TableSortTypeEnum.SortDefault : VmsEnum.TableSortTypeEnum.SortFaceDesc
                    }else{
                        VmsEnum.TableSortTypeEnum.SortDefault
                    }
                }
            }
        }
    }

    Component{
        id:com_action
        Item{
            RowLayout{
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.scaleNum(10)
                anchors.topMargin: ScreenTools.scaleNum(8)
                anchors.bottomMargin: ScreenTools.scaleNum(8)
                anchors.verticalCenter: parent.verticalCenter

                FluCustomIconButton {
                    id: setBtn
                    objectName: "settingsBtn"
                    property var obj: (dynamicTableLoader.item) ? dynamicTableLoader.item.getRow(row) : null
                    disabled: obj ? obj.isShare : false //如果是共享设备则不可点击设置功能, 需要禁用按钮
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Math.max(ScreenTools.calculateTextWidth(setBtn.text,setBtn.font.pointSize, false, false) +  ScreenTools.scaleNum(8),  ScreenTools.scaleNum(44))
                    Layout.preferredHeight:ScreenTools.scaleNum(32)
                    font.pointSize: ScreenTools.scaleNum(10, true)
                    disableColor: "transparent"
                    textDisableColor: ThemeColorStyle.text_disable_color
                    hoverColor: "#EDEFF2"
                    borderWidth: 0
                    textNormalColor: ThemeColorStyle.privacy_text_color
                    text: qsTr("Settings")
                    onClicked: {
                        if(obj !== null){
                            DispatchManager.deviceObj.deviceManagerModel.openDeviceSetting(obj.deviceID.toString(),true,obj.deviceType==qsTr("Account device")?true:false);
                        }
                    }
                }

                FluCustomIconButton {
                    id: delBtn
                    objectName: "deleteBtn"
                    property var obj: (dynamicTableLoader.item) ? dynamicTableLoader.item.getRow(row) : null
                    disabled: obj ? obj.isShare : false //如果是共享设备则不可点击设置功能, 需要禁用按钮
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Math.max(ScreenTools.calculateTextWidth(delBtn.text,delBtn.font.pointSize, false, false) +  ScreenTools.scaleNum(8),  ScreenTools.scaleNum(44))
                    Layout.preferredHeight:ScreenTools.scaleNum(32)
                    font.pointSize: ScreenTools.scaleNum(10, true)
                    disableColor: "transparent"
                    textDisableColor: ThemeColorStyle.text_disable_color
                    hoverColor: "#EDEFF2"
                    borderWidth: 0
                    textNormalColor: ThemeColorStyle.privacy_error_color
                    visible: (obj !==null &&obj.deviceType !== null) ? obj.deviceType!==qsTr("Account device") : false
                    text: qsTr("Delete")
                    onClicked: {
                        if(obj !== null){
                            deleteDialog.deviceName = obj.deviceName.toString()
                            deleteDialog.deviceUID = obj.deviceID.toString()
                            deleteDialog.open()
                        }
                    }
                }

                FluCustomIconButton {
                    id: faceBtn
                    objectName: "faceBtn"
                    property var obj: (dynamicTableLoader.item) ? dynamicTableLoader.item.getRow(row) : null
                    visible:hasTeamManager
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Math.max(ScreenTools.calculateTextWidth(faceBtn.text,faceBtn.font.pointSize, false, false) +  ScreenTools.scaleNum(8),  ScreenTools.scaleNum(44))
                    Layout.preferredHeight:ScreenTools.scaleNum(32)
                    font.pointSize: ScreenTools.scaleNum(10, true)
                    disableColor: "transparent"
                    textDisableColor: ThemeColorStyle.text_disable_color
                    hoverColor: "#EDEFF2"
                    borderWidth: 0
                    textNormalColor: ThemeColorStyle.privacy_text_color
                    text: qsTr("Face management")
                    onClicked: {
                        if(obj !== null){
                            obj.name = "Face manager"
                            showSuccess("Face manager")
                        }
                    }
                }
            }
        }
    }

    Component{
        id:com_column_checbox
        Item{
            RowLayout{
                anchors.centerIn: parent
                FluText{
                    text: qsTr("All")
                    Layout.alignment: Qt.AlignVCenter
                    font.pointSize: ScreenTools.scaleNum(10)
                    font.family: ScreenTools.fontFamily
                }
                FluCustomCheckBox {
                    Layout.alignment: Qt.AlignVCenter
                    checkState: root.allCheckState
                    animationEnabled: false
                    clickListener: function () {
                        root.allCheckState = checkState
                        if(hasTeamManager){
                            for (let i = 0; i < dynamicTableLoader.item.rows; i++) {
                                const rowData = dynamicTableLoader.item.getRow(i)
                                if(rowData !== null){
                                    rowData.checkbox = dynamicTableLoader.item.customItem(com_checbox, {"checked": checkState === Qt.Checked})
                                    dynamicTableLoader.item.setRow(i, rowData)
                                }
                            }
                        }
                        else{
                            for (let i = 0; i < dynamicTableLoader.item.rows; i++) {
                                const rowData = dynamicTableLoader.item.getRow(i)
                                if(rowData !== null){
                                    rowData.checkbox = dynamicTableLoader.item.customItem(com_checbox, {"checked": checkState === Qt.Checked})
                                    dynamicTableLoader.item.setRow(i, rowData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component{
        id:com_combobox
        FluComboBox {
            anchors.fill: parent
            focus: true
            editText: display
            editable: true
            model: ListModel {
                ListElement { text: "100" }
                ListElement { text: "300" }
                ListElement { text: "500" }
                ListElement { text: "1000" }
            }
            Component.onCompleted: {
                currentIndex=["100","300","500","1000"].findIndex((element) => element === display)
                textBox.forceActiveFocus()
                textBox.selectAll()
            }
            onCommit: {
                editTextChaged(editText)
                tableView.closeEditor()
            }
        }
    }

    Component{
        id:com_column_status
        Item{
            RowLayout{
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.scaleNum(20)
                anchors.verticalCenter: parent.verticalCenter
                Rectangle{
                    Layout.alignment: Qt.AlignVCenter
                    width: ScreenTools.scaleNum(6)
                    height: ScreenTools.scaleNum(6)
                    radius: ScreenTools.scaleNum(4)
                    color: options && options.status ? options.status.statusColor :ThemeColorStyle.privacy_text_color
                }
                FluText{
                    objectName: "statusText"
                    text: (options && options.status) && options.status.status == "1" ? qsTr("Online"): qsTr("Offline")
                    font.pointSize: root.fontSize
                    font.family: ScreenTools.fontFamily
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }

    Component{
        id:com_column_depart
        Item{
            RowLayout{
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.scaleNum(10)
                anchors.verticalCenter: parent.verticalCenter
                FluText{
                    text: (options && options.teamInfo) ? options.teamInfo.departName : ""
                    font.pointSize: root.fontSize
                    font.family: ScreenTools.fontFamily
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }

    Component{
        id:com_column_switch
        Item{
            CustomSwitch{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.scaleNum(10)
                itemWidth: ScreenTools.scaleNum(48)
                itemHeight: ScreenTools.scaleNum(24)
                dotCheckColor: ThemeColorStyle.radioBtn_nor_color
                dotDisableColor: ThemeColorStyle.radioBtn_nor_color
                dotNormalColor:ThemeColorStyle.radioBtn_nor_color
                checkColor: ThemeColorStyle.radioBtn_checked_color
                normalColor:"#40000000"
                hoverColor:"#40000000"
                checked: options && options.checked ? options.checked.check == "1" : false
                textVisible: false
                onCheckedChanged:{
                    //console.log("row:",row,"checked:",checked)
                }
            }
        }
    }
    
    // 标准表格组件（无团队管理） RTL布局
    Component {
        id: deviceRTLComponent
        FluCustomTableView {
            id: table_view_rtl
            fontSize: root.fontSize
            headIsBold: true
            width: parent.width
            height: parent.height
            wrapType: Text.NoWrap
            tableViewBorderVisible: false
            horizontalScroolVisible: false
            activeBgColor: "#FFFFFF"
            headBgColor: "#F7F8FA"
            itemBorderColor: "#F0F2F5"
            alginType: Text.AlignLeft
            headAlginType: Text.AlignLeft
            onRowsChanged: {
                root.checkBoxChanged()
            }
            startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
            property var columnDeviceSource: [
                {
                    title: qsTr("Operation"),
                    dataIndex: 'action',
                    width: optioColumnnWidth,
                    //frozen: true
                },
                {
                    title: table_view_rtl.customItem(deviceStatusComponent, {title: qsTr("Device Status")}),
                    dataIndex: 'status',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.145, ScreenTools.scaleNum(110)),
                    readOnly: true
                },
                {
                    title: qsTr("Device Type"),
                    dataIndex: 'deviceType',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.171, ScreenTools.scaleNum(130)),
                    minimumWidth: ScreenTools.scaleNum(80),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                },
                {
                    title: qsTr("MAC address"),
                    dataIndex: 'address',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.184, ScreenTools.scaleNum(140)),
                    textColor: ThemeColorStyle.text_nor_color,
                    minimumWidth: ScreenTools.scaleNum(140),
                    readOnly: true
                },
                {
                    title: table_view_rtl.customItem(deviceIDComponent, {title: qsTr("Device ID")}),
                    dataIndex: 'deviceID',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.263, ScreenTools.scaleNum(200)),
                    minimumWidth: ScreenTools.scaleNum(200),
                    textColor: ThemeColorStyle.text_nor_color,
                    readOnly: true
                },
                {
                    title: table_view_rtl.customItem(deviceNameComponent, {title: qsTr("Device Name")}),
                    dataIndex: 'deviceName',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.237, ScreenTools.scaleNum(180)),
                    minimumWidth: ScreenTools.scaleNum(180),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                }
            ]
            columnSource: columnDeviceSource
            visible: true
        }
    }
    // 无团队管理 
    Component {
        id: deviceComponent
        FluCustomTableView {
            id: table_view
            fontSize: root.fontSize
            headIsBold: true
            width: parent.width
            height: parent.height
            wrapType: Text.NoWrap
            tableViewBorderVisible: false
            horizontalScroolVisible: false
            activeBgColor: "#FFFFFF"
            headBgColor: "#F7F8FA"
            itemBorderColor: "#F0F2F5"
            alginType: Text.AlignLeft
            headAlginType: Text.AlignLeft
            onRowsChanged: {
                root.checkBoxChanged()
            }
            startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
            property var columnDeviceSource: [
                {
                    title: table_view.customItem(deviceNameComponent, {title: qsTr("Device Name")}),
                    dataIndex: 'deviceName',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.237, ScreenTools.scaleNum(180)),
                    minimumWidth: ScreenTools.scaleNum(180),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                },
                {
                    title: table_view.customItem(deviceIDComponent, {title: qsTr("Device ID")}),
                    dataIndex: 'deviceID',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.263, ScreenTools.scaleNum(200)),
                    minimumWidth: ScreenTools.scaleNum(200),
                    textColor: ThemeColorStyle.text_nor_color,
                    readOnly: true
                },
                {
                    title: qsTr("MAC address"),
                    dataIndex: 'address',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.184, ScreenTools.scaleNum(140)),
                    textColor: ThemeColorStyle.text_nor_color,
                    minimumWidth: ScreenTools.scaleNum(140),
                    readOnly: true
                },
                {
                    title: qsTr("Device Type"),
                    dataIndex: 'deviceType',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.171, ScreenTools.scaleNum(130)),
                    minimumWidth: ScreenTools.scaleNum(80),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                },
                {
                    title: table_view.customItem(deviceStatusComponent, {title: qsTr("Device Status")}),
                    dataIndex: 'status',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.145, ScreenTools.scaleNum(110)),
                    readOnly: true
                },
                {
                    title: qsTr("Operation"),
                    dataIndex: 'action',
                    width: optioColumnnWidth,
                    //frozen: true
                }
            ]
            columnSource: columnDeviceSource
            visible: true
        }
    }
    // 团队管理表格组件
    Component {
        id: teamComponent
        FluCustomTableView {
            id: team_table_view
            fontSize: root.fontSize
            headIsBold: true
            width: parent.width
            height: parent.height
            wrapType: Text.NoWrap
            tableViewBorderVisible: false
            activeBgColor: "#FFFFFF"
            headBgColor: "#F7F8FA"
            itemBorderColor: "#F0F2F5"
            alginType: Text.AlignLeft
            headAlginType: Text.AlignLeft
            onRowsChanged: {
                root.checkBoxChanged()
            }
            startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1          
            property var columnTeamSource: [
                {
                    title: team_table_view.customItem(deviceNameComponent, {title: qsTr("Device Name")}),
                    dataIndex: 'deviceName',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.177, ScreenTools.scaleNum(170)),
                    minimumWidth: ScreenTools.scaleNum(170),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                },
                {
                    title: team_table_view.customItem(deviceIDComponent, {title: qsTr("Device ID")}),
                    dataIndex: 'deviceID',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.198, ScreenTools.scaleNum(190)),
                    minimumWidth: ScreenTools.scaleNum(190),
                    textColor: ThemeColorStyle.text_nor_color,
                    readOnly: true
                },
                {
                    title: qsTr("MAC address"),
                    dataIndex: 'address',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.146, ScreenTools.scaleNum(140)),
                    textColor: ThemeColorStyle.text_nor_color,
                    minimumWidth: ScreenTools.scaleNum(140),
                    readOnly: true
                },
                {
                    title: qsTr("Device Type"),
                    dataIndex: 'deviceType',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.135, ScreenTools.scaleNum(130)),
                    minimumWidth: ScreenTools.scaleNum(80),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                },
                {
                    title: team_table_view.customItem(departComponent, {title: qsTr("Dept.")}),
                    dataIndex: 'departName',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.125, ScreenTools.scaleNum(120)),
                    minimumWidth: ScreenTools.scaleNum(110),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                },
                {
                    title: team_table_view.customItem(deviceStatusComponent, {title: qsTr("Device Status")}),
                    dataIndex: 'status',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.115, ScreenTools.scaleNum(110)),
                    minimumWidth: ScreenTools.scaleNum(90),
                    readOnly: true
                },
                {
                    title: team_table_view.customItem(faceComponent, {title: qsTr("Face attendance")}),
                    dataIndex: 'faceSwitch',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.114, ScreenTools.scaleNum(110)),
                    minimumWidth: ScreenTools.scaleNum(110),
                },
                {
                    title: qsTr("Operation"),
                    dataIndex: 'action',
                    width: optioColumnnWidth,
                    //frozen: true
                }
            ]
            columnSource: columnTeamSource
            visible: true
        }
    }
    // 团队管理RTL布局
    Component {
        id: teamRTLComponent  
        FluCustomTableView {
            id: team_table_view_rtl
            fontSize: root.fontSize
            headIsBold: true
            width: parent.width
            height: parent.height
            wrapType: Text.NoWrap
            tableViewBorderVisible: false
            activeBgColor: "#FFFFFF"
            headBgColor: "#F7F8FA"
            itemBorderColor: "#F0F2F5"
            alginType: Text.AlignLeft
            headAlginType: Text.AlignLeft
            onRowsChanged: {
                root.checkBoxChanged()
            }
            startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
            
            property var columnTeamSource: [
                {
                    title: qsTr("Operation"),
                    dataIndex: 'action',
                    width: optioColumnnWidth,
                    //frozen: true
                },
                {
                    title: team_table_view_rtl.customItem(faceComponent, {title: qsTr("Face attendance")}),
                    dataIndex: 'faceSwitch',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.114, ScreenTools.scaleNum(110)),
                    minimumWidth: ScreenTools.scaleNum(120),
                },
                {
                    title: team_table_view_rtl.customItem(deviceStatusComponent, {title: qsTr("Device Status")}),
                    dataIndex: 'status',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.115, ScreenTools.scaleNum(110)),
                    minimumWidth: ScreenTools.scaleNum(90),
                    readOnly: true
                },
                {
                    title: team_table_view_rtl.customItem(departComponent, {title: qsTr("Dept.")}),
                    dataIndex: 'departName',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.125, ScreenTools.scaleNum(120)),
                    minimumWidth: ScreenTools.scaleNum(110),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                },
                {
                    title: qsTr("Device Type"),
                    dataIndex: 'deviceType',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.135, ScreenTools.scaleNum(130)),
                    minimumWidth: ScreenTools.scaleNum(80),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                },
                {
                    title: qsTr("MAC address"),
                    dataIndex: 'address',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.146, ScreenTools.scaleNum(140)),
                    textColor: ThemeColorStyle.text_nor_color,
                    minimumWidth: ScreenTools.scaleNum(140),
                    readOnly: true
                },
                {
                    title: team_table_view_rtl.customItem(deviceIDComponent, {title: qsTr("Device ID")}),
                    dataIndex: 'deviceID',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.198, ScreenTools.scaleNum(190)),
                    minimumWidth: ScreenTools.scaleNum(190),
                    textColor: ThemeColorStyle.text_nor_color,
                    readOnly: true
                },
                {
                    title: team_table_view_rtl.customItem(deviceNameComponent, {title: qsTr("Device Name")}),
                    dataIndex: 'deviceName',
                    width: Math.max((parent.width - optioColumnnWidth) * 0.177, ScreenTools.scaleNum(170)),
                    minimumWidth: ScreenTools.scaleNum(170),
                    textColor: ThemeColorStyle.title_text_nor_color,
                    readOnly: true
                }
            ]
            columnSource: columnTeamSource
            visible: true
        }
    }
    
    // 动态表格加载器
    Rectangle {
        id: outerRect
        height: parent.height - gagination.height
        width: parent.width
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: gagination.top
            bottomMargin: ScreenTools.scaleNum(12)
        }
        radius:ScreenTools.scaleNum(10)
        color: "#FFFFFF"
        border.color: "#EDEFF2"
        border.width: 1
        clip: true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: outerRect.width
                height: outerRect.height
                radius: outerRect.radius
            }
        }
        Loader {
            id: dynamicTableLoader
            property int  bottomOffset: 0
            anchors.fill: parent
            anchors.leftMargin: 1
            anchors.topMargin: 1
            anchors.rightMargin: 1
            anchors.bottomMargin: bottomOffset
            
            // 根据 是否团队管理 和 布局方式 决定加载哪个组件
            sourceComponent: {
                if (hasTeamManager) {
                    return isRTL  ? teamRTLComponent : teamComponent
                } else {
                    return isRTL ? deviceRTLComponent : deviceComponent
                }
            }
            // 组件加载完成
            onLoaded: {
                if (item) {
                    updateModelData()
                    item.verScroolBarVisibleChanged.connect(onVerScrollBarVisibleChanged)
                }
            }
            function onVerScrollBarVisibleChanged(isVisible){
                anchors.bottomMargin = !isVisible ? ScreenTools.scaleNum(8) : ScreenTools.scaleNum(6)
            }
        }
    }

    QAPagination{
        id:gagination
        anchors{
            bottom: parent.bottom
            right: parent.right
        }
        height: ScreenTools.scaleNum(40)
        pageCurrent: 1
        itemCount: totalNumber
        pageButtonCount: 7
        __itemPerPage: 10
        onRequestPage:(page,count)=> {
            currentPageNum = page
            currentPerPageNum = count
            dynamicTableLoader.item.closeEditor()
            dynamicTableLoader.item.sourceModel.clear();
            updateModelData()
            dynamicTableLoader.item.resetPosition()
        }
    }

    function getRowObject(name,uid,address1,type,deviceStatus,departName1,faceSwitch,teamid, isShareDevice){
        var statuses = [
                {status: "1", statusColor: ThemeColorStyle.privacy_text_color},
                {status: "0", statusColor: ThemeColorStyle.privacy_error_color}
            ];

        var faceSwitchs = [
                {check: "1"},
                {check: "0"}
            ];
        var teamInfo = {departName: "", teamID: ""}
        teamInfo.departName = departName1;
        teamInfo.teamID = teamid;
        var deviceMsg = {
            deviceName : name,
            deviceID : uid.toString(),
            address : address1,
            deviceType : type === 1 ? deviceTypeList[0] : deviceTypeList[1],
            status : dynamicTableLoader.item.customItem(com_column_status,{status:deviceStatus ? statuses[0] : statuses[1]}),
            action : dynamicTableLoader.item.customItem(com_action),
            isShare: isShareDevice,
            _minimumHeight : ScreenTools.scaleNum(56),
            _key : FluTools.uuid()
        }
        // 如果有团队管理，添加额外属性
        if (hasTeamManager) {
            deviceMsg.departName = dynamicTableLoader.item ? dynamicTableLoader.item.customItem(com_column_depart, {teamInfo: teamInfo}) : null
            deviceMsg.faceSwitch = dynamicTableLoader.item ? dynamicTableLoader.item.customItem(com_column_switch, {checked: faceSwitch ? faceSwitchs[0] : faceSwitchs[1]}) : null
        }
        return deviceMsg
    }

    function updateModelData()
    { 
        var model = tabelModel
        var rowCount = model ? model.getRowCount() : 0
        if (!model) {
            console.log("Model is null")
            return
        }
        if(dynamicTableLoader.item)
            dynamicTableLoader.item.removeAllRows()
        if(rowCount == 0){
            console.log("No data")
            totalNumber = 0;
            return;
        }
        totalNumber = rowCount

        // 修正越界页码：总数减少后当前页可能超出范围
        var maxPage = Math.ceil(rowCount / currentPerPageNum)
        if (currentPageNum > maxPage && maxPage > 0) {
            currentPageNum = maxPage
            gagination.pageCurrent = maxPage
        }

        for (var i = (currentPageNum-1) * currentPerPageNum; i < Math.min(currentPageNum * currentPerPageNum,rowCount) ; i++) {
            var uid = model.getRoleValue(i, "uid")
            var index = dynamicTableLoader.item.getIndexById(uid, model.getRoleValue(i, "netMode") === 1 ? deviceTypeList[0] : deviceTypeList[1])
            if(index !== -1){
                dynamicTableLoader.item.setRow(getRowObject(model.getRoleValue(i, "name"), model.getRoleValue(i, "uid"), model.getRoleValue(i, "mac"), model.getRoleValue(i, "netMode") , model.getRoleValue(i, "isOnLine"), model.getRoleValue(i, "teamName"), model.getRoleValue(i, "faceSwitch") === undefined ? false : model.getRoleValue(i, "faceSwitch"),model.getRoleValue(i, "teamId"), model.getRoleValue(i, "isShareDevice")))
            }
            else {
                dynamicTableLoader.item.appendRow(getRowObject(model.getRoleValue(i, "name"), model.getRoleValue(i, "uid"), model.getRoleValue(i, "mac"), model.getRoleValue(i, "netMode") , model.getRoleValue(i, "isOnLine"), model.getRoleValue(i, "teamName"), model.getRoleValue(i, "faceSwitch") === undefined ? false : model.getRoleValue(i, "faceSwitch"),model.getRoleValue(i, "teamId"),model.getRoleValue(i, "isShareDevice")))
            }
        }
    }

    function filterTableByModel()
    {
        if(DispatchManager && DispatchManager.deviceObj && DispatchManager.deviceObj.deviceManagerModel)
        {
            DispatchManager.deviceObj.deviceManagerModel.filterDevices(root.sortType, currentPageIndex - 1, nameKeyword, teamIdsArray, searchMode)
        }
    }

    function updateTeamIdsArray(array)
    {
        teamIdsArray = array
        filterTableByModel()
    }

    Timer {
        id: languageTimer
        interval: 50
        repeat:false
        running: false
        onTriggered: {
            updateLanguage()                   
            running: false
            languageTimer.stop()
        }
    }

    // 删除本地设备弹窗
    FluCustomTipDialog{
        id: deleteDialog
        property string deviceName: ""
        property string deviceUID: ""
        objectName: "deleteDialog"
        width: ScreenTools.scaleNum(500)
        height: ScreenTools.scaleNum(228)
        title: ""
        titleBgColor: "#FFFFFF"
        messageImgUrl: CommonImageStyle.delete_img
		leftRightMargin: ScreenTools.scaleNum(80)
        message: qsTr("After deleting device %1, the device will no longer appear in the list. To view it again, you need to manually re-add it.").arg(deviceName)
        negativeText: qsTr("Cancel")
        positiveText: qsTr("Delete")
        positiveColor: ThemeColorStyle.deleteBtn_bg_color
        onPositiveClicked:{
            DispatchManager.deviceObj.deviceManagerModel.deleteDevice(deviceUID, false)
        }
    }

    function updateLanguage(){
        var model = tabelModel
        var rowCount = model ? model.getRowCount() : 0
        if (!model) {
            return
        }
        if(rowCount < 0)return;  
        //数据已存在只需要更新已有数据
        for (var i = 0; i < rowCount ; i++) {
            dynamicTableLoader.item.setRow(i, getRowObject(model.getRoleValue(i, "name"), model.getRoleValue(i, "uid"), model.getRoleValue(i, "mac"), model.getRoleValue(i, "netMode") , model.getRoleValue(i, "isOnLine"), model.getRoleValue(i, "teamName"), model.getRoleValue(i, "faceSwitch") === undefined ? false : model.getRoleValue(i, "faceSwitch"),model.getRoleValue(i, "teamId"), model.getRoleValue(i, "isShareDevice")))
        }
        // 切换语言后页面数据会显示第一页，需要重新请求当前页码数据
        if(gagination.pageCurrent > 1){
            gagination.requestCurrentPage()
        }
    }

    // 重置页码到第一页（供外部调用，切换设备类型时使用）
    function resetToFirstPage() {
        currentPageNum = 1
        // 先修改pageCurrent为0，绕过calcNewPage中的相等检查
        gagination.pageCurrent = 0
        gagination.calcNewPage(1)
    }

    Connections {
        target: TranslatorManager
        function onLanguageChanged() {
            languageTimer.start()
        }
    }
}
