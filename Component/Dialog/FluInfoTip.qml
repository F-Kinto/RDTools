
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import FluentUI 1.0
import InfoInterface 1.0
import Component.FluComponent 1.0

//MessageInfoPage.css
Item {
    id: control
    objectName: "fluInfoTip"
    visible: false
    width: ScreenTools.scaleNum(684)
    height: ScreenTools.scaleNum(40)

    property int infoType: 1
    property string infoText: "看这里！这是一条通知信息"
    property string btnText: "查看信息"
    property int leftSpace: ScreenTools.scaleNum(12)
    property alias img :_img
    property int iconWidth: ScreenTools.scaleNum(24)
    property int iconHeight: ScreenTools.scaleNum(24)
    property int fontSize: InfoInterface.pointSize
    property int rectRadius: ScreenTools.scaleNum(4)

    
    property var bgList: [
        ThemeColorStyle.privacy_color,
        InfoInterface.warningBgColor,
        InfoInterface.errorBgColor,
        InfoInterface.successBgColor, 
    ]

    property var iconList: [
        CommonImageStyle.rect_info_img,
        CommonPngImageStyle.info_warning24_img,
        CommonImageStyle.tip_error_img,
        CommonPngImageStyle.info_success24_img
    ]

    signal btnClicked()

    function showTip(type, info, btntxt, interval = 3000) {
        control.infoType = type
        control.infoText = info
        control.btnText = btntxt
        timer.interval = interval
        timer.restart()
        control.visible = true;
    }

    Timer{
        id: timer
        interval: 3000
        repeat: false
        running: false
        triggeredOnStart: false
        onTriggered: {
            control.visible = false;
        }
    }

    Rectangle{
        anchors.fill: parent
        color: bgList[infoType]
        radius: rectRadius
        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item{
                Layout.preferredWidth: leftSpace
                Layout.fillHeight: true
            }

            FluCustomImageLoader {
                id: _img
                Layout.alignment: Qt.AlignVCenter
                normalImageUrl: iconList[infoType]
                imageWidth: iconWidth
                imageHeight: iconHeight
                visible: !ScreenTools.imageIsSvgSource(iconList[infoType])
            }

            FluCustomSvg{
                imageWidth: iconWidth
                imageHeight: iconHeight
                Layout.alignment: Qt.AlignVCenter
                sourceImage: iconList[infoType]
                fillColorFirst: infoType === 2 ? ThemeColorStyle.privacy_error_color : ThemeColorStyle.privacy_text_color
                visible: ScreenTools.imageIsSvgSource(iconList[infoType])
            }

            FluCustomLable{
                objectName: "tipLabel"
                currentTextColor: ThemeColorStyle.title_text_nor_color
                Layout.fillHeight: true
                Layout.preferredWidth: control.width - leftSpace * 2 - iconWidth
                text: infoText
                currentBackgroundColor: "transparent"
                borderWidth: 0
                alignValue: Text.AlignLeft
                fontSize: control.fontSize
                textWrap:Text.WrapAnywhere
            }

            Item{
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            FluTextButton{
                visible: !!btnText
                Layout.alignment: Qt.AlignVCenter
                text: btnText
                Layout.fillHeight: true
                Layout.preferredWidth: control.width - leftSpace * 2 - iconWidth
                font.pointSize: control.fontSize
                font.family: ScreenTools.fontFamily
                onClicked: {
                    btnClicked();
                    control.visible = false;
                }
            }
            
            Item  {
                Layout.preferredWidth: leftSpace
                Layout.fillHeight: true
            }
        }
    }

}
