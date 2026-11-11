/*********************************************************************
File : CustomAreaDialog.qml
Module : DeviceManager
Authors: guangnan
date : 2023/07/12 16:00
Ver : 1.0.0
History:
guangnan 2023/07/12 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtQml 2.15
import Component.Login 1.0
import ScreenTools 1.0
import Component.Edit 1.0
import Component.Button 1.0
import VMS.Enum 1.0
import ConfigureManager 1.0
import InformationNotifier 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import DeviceMessage 1.0
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15

// 带阴影的容器
Item {
    id: shadowContainer
    width: dialog.width + ScreenTools.scaleNum(20)
    height: dialog.height + ScreenTools.scaleNum(20)
    property bool isSearch: false
    property int dialogWidth: ScreenTools.scaleNum(200)

    signal currentCountryCode(string code)
    signal currentRegionCode(string code)
    signal currentSelectIndex(int index)

    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    // 阴影效果
    DropShadow {
        anchors.fill: dialog
        horizontalOffset: ScreenTools.scaleNum(2)
        verticalOffset: ScreenTools.scaleNum(4)
        radius: ScreenTools.scaleNum(8)
        samples: ScreenTools.scaleNum(12)
        color: "#33000000"
        source: dialog
        transparentBorder: true
    }

    Rectangle {
        id: dialog
        width: dialogWidth
        height: ScreenTools.scaleNum(12) + ((isSearch ? searchModel.count : listModel.count) > 7 ? 7 : (isSearch ? searchModel.count : listModel.count)) * ScreenTools.scaleNum(30)
        anchors.centerIn: parent
        color: "#FFFFFF"
        radius: ScreenTools.scaleNum(4)

        ListModel{
            id:listModel
        }

        ListModel {
            id: searchModel
            ListElement { country: qsTr("Search for device name/ID"); areaId: "";region : "0" }
            ListElement { country: qsTr("Search device name"); areaId: "";region : "1" }
            ListElement { country: qsTr("Search device ID"); areaId: "";region : "2" }
        }
    

        ListView {
            id: countryView
            anchors.fill: parent
            anchors.margins: ScreenTools.scaleNum(6)
            model: isSearch ? searchModel : listModel
            delegate: countryDelegate
            clip: true
            spacing: 0
            flickableDirection: Flickable.AutoFlickIfNeeded
            boundsBehavior: Flickable.StopAtBounds
            
            // 设置当前选中项
            currentIndex: (isSearch ? searchModel.count : listModel.count) ? ConfigureManager.regionIndex : -1
        }

        Component {
            id: countryDelegate
            Item {
                id: delegateItem
                width: dialog.width - ScreenTools.scaleNum(12)
                height: ScreenTools.scaleNum(30)
                
                // 背景矩形 - 处理悬停和选中状态
                Rectangle {
                    id: backgroundRect
                    anchors.fill: parent
                    radius:ScreenTools.scaleNum(4)
                    color: {
                        if (countryView.currentIndex === index) {
                            return ThemeColorStyle.list_bg_select_color // 选中状态背景色
                        } else if (delegateItem.containsMouse) {
                            return ThemeColorStyle.list_bg_hover_color // 悬停状态背景色
                        }
                        return ThemeColorStyle.list_bg_nor_color // 默认白色
                    }
                }
                
                Item {
                    anchors.fill: parent
                    //spacing: 0
                    
                    Label {
                        id: countryLabel
                        anchors {
                            left: parent.left
                            leftMargin: ScreenTools.scaleNum(6)
                            verticalCenter: parent.verticalCenter  // 垂直居中
                        }
                        text: country
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        font.family: ScreenTools.fontFamily
                        width: isSearch ? parent.width : parent.width * 0.7
                        horizontalAlignment: Text.AlignLeft
                        // 只有选中时文本颜色才变化
                        color: countryView.currentIndex === index ? ThemeColorStyle.list_text_select_color : ThemeColorStyle.list_text_nor_color
                        elide: Text.ElideRight
                    }
                    
                    Label {
                        id: codeLabel
                        text: areaId
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        anchors {
                            right: parent.right
                            rightMargin: ScreenTools.scaleNum(6)
                            verticalCenter: parent.verticalCenter  // 垂直居中
                        }
                        font.family: ScreenTools.fontFamily
                        horizontalAlignment: Text.AlignRight
                        width: isSearch ? 0 : parent.width * 0.3
                        // 只有选中时文本颜色才变化
                        color: countryView.currentIndex === index ? ThemeColorStyle.list_text_select_color : ThemeColorStyle.list_text_nor_color
                    }
                }
                
                // 鼠标区域处理悬停和点击
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    
                    // 更新悬停状态
                    onEntered: delegateItem.containsMouse = true
                    onExited: delegateItem.containsMouse = false
                    
                    onClicked: {
                        countryView.currentIndex = index
                        getCurrentCode()
                    }
                }
                
                // 自定义悬停状态
                property bool containsMouse: false
            }
        }
    }

    function getCurrentCode() {        
        if(isSearch)
        {
            var item = searchModel.get(countryView.currentIndex)
            shadowContainer.currentCountryCode(searchModel.count && item ? searchModel.get(countryView.currentIndex).areaId : "")
            shadowContainer.currentRegionCode(searchModel.count&& item ? searchModel.get(countryView.currentIndex).region : "0")
            shadowContainer.currentSelectIndex(searchModel.count&& item ? countryView.currentIndex : 0)
        }
        else
        {
            var item = listModel.get(countryView.currentIndex)
            shadowContainer.currentCountryCode(listModel.count && item ? listModel.get(countryView.currentIndex).areaId : "+1")
            shadowContainer.currentRegionCode(listModel.count && item ? listModel.get(countryView.currentIndex).region : "US")
            shadowContainer.currentSelectIndex(listModel.count && item ? countryView.currentIndex : 0)
        }

    }

    function resetAllMouseStates() {
        // 遍历所有可见的委托项
        if(listModel.count === 0)
            return
        for (var i = 0; i < countryView.count; i++) {
            var item = countryView.itemAt(0, i * 30)
            if (item && item.containsMouse !== undefined) {
                item.containsMouse = false
            }
        }
    }

    function clearModelData(){
        listModel.clear();
    }

    function addModelData(region){
        var index = findIndex(region)
        if(index != -1)
            return
        if(region === "US"){
            listModel.append({"country":qsTr("USA") , "areaId":"+1" , "region" : region})
        }else if(region === "TH"){
            listModel.append({"country":qsTr("Thailand") , "areaId":"+66" , "region" : region})
        }else if(region === "ID"){
            listModel.append({"country":qsTr("Indonesia") , "areaId":"+62" , "region" : region})
        }else if(region === "DE"){
            listModel.append({"country":qsTr("Germany") , "areaId":"+49" , "region" : region})
        }else if(region === "FR"){
            listModel.append({"country":qsTr("France") , "areaId":"+33" , "region" : region})
        }else if(region === "IT"){
            listModel.append({"country":qsTr("Italy") , "areaId":"+39" , "region" : region})
        }else if(region === "ES"){
            listModel.append({"country":qsTr("Spain") , "areaId":"+34" , "region" : region})
        }else if(region === "MX"){
            listModel.append({"country":qsTr("Mexico") , "areaId":"+52" , "region" : region})
        }else if(region === "JP"){
            listModel.append({"country":qsTr("Japan") , "areaId":"+81" , "region" : region})
        }else if(region === "PT"){
            listModel.append({"country":qsTr("Portugal") , "areaId":"+351" , "region" : region})
        }else if(region === "HK"){
            listModel.append({"country":qsTr("Hong Kong, China") , "areaId":"+852" , "region" : region})
        }
    }

    function getRegionList(){
        var list = ScreenTools.regionList
        clearModelData()
        // 遍历打印所有元素
        for (var i = 0; i < list.length; i++) {
            addModelData(list[i])
        }
        countryView.currentIndex = listModel.count ? ConfigureManager.regionIndex : -1
        getCurrentCode()
    }

    function findIndex(region){
        for(var i = 0 ; i < listModel.count ; ++i){
            if(listModel.get(i).region == region){
                return i
            }
        }
        return -1
    }

    Connections {
        target: ScreenTools
        function onRegionListChanged() {
            getRegionList()
        }
    }
    Connections {
        target: ConfigureManager
        function onRegionListChanged() {
            getRegionList()
        }
    }
}