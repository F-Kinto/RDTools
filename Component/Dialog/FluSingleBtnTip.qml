
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import FluentUI 1.0
import InfoInterface 1.0

Item {
    id: control
    width: ScreenTools.scaleNum(424)
    height: ScreenTools.scaleNum(208)
    property string contentText: qsTr("Regular users can view up to 25 channels simultaneously. If you need to view more, please subscribe to the Extended Viewing feature.")
    property alias btn: _btn

    property int bottomMargin: ScreenTools.scaleNum(32)

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

        Item{
            height: ScreenTools.scaleNum(56)
        }

        RowLayout { 
            property bool isSvgSource: ScreenTools.imageIsSvgSource(CommonImageStyle.border_info_img)
            Item{
                width: ScreenTools.scaleNum(50)
            }

            Image {
                id: icon
                // Layout.alignment: Qt.AlignVCenter
                source:CommonImageStyle.border_info_img
                visible: !isSvgSource
            }
            FluCustomSvg{
                imageWidth: ScreenTools.scaleNum(24)
                imageHeight: ScreenTools.scaleNum(24)
                Layout.alignment: Qt.AlignVCenter
                sourceImage: CommonImageStyle.border_info_img
                fillColorFirst: ThemeColorStyle.privacy_text_color
                visible: isSvgSource
            }

            Item{
                width: ScreenTools.scaleNum(8)
            }
            Text {
                id: contentLabel
                text: contentText
                Layout.alignment: Qt.AlignVCenter
                font.pointSize: ScreenTools.scaleNum(12,true)
                Layout.maximumWidth: control.width - ScreenTools.scaleNum(132)
                color: InfoInterface.contentTextColor
                font.family: ScreenTools.fontFamily
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item{
                Layout.fillWidth: true
            }
        }

        Item{
            height: ScreenTools.scaleNum(32)

        }

        FluButton {
            id: _btn
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: ScreenTools.scaleNum(144)
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(10, true)
            text: qsTr("Enable long preview")
            textColor: ThemeColorStyle.okBtn_text_color
            background: FluControlBackground{
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
            height: bottomMargin
        }
    }

    // 关闭按钮
    Image {
        id: closeBtn
        anchors.right: parent.right
        anchors.rightMargin: ScreenTools.scaleNum(10)
        anchors.top: parent.top
        anchors.topMargin: ScreenTools.scaleNum(10)
        source: CommonPngImageStyle.closeButtonUrl_img

        MouseArea{
            anchors.fill: parent
            onClicked: {
                control.closed()
            }
        }
    }
    
}
