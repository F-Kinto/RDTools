/*********************************************************************
File : DeleteCloudFileDialog.qml
Module : VideoPage
Authors: guangnan
date : 2023/10/24 16:00
Ver : 1.0.0
History:
guangnan 2023/08/01 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtQml 2.15
import Component.Login 1.0
import ScreenTools 1.0
import Component.Button 1.0
import Component.FluButton 1.0
import Component.Dialog 1.0
import Component.FluComponent 1.0
import VMS.Enum 1.0
import ConfigureManager 1.0
import InformationNotifier 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import FluentUI 1.0
FluCustomTipDialog {
    id: dialog
    signal closeReuslt(real cmd)
    property string showContent: qsTr("Select up to 30 cloud recordings.")
    property string imageTipsUrl: CommonImageStyle.border_info_img
    property int btnStyle: 1 // 0: 两个按钮, 1: 显示一个按钮
    property bool isSvgSource: ScreenTools.imageIsSvgSource(imageTipsUrl)

    width: ScreenTools.scaleNum(500)
    height: ScreenTools.scaleNum(228)

    title: ""
    titleBgColor: "#FFFFFF"
    messageImgUrl: imageTipsUrl
    leftRightMargin: ScreenTools.scaleNum(36)
    message: showContent
    negativeText: qsTr("Cancel")
    positiveText: qsTr("Confirm")
    neutralText: positiveText
    showTwoButton: btnStyle == 0

    imgComponent: Component{
        Rectangle{
            width: ScreenTools.scaleNum(20)
            height: ScreenTools.scaleNum(20)
            
            Image{
                source: imageTipsUrl
                Layout.alignment: Qt.AlignVCenter
                width: ScreenTools.scaleNum(24)
                height: ScreenTools.scaleNum(24)
                visible: !isSvgSource
            }
            FluCustomSvg{
                imageWidth: ScreenTools.scaleNum(24)
                imageHeight: ScreenTools.scaleNum(24)
                Layout.alignment: Qt.AlignVCenter
                sourceImage: imageTipsUrl
                fillColorFirst: ThemeColorStyle.privacy_text_color
                visible: isSvgSource
            }
        }
    }
    
    onPositiveClicked:{
        close();
        closeReuslt(1);
    }
    onNegativeClicked:{
        closeReuslt(0);
        close();
    }
    onNeutralClicked:{
        closeReuslt(0);
        close();
    }
    
}
