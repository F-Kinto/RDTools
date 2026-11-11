import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import Component.DeviceManager 1.0
import Component.VideoPage 1.0
import Component.Page 1.0
import ScreenTools 1.0
import ConfigureManager 1.0
import InformationNotifier 1.0
import TranslatorManager 1.0
import Component.FluComponent 1.0
import Component.FluButton 1.0
import VMS.Enum 1.0

Rectangle {
    property var currentPreviewVideoItem: previewObjIsNull ? previewVideoModel.currentVideoItem : null
    // =========================
    // 样式 / 全局配置引用
    // =========================
    // mainVideoPageStyle：从 DispatchManager.pageStyleManager 取样式（styleIsNull 为真时才取）
    property var mainVideoPageStyle: styleIsNull ? DispatchManager.pageStyleManager.mainVideoPageStyle : null

    // deviceManagerPageStyle：做了更严格的 undefined 判断，避免 DispatchManager 未就绪时报错
    property var deviceManagerPageStyle: (dispatchManagerIsNull && DispatchManager.pageStyleManager)
                                         ? DispatchManager.pageStyleManager.deviceManagerPageStyle
                                         : null

    // =========================
    // UI 布局/尺寸相关参数
    // =========================
    property int pageButtonWidth:ScreenTools.scaleNum(60)          // 页内按钮的最小宽度（语言切换后会重新计算）
    property int currentPageMode: 2          // 当前页面模式（传给 DynamicPage.handleNotification）
    property string curLanguage: "zh_CN"    // 默认中文
    property int imageWidth: ScreenTools.scaleNum(54)
    property string textNormalColor: ThemeColorStyle.tab_text_nor_color
    property string textHoverColor: ThemeColorStyle.text_nor_color

    // =========================
    // 直播页重新激活时重置视频窗格选中态
    //
    // 背景：直播页通过 FluLoader 仅隐藏不销毁（切走 tab 时实例保留），
    // 导致 DynamicPage.currentVideoItemBg 残留为上一次选中的旧窗格引用。
    // 重新进入直播页后第 1 路画面因懒初始化条件（!currentVideoItemBg）被跳过而无法选中，
    // 表现为"首格第一次点击失效，需多点几次才恢复"。
    // 处理：切回直播页（currentPage 变为 RealtimePreviewEnum）时，将 currentVideoItemBg 置空，
    // 由 DynamicPage 内 Connections 监听 currentVideoItemBgChanged 触发第 1 路画面重新认领选中态。
    //
    // 注意：currentPage 是 mainWindowRoot 的 property，RealTimePreview 作为子项无法在其自身写
    // onCurrentPageChanged，需通过 Connections 监听 mainWindowRoot.currentPageChanged 信号。
    // =========================
    Connections {
        target: mainWindowRoot
        function onCurrentPageChanged() {
            if (mainWindowRoot.currentPage === VmsEnum.PageOperate.RealtimePreviewEnum) {
                onLineVideoPage.currentVideoItemBg = null;
            }
        }
    }

    // =========================
    // 全屏/普通模式切换（影响 onLineVideoPage 的父对象与 anchors）
    //
    // 目标：
    // - 全屏：把 onLineVideoPage 挂到 overlay(fullScreenHost) 上并铺满，避免被布局裁剪
    // - 普通：挂回 normalPlaceHolder（布局占位符）中
    //
    // 注意：isItemShowFullScreen、fullScreenHost 应来自外部上下文（Window/Overlay 或上层组件）
    // =========================
    states: [
        State {
            name: "fullscreen"
            when: isItemShowFullScreen && currentPage === VmsEnum.PageOperate.RealtimePreviewEnum

            // 切换父对象到顶层 overlay，避免被布局裁剪
            ParentChange {
                target: onLineVideoPage
                parent: fullScreenHost
            }

            // 全屏时铺满 overlay
            AnchorChanges {
                target: onLineVideoPage
                anchors.left: fullScreenHost.left
                anchors.right: fullScreenHost.right
                anchors.top: fullScreenHost.top
                anchors.bottom: fullScreenHost.bottom
            }

            // 提升层级，保证盖住其它控件
            PropertyChanges {
                target: onLineVideoPage
                z: 100000
            }
        },

        State {
            name: "normal"
            when: !isItemShowFullScreen && currentPage === VmsEnum.PageOperate.RealtimePreviewEnum

            // 回到原来的占位符（参与 RowLayout/ColumnLayout 布局）
            ParentChange {
                target: onLineVideoPage
                parent: normalPlaceHolder
            }

            // 恢复占位符内的 anchors
            AnchorChanges {
                target: onLineVideoPage
                anchors.left: normalPlaceHolder.left
                anchors.right: normalPlaceHolder.right
                anchors.top: normalPlaceHolder.top
                anchors.bottom: normalPlaceHolder.bottom
            }

            // 恢复层级
            PropertyChanges {
                target: onLineVideoPage
                z: 0
            }
        }
    ]

    // 状态切换时位置/尺寸动画，让全屏切换更顺滑
    transitions: Transition {
        NumberAnimation { properties: "x,y,width,height"; duration: 150 }
    }

    // 当本控件高度变化时，通知视频页根据 currentPageMode 重新处理（例如重排/刷新某些 UI）
    onHeightChanged: {
        onLineVideoPage.handleNotification(currentPageMode)
    }

    // =========================
    // 语言切换延迟处理定时器
    // 目的：语言变化时 UI 可能在一两帧内重新布局，延迟 50ms 再统一重算宽度/布局更稳
    // =========================
    Timer {
        id: languageTimer
        interval: 50
        repeat:false
        running: false
        onTriggered: {
            running: false

            // 底部菜单宽度/label 宽度重算
            onLineVideoFooter.caluculateMenuWidth()
            onLineVideoFooter.resetLabelWidth()

            // 视频页 label 宽度重算（传入当前语言）
            onLineVideoPage.resetLabelWidth(curLanguage)

            // 语言导致按钮文字宽度变化：取多个文本的最大宽度 + padding，并确保不小于 60
            pageButtonWidth = ScreenTools.scaleNum(Math.max(ScreenTools.calculateMultiTextWidth(qsTr("Got it"),qsTr("Renew"), qsTr("Retrieve")) + 16,60))
            languageTimer.stop()
        }
    }

    id:control
    color: "#FFFFFF"
    radius: ScreenTools.isWin7System ? 0 : ScreenTools.scaleNum(12)
    clip: !ScreenTools.isWin7System

	//组件实例化
    Component.onCompleted: {
        if(deviceObjIsNull){
            // 延迟到下一个事件循环迭代执行，确保页面布局完成后再触发自动播放
            // 避免在 Component.onCompleted 阶段过早访问 VideoListModel 等尚未就绪的对象
            Qt.callLater(function() {
                DispatchManager.deviceObj.slotHandleDeviceAutoPlay(1)
                DispatchManager.deviceObj.slotHandleDeviceAutoPlay(0)
            })
        }
    }
    // =========================
    // 主体布局：左右两栏
    // 左：DeviceSidePanel（设备搜索 + 设备列表 + PTZ 控制，支持展开/折叠）
    // 右：视频动态页面 + 底部 FooterPanel
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
            titleText: qsTr("Live View")
            pageOperateEnum: VmsEnum.PageOperate.RealtimePreviewEnum
            defaultLocalDeviceVisible: true
            showFooter: true

            footerItem: Component {
                FluCustomPtzControl {
                    objectName: "ptzControl"
                    property var deviceMsg: currentPreviewVideoItem ? currentPreviewVideoItem.deviceMsg : null
                    property var deviceMsgImp: deviceMsg ? deviceMsg.deviceMsg : null
                    property var task: currentPreviewVideoItem ? currentPreviewVideoItem.controlTask : null

                    ptzSize: Math.max(deviceSidePanel.width, ScreenTools.scaleNum(200))
                    mirrorMode: ConfigureManager.isRTLLayout
                    collapseBtnCheck: true
                    visible: {
                        if (deviceMsgImp) {
                            if (deviceMsgImp.isSupportWheelControlPtz) {
                                if (deviceMsgImp.deviceType >= 2) {
                                    if (deviceMsg.videoIndex === 0) {
                                        return true
                                    } else {
                                        if (deviceMsgImp.supportMultimotor === 2 || deviceMsgImp.supportMultimotor === 3) {
                                            return true
                                        }
                                    }
                                } else {
                                    return true
                                }
                            }
                        }
                        return false
                    }
                    upDownBtnEnabled: (deviceMsgImp && deviceMsg.videoIndex > 0 && (deviceMsgImp.supportMultimotor === 2 || deviceMsgImp.supportMultimotor === 3))
                    onSendCmd: {
                        if (!currentPreviewVideoItem.controlTask)
                            return
                        currentPreviewVideoItem.controlTask.controlPTZ(direction, currentPreviewVideoItem.deviceMsg.videoIndex);
                    }
                }
            }
        }

        // -------- 右侧栏（视频 + 底部控制）--------
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

                // 视频动态页（主显示区域）
                DynamicPage{
                    id:onLineVideoPage
                    objectName: "onLineVideoPage"
                    anchors.fill: parent
                    color: "#FFFFFF"
                    // 仅当 previewObjIsNull 成立时绑定模型（命名可能表示“对象不为空/为空”，需结合外部）
                    videoModel: previewObjIsNull ? previewVideoModel : null

                    Component.onCompleted: {
                        // 确保加载完成后可见
                        onLineVideoPage.visible = true;
                        onLineVideoPage.resetLabelWidth(curLanguage);
                    }
                }
            }

            // 底部控制面板：正常模式显示，全屏时隐藏
            FooterPanel{
                id:onLineVideoFooter
				objectName: "onLineVideoFooter"
                Layout.preferredHeight: ScreenTools.scaleNum(72)
                Layout.maximumHeight: ScreenTools.scaleNum(72)
                Layout.fillWidth: true
                videoModel: previewObjIsNull ? previewVideoModel : null
                // 有模型时：全屏隐藏；无模型时保持可见（避免布局空洞/或用于提示）
                visible: onLineVideoFooter.videoModel ? !isItemShowFullScreen : true

                Component.onCompleted: {
                    onLineVideoFooter.resetLabelWidth();
                    onLineVideoFooter.caluculateMenuWidth();
                }
            }
            Item {
                height: 1
            }
        }
    }

    // =========================
    // 语言切换监听：TranslatorManager 发出 languageChanged
    // 处理：更新 curLanguage，启动 languageTimer 延迟刷新布局/文字宽度
    // =========================
    Connections {
        target: TranslatorManager
        function onLanguageChanged(language) {
            if(curLanguage !== language)
                curLanguage = language
            if(!languageTimer.running)
                languageTimer.start()
        }
    }

    function notifyDynamic(mode) {
        // 保存当前 mode，并发信号给 DynamicPage
        currentPageMode = mode
        onLineVideoPage.handleNotification(mode)
        onLineVideoFooter.handleNotification(mode)
    }
}
