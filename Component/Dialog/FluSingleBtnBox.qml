
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import FluentUI 1.0
import InfoInterface 1.0

Item {
    id: control
    width: ScreenTools.scaleNum(400)
    height: ScreenTools.scaleNum(247)

    property string titleText: "帮助信息"
    property string contentText: "这是一条解释的信息文案！"
    property alias btn: _btn

    // 信号
    signal closed()
    
    // 背景
    FluControlBackground{
        anchors.fill: parent
        radius: ScreenTools.scaleNum(4)
        color: "#FFFFFF"
        FluFocusRectangle{
            visible: control.activeFocus
            radius: ScreenTools.scaleNum(4)
        }
    }


    // 内容区域
    ColumnLayout {
        anchors.fill: parent
        Layout.alignment: Qt.AlignHCenter
        spacing: ScreenTools.scaleNum(16)

        Item{
            height: ScreenTools.scaleNum(16)
        }

        RowLayout { 
            Item{
                width: ScreenTools.scaleNum(24)
            }

            // 标题
            Text {
                id: titleLabel
                text: titleText
                Layout.alignment: Qt.AlignHCenter
                width: Math.min(titleLabel.implicitWidth, control.width - 128)
                font.pointSize: ScreenTools.scaleNum(14,true)
                font.weight: Font.Medium
                color: InfoInterface.titleTextColor
                font.family: ScreenTools.fontFamily
                font.bold: true
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item{
                Layout.fillWidth: true
            }

            // 关闭按钮
            Image {
                id: closeBtn
                Layout.alignment: Qt.AlignVCenter
                source: CommonPngImageStyle.closeButtonUrl_img

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        control.closed()
                    }
                }
            }

            Item{
                width: ScreenTools.scaleNum(24)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            radius: ScreenTools.scaleNum(2)
            color: "#F0F2F5"
        }

        Item {
            height: ScreenTools.scaleNum(120)
            width: control.width - ScreenTools.scaleNum(48)
            Layout.leftMargin: ScreenTools.scaleNum(24)
            Layout.rightMargin: ScreenTools.scaleNum(24)
            Layout.topMargin: ScreenTools.scaleNum(16)
            Layout.bottomMargin: ScreenTools.scaleNum(16)
            // Layout.alignment: Qt.AlignHCenter

            // 内容
            Text {
                id: contentLabel
                text: contentText
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: ScreenTools.scaleNum(24)
                font.pointSize: ScreenTools.scaleNum(12,true)
                width: Math.min(contentLabel.implicitWidth, control.width - ScreenTools.scaleNum(48))
                color: InfoInterface.titleTextColor
                font.family: ScreenTools.fontFamily
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 4
            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            radius: ScreenTools.scaleNum(2)
            color: "#F0F2F5"
        }

        FluButton {
            id: _btn
            Layout.alignment: Qt.AlignHCenter
            width: ScreenTools.scaleNum(352)
            height: ScreenTools.scaleNum(36)
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(10, true)
            text: "主要按钮"
            textColor: ThemeColorStyle.okBtn_text_color
            background: FluControlBackground{
                implicitWidth: ScreenTools.scaleNum(352)
                implicitHeight: ScreenTools.scaleNum(36)
                radius: ScreenTools.scaleNum(8)
                opacity: _btn.hovered ? 0.7 : 1
                shadow: !_btn.pressed
                color: ThemeColorStyle.okBtn_bg_color
                FluFocusRectangle{
                    visible: control.activeFocus
                    radius: ScreenTools.scaleNum(4)
                }
            }
        }

        Item{
            height: ScreenTools.scaleNum(16)
        }
    }
    
}
