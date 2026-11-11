import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import InformationNotifier 1.0
import TranslatorManager 1.0
import ConfigureManager 1.0
import VMS.Enum 1.0
import ScreenTools 1.0


// 标签页视图组件 - 支持拖拽排序、多种宽度模式、滚动导航的 Tab 容器
// 可用于多文档界面、多标签浏览、页面切换等场景
Item {
    // ==================== 属性定义 ====================

    // 标签宽度行为模式（参考 FluTabViewType 枚举）
    // - Equal: 等宽模式（所有标签平分宽度）
    // - SizeToContent: 自适应内容宽度
    // - Compact: 紧凑模式（默认显示图标，悬停/选中时展开）
    property int tabWidthBehavior: FluTabViewType.Equal

    // 关闭按钮显示策略
    // - Always: 始终显示
    // - OnHover: 悬停时显示
    // - Never: 不显示
    property int closeButtonVisibility: FluTabViewType.Always

    // 标签项宽度（SizeToContent/Compact 模式使用）
    property int itemWidth: ScreenTools.scaleNum(150)

    // 标签按钮间距（ListView 内每个标签按钮之间的边距）
    property int tabButtonSpacing: ScreenTools.scaleNum(8)

    // 是否显示新建标签按钮
    property bool addButtonVisibility: true

    // 导航列表别名（外部可访问）
    property alias _tab_nav: tab_nav

    //绑定登录状态
    property bool isLogin: InformationNotifier.isLogin


    onIsLoginChanged: {
        if (!isLogin && dispatchManagerIsNull) {//登出关闭消息中心和增值服务页
            for (var i = tab_model.count - 1; i >= 0; i--) {
                var item = tab_model.get(i);

                if (item.pageEnum === VmsEnum.PageOperate.VipWebViewManagerEnum ||
                    item.pageEnum === VmsEnum.PageOperate.MessageCenterEnum ||
                    item.pageEnum === VmsEnum.PageOperate.CloudPlaybackEnum)
                {
                    removePage(item.pageEnum);
                    tab_model.remove(i);
                }
            }
        }
    }

    // ==================== 信号定义 ====================

    // 新建按钮点击信号
    signal newPressed()

    // 当前页面切换信号
    // @param page 当前页面的枚举值
    signal sendCurrentPage(var page)

    // 移除当前标签
    // @param page 当前页面的枚举值
    signal removePage(var page)

    // ==================== 组件配置 ====================

    id: control
    implicitHeight: height
    implicitWidth: width

    // 填充父容器
    anchors.fill: {
        if(parent)
            return parent
        return undefined
    }

    // ==================== 内部数据对象 ====================

    QtObject {
        id: d

        // 拖拽中的标签索引
        property int dragIndex: -1

        // 是否启用拖拽动画
        property bool dragBehavior: false

        // 标签是否被按下
        property bool itemPress: false

        // 等宽模式下的最大宽度限制
        property int maxEqualWidth: ScreenTools.scaleNum(240)
    }

    // 防止事件冒泡的鼠标区域
    MouseArea{
        anchors.fill: parent
        preventStealing: true
    }

    // ==================== 数据模型 ====================

    ListModel{
        id: tab_model
        // 数据项结构：
        // {
        //     icon: "图标路径",
        //     text: "标签文本",
        //     page: Component,        // 页面组件
        //     pageEnum: 页面枚举值，
        //     argument: 附加参数
        // }
    }

    // ==================== 新建按钮 ====================

    FluIconButton{
        id: btn_new
        visible: addButtonVisibility
        width: ScreenTools.scaleNum(34)
        height: ScreenTools.scaleNum(34)

        // 按钮位置：跟随标签内容宽度，但不超过导航区域
        x: Math.min(tab_nav.contentWidth, tab_nav.width)
        anchors.top: parent.top
        font.pointSize: ScreenTools.scaleNum(10, true)
        font.family: ScreenTools.fontFamily

        iconSource: FluentIcons.Add

        // 点击时触发新建信号
        onClicked: {
            newPressed()
        }
    }

    // ==================== 标签导航列表 ====================

    ListView{
        id: tab_nav
        height: ScreenTools.scaleNum(36)
        orientation: ListView.Horizontal      // 水平布局
        spacing: ScreenTools.scaleNum(12)                        // 标签间距

        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: tabButtonSpacing
            leftMargin: ScreenTools.scaleNum(12)
            rightMargin: ScreenTools.scaleNum(34)                  // 预留新建按钮空间
        }

        interactive: false                    // 禁用直接交互（使用自定义拖拽）
        model: tab_model

        // 拖拽移动动画
        move: Transition {
            NumberAnimation { properties: "x"; duration: 100; easing.type: Easing.OutCubic }
            NumberAnimation { properties: "y"; duration: 100; easing.type: Easing.OutCubic }
        }

        // 拖拽后位置调整动画
        moveDisplaced: Transition {
            NumberAnimation { properties: "x"; duration: 300; easing.type: Easing.OutCubic}
            NumberAnimation { properties: "y"; duration: 100;  easing.type: Easing.OutCubic }
        }

        clip: true

        // 隐藏滚动条（使用自定义滚动逻辑）
        ScrollBar.horizontal: ScrollBar{
            id: scroll_nav
            policy: ScrollBar.AlwaysOff
        }

        // ==================== 标签项委托 ====================

        delegate: Item{
            width: item_layout.width
            height: item_container.height

            // 拖拽时提高层级
            z: item_mouse_drag.pressed ? 1000 : 1

            Item{
                id: item_layout
                width: item_container.width
                height: item_container.height

                Item{
                    id: item_container
                    property real timestamp: new Date().getTime()    // 用于检测单击/双击
                    property bool isDraggingDetached: false          // 是否已脱离布局进入拖拽态
                    height: tab_nav.height
                    anchors.centerIn: parent

                    // 动态计算标签宽度
                    width: {
                        if(tabWidthBehavior === FluTabViewType.Equal){
                            // 等宽模式：平分可用宽度，限制最大最小值
                            return Math.max(Math.min(d.maxEqualWidth, tab_nav.width/tab_nav.count), ScreenTools.scaleNum(41) + rightBtn.width)
                        }
                        if(tabWidthBehavior === FluTabViewType.SizeToContent){
                            // 自适应模式：使用固定 itemWidth
                            return itemWidth
                        }
                        if(tabWidthBehavior === FluTabViewType.Compact){
                            // 紧凑模式：悬停/选中时展开，否则只显示图标
                            return item_mouse_hove.containsMouse || rightBtn.hovered || tab_nav.currentIndex === index ? itemWidth : ScreenTools.scaleNum(41) + rightBtn.width
                        }
                        return Math.max(Math.min(d.maxEqualWidth, tab_nav.width/tab_nav.count), ScreenTools.scaleNum(41) + rightBtn.width)
                    }

                    // 拖拽位置动画
                    Behavior on x { enabled: d.dragBehavior; NumberAnimation { duration: 200 } }
                    Behavior on y { enabled: d.dragBehavior; NumberAnimation { duration: 200 } }

                    // 悬停检测
                    MouseArea{
                        id: item_mouse_hove
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    // 工具提示（显示完整标签文本）
                    FluTooltip{
                        visible: item_mouse_hove.containsMouse
                        margins: ScreenTools.scaleNum(6)
                        padding: ScreenTools.scaleNum(6)
                        width: Math.min(implicitWidth, ScreenTools.scaleNum(320))
                        x: parent ? (parent.width - width) / 2 : 0
                        font.family: ScreenTools.fontFamily
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        background: Rectangle {
                            color: FluTheme.dark ? Qt.rgba(50/255,49/255,48/255,1) : Qt.rgba(1,1,1,1)
                            radius: ScreenTools.scaleNum(4)
                            FluShadow{
                                radius: ScreenTools.scaleNum(4)
                            }
                        }
                        text: item_text.text
                        delay: 1000
                    }

                    // ==================== 拖拽交互区域 ====================

                    MouseArea{
                        id: item_mouse_drag
                        objectName: "tab_item_mouse_drag_" + model.pageEnum
                        anchors.fill: parent
                        drag.target: item_container
                        drag.axis: Drag.XAxis

                        // 滚轮滚动导航
                        onWheel: (wheel)=>{
                            if (wheel.angleDelta.y > 0) scroll_nav.decrease()
                            else scroll_nav.increase()
                        }

                        // 按下时开始拖拽
                        onPressed: {
                            d.itemPress = true
                            item_container.timestamp = new Date().getTime();
                            d.dragBehavior = false;
                            item_container.isDraggingDetached = false
                        }

                        // 释放时结束拖拽
                        onReleased: {
                            d.itemPress = false
                            timer.stop()

                            // 检测是否为单击（300ms 内释放）
                            var timeDiff = new Date().getTime() - item_container.timestamp
                            if (timeDiff < 300) {
                                if(tab_nav.currentIndex !== index){
                                    let targetIdx = index;
                                    let checkStatus = checkDeviceIntercomAndRecordStatus()
                                    if(checkStatus){
                                        mainWindowRoot.showMessageDialog(
                                                    qsTr("Warning"),
                                                    qsTr("Continuing this operation will interrupt the recording. Are you sure you want to continue?"),
                                                    function(){
                                                        closeAllDeviceIntercomAndRecord();
                                                        tab_nav.currentIndex = targetIdx;
                                                    }
                                                    )
                                        return
                                    }
                                    tab_nav.currentIndex = index
                                }
                            }

                            if(item_container.isDraggingDetached){
                                d.dragIndex = -1;

                                // 恢复原始父容器和位置
                                var pos = tab_nav.mapToItem(item_layout, item_container.x, item_container.y)
                                item_container.parent = item_layout;
                                item_container.x = pos.x;
                                item_container.y = pos.y;
                                item_container.anchors.centerIn = item_layout
                                d.dragBehavior = true;
                                item_container.x = 0;
                                item_container.y = 0;
                                item_container.isDraggingDetached = false
                            }
                        }

                        // 位置变化时更新排序
                        onPositionChanged: {
                            if(!item_container.isDraggingDetached){
                                if(!item_mouse_drag.drag.active){
                                    return
                                }
                                // 真正进入拖拽时再脱离布局，避免单击引起位置跳动
                                var dragPos = tab_nav.mapFromItem(item_container, 0, 0)
                                d.dragIndex = model.index
                                item_container.anchors.centerIn = undefined
                                item_container.parent = tab_nav
                                item_container.x = dragPos.x
                                item_container.y = dragPos.y
                                item_container.isDraggingDetached = true
                            }

                            var pos = tab_nav.mapFromItem(item_container, 0, 0)
                            updatePosition(pos)

                            // 边缘自动滚动
                            if(pos.x < 0){
                                timer.isIncrease = false
                                timer.restart()
                            }else if(pos.x > tab_nav.width - itemWidth){
                                timer.isIncrease = true
                                timer.restart()
                            }else{
                                timer.stop()
                            }
                        }

                        // 边缘自动滚动定时器
                        Timer{
                            id: timer
                            property bool isIncrease: true
                            interval: 10
                            repeat: true
                            onTriggered: {
                                if(isIncrease){
                                    if(tab_nav.contentX >= tab_nav.contentWidth - tab_nav.width){
                                        return
                                    }
                                    tab_nav.contentX = tab_nav.contentX + 2
                                }else{
                                    if(tab_nav.contentX <= 0){
                                        return
                                    }
                                    tab_nav.contentX = tab_nav.contentX - 2
                                }
                                item_mouse_drag.updatePosition(tab_nav.mapFromItem(item_container, 0, 0))
                            }
                        }

                        // 更新标签位置（交换模型数据）
                        function updatePosition(pos){
                            var idx = tab_nav.indexAt(pos.x + tab_nav.contentX + 1, pos.y)
                            if(idx < 0){
                                return
                            }
                            if(idx >= tab_nav.count){
                                return
                            }
                            if (d.dragIndex !== idx) {
                                // 移动模型项实现排序
                                tab_model.move(d.dragIndex, idx, 1)
                                d.dragIndex = idx;
                            }
                        }
                    }

                    // 标签背景
                    FluRectangle{
                        anchors.fill: parent
                        radius: [ScreenTools.scaleNum(4), ScreenTools.scaleNum(4), ScreenTools.scaleNum(4), ScreenTools.scaleNum(4)]
                        color: {
                            if(item_mouse_hove.containsMouse || rightBtn.hovered){
                                return ThemeColorStyle.privacy_color
                            }
                            if(tab_nav.currentIndex === index){
                                return ThemeColorStyle.privacy_color          // 选中状态浅蓝色
                            }
                            return "#B3FFFFFF"            // 默认白色(70%不透明)
                        }
                    }

                    // 标签内容布局
                    RowLayout{
                        anchors.fill: parent
                        spacing: ScreenTools.scaleNum(4)
                        anchors.leftMargin: model.argument === FluTabViewType.Never ? 0 : ScreenTools.scaleNum(12)

                        Item{
                            Layout.fillWidth: true
                            visible: model.argument === FluTabViewType.Never
                        }

                        // 标签图标始终位于文字左侧
                        FluCustomSvg{
                            objectName: "tabImg_" + model.pageEnum
                            sourceImage: model.icon
                            imageWidth: ScreenTools.scaleNum(16)
                            imageHeight: ScreenTools.scaleNum(16)
                            hoverEnabled: false
                            svgType: (model.pageEnum === VmsEnum.PageOperate.WorkbenchEnum) ? VmsEnum.SvgColorTypeEnum.GradientColor : VmsEnum.SvgColorTypeEnum.PureColor
                            visible: model.pageEnum !== VmsEnum.PageOperate.VipWebViewManagerEnum
                            fillColorFirst: {
                                if(model.pageEnum === VmsEnum.PageOperate.WorkbenchEnum){
                                    return (currentPage() === VmsEnum.PageOperate.WorkbenchEnum) ? ThemeColorStyle.workspace_checked_begin_color : ThemeColorStyle.workspace_begin_color
                                }
                                return item_text.textColor
                            }
                            fillColorSecond: {
                                if(model.pageEnum === VmsEnum.PageOperate.WorkbenchEnum){
                                    return (currentPage() === VmsEnum.PageOperate.WorkbenchEnum)  ? ThemeColorStyle.workspace_checked_end_color : ThemeColorStyle.workspace_end_color
                                }
                                return item_text.textColor
                            }
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // 长时浏览图标使用img加载png
                        Image{
                            objectName: "tabImg_" + VmsEnum.PageOperate.VipWebViewManagerEnum
                            source: {
                                if(currentPage() !== VmsEnum.PageOperate.VipWebViewManagerEnum){
                                    return VmsToolPngStyle.tab_service_nor_img
                                }
                                return model.icon
                            }
                            Layout.preferredWidth: ScreenTools.scaleNum(20)
                            Layout.preferredHeight: ScreenTools.scaleNum(20)
                            visible: model.pageEnum === VmsEnum.PageOperate.VipWebViewManagerEnum
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // 标签文本
                        FluText{
                            id: item_text
                            objectName: "tabTitle_" + model.pageEnum
                            text: model.text || ""
                            textColor: tab_nav.currentIndex === index ? ThemeColorStyle.tab_text_checked_color : ThemeColorStyle.tab_text_nor_color
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight        // 文本过长时省略
                            Layout.fillWidth: model.argument === FluTabViewType.Never ? false : true
                            font.pointSize: ScreenTools.scaleNum(10, true)
                            font.family: ScreenTools.fontFamily

                            // 根据宽度模式控制显示
                            visible: {
                                if(tabWidthBehavior === FluTabViewType.Equal){
                                    return true
                                }
                                if(tabWidthBehavior === FluTabViewType.SizeToContent){
                                    return true
                                }
                                if(tabWidthBehavior === FluTabViewType.Compact){
                                    return item_mouse_hove.containsMouse || rightBtn.hovered || tab_nav.currentIndex === index
                                }
                                return false
                            }
                        }

                        Item{ Layout.fillWidth: true }

                        FluCustomSvg{
                            id: rightBtn
                            objectName: "tabRightBtn_" + model.pageEnum
                            imageWidth: ScreenTools.scaleNum(16)
                            imageHeight: ScreenTools.scaleNum(16)
                            sourceImage: CommonImageStyle.tab_close_img
                            svgType: VmsEnum.SvgColorTypeEnum.PureColor
                            fillColorFirst: item_text.textColor
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: ScreenTools.scaleNum(4)
                            tooltipText: qsTr("Close")
                            toolTipVisible: true
                            visible: {
                                if(model.argument === FluTabViewType.Never)
                                    return false
                                if(closeButtonVisibility === FluTabViewType.Never)
                                    return false
                                return true
                            }
                            onClicked: {
                                removePage(model.pageEnum)
                                tab_model.remove(index)    // 从模型移除
                            }
                        }
                    }
                }
            }
        }

        // 当前索引变化时发送信号
        onCurrentIndexChanged: {
            sendCurrentPage(currentPage())
        }
    }

    // ==================== 页面内容容器 ====================
    Item{
        id: container
        anchors{
            top: tab_nav.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: tabButtonSpacing
        }

        // 页面内容重复器
        Repeater{
            model: tab_model
            FluLoader{
                property var argument: model.argument
                anchors.fill: parent

                // 加载页面对应的组件
                sourceComponent: model.page || undefined

                // 仅当前选中的标签页可见
                visible: tab_nav.currentIndex === index
            }
        }
    }

    // ==================== 数据管理函数 ====================

    // 根据文本查找标签索引
    // @param targetText 目标标签文本
    // @return 找到返回索引，未找到返回 -1
    function findTabIndexByText(targetText){
        for(var i = 0; i < tab_model.count; i++){
            if(tab_model.get(i).text === targetText){
                return i;
            }
        }
        return -1;
    }

    // 创建标签数据对象
    // @param icon 图标路径
    // @param text 标签文本
    // @param page 页面组件
    // @param pageEnum 页面枚举值
    // @param argument 附加参数
    // @return 标签数据对象
    function createTab(icon, text, page, pageEnum, argument={}){
        return {icon: icon, text: text, page: page, pageEnum: pageEnum, argument: argument}
    }

    // 追加标签（同名标签不重复添加，自动滚动到可见）
    // @param icon 图标路径
    // @param text 标签文本
    // @param page 页面组件
    // @param pageEnum 页面枚举值
    // @param argument 附加参数
    function appendTab(icon, text, page, pageEnum, argument){
        if(!icon || !text || !page)
            return;
        // 检查是否已存在
        var existIndex = findTabIndexByText(text);
        if(existIndex !== -1){
            // 已存在则切换到该标签
            tab_nav.currentIndex = existIndex;

            // 滚动到可见位置
            Qt.callLater(function() {
                if(!tab_nav || tab_nav.count === 0) return;
                tab_nav.positionViewAtIndex(existIndex, ListView.Contain)
            });

            return;
        }
        // 添加新标签
        tab_model.append(createTab(icon, text, page, pageEnum, argument))
        var newTabIndex = tab_model.count - 1
        tab_nav.currentIndex = newTabIndex

        // 滚动到新标签可见位置
        Qt.callLater(function() {
            if(!tab_nav || tab_nav.count === 0 || newTabIndex < 0){
                return;
            }
            tab_nav.positionViewAtIndex(newTabIndex, ListView.Contain)
        })
    }

    // 设置标签列表（清空后批量添加）
    // @param list 标签数据数组
    function setTabList(list){
        tab_model.clear()
        if(Array.isArray(list) && list.length > 0){
            tab_model.append(list)
            tab_nav.currentIndex = tab_model.count - 1;

            // 滚动到最后一个标签
            if(tab_model.count > 0){
                var lastIdx = tab_model.count - 1;
                Qt.callLater(function() {
                    if(!tab_nav || tab_nav.count === 0) return;
                    tab_nav.positionViewAtIndex(lastIdx, ListView.Contain)
                });
            }
        } else {
            tab_nav.currentIndex = -1;
        }
    }

    // 获取标签数量
    // @return 标签数量
    function count(){
        return tab_nav.count || 0
    }

    // 获取当前页面枚举值
    // @return 当前页面枚举值
    function currentPage(){
        if(!count() || tab_nav.currentIndex < 0) return undefined
        return tab_model.get(tab_nav.currentIndex).pageEnum
    }

    // 获取当前标签名称
    // @return 当前标签文本
    function currentPageName(){
        if(!count() || tab_nav.currentIndex < 0) return undefined
        return tab_model.get(tab_nav.currentIndex).text
    }

    // 刷新当前标签页（重新加载Loader）
    function refreshCurrentTabPage(){
        if(tab_nav.currentIndex < 0) return;

        // 获取当前页的Loader
        var loader = tab_repeater.itemAt(tab_nav.currentIndex);
        if(loader && loader.active){
            loader.active = false;   // 卸载
            loader.active = true;    // 重新加载 → 刷新完成
        }
    }

    function checkDeviceIntercomAndRecordStatus(){
        if(!mainWindowRoot.previewObjIsNull )
            return false

        //录像回放
        if(currentPage() === VmsEnum.PageOperate.VideoPlaybackEnum){
            var recordListPlayback = DispatchManager.previewObj.playBackVideoListModel.getDeviceRecordList(VmsEnum.PageOperate.VideoPlaybackEnum)
            if(recordListPlayback.length > 0){
                return true
            }
        }
        //实时预览
        else if(currentPage() === VmsEnum.PageOperate.RealtimePreviewEnum) {
            var intercomList = DispatchManager.previewObj.onLineVideoListModel.getDeviceIntercomList(VmsEnum.PageOperate.RealtimePreviewEnum)
            var recordList = DispatchManager.previewObj.onLineVideoListModel.getDeviceRecordList(VmsEnum.PageOperate.RealtimePreviewEnum)
            if(intercomList.length > 0 || recordList.length > 0){
                return true
            }
        }

        return false
    }

    function closeAllDeviceIntercomAndRecord() {
        if(!mainWindowRoot.previewObjIsNull)
            return

        //录像回放
        if(currentPage() === VmsEnum.PageOperate.VideoPlaybackEnum){
            DispatchManager.previewObj.playBackVideoListModel.aboutAllDeviceRecord()
        }
        //实时预览
        else if(currentPage() === VmsEnum.PageOperate.RealtimePreviewEnum) {
            DispatchManager.previewObj.onLineVideoListModel.aboutAllDeviceIntercom()
            DispatchManager.previewObj.onLineVideoListModel.aboutAllDeviceRecord()
        }
    }

    function resetTabTitleText(){
        if (!tab_model) return;
        // 遍历所有 tab 项
        for (var i = 0; i < tab_model.count; i++) {
            var newText = tab_model.get(i).text;
            if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.WorkbenchEnum){
                newText = qsTr("Workspace")
            }
            else if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.RealtimePreviewEnum){
                newText = qsTr("Live View")
            }
            else if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.VideoPlaybackEnum){
                newText = qsTr("Playback")
            }
            else if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.LocalRecordingEnum){
                newText = qsTr("Local Recording")
            }
            else if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.LANDeviceEnum){
                newText = qsTr("LAN Device")
            }
            else if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.MessageCenterEnum){
                newText = qsTr("Notification Center")
            }
            else if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.DeviceManagementEnum){
                newText = qsTr("Device Management")
            }
            else if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.TeamManagementEnum){
                newText = qsTr("Team Management")
            }
            else if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.VipWebViewManagerEnum){
                newText = qsTr("Value-Added Services")
            }
            tab_model.setProperty(i, "text", newText);
        }
    }

    // 充值页面是否已打开 因为充值完成后，不会有消息推送告诉客户端, 所以需要切页面时主动调接口获取充值信息
    function vipWebViewIsShow(){
        if (!tab_model) return false;
        // 遍历所有 tab 项
        for (var i = 0; i < tab_model.count; i++) {
            if(tab_model.get(i).pageEnum === VmsEnum.PageOperate.VipWebViewManagerEnum){
                return true
            }
        }
        return false;
    }

    // 关闭所有选项卡（逆序遍历，逐个发出 removePage 信号触发 C++ 侧清理，最后清空模型）
    function closeAllTabs() {
        if (!tab_model) return;
        for (var i = tab_model.count - 1; i >= 0; i--) {
            var tabItem = tab_model.get(i);
            removePage(tabItem.pageEnum);
        }
        tab_model.clear();
    }

    Connections {
        target: TranslatorManager
        function onLanguageChanged() {
            resetTabTitleText()
        }
    }
}
