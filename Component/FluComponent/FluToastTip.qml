import QtQuick 2.0
import QtQuick.Controls 2.15
import ScreenTools 1.0
import QtQuick.Layouts 1.15
import ConfigureManager 1.0
import Component.FluComponent 1.0
import InfoInterface 1.0

Rectangle {
    id:tips

    // 字体属性设置
    property string textColor: ThemeColorStyle.title_text_nor_color   //文本颜色
    property int  fontSize: ScreenTools.scaleNum(10, true)
    property bool isBold: false
    //显示最大宽度，超过宽度自动换行
    property int maxWidth: ScreenTools.scaleNum(40)    

    // 图标尺寸 可见性
    property bool iconVisible: true
    property int iconSize: iconVisible ? ScreenTools.scaleNum(20) : 0

    //文本对齐方式
    property int alignmentValue: iconVisible ? Qt.AlignLeft : Qt.AlignHCenter   
    property int lineHeight: Math.max(ScreenTools.calculateMultiLineHeight(tipsText, fontSize, maxWidth - iconSize - ScreenTools.scaleNum(40), isBold), ScreenTools.scaleNum(40))//maxWidth - iconSize - 40 = 最大宽度 - 图标宽度,左右边距(16), 布局spacing(8)
    property string tipsText: qsTr("Registration successful, please log in")

    // 消息提示类型 以及对应 背景色配置 0-Info, 1-Success,2-Warning, 3-Error
    property int infoType: 1
    property var bgList: [
        ThemeColorStyle.privacy_color,  // Info - 蓝色
        InfoInterface.successBgColor,   // Success - 绿色
        InfoInterface.warningBgColor,   // Warning - 黄色
        InfoInterface.errorBgColor,     // Error - 红色
    ]

    // 图标配置（根据类型变化）
    property var iconList: [
        CommonImageStyle.rect_info_img,
        CommonPngImageStyle.info_success24_img,
        CommonPngImageStyle.info_warning24_img,
        CommonImageStyle.tip_error_img,
    ]

    color: bgList[Math.min(infoType, 3)]
    implicitWidth: Math.min(ScreenTools.calculateTextWidth(tipsText, fontSize, isBold, false) + ScreenTools.scaleNum(64), maxWidth)
    height: lineHeight > ScreenTools.scaleNum(60) ? lineHeight + ScreenTools.scaleNum(16) : lineHeight
    radius: ScreenTools.scaleNum(4)
    opacity: 0.9;
    visible: loginTipsTimer.running

    // 镜像
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    anchors.top: parent.top
    anchors.topMargin: ScreenTools.scaleNum(12)
    anchors.horizontalCenter: parent.horizontalCenter

    RowLayout {
        anchors.fill: parent
        spacing: ScreenTools.scaleNum(8)

        Item {
            Layout.fillHeight: true
            width: ScreenTools.scaleNum(8)
        }

        // 图标
        FluCustomSvg{
            imageWidth: iconSize
            imageHeight: iconSize
            Layout.alignment: Qt.AlignVCenter
            sourceImage: iconList[Math.min(infoType, 3)]
            fillColorFirst: infoType === 3 ? ThemeColorStyle.privacy_error_color : ThemeColorStyle.privacy_text_color
            visible: ScreenTools.imageIsSvgSource(iconList[Math.min(infoType, 3)])
        }
        FluCustomImageLoader {
            id: typeIcon
            Layout.alignment: Qt.AlignVCenter
            normalImageUrl: iconList[Math.min(infoType, 3)]
            imageWidth: iconSize
            imageHeight: iconSize
            visible: !ScreenTools.imageIsSvgSource(iconList[Math.min(infoType, 3)])
        }

        Label {
            text: tipsText
            objectName: "tipsText"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            font.pointSize: fontSize
            Layout.topMargin: ScreenTools.scaleNum(8)
            Layout.bottomMargin: ScreenTools.scaleNum(8)
            height: parent.height
            font.bold: isBold
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: alignmentValue
            font.family:ScreenTools.fontFamily
            wrapMode: Text.WrapAnywhere
            color: textColor
        }

        Item {
            Layout.fillHeight: true
            width: ScreenTools.scaleNum(6)
        }
    }


    Timer{
        id:loginTipsTimer
        running: false
        repeat: false
        interval: 3500
        onTriggered: {
            loginTipsTimer.stop();
        }
    }
    
    function showTips(txt){
        tipsText = txt;
        loginTipsTimer.running = true;
    }
}

