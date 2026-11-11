
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import FluentUI 1.0
import InfoInterface 1.0

Item {
    id: control
    width: ScreenTools.scaleNum(257)
    height: titleLabel.contentHeight > ScreenTools.scaleNum(40) ? ScreenTools.scaleNum(124) : ScreenTools.scaleNum(104)
    anchors.right: parent.right
    anchors.rightMargin: ScreenTools.scaleNum(93)
    anchors.top: parent.top
    anchors.topMargin: ScreenTools.scaleNum(106)
    // 类型：0-Info, 1-Warning, 2-Error, 3-Success
    property int infoType: 0

    // 背景色配置
    property var bgList: [
        InfoInterface.infoBgColor,      // Info - 蓝色
        InfoInterface.warningBgColor,   // Warning - 黄色
        InfoInterface.errorBgColor,     // Error - 红色
        InfoInterface.successBgColor    // Success - 绿色
    ]

    // 图标配置（根据类型变化）
    property var iconList: [
        CommonImageStyle.rect_info_img,
        CommonPngImageStyle.info_warning24_img,
        CommonImageStyle.tip_error_img,
        CommonPngImageStyle.info_success24_img
    ]

    property string titleText: "帮助信息"

    property alias leftBtn: _leftBtn
    property alias rightBtn: _rightBtn
    
    // 背景
    FluControlBackground{
        anchors.fill: parent
        radius: 4
        color: "#FFFFFF"
        FluFocusRectangle{
            visible: control.activeFocus
            radius:4
        }
    }
    ColumnLayout {
        anchors.fill: parent
        Layout.bottomMargin: ScreenTools.scaleNum(12)
        RowLayout {
            spacing: ScreenTools.scaleNum(8)
            Layout.topMargin: ScreenTools.scaleNum(12)
            Layout.leftMargin: ScreenTools.scaleNum(12)
            Layout.rightMargin: ScreenTools.scaleNum(12)
            Layout.fillWidth: true
            Layout.preferredHeight: titleLabel.contentHeight > ScreenTools.scaleNum(40) ? ScreenTools.scaleNum(60) : ScreenTools.scaleNum(40)

            // 图标
            Image {
                id: typeIcon
                Layout.alignment: Qt.AlignTop
                source: iconList[Math.min(infoType, 3)]
                width: ScreenTools.scaleNum(16)
                height: ScreenTools.scaleNum(16)
                // fillMode: Image.PreserveAspectFit
            }
            // 标题
            Text {
                id: titleLabel
                text: titleText
                Layout.fillWidth: true // 填充宽度
                Layout.preferredHeight: ScreenTools.scaleNum(60) // contentHeight > ScreenTools.scaleNum(40) ? ScreenTools.scaleNum(60) : ScreenTools.scaleNum(60)
                font.pointSize: ScreenTools.scaleNum(8)
                font.weight: Font.Medium
                color: "#6D7682"
                font.family: ScreenTools.fontFamily
                elide: Text.ElideRight
                wrapMode: Text.Wrap // 自动换行
            }
        }
        // 按钮区域
        RowLayout {
            Layout.alignment: Qt.AlignHCenter // 居中对齐
            spacing: ScreenTools.scaleNum(12)
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.scaleNum(28)

            FluButton {
                id: _leftBtn
                width: ScreenTools.scaleNum(78)
                height: ScreenTools.scaleNum(28)
                text: qsTr("Cancel")
                textColor: "#6D7682"
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
                background:  Rectangle {
                    implicitWidth: ScreenTools.scaleNum(78)
                    implicitHeight: ScreenTools.scaleNum(28)
                    radius: 4
                    border.color: "#CAD2DD"
                    border.width: 1
                    color: "transparent"
                    opacity: _leftBtn.hovered ? 0.7 : 1
                }
            }

            FluButton {
                id: _rightBtn
                width: ScreenTools.scaleNum(78) // 调整宽度
                height: ScreenTools.scaleNum(28)
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
                text: qsTr("Confirm")
                textColor: "#FFFFFF"
                background: FluControlBackground{
                    implicitWidth: ScreenTools.scaleNum(78)
                    implicitHeight: ScreenTools.scaleNum(28)
                    radius: 4
                    opacity: _rightBtn.hovered ? 0.7 : 1
                    shadow: !_rightBtn.pressed
                    color: "#0099FF"
                    FluFocusRectangle{
                        visible: control.activeFocus
                        radius:4
                    }
                }
            }
        }
        
        Item{
            height: ScreenTools.scaleNum(12)
        }

    }
}