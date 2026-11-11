import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import Component.Dialog 1.0
import Component.FluButton 1.0
import ScreenTools 1.0

//截屏、录屏预览图组件
FluCustomTipDialog {
    id: control
    
    // 公共属性
    property string titleIconSource: CommonImageStyle.download_img
    property int titleIconSpacing: ScreenTools.scaleNum(8)     // 图标和文本的间隔，默认4px
    property var imageData: null
    property string imageSource: ""
    property string closeIconSource: ""  // 关闭图标路径
    property string imageName: ""
    property int dialogWidth: ScreenTools.scaleNum(260)    
    property int dialogHeight: ScreenTools.scaleNum(196) 
    property int mediaType: 0  // 0: 截图, 1: 录屏
    property string playButtonSource: ""  // 播放按钮图标路径（仅录屏时使用）
    width:dialogWidth
    height:dialogHeight

    background: Rectangle {
        color: "#FFFFFF"
        radius: ScreenTools.scaleNum(4)   // 覆盖掉基类的 
    }
    
    // 信号 - 使用信号槽机制
    signal buttonClicked(int index, int type, string text)  // 通用按钮信号
    signal playButtonClicked(int type)  // 录屏播放按钮点击信号
    signal closed()
    Timer {
        id: autoCloseTimer
        repeat: false
        
        onTriggered: {
            control.close()
        }
    }
    // 公开方法：启动定时器
    function startTimer(interval) {
        if (interval > 0) {
            autoCloseTimer.interval = interval
            autoCloseTimer.start()
        }
    }
    
    title: ""
    
    contentItem: Item {
        anchors.fill: parent
        
        //三行布局  
        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: ScreenTools.scaleNum(8)
            anchors.right: parent.right
            anchors.rightMargin: ScreenTools.scaleNum(8)
            anchors.top: parent.top
            anchors.topMargin: ScreenTools.scaleNum(6)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: ScreenTools.scaleNum(6)
            width: parent.width - anchors.leftMargin  - anchors.rightMargin
            height: parent.height - anchors.topMargin - anchors.bottomMargin      
            spacing: ScreenTools.scaleNum(4)
            
            // 标题区域
            RowLayout {
                id: titleArea
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.scaleNum(24) 
                spacing: ScreenTools.scaleNum(4)

                // 左侧图标 - 新增，紧挨着文字
                Item {
                    id: titleIconItem
                    Layout.preferredWidth: titleIconSource !== "" ? ScreenTools.scaleNum(24) : 0
                    Layout.preferredHeight: ScreenTools.scaleNum(24)
                    Layout.alignment: Qt.AlignVCenter
                    
                    FluCustomIconButton {
                        objectName: "titleIcon"
                        display: Button.IconOnly
                        buttonWidth: ScreenTools.scaleNum(24)
                        buttonHeight: ScreenTools.scaleNum(24)
                        iconSize: ScreenTools.scaleNum(20)
                        sourceImgUrl: titleIconSource
                        visible: control.titleIconSource !== ""
                        buttonFillColor: ThemeColorStyle.text_nor_color
                        Layout.alignment:Qt.AlignVCenter
                    }
                }
                
                
                // 标题文本 - 左侧
                Text {
                    id: titleTextItem
                    objectName: "titleTextItem"
                    font.family: ScreenTools.fontFamily
                    Layout.alignment: Qt.AlignVCenter
                    Layout.maximumWidth: ScreenTools.scaleNum(140)
                    
                    text: qsTr("Saved locally")
                    font.pointSize: ScreenTools.scaleNum(10,true)
                    color: ThemeColorStyle.title_text_nor_color
                    elide: Text.ElideRight
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                FluCustomIconButton {
                    id: closeBtn
                    objectName: "closeBtn"
                    display: Button.IconOnly
                    buttonWidth: ScreenTools.scaleNum(24)
                    buttonHeight: ScreenTools.scaleNum(24)
                    iconSize: ScreenTools.scaleNum(16)
                    sourceImgUrl: CommonImageStyle.close_img
                    buttonFillColor: closeBtn.isHovered ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.text_nor_color
                    Layout.alignment:Qt.AlignVCenter
                    showHoverTip: true
                    hoverTipText: qsTr("Close")
                    iconOnlyNeedHoverBg: true
                    onClicked: {
                        if (autoCloseTimer.running) {
                            autoCloseTimer.stop()
                        }
                        control.close();
                    }
                }
            }
            
            //缩略图区域
            Rectangle {
                id: imageArea
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.scaleNum(108)
                color: "transparent"
                
                Image {
                    objectName: "previewImg"
                    anchors.fill: parent
                    anchors.margins: 0
                    source: control.imageData !== null ? control.imageData : control.imageSource  //优先 QImage，其次字符串
                    fillMode: Image.PreserveAspectFit
                    
                    onStatusChanged: {
                        if (status === Image.Error) {
                            console.log("图片加载失败:", control.imageData !== null ? "imageData" : control.imageSource)
                        }
                    }
                }
                // 录屏时显示的播放按钮（叠加在图片中心）
                Item {
                    id: playButtonItem
                    anchors.centerIn: parent
                    width: ScreenTools.scaleNum(40)
                    height: ScreenTools.scaleNum(40)
                    visible: control.mediaType === 1
                    
                    FluIconButton{
                        objectName: "playBtn"
                        iconSource:FluentIcons.Play
                        horizontalPadding: ScreenTools.scaleNum(4)
                        verticalPadding: ScreenTools.scaleNum(4)
                        iconSize: ScreenTools.scaleNum(32)
                        iconColor: "#FFFFFF"
                        onClicked: {
                            control.playButtonClicked(mediaType);
                        }
                    }
                }
            }
            
            RowLayout {
                id: controlBtnArea
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.scaleNum(24)

                FluCustomIconButton {
                    id: deleteBtn
                    objectName: "deleteBtn"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Math.max(ScreenTools.calculateTextWidth(deleteBtn.text,deleteBtn.font.pointSize, false, false) +  ScreenTools.scaleNum(4),  ScreenTools.scaleNum(36))
                    Layout.fillHeight: true
                    font.pointSize: ScreenTools.scaleNum(10, true)
                    hoverColor: ThemeColorStyle.privacy_color
                    borderWidth: 0
                    textNormalColor: ThemeColorStyle.privacy_error_color
                    text: qsTr("Delete")
                    onClicked: {
                        control.buttonClicked(0, mediaType, imageName);
                    }
                }

                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                FluCustomIconButton {
                    id: openFolderBtn
                    objectName: "openFolderBtn"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Math.max(ScreenTools.calculateTextWidth(openFolderBtn.text,openFolderBtn.font.pointSize, false, false) +  ScreenTools.scaleNum(4),  ScreenTools.scaleNum(36))
                    Layout.fillHeight: true
                    font.pointSize: ScreenTools.scaleNum(10, true)
                    hoverColor: ThemeColorStyle.privacy_color
                    borderWidth: 0
                    textNormalColor: ThemeColorStyle.privacy_text_color
                    text: qsTr("Open folder")
                    onClicked: {
                        control.buttonClicked(1, mediaType, imageName)
                    }
                }
            }
        }
    }
}