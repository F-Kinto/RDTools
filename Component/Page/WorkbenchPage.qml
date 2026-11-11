import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import Component.VideoPage 1.0
import Component.DeviceManager 1.0
import Component.FluDeviceManager 1.0
import Component.FluComponent 1.0
import Component.FluButton 1.0
import Component.Message 1.0
import InformationNotifier 1.0
import VMS.Enum 1.0
import SystemMessageModel 1.0
import Component.CardVideo 1.0
import ConfigureManager 1.0
import ScreenTools 1.0
import Component.Page 1.0

Item{
    objectName: "workBenchPage"
    signal sendPage(var ico, var title, var sender, var pageEnum)

    property real deviceTotal: 0
    property real onLineNumber: 0
    property real offLineNumber: deviceTotal - onLineNumber
    // toast 提示时长
    property int toastDuration: 3000

    id:control
    width: ScreenTools.scaleNum(800)
    height: ScreenTools.scaleNum(600)
    anchors.leftMargin: ScreenTools.scaleNum(12)
    anchors.rightMargin: ScreenTools.scaleNum(12)
    anchors.bottomMargin: ScreenTools.scaleNum(12)

    Component.onCompleted: {
        control.updateDeviceCount()
    }

    RowLayout{
        anchors.fill: parent
        spacing: ScreenTools.scaleNum(12)
        //左布局页
        FluFrame {
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius:ScreenTools.scaleNum(24)
            color: "#FFFFFF"
            border.width: 0
            topPadding: ScreenTools.scaleNum(24)
            bottomPadding: ScreenTools.scaleNum(24)

            Flickable{
                id: leftFlickable
                anchors.fill: parent
                contentWidth: width
                contentHeight: leftColumnLayout.implicitHeight
                clip: true
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
                ColumnLayout{
                    id: leftColumnLayout
                    width: parent.width
                    height: implicitHeight
                    spacing: ScreenTools.scaleNum(48)
                    //视频功能
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        Layout.leftMargin: ScreenTools.scaleNum(24)
                        Layout.rightMargin: ScreenTools.scaleNum(24)
                        spacing: ScreenTools.scaleNum(8)
                        Item {
                            Layout.preferredHeight: ScreenTools.scaleNum(24)
                            Layout.fillWidth: true

                            FluText {
                                id: videoText
                                objectName: "videoText"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                text: qsTr("Video Functions")
                                textColor: ThemeColorStyle.title_text_nor_color
                                font.pointSize: ScreenTools.scaleNum(12, true)
                                font.bold: true
                                font.family: ScreenTools.fontFamily
                            }
                            Rectangle {
                                height: ScreenTools.scaleNum(6)
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                width: ScreenTools.calculateTextWidth(videoText.text, videoText.font.pointSize)
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: ConfigureManager.isRTLLayout ? 1.0 :0.0;
                                        color: Qt.rgba(parseInt(ThemeColorStyle.privacy_text_color.substring(1, 3) , 16) / 255,
                                                       parseInt(ThemeColorStyle.privacy_text_color.substring(3, 5) , 16) / 255,
                                                       parseInt(ThemeColorStyle.privacy_text_color.substring(5, 7) , 16) / 255,
                                                       0.5)
                                    }
                                    GradientStop { position: ConfigureManager.isRTLLayout ? 0.1 : 1.0; color: "#FFFFFF" }
                                }
                            }
                        }

                        Flow{
                            id: videoFlow
                            Layout.fillWidth: true
                            spacing: ScreenTools.scaleNum(16)
                            flow: Flow.LeftToRight

                            FluCustomImage{
                                objectName: "realtimePreview"
                                clip: true
                                height: ScreenTools.scaleNum(100)
                                width: ScreenTools.scaleNum(266)
                                normalImageUrl: VmsToolPngStyle.content_preview_img
                                onClicked: {
                                    sendPage(CommonImageStyle.tab_preview_img, qsTr("Live View"), realTimePreview,VmsEnum.PageOperate.RealtimePreviewEnum)
                                }
                                mirror: ConfigureManager.isRTLLayout

                                Item{
                                    anchors.fill: parent
                                    anchors.margins: ScreenTools.scaleNum(24)

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: ScreenTools.scaleNum(8)

                                        FluText{
                                            objectName: "realtimePreviewTitle"
                                            Layout.preferredHeight: ScreenTools.scaleNum(24)
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: ScreenTools.scaleNum(12, true)
                                            font.family: ScreenTools.fontFamily
                                            color: ThemeColorStyle.title_text_nor_color
                                            text:qsTr("Live View");
                                            wrapMode:Text.WrapAnywhere
                                        }

                                        FluText{
                                            objectName: "realtimePreviewDetail"
                                            Layout.preferredHeight: ScreenTools.scaleNum(32)
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: ScreenTools.scaleNum(10, true)
                                            font.family: ScreenTools.fontFamily
                                            color: ThemeColorStyle.text_nor_color
                                            text:qsTr("Multi-view Live");
                                            wrapMode:Text.WrapAnywhere
                                        }
                                    }
                                }
                            }

                            FluCustomImage{
                                objectName: "cloudPlayBack"
                                clip: true
                                height: ScreenTools.scaleNum(100)
                                width: ScreenTools.scaleNum(266)
                                visible: InformationNotifier.isLogin
                                normalImageUrl: VmsToolPngStyle.content_cloudPlayback_img
                                onClicked: {
                                    sendPage(CommonImageStyle.tab_cloudPlayback_img, qsTr("Cloud Playback"), cloudPlayback,VmsEnum.PageOperate.CloudPlaybackEnum)
                                }
                                mirror: ConfigureManager.isRTLLayout

                                Item{
                                    anchors.fill: parent
                                    anchors.margins: ScreenTools.scaleNum(24)

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: ScreenTools.scaleNum(8)

                                        FluText{
                                            objectName: "cloudPlayBackTitle"
                                            Layout.preferredHeight: ScreenTools.scaleNum(24)
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: ScreenTools.scaleNum(12, true)
                                            font.family: ScreenTools.fontFamily
                                            color: ThemeColorStyle.title_text_nor_color
                                            text:qsTr("Cloud Playback");
                                            wrapMode:Text.WrapAnywhere
                                        }

                                        FluText{
                                            objectName: "cloudPlayBackDetail"
                                            Layout.preferredHeight: ScreenTools.scaleNum(32)
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: ScreenTools.scaleNum(10, true)
                                            font.family: ScreenTools.fontFamily
                                            color: ThemeColorStyle.text_nor_color
                                            text:qsTr("Cloud Storage");
                                            wrapMode:Text.WrapAnywhere
                                        }
                                    }
                                }
                            }

                            FluCustomImage{
                                objectName: "videoPlayBack"
                                clip: true
                                height: ScreenTools.scaleNum(100)
                                width: ScreenTools.scaleNum(266)
                                normalImageUrl: VmsToolPngStyle.content_playback_img
                                onClicked: {
                                    sendPage(CommonImageStyle.sd_record_img, qsTr("Playback"), videoPlayback,VmsEnum.PageOperate.VideoPlaybackEnum)
                                }
                                mirror: ConfigureManager.isRTLLayout

                                Item{
                                    anchors.fill: parent
                                    anchors.margins: ScreenTools.scaleNum(24)

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: ScreenTools.scaleNum(8)

                                        FluText{
                                            objectName: "videoPlayBackTitle"
                                            Layout.preferredHeight: ScreenTools.scaleNum(24)
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: ScreenTools.scaleNum(12, true)
                                            font.family: ScreenTools.fontFamily
                                            color: ThemeColorStyle.title_text_nor_color
                                            text:qsTr("Playback");
                                            wrapMode:Text.WrapAnywhere
                                        }

                                        FluText{
                                            objectName: "videoPlayBackDetail"
                                            Layout.preferredHeight: ScreenTools.scaleNum(32)
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: ScreenTools.scaleNum(10, true)
                                            font.family: ScreenTools.fontFamily
                                            color: ThemeColorStyle.text_nor_color
                                            text:qsTr("SD Card Recording");
                                            wrapMode:Text.WrapAnywhere
                                        }
                                    }
                                }
                            }

                            //本地回放
                            FluCustomImage{
                                objectName: "localRecording"
                                clip: true
                                height: ScreenTools.scaleNum(100)
                                width: ScreenTools.scaleNum(266)
                                normalImageUrl: VmsToolPngStyle.content_local_record_img
                                onClicked: {
                                    sendPage(CommonImageStyle.tab_record_img, qsTr("Local Recording"), localRecordingPage,VmsEnum.PageOperate.LocalRecordingEnum)
                                }
                                mirror: ConfigureManager.isRTLLayout

                                Item{
                                    anchors.fill: parent
                                    anchors.margins: ScreenTools.scaleNum(24)

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: ScreenTools.scaleNum(8)

                                        FluText{
                                            objectName: "localRecordingTitle"
                                            Layout.preferredHeight: ScreenTools.scaleNum(24)
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: ScreenTools.scaleNum(12, true)
                                            font.family: ScreenTools.fontFamily
                                            color: ThemeColorStyle.title_text_nor_color
                                            text:qsTr("Local Recording");
                                            wrapMode:Text.WrapAnywhere
                                        }

                                        FluText{
                                            objectName: "localRecordingDetail"
                                            Layout.preferredHeight: ScreenTools.scaleNum(32)
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: ScreenTools.scaleNum(10, true)
                                            font.family: ScreenTools.fontFamily
                                            color: ThemeColorStyle.text_nor_color
                                            text:qsTr("SD Card Playback");
                                            wrapMode:Text.WrapAnywhere
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //基础功能
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: ScreenTools.scaleNum(8)
                        Layout.rightMargin: ScreenTools.scaleNum(24)
                        spacing: ScreenTools.scaleNum(8)

                        Item {
                            Layout.preferredHeight: ScreenTools.scaleNum(24)
                            Layout.fillWidth: true
                            Layout.leftMargin: ScreenTools.scaleNum(18)

                            FluText {
                                id: basicText
                                objectName: "basicText"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                text: qsTr("Basic Functions")
                                textColor: ThemeColorStyle.title_text_nor_color
                                font.pointSize: ScreenTools.scaleNum(12, true)
                                font.bold: true
                                font.family: ScreenTools.fontFamily
                            }

                            Rectangle {
                                height: ScreenTools.scaleNum(6)
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                width: ScreenTools.calculateTextWidth(basicText.text, basicText.font.pointSize)
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: ConfigureManager.isRTLLayout ? 1.0 :0.0;
                                        color: Qt.rgba(parseInt(ThemeColorStyle.privacy_text_color.substring(1, 3), 16) / 255,
                                                       parseInt(ThemeColorStyle.privacy_text_color.substring(3, 5), 16) / 255,
                                                       parseInt(ThemeColorStyle.privacy_text_color.substring(5, 7), 16) / 255,
                                                       0.5)
                                    }
                                    GradientStop { position: ConfigureManager.isRTLLayout ? 0.1 : 1.0; color: "#FFFFFF" }
                                }
                            }
                        }

                        Flow{
                            id: basicFlow
                            Layout.fillWidth: true
                            spacing: ScreenTools.scaleNum(16)
                            flow: Flow.LeftToRight

                            //消息中心
                            Item{
                                height: ScreenTools.scaleNum(86)
                                width: ScreenTools.scaleNum(88)
                                visible: InformationNotifier.isLogin
                                ColumnLayout{
                                    anchors.fill: parent
                                    spacing: ScreenTools.scaleNum(8)
                                    FluCustomImage{
                                        objectName: "messageCenter"
                                        Layout.preferredHeight: ScreenTools.scaleNum(56)
                                        Layout.preferredWidth: ScreenTools.scaleNum(56)
                                        Layout.alignment: Qt.AlignHCenter
                                        normalImageUrl: VmsToolPngStyle.content_msg_img
                                        mirror: ConfigureManager.isRTLLayout
                                        onClicked: {
                                            if(!InformationNotifier.isLogin){
                                                showError(qsTr("Please log in to your account first"), toastDuration)
                                                return;
                                            }
                                            //获取未读系统消息数
                                            SystemMessageModel.queryExistUnreadMsg([])
                                            sendPage(CommonImageStyle.tab_msg_img, qsTr("Notification Center"), messageCenter,VmsEnum.PageOperate.MessageCenterEnum)
                                        }
                                    }

                                    FluText{
                                        objectName: "messageCenterLabel"
                                        Layout.preferredHeight: ScreenTools.scaleNum(22)
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignTop
                                        text:qsTr("Notification Center");
                                        textColor: ThemeColorStyle.text_nor_color
                                        font.pointSize: ScreenTools.scaleNum(10, true)
                                        font.family: ScreenTools.fontFamily
                                        wrapMode:Text.WrapAnywhere
                                    }
                                }
                            }
                            //本地文件夹
                            Item{
                                height: ScreenTools.scaleNum(86)
                                width: ScreenTools.scaleNum((88))
                                ColumnLayout{
                                    anchors.fill: parent
                                    spacing: ScreenTools.scaleNum(8)
                                    FluCustomImage{
                                        objectName: "localFiles"
                                        Layout.preferredHeight: ScreenTools.scaleNum(56)
                                        Layout.preferredWidth: ScreenTools.scaleNum(56)
                                        Layout.alignment: Qt.AlignHCenter
                                        normalImageUrl: VmsToolPngStyle.content_local_file_img
                                        mirror: ConfigureManager.isRTLLayout
                                        onClicked: {
                                            DispatchManager.deviceObj.operateCapturePicture(2,"");
                                        }
                                    }

                                    FluText{
                                        objectName: "localFilesLabel"
                                        Layout.preferredHeight: ScreenTools.scaleNum(22)
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignTop
                                        text:qsTr("Local Files");
                                        textColor: ThemeColorStyle.text_nor_color
                                        font.pointSize: ScreenTools.scaleNum(10, true)
                                        font.family: ScreenTools.fontFamily
                                        wrapMode:Text.WrapAnywhere
                                    }
                                }
                            }
                            //团队管理
                            // Item{
                            // Layout.preferredHeight: ScreenTools.scaleNum(120)
                            // Layout.preferredWidth: ScreenTools.scaleNum(100)
                            // ColumnLayout{
                            // anchors.fill: parent
                            // spacing: ScreenTools.scaleNum(10)
                            // FluImageButton{
                            // Layout.preferredHeight: ScreenTools.scaleNum(100)
                            // Layout.fillWidth: true
                            // normalImage: "../Image/btn_max_normal.png"
                            // hoveredImage: "../Image/btn_max_hovered.png"
                            // pushedImage: "../Image/btn_max_pushed.png"
                            // onClicked: {
                            // showSuccess(qsTr("Team Management"))
                            // //sendPage(ConfigureManager.getProgramLogoUrl(), qsTr("testDemo"), testDemo)
                            // }
                            // }

                            // FluText{
                            // Layout.preferredHeight: ScreenTools.scaleNum(24)
                            // Layout.fillWidth: true
                            // horizontalAlignment: Text.AlignHCenter
                            // verticalAlignment: Text.AlignVCenter
                            // text:qsTr("Team Management");
                            // font.pointSize: ScreenTools.scaleNum(10, true)
                            // font.family: ScreenTools.fontFamily
                            // wrapMode:Text.WrapAnywhere
                            // }
                            // }
                            // }
                            //局域网设备
                            Item{
                                height: ScreenTools.scaleNum(86)
                                width: ScreenTools.scaleNum((88))
                                ColumnLayout{
                                    anchors.fill: parent
                                    spacing: ScreenTools.scaleNum(8)
                                    FluCustomImage{
                                        objectName: "lanDevice"
                                        Layout.preferredHeight: ScreenTools.scaleNum(56)
                                        Layout.preferredWidth: ScreenTools.scaleNum(56)
                                        Layout.alignment: Qt.AlignHCenter
                                        normalImageUrl: VmsToolPngStyle.content_local_device_img
                                        mirror: ConfigureManager.isRTLLayout
                                        onClicked: {
                                            sendPage(CommonImageStyle.tab_lan_img, qsTr("LAN Device"), lanDevicePage,VmsEnum.PageOperate.LANDeviceEnum)
                                        }
                                    }

                                    FluText{
                                        objectName: "lanDeviceLabel"
                                        Layout.preferredHeight: ScreenTools.scaleNum(22)
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignTop
                                        text:qsTr("LAN Device");
                                        wrapMode:Text.WrapAnywhere
                                        textColor: ThemeColorStyle.text_nor_color
                                        font.pointSize: ScreenTools.scaleNum(10, true)
                                        font.family: ScreenTools.fontFamily
                                    }
                                }
                            }

                            //设备管理
                            Item{
                                height: ScreenTools.scaleNum(86)
                                width: ScreenTools.scaleNum(88)
                                ColumnLayout{
                                    anchors.fill: parent
                                    spacing: ScreenTools.scaleNum(8)
                                    FluCustomImage{
                                        objectName: "deviceManagement"
                                        Layout.preferredHeight: ScreenTools.scaleNum(56)
                                        Layout.preferredWidth: ScreenTools.scaleNum(56)
                                        Layout.alignment: Qt.AlignHCenter
                                        normalImageUrl: VmsToolPngStyle.content_device_manage_img
                                        mirror: ConfigureManager.isRTLLayout
                                        onClicked: {
                                            isShowdeviceManager++
                                        }
                                    }

                                    FluText{
                                        objectName: "deviceManagementLabel"
                                        Layout.preferredHeight: ScreenTools.scaleNum(22)
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignTop
                                        text:qsTr("Device Management");
                                        wrapMode:Text.WrapAnywhere
                                        textColor: ThemeColorStyle.text_nor_color
                                        font.pointSize: ScreenTools.scaleNum(10, true)
                                        font.family: ScreenTools.fontFamily
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //右布局页
        // Item {
        // clip: true
        // Layout.preferredWidth: parent.width * 0.3
        // Layout.fillHeight: parent.height
        // ColumnLayout{
        // anchors.fill: parent
        // spacing: ScreenTools.scaleNum(10)
        // //上部分布局（团队）
        // FluFrame {
        // clip: true
        // Layout.fillWidth: true
        // implicitHeight: parent.height * 0.25
        // padding: ScreenTools.scaleNum(10)
        // ColumnLayout{
        // id: teamHead
        // anchors.fill: parent
        // spacing: ScreenTools.scaleNum(12)

        // Item{
        // Layout.fillWidth: true
        // Layout.preferredHeight: ScreenTools.scaleNum(64)
        // RowLayout{
        // anchors.fill: parent
        // spacing: ScreenTools.scaleNum(10)

        // FluImage {
        // source: "qrc:/button/image/home/home_content_avatar@2x.png"
        // sourceSize.width: ScreenTools.scaleNum(64)
        // sourceSize.height: ScreenTools.scaleNum(64)
        // Layout.preferredWidth: ScreenTools.scaleNum(40)
        // Layout.preferredHeight: ScreenTools.scaleNum(40)
        // }

        // FluText {
        // text: "12215412541"
        // font.pointSize: ScreenTools.scaleNum(12, true)
        // font.bold: true
        // font.family: ScreenTools.fontFamily
        // color: "#2A2A2A"
        // verticalAlignment: Text.AlignVCenter
        // }
        // }
        // }

        // FluRectangle{
        // Layout.fillWidth: true
        // Layout.preferredHeight: ScreenTools.scaleNum(110)
        // radius: [10,10,10,10]
        // color: "#F3F5F8"

        // ColumnLayout{
        // anchors.fill: parent
        // anchors.margins: ScreenTools.scaleNum(12)
        // spacing: ScreenTools.scaleNum(10)

        // RowLayout{
        // Layout.fillWidth: true
        // FluText {
        // text: qsTr("My Devices")
        // font.pointSize: ScreenTools.scaleNum(12, true)
        // font.family: ScreenTools.fontFamily
        // color: "#333333"
        // }
        // Item{ Layout.fillWidth: true }
        // FluCustomSvg{
        //     imageWidth: ScreenTools.scaleNum(16)
        //     imageHeight: ScreenTools.scaleNum(16)
        //     Layout.alignment: Qt.AlignVCenter
        //     sourceImage: CommonImageStyle.list_arrow_right_img
        //     fillColorFirst: (hovered || pressed) ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.tab_text_nor_color
        //     onClicked: {
        //         isShowdeviceManager++
        //     }
        // }
        // }

        // RowLayout{
        // Layout.fillWidth: true
        // spacing: ScreenTools.scaleNum(20)

        // ColumnLayout{
        // spacing: 4
        // FluText{ text: qsTr("Total"); color: "#9197A0"; font.pointSize: ScreenTools.scaleNum(10, true); font.family: ScreenTools.fontFamily }
        // FluText{ text: "20"; color: "#2A2A2A"; font.pointSize: ScreenTools.scaleNum(18, true); font.family: ScreenTools.fontFamily }
        // }
        // ColumnLayout{
        // spacing: 4
        // FluText{ text: qsTr("Online"); color: "#9197A0"; font.pointSize: ScreenTools.scaleNum(10, true); font.family: ScreenTools.fontFamily }
        // FluText{ text: "10"; color: "#2A2A2A"; font.pointSize: ScreenTools.scaleNum(18, true); font.family: ScreenTools.fontFamily }
        // }
        // ColumnLayout{
        // spacing: 4
        // FluText{ text: qsTr("Offline"); color: "#9197A0"; font.pointSize: ScreenTools.scaleNum(10, true); font.family: ScreenTools.fontFamily }
        // FluText{ text: "10"; color: "#2A2A2A"; font.pointSize: ScreenTools.scaleNum(18, true); font.family: ScreenTools.fontFamily }
        // }
        // Item{ Layout.fillWidth: true }
        // }
        // }
        // }
        // }
        // }
        // //下部分布局（消息）
        // FluFrame {
        // clip: true
        // Layout.fillWidth: true
        // Layout.fillHeight: true
        // padding: 10
        // //更多消息
        // RowLayout{
        // id: latestMessagesHead
        // anchors{
        // left: parent.left
        // right: parent.right
        // top: parent.top
        // }
        // FluText {
        // text: qsTr("Latest Message")
        // Layout.alignment: Qt.AlignLeft
        // font.pointSize: ScreenTools.scaleNum(12, true)
        // font.bold: true
        // font.family: ScreenTools.fontFamily
        // }

        // // FluTextButton {
        // // Layout.alignment: Qt.AlignRight
        // // text: qsTr("More >")
        // // onClicked: {
        // // showSuccess(qsTr("More > btn Click"))
        // // }
        // // }
        // }
        // //消息显示区域
        // FluRectangle{
        // anchors{
        // top: latestMessagesHead.bottom
        // left:parent.left
        // right: parent.right
        // bottom: parent.bottom
        // }

        // FluText {
        // //text: qsTr("No data")
        // text: qsTr("This feature is currently under development and will be available soon.")
        // anchors.centerIn: parent
        // width: parent.width - 32
        // font.pointSize: ScreenTools.scaleNum(12, true)
        // font.family: ScreenTools.fontFamily
        // verticalAlignment: Text.AlignVCenter
        // horizontalAlignment: Text.AlignHCenter
        // wrapMode:Text.WrapAnywhere
        // }
        // }
        // }
        // }
        // }
        FluFrame{
            clip: true
            Layout.preferredWidth: parent.width * 0.32
            Layout.fillHeight: parent.height
            radius: ScreenTools.scaleNum(24)
            color: "#FFFFFF"
            border.width: 0
            padding: ScreenTools.scaleNum(24)

            ColumnLayout{
                anchors.fill: parent
                spacing: ScreenTools.scaleNum(24)

                Item{
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.scaleNum(64)
                    RowLayout{
                        anchors.fill: parent
                        spacing: ScreenTools.scaleNum(8)

                        FluImage {
                            objectName: "loginImg"
                            source: InformationNotifier.isLogin ? VmsToolPngStyle.content_avatar_img : CommonPngImageStyle.main_title_avatar_nor_Btn_img
                            sourceSize.width: ScreenTools.scaleNum(64)
                            sourceSize.height: ScreenTools.scaleNum(64)
                            Layout.preferredWidth: ScreenTools.scaleNum(64)
                            Layout.preferredHeight: ScreenTools.scaleNum(64)
                        }

                        FluText {
                            objectName: "loginText"
                            text: InformationNotifier.isLogin
                                  ? ConfigureManager.userAccount
                                  : qsTr("Not logged in")
                            font.pointSize: ScreenTools.scaleNum(12, true)
                            font.bold: true
                            font.family: ScreenTools.fontFamily
                            color: ThemeColorStyle.title_text_nor_color
                            verticalAlignment: Text.AlignVCenter
                        }

                        Item{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                    }
                }

                FluRectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.scaleNum(156)
                    radius: [ScreenTools.scaleNum(16),ScreenTools.scaleNum(16),ScreenTools.scaleNum(16),ScreenTools.scaleNum(16)]
                    color: ThemeColorStyle.privacy_rect_color

                    ColumnLayout{
                        anchors.fill: parent
                        anchors.margins: ScreenTools.scaleNum(12)
                        spacing: ScreenTools.scaleNum(10)

                        RowLayout{
                            Layout.fillWidth: true
                            FluText {
                                objectName: "myDeviceText"
                                text: qsTr("My Devices")
                                font.pointSize: ScreenTools.scaleNum(10, true)
                                font.family: ScreenTools.fontFamily
                                color: ThemeColorStyle.title_text_nor_color
                            }
                            Item{ Layout.fillWidth: true }
                            FluCustomSvg{
                                objectName: "workbenchNavArrowSvg"
                                imageWidth: ScreenTools.scaleNum(16)
                                imageHeight: ScreenTools.scaleNum(16)
                                Layout.alignment: Qt.AlignVCenter
                                needBg: true
                                sourceImage: CommonImageStyle.list_arrow_right_img
                                rotation: ConfigureManager.isRTLLayout ? 180 : 0
                                fillColorFirst: (hovered || pressed) ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.tab_text_nor_color
                                onClicked: {
                                    isShowdeviceManager++
                                }
                            }
                        }

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#EDEFF2"
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            spacing: 0

                            Item{
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.minimumWidth: 0
                                Layout.preferredHeight: ScreenTools.scaleNum(52)
                                ColumnLayout{
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4
                                    FluText{ objectName: "total"; text: qsTr("Total"); color: ThemeColorStyle.text_nor_color; font.pointSize: ScreenTools.scaleNum(10, true); font.family: ScreenTools.fontFamily; horizontalAlignment: Text.AlignHCenter }
                                    FluText{ objectName: "totalNum"; Layout.fillWidth: true; text: control.deviceTotal; color: ThemeColorStyle.title_text_nor_color; font.pointSize: ScreenTools.scaleNum(18, true); font.family: ScreenTools.fontFamily; horizontalAlignment: Text.AlignHCenter }
                                }
                            }
                            Item{
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.minimumWidth: 0
                                Layout.preferredHeight: ScreenTools.scaleNum(52)
                                ColumnLayout{
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: ScreenTools.scaleNum(4)
                                    RowLayout{
                                        Layout.fillWidth: true
                                        spacing: ScreenTools.scaleNum(6) // 圆点与文字的间距

                                        // 状态指示圆点
                                        Rectangle{
                                            Layout.alignment: Qt.AlignHCenter
                                            Layout.preferredHeight: ScreenTools.scaleNum(6)
                                            Layout.preferredWidth: ScreenTools.scaleNum(6)
                                            radius: height / 2 // 圆形（半径为高度一半）
                                            color: ThemeColorStyle.privacy_text_color // 状态颜色
                                        }
                                        FluText{ objectName: "onLineDevice"; text: qsTr("Online"); color: ThemeColorStyle.text_nor_color; font.pointSize: ScreenTools.scaleNum(10, true); font.family: ScreenTools.fontFamily; horizontalAlignment: Text.AlignHCenter }
                                    }
                                    FluText{ objectName: "onLineDeviceNum"; Layout.fillWidth: true; text: control.onLineNumber; color: ThemeColorStyle.title_text_nor_color; font.pointSize: ScreenTools.scaleNum(18, true); font.family: ScreenTools.fontFamily; horizontalAlignment: Text.AlignHCenter }
                                }
                            }
                            Item{
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.minimumWidth: 0
                                Layout.preferredHeight: ScreenTools.scaleNum(52)
                                ColumnLayout{
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: ScreenTools.scaleNum(4)
                                    RowLayout{
                                        Layout.fillWidth: true
                                        spacing: ScreenTools.scaleNum(6) // 圆点与文字的间距

                                        // 状态指示圆点
                                        Rectangle{
                                            Layout.alignment: Qt.AlignHCenter
                                            Layout.preferredHeight: ScreenTools.scaleNum(6)
                                            Layout.preferredWidth: ScreenTools.scaleNum(6)
                                            radius: height / 2 // 圆形（半径为高度一半）
                                            color: ThemeColorStyle.border_nor_color // 状态颜色
                                        }
                                        FluText{ objectName: "offLineDevice"; text: qsTr("Offline"); color: ThemeColorStyle.text_nor_color; font.pointSize: ScreenTools.scaleNum(10, true); font.family: ScreenTools.fontFamily; horizontalAlignment: Text.AlignHCenter }
                                    }
                                    FluText{ objectName: "offLineDeviceNum"; Layout.fillWidth: true; text: control.offLineNumber; color: ThemeColorStyle.title_text_nor_color; font.pointSize: ScreenTools.scaleNum(18, true); font.family: ScreenTools.fontFamily; horizontalAlignment: Text.AlignHCenter }
                                }
                            }
                        }
                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                FluText{ 
                    objectName: "deviceListHeader";
                    text: qsTr("Notifications");
                    color: ThemeColorStyle.title_text_nor_color;
                    font.pointSize: ScreenTools.scaleNum(12, true);
                    font.family: ScreenTools.fontFamily;
                    horizontalAlignment: Text.AlignHCenter
                }
                //右边下面空白区域
                MessageListenItem{
                    objectName: "messageListenItem"
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                } 
                               
                Item{
                    Layout.preferredHeight: ScreenTools.scaleNum(12)
                    Layout.fillWidth: true
                }
            }
        }
    }
    //实时预览组件
    Component{
        id:realTimePreview
        RealTimePreview{
            objectName: "realTimePreview"
            anchors.fill: parent
            anchors.margins: 1
        }
    }

    //云录像回放组件
    Component{
        id:cloudPlayback
        CloudPlayback{
            objectName: "cloudPlayback"
            anchors.fill: parent
            anchors.margins: 1
            Component.onCompleted: {
                resetLabelWidth();
            }
        }
    }

    //卡录像回放组件
    Component{
        id:videoPlayback
        VideoPlayback{
            objectName: "videoPlayback"
            anchors.fill: parent
            anchors.margins: 1
            Component.onCompleted: {
                resetLabelWidth();
            }
        }
    }

    Component{
        id: messageCenter
        MessageMain{
            objectName: "messageMain"
            anchors.fill: parent
            anchors.margins: 1
        }
    }

    Component{
        id: localRecordingPage
        LocalRecordingPage{
            objectName: "localRecordingPage"
            anchors.fill: parent
            anchors.margins: 1
        }
    }

    Component{
        id:lanDevicePage
        LanDevicePage{
            anchors.fill: parent
            anchors.margins: 1
        }
    }

    FluDeviceSetting{
        id:devSet
        objectName: "devSet"
    }

    // 监听界面的toast提示
    Connections{
        target: (dispatchManagerIsNull && DispatchManager.deviceObj) ? DispatchManager.deviceObj : null
        function onSignalSendOperateToast(msg, result)
        {
            if(msg.length === 0){
                return
            }
            if(result === 0){
                showError(msg, toastDuration)
            }
            else if(result === 1){
                showSuccess(msg, toastDuration)
            }
            else if(result === 2){
                showWarning(msg, toastDuration)
            }
        }
    }

    Connections{
        target: deviceObjIsNull ? DispatchManager.deviceObj : null
        function onDeviceListModelChanged(){
            control.updateDeviceCount()
        }
        function onLanDeviceListChanged(){
            control.updateDeviceCount()
        }
        function onSignalFreshFinished(){
            control.updateDeviceCount()
        }
        function onSignalRefreshDeviceListModel(){
            control.updateDeviceCount()
        }
        function onSignalFreshAliDeviceStatus(){
            control.updateDeviceCount()
        }
    }

    // 删除云存视频提示
    Connections{
        target: (dispatchManagerIsNull && DispatchManager.cloudObj) ? DispatchManager.cloudObj : null
        function onMessageTips(customCmd, result, message)
        {
            if(message.length === 0){
                return
            }
            // 0: VmsEnum.CloudRequestResult.eRequestFail 1: VmsEnum.CloudRequestResult.eRequestSuccess
            if(customCmd==="deleteCloudStore")
            {
                if(result === 0){
                    showError(message, toastDuration)
                }
                else if(result === 1){
                    showSuccess(message, toastDuration)
                }
            }

        }
    }


    function updateDeviceCount(){
        if(!deviceObjIsNull) return
        control.deviceTotal = DispatchManager.deviceObj.deviceListModel.deviceTotal()
        control.onLineNumber = DispatchManager.deviceObj.deviceListModel.onLineDeviceNumber()
    }
}
