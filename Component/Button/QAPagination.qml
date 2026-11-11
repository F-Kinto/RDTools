import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import Component.FluButton 1.0
import FluentUI 1.0
import ConfigureManager 1.0
import Component.Button 1.0
Item {
    signal requestPage(int page, int count)
    property string previousText: "<" //Previous
    property string nextText: ">" //Next
    property int pageCurrent: 10
    property int itemCount: 1000
    property int pageButtonCount: 5
    property int pageCount: itemCount > 0 ? Math.ceil(itemCount / __itemPerPage) : 0
    property int __itemPerPage: 10
    property int __pageButtonHalf: Math.floor(pageButtonCount / 2) + 1
    property Component header: null
    property Component footer: null
    id: control
    implicitHeight: ScreenTools.scaleNum(40)
    implicitWidth: content.width
    //UI镜像使能(兼容海外客户UI从右到左布局)
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    Row {
        id: content
        // anchors.fill: parent
        height: control.height
        spacing: ScreenTools.scaleNum(10)
        padding: ScreenTools.scaleNum(10)
        FluText{
            objectName: "sumText"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter  // 文本内容水平居中
            verticalAlignment: Text.AlignVCenter
            //text: "共 <font color=\"#1D1F21\">" + itemCount + "</font> 条"
            text: qsTr("%1 items total").arg(itemCount)  //10 items total
            textFormat: Text.RichText
            color: ThemeColorStyle.text_nor_color
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(10, true)
        }

        Item {
            width: ScreenTools.scaleNum(20)
        }

        FluCustomDropDownButton{
            id: dropDownBtn
            visible: false
            text: __itemPerPage + "/" + qsTr("items")
            display: Button.TextOnly
            width: Math.max(ScreenTools.calculateTextWidth(dropDownBtn.text) + ScreenTools.scaleNum(40) , ScreenTools.scaleNum(80))
            height: ScreenTools.scaleNum(24)
            rightPadding: ConfigureManager.isRTLLayout ? undefined : ScreenTools.scaleNum(36)
            leftPadding: ConfigureManager.isRTLLayout ? ScreenTools.scaleNum(36) : undefined

            Layout.alignment: Qt.AlignVCenter
            background: Rectangle{
                implicitWidth: dropDownBtn.width
                implicitHeight: dropDownBtn.height
                radius: dropDownBtn.radius
                color: dropDownBtn.color
                border.color: ThemeColorStyle.border_nor_color
                border.width: 1
                FluFocusRectangle{
                    visible: control.activeFocus
                }
            }

            function changePerPage(count) {
                __itemPerPage = count
                if(__itemPerPage > itemCount){
                    calcNewPage(1)
                }
                control.requestPage(control.pageCurrent, control.__itemPerPage)
            }

            FluMenuItem{
                text: qsTr("10 items")
                onClicked: {
                    dropDownBtn.changePerPage(10)
                }
            }
            FluMenuItem{
                text: qsTr("100 items")
                onClicked: {
                    dropDownBtn.changePerPage(100)
                }
            }
            FluMenuItem{
                text: qsTr("500 items")
                onClicked: {
                    dropDownBtn.changePerPage(500)  
                }
            }
        }

        CustomFluToggleButton {
			objectName: "forwardBtn"
            width: ScreenTools.scaleNum(24)
            height: ScreenTools.scaleNum(24)
            visible: control.pageCount > 1
            anchors.verticalCenter: parent.verticalCenter
            disabled: control.pageCurrent <= 1
            showHoverTip: true
            hoverTipText: qsTr("Prev")
            text: ConfigureManager.isRTLLayout ? control.nextText : control.previousText
            clickListener: function () {
                control.calcNewPage(control.pageCurrent - 1);
            }
        }
        Row {
            spacing: ScreenTools.scaleNum(6)
            anchors.verticalCenter: parent.verticalCenter
            CustomFluToggleButton {
				objectName: "firstPageBtn"
                width: ScreenTools.scaleNum(24)
                height: ScreenTools.scaleNum(24)
                property int pageNumber: 1
                visible: control.pageCount > 0
                checked: pageNumber === control.pageCurrent
                text: String(pageNumber)
                clickListener: function () {
                    control.calcNewPage(pageNumber);
                }
            }
            FluText {
                visible: (control.pageCount > control.pageButtonCount &&
                    control.pageCurrent > control.__pageButtonHalf)
                text: "..."
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
            }
            Repeater {
                id: button_repeator
                model: (control.pageCount < 2) ? 0 : (control.pageCount >= control.pageButtonCount) ? (control.pageButtonCount - 2) : (control.pageCount - 2)
                delegate: CustomFluToggleButton {
					objectName: "page_" + pageNumber
                    width: ScreenTools.scaleNum(24)
                    height: ScreenTools.scaleNum(24)
                    property int  pageNumber: {
                        return (control.pageCurrent <= control.__pageButtonHalf)
                            ? (2 + index)
                            : (control.pageCount - control.pageCurrent <= control.pageButtonCount - control.__pageButtonHalf)
                                ? (control.pageCount - button_repeator.count + index)
                                : (control.pageCurrent + 2 + index - control.__pageButtonHalf)
                    }
                    text: String(pageNumber)
                    checked: pageNumber === control.pageCurrent
                    clickListener: function () {
                        control.calcNewPage(pageNumber);
                    }
                }
            }
            FluText {
                visible: (control.pageCount > control.pageButtonCount &&
                    control.pageCount - control.pageCurrent > control.pageButtonCount - control.__pageButtonHalf)
                text: "..."
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
            }
            CustomFluToggleButton {
				objectName: "lastPageBtn"
                width: ScreenTools.scaleNum(24)
                height: ScreenTools.scaleNum(24)
                property int pageNumber: control.pageCount
                visible: control.pageCount > 1
                checked: pageNumber === control.pageCurrent
                text: String(pageNumber)
                clickListener: function () {
                    control.calcNewPage(pageNumber);
                }
            }
        }
        CustomFluToggleButton {
			objectName: "backwardsBtn"
            width: ScreenTools.scaleNum(24)
            height: ScreenTools.scaleNum(24)
            visible: control.pageCount > 1
            anchors.verticalCenter: parent.verticalCenter
            disabled: control.pageCurrent >= control.pageCount
            showHoverTip: true
            hoverTipText: qsTr("Next")
            text: ConfigureManager.isRTLLayout ? control.previousText : control.nextText
            clickListener: function () {
                control.calcNewPage(control.pageCurrent + 1);
            }
        }
        
        FluText{
            objectName: "jumpText1"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter  // 文本内容水平居中
            verticalAlignment: Text.AlignVCenter
            text: qsTr("Go to")
            textFormat: Text.RichText
            color: ThemeColorStyle.text_nor_color
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(10, true)
        }

        Rectangle {
            width: ScreenTools.scaleNum(40)
            height: ScreenTools.scaleNum(24)
            anchors.verticalCenter: parent.verticalCenter
            border.width: 1
            border.color: ThemeColorStyle.border_nor_color
            radius: ScreenTools.scaleNum(2)
            TextField {
                objectName: "pageNumField"
                text: control.pageCurrent
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
                anchors.verticalCenter: parent.verticalCenter
                validator: IntValidator {bottom: 1; top: control.pageCount;}
                onEditingFinished: {
                    control.calcNewPage(Number(text))
                }
                background: Rectangle {
                    color: "transparent" 
                    implicitWidth: ScreenTools.scaleNum(40)
                    implicitHeight: ScreenTools.scaleNum(24)
                }
            }
        }

        FluText{
            objectName: "jumpText2"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter  // 文本内容水平居中
            verticalAlignment: Text.AlignVCenter
            text: qsTr("Page")
            textFormat: Text.RichText
            color: ThemeColorStyle.text_nor_color
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(10, true)
        }

    }
    function calcNewPage(page) {
        if (!page)
            return
        let page_num = Number(page)
        if (page_num < 1 || page_num > control.pageCount || page_num === control.pageCurrent)
            return
        control.pageCurrent = page_num
        requestCurrentPage()
    }

    function requestCurrentPage() {
        control.requestPage(control.pageCurrent, control.__itemPerPage)
    }
}
