
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import FluentUI 1.0
import InfoInterface 1.0

Item {
    id: control
    width: ScreenTools.scaleNum(684)
    height: ScreenTools.scaleNum(132)

    // 类型：0-Info, 1-Warning, 2-Error, 3-Success
    property int infoType: 3

    // 背景色配置
    property var bgList: [
        ThemeColorStyle.privacy_color,      // Info - 蓝色
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
    property string contentText: "这是一条解释的信息文案！"

    // 信号
    signal closed()

    // 背景
    Rectangle {
        id: background
        anchors.fill: parent
        color: bgList[Math.min(infoType, 3)]
        radius: ScreenTools.scaleNum(4)

        // 左侧装饰条
        Rectangle {
            id: leftIndicator
            visible: false
            width: ScreenTools.scaleNum(4)
            height: parent.height
            radius: ScreenTools.scaleNum(4)
            color: {
                switch(infoType) {
                    case 0: return "#1677FF"  // Info - 蓝色
                    case 1: return "#FAAD14"  // Warning - 黄色
                    case 2: return "#FF4D4F"  // Error - 红色
                    case 3: return "#52C41A"  // Success - 绿色
                    default: return "#1677FF"
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: ScreenTools.scaleNum(20)
        anchors.rightMargin: ScreenTools.scaleNum(12)
        anchors.topMargin: ScreenTools.scaleNum(16)
        anchors.bottomMargin: ScreenTools.scaleNum(16)
        spacing: ScreenTools.scaleNum(12)

        // 图标
        Image {
            id: typeIcon
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: ScreenTools.scaleNum(2)
            source: iconList[Math.min(infoType, 3)]
            width: ScreenTools.scaleNum(24)
            height: ScreenTools.scaleNum(24)
            fillMode: Image.PreserveAspectFit
            visible: !ScreenTools.imageIsSvgSource(iconList[Math.min(infoType, 3)])
        }

        FluCustomSvg{
            imageWidth: ScreenTools.scaleNum(24)
            imageHeight: ScreenTools.scaleNum(24)
            Layout.alignment: Qt.AlignVCenter
            sourceImage: iconList[Math.min(infoType, 3)]
            fillColorFirst: infoType === 2 ? ThemeColorStyle.privacy_error_color : ThemeColorStyle.privacy_text_color
            visible: ScreenTools.imageIsSvgSource(iconList[Math.min(infoType, 3)])
        }

        // 内容区域
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: ScreenTools.scaleNum(8)

            // 标题
            Text {
                id: titleLabel
                text: titleText
                font.pointSize: ScreenTools.scaleNum(14,true)
                font.weight: Font.Medium
                color: ThemeColorStyle.title_text_nor_color
                font.family: ScreenTools.fontFamily
                elide: Text.ElideRight
            }

            // 内容
            Text {
                id: contentLabel
                text: contentText
                font.pointSize: ScreenTools.scaleNum(12,true)
                color: ThemeColorStyle.text_nor_color
                font.family: ScreenTools.fontFamily
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.fillHeight: true
                elide: Text.ElideRight
                maximumLineCount: 2
                lineHeight: 1.4
                lineHeightMode: Text.ProportionalHeight
            }
        }

        // 关闭按钮
        Image {
            id: closeBtn
            Layout.alignment: Qt.AlignTop
            width: ScreenTools.scaleNum(10)
            height: ScreenTools.scaleNum(10)
            source: CommonPngImageStyle.closeButtonUrl_img

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    control.closed()
                }
            }
        }
    }
}
