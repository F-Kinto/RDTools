import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import ScreenTools 1.0
import Component.DeviceManager 1.0
import Component.VideoPage 1.0
import Component.Page 1.0
import CustomTimeLine 1.0
import TranslatorManager 1.0
import VMS.Enum 1.0

Rectangle {
    // =========================
    // 当前选中的回放视频条目（本地/NVR 侧）
    // 依赖 DispatchManager.previewObj.playBackVideoListModel.currentVideoItem
    // 注意：previewObjIsNull 命名看起来像"对象为空"，但这里当它为 true 时才取值；
    // =========================
    property var currentPlayBackVideoItem:
        (previewObjIsNull && playBackVideoModel.currentVideoItem)
        ? playBackVideoModel.currentVideoItem
        : null;
    // =========================
    // 全屏/普通模式切换（影响 cardPlayBackPage的父对象与 anchors）
    //
    // 目标：
    // - 全屏：把 cardPlayBackPage挂到 overlay(fullScreenHost) 上并铺满，避免被布局裁剪
    // - 普通：挂回 normalPlaceHolder（布局占位符）中
    //
    // 注意：isItemShowFullScreen、fullScreenHost 应来自外部上下文（Window/Overlay 或上层组件）
    // =========================
    states: [
        State {
            name: "fullscreen"
            when: isItemShowFullScreen && currentPage === VmsEnum.PageOperate.VideoPlaybackEnum

            // CardPlayBackPage 全屏
            ParentChange {
                target: cardPlayBackPage
                parent: fullScreenHost
            }
            AnchorChanges {
                target: cardPlayBackPage
                anchors.left: fullScreenHost.left
                anchors.right: fullScreenHost.right
                anchors.top: fullScreenHost.top
                anchors.bottom: fullScreenHost.bottom
            }
            PropertyChanges {
                target: cardPlayBackPage
                z: 100000
            }
        },

        State {
            name: "normal"
            when: !isItemShowFullScreen && currentPage === VmsEnum.PageOperate.VideoPlaybackEnum

            // CardPlayBackPage 恢复
            ParentChange {
                target: cardPlayBackPage
                parent: normalPlaceHolder
            }
            AnchorChanges {
                target: cardPlayBackPage
                anchors.left: normalPlaceHolder.left
                anchors.right: normalPlaceHolder.right
                anchors.top: normalPlaceHolder.top
                anchors.bottom: normalPlaceHolder.bottom
            }
            PropertyChanges {
                target: cardPlayBackPage
                z: 0
            }
        }
    ]

    // 状态切换时位置/尺寸动画，让全屏切换更顺滑
    transitions: Transition {
        NumberAnimation { properties: "x,y,width,height"; duration: 150 }
    }

    id:control
    color: "#FFFFFF"
    radius: ScreenTools.isWin7System ? 0 : ScreenTools.scaleNum(12)
    clip: !ScreenTools.isWin7System

    // =========================
    // 主体布局：左右两栏
    // 左：DeviceSidePanel（设备搜索 + 设备列表，支持展开/折叠）
    // 右：卡回放页面
    // =========================
    RowLayout{
        anchors{
            fill: parent
            topMargin: ScreenTools.scaleNum(4)
        }
        spacing: 0
        // -------- 左侧栏（公共侧边栏组件）--------
        DeviceSidePanel {
            id: deviceSidePanel
            titleText: qsTr("Playback")
            pageOperateEnum: VmsEnum.PageOperate.VideoPlaybackEnum
            defaultLocalDeviceVisible: true
            onRefreshExtra: function() {
                DispatchManager.cloudObj.startCloudVideo();
            }
        }

        // -------- 右侧栏：回放页面区域 --------
        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            clip:true
            // normalPlaceHolder：普通模式下 onLineVideoPage 的父容器（用于布局占位）
            Item {
                id: normalPlaceHolder
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 卡片回放页
                CardPlayBackPage{
                    id:cardPlayBackPage
                    objectName: "cardPlayBackPage"
                    anchors.fill: parent
                    videoModel: previewObjIsNull ? playBackVideoModel : null

                    // 初始化时按当前语言重算 label 宽度（适配多语言）
                    Component.onCompleted: {
                        resetLabelWidth();
                    }
                }
            }
            Item {
                height: 1
            }
        }
    }

    // =========================
    // 多语言适配入口：外部传入 language 时，刷新两种回放页的 label 宽度
    // - 云回放页：无参 resetLabelWidth()
    // - 卡片回放页：带 language 的 resetLabelWidth(language)
    // =========================
    function resetLabelWidth()
    {
        cardPlayBackPage.resetLabelWidth()
    }

    Timer {
        id: languageTimer
        interval: 100
        repeat:false
        running: false
        onTriggered: {
            resetLabelWidth()
            languageTimer.stop()
        }
    }
    // 监听语言切换
    Connections {
        target: TranslatorManager
        function onLanguageChanged() {
            if(!languageTimer.running)
                languageTimer.start()
        }
    }
}
