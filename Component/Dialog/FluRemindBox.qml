
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import FluentUI 1.0
import Component.FluComponent 1.0
import InfoInterface 1.0

Item {
    id: control
    width: ScreenTools.scaleNum(420)
    height: ScreenTools.scaleNum(216)

    property string titleText: "帮助信息"
    property string contentText: "这是一条解释的信息文案！"

    property alias leftBtn: _leftBtn
    property alias rightBtn: _rightBtn
    property int iconSize: ScreenTools.scaleNum(16)
    

    // 信号
    signal closed()
    
    // 背景
    FluControlBackground{
        anchors.fill: parent
        radius: ScreenTools.scaleNum(8)
        color: "#FFFFFF"
        FluFocusRectangle{
            visible: control.activeFocus
            radius: ScreenTools.scaleNum(8)
        }
    }


    // 内容区域
    ColumnLayout {
        anchors.fill: parent
        Layout.alignment: Qt.AlignHCenter
        spacing: ScreenTools.scaleNum(16)

        Item{
            height: ScreenTools.scaleNum(8)
        }

        FluCustomSvg{
            imageWidth: iconSize
            imageHeight: iconSize
            Layout.alignment: Qt.AlignHCenter
            sourceImage: CommonImageStyle.rect_info_img
            fillColorFirst: ThemeColorStyle.privacy_text_color
        }

        // 标题
        Text {
            id: titleLabel
            text: titleText
            visible: !!titleText
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: control.width - ScreenTools.scaleNum(132)
            width: Math.min(titleLabel.implicitWidth, control.width - ScreenTools.scaleNum(48))
            font.pointSize: ScreenTools.scaleNum(14,true)
            font.weight: Font.Medium
            color: InfoInterface.titleTextColor
            font.family: ScreenTools.fontFamily
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // 内容
        Text {
            id: contentLabel
            text: contentText
            visible: !!contentText
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: control.width - ScreenTools.scaleNum(132)
            font.pointSize: ScreenTools.scaleNum(12,true)
            width: Math.min(contentLabel.implicitWidth, control.width - 48)
            color: InfoInterface.contentTextColor
            font.family: ScreenTools.fontFamily
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        RowLayout {
            spacing: ScreenTools.scaleNum(16)
            Layout.alignment: Qt.AlignHCenter
            Item {
                width: ScreenTools.scaleNum(8)
            }
            FluButton {
                id: _leftBtn
                Layout.preferredWidth: ScreenTools.scaleNum(120)
                Layout.preferredHeight: ScreenTools.scaleNum(36)
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
                text: "次级按钮"
                textColor: ThemeColorStyle.text_nor_color
                background:  Rectangle {
                    radius: ScreenTools.scaleNum(4)
                    border.color: ThemeColorStyle.border_nor_color
                    border.width: 1
                    color: "transparent"
                    opacity: _leftBtn.hovered ? 0.7 : 1
                }
            }

            FluButton {
                id: _rightBtn
                Layout.preferredWidth: ScreenTools.scaleNum(120)
                Layout.preferredHeight: ScreenTools.scaleNum(36)
                text: "主要按钮"
                textColor: ThemeColorStyle.okBtn_text_color
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
                background: FluControlBackground{
                    radius: ScreenTools.scaleNum(4)
                    opacity: _rightBtn.hovered ? 0.7 : 1
                    shadow: !_rightBtn.pressed
                    color: ThemeColorStyle.okBtn_bg_color
                    FluFocusRectangle{
                        visible: control.activeFocus
                        radius: ScreenTools.scaleNum(4)
                    }
                }
            }

            Item {
                width: ScreenTools.scaleNum(8)
            }
        }

        Item{
            height: ScreenTools.scaleNum(24)
        }
    }
    
}
