import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import ScreenTools 1.0

Window {
    default property alias contentData : layout_content.data
    property string windowIcon: FluApp.windowIcon
    property int launchMode: FluWindowType.Standard
    property var argument:({})
    property var background : com_background
    property bool fixSize: false
    property Component loadingItem: com_loading
    property bool fitsAppBarWindows: false
    property var tintOpacity: FluTheme.dark ? 0.80 : 0.75
    property int blurRadius: 60
    property string effect: ""
    readonly property bool effective: false
    readonly property var availableEffects: []
    property Item appBar
    Component{
        id: appBarComponent
        FluAppBar {}
    }
    property color backgroundColor: FluTheme.windowActiveBackgroundColor
    property bool stayTop: false
    property bool showDark: false
    property bool showClose: true
    property bool showMinimize: true
    property bool showMaximize: true
    property bool showStayTop: false
    property bool autoMaximize: false
    property bool autoVisible: true
    property bool autoCenter: true
    property bool autoDestroy: true
    property bool useSystemAppBar
    // 窗口圆角半径（像素）
    // Win7下禁用圆角以避免黑角问题
    property int borderRadius: ScreenTools.isWin7System ? 0 : ScreenTools.scaleNum(12)
    property int __margins: 0
    property color resizeBorderColor: {
        if(window.active){
            return FluTheme.dark ? Qt.rgba(51/255,51/255,51/255,1) : Qt.rgba(110/255,110/255,110/255,1)
        }
        return FluTheme.dark ? Qt.rgba(61/255,61/255,61/255,1) : Qt.rgba(167/255,167/255,167/255,1)
    }
    property int resizeBorderWidth: 1
    property int resizeEdgeWidth: 5  // 拖动区域宽度
    property var closeListener: function(event){
        if(autoDestroy){
            FluRouter.removeWindow(window)
        }else{
            window.visibility = Window.Hidden
            event.accepted = false
        }
    }
    signal initArgument(var argument)
    signal lazyLoad()
    property var _windowRegister
    property string _route
    property bool _hideShadow: false
    property int _preVisibility: Window.Windowed
    property bool _wasMinimizedOrHidden: false
    property bool _isCompleted: false
    id: window
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"
    onVisibilityChanged: {
        if (!_isCompleted) return
        if (visibility === Window.Minimized || visibility === Window.Hidden) {
            _wasMinimizedOrHidden = true
        } else {
            if (_wasMinimizedOrHidden) {
                _wasMinimizedOrHidden = false
                if (_preVisibility === Window.Maximized) {
                    Qt.callLater(function() { window.showMaximized() })
                } else if (_preVisibility === Window.FullScreen) {
                    Qt.callLater(function() { window.showFullScreen() })
                } else if (_preVisibility === Window.Windowed) {
                    Qt.callLater(function() { window.showNormal() })
                }
            } else {
                _preVisibility = visibility
            }
        }
    }
    Component.onCompleted: {
        // 初始化 appBar
        if(!appBar){
            appBar = appBarComponent.createObject(window, {
                title: Qt.binding(function(){ return window.title }),
                height: ScreenTools.scaleNum(30),
                showDark: Qt.binding(function(){ return window.showDark }),
                showClose: Qt.binding(function(){ return window.showClose }),
                showMinimize: Qt.binding(function(){ return window.showMinimize }),
                showMaximize: Qt.binding(function(){ return window.showMaximize }),
                showStayTop: Qt.binding(function(){ return window.showStayTop }),
                icon: Qt.binding(function(){ return window.windowIcon })
            })
        }
        FluRouter.addWindow(window)
        useSystemAppBar = FluApp.useSystemAppBar
        if(!useSystemAppBar && autoCenter){
            moveWindowToDesktopCenter()
        }
        fixWindowSize()
        initArgument(argument)
        if(window.autoVisible){
            if(window.autoMaximize){
                window.visibility = Window.Maximized
            }else{
                window.show()
            }
        }
        _preVisibility = window.visibility
        _isCompleted = true
    }
    onActiveChanged: {
        // 窗口失焦时（如Alt+Tab切换），隐藏缩放预览框
        if (!window.active) {
            hideResizePreview()
        }
    }
    onVisibleChanged: {
        if(visible && d.isLazyInit){
            window.lazyLoad()
            d.isLazyInit = false
        }
        // 窗口隐藏时也清除预览框
        if(!visible) {
            hideResizePreview()
        }
    }
    QtObject{
        id:d
        property bool isLazyInit: true
    }

    Connections{
        target: window
        function onClosing(event){closeListener(event)}
    }
    Component{
        id:com_background
        Item{
            Rectangle{
                anchors.fill: parent
                color: window.backgroundColor
                // 使用 window.borderRadius 实现圆角背景
                radius: window.borderRadius
                border.color: ThemeColorStyle.border_nor_color
                border.width: 1
                // 确保背景自身裁剪其子项（如 FluAcrylic 的 targetRect）
                clip: true
            }
            Image{
                id:img_back
                visible: false
                cache: false
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                Component.onCompleted: {
                    img_back.updateLayout()
                    source = FluTools.getUrlByFilePath(FluTheme.desktopImagePath)
                }
                Connections{
                    target: window
                    function onScreenChanged(){
                        img_back.updateLayout()
                    }
                }
                function updateLayout(){
                    var geometry = FluTools.desktopAvailableGeometry(window)
                    img_back.width = geometry.width
                    img_back.height =  geometry.height
                    img_back.sourceSize = Qt.size(img_back.width,img_back.height)
                }
                Connections{
                    target: FluTheme
                    function onDesktopImagePathChanged(){
                        timer_update_image.restart()
                    }
                    function onBlurBehindWindowEnabledChanged(){
                        if(FluTheme.blurBehindWindowEnabled){
                            img_back.source = FluTools.getUrlByFilePath(FluTheme.desktopImagePath)
                        }else{
                            img_back.source = ""
                        }
                    }
                }
                Timer{
                    id:timer_update_image
                    interval: 150
                    onTriggered: {
                        img_back.source = ""
                        img_back.source = FluTools.getUrlByFilePath(FluTheme.desktopImagePath)
                    }
                }
            }
            FluAcrylic{
                anchors.fill: parent
                target: img_back
                tintOpacity: window.tintOpacity
                blurRadius: window.blurRadius
                visible: window.active && FluTheme.blurBehindWindowEnabled
                tintColor: FluTheme.dark ? Qt.rgba(0, 0, 0, 1)  : Qt.rgba(1, 1, 1, 1)
                targetRect: Qt.rect(window.x-window.screen.virtualX,window.y-window.screen.virtualY,window.width,window.height)
            }
        }
    }
    Component{
        id:com_app_bar
        Item{
            id: barRoot
            data: window.appBar
            anchors{
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 1
                leftMargin: 1
                rightMargin: 1
            }
            Component.onCompleted: {
                window.appBar.width = Qt.binding(function(){
                    return barRoot.parent ? barRoot.parent.width - 2 : 0
                }) 
            }
        }
    }
    Component{
        id:com_loading
        Popup{
            id:popup_loading
            focus: true
            width: window.width
            height: window.height
            anchors.centerIn: Overlay.overlay
            closePolicy: {
                if(cancel){
                    return Popup.CloseOnEscape | Popup.CloseOnPressOutside
                }
                return Popup.NoAutoClose
            }
            Overlay.modal: Item {}
            onVisibleChanged: {
                if(!visible){
                    loader_loading.sourceComponent = undefined
                }
            }
            padding: 0
            opacity: 0
            visible:true
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation {
                        duration: 83
                    }
                    NumberAnimation{
                        duration:  167
                    }
                }
            }
            Component.onCompleted: {
                opacity = 1
            }
            background: Rectangle{
                color:"#44000000"
            }
            contentItem: Item{
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (cancel){
                            popup_loading.visible = false
                        }
                    }
                }
                ColumnLayout{
                    spacing: ScreenTools.scaleNum(88)
                    anchors.centerIn: parent
                    FluProgressRing{
                        Layout.alignment: Qt.AlignHCenter
                    }
                    FluText{
                        text:loadingText
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.scaleNum(10)
                        font.family: ScreenTools.fontFamily
                    }
                }
            }
        }
    }
    Component{
        id:com_border
        Rectangle{
            color:"transparent"
            border.width: window.resizeBorderWidth
            border.color: window.resizeBorderColor
            // 边框圆角与背景一致
            radius: window.borderRadius
        }
    }
    Item{
        id: layout_container
        anchors.fill: parent
        anchors.margins: window.__margins
        FluLoader{
            anchors.fill: parent
            sourceComponent: background
        }
        Item{
            id: layout_content
            anchors{
                top: loader_app_bar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            clip: true
        }
        FluLoader{
            id:loader_app_bar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: {
                if(window.useSystemAppBar){
                    return 0
                }
                return window.fitsAppBarWindows ? 0 : window.appBar.height
            }
            sourceComponent: window.useSystemAppBar ? undefined : com_app_bar
        }
        FluLoader{
            property string loadingText
            property bool cancel: false
            id:loader_loading
            anchors.fill: parent
        }
        FluCustomInfoBar{
            id:info_bar
            root: layout_container
        }
        FluLoader{
            id:loader_border
            anchors.fill: parent
            sourceComponent: {
                if(window.useSystemAppBar || FluTools.isWin() || window.visibility === Window.Maximized || window.visibility === Window.FullScreen){
                    return undefined
                }
                return com_border
            }
        }

        // ================================
        // 顶部边框拖动区域
    // ================================
    MouseArea {
        id: top_resize
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: window.resizeEdgeWidth
        cursorShape: Qt.SizeVerCursor
        visible: !window.fixSize && window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen

        property int startY
        property int startHeight
        property int startWindowY

        onPressed: {
            startY = mouse.y
            startHeight = window.height
            startWindowY = window.y
        }

        onPositionChanged: {
            if (!pressed) return
            var delta = mouse.y - startY
            var newHeight = clamp(startHeight - delta, getMinHeight(), getMaxHeight())
            var actualDelta = startHeight - newHeight
            showResizePreview(window.x, startWindowY + actualDelta, window.width, newHeight)
        }

        onReleased: {
            hideResizePreview()
            let delta = mouse.y - startY
            let newHeight = clamp(startHeight - delta, getMinHeight(), getMaxHeight())
            let actualDelta = startHeight - newHeight
            window.height = newHeight
            window.y = startWindowY + actualDelta
        }
    }

    // ================================
    // 底部边框拖动区域
    // ================================
    MouseArea {
        id: bottom_resize
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: window.resizeEdgeWidth
        cursorShape: Qt.SizeVerCursor
        visible: !window.fixSize && window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen

        property int startY
        property int startHeight

        onPressed: {
            startY = mouse.y
            startHeight = window.height
        }

        onPositionChanged: {
            if (!pressed) return
            var delta = mouse.y - startY
            var newHeight = clamp(startHeight + delta, getMinHeight(), getMaxHeight())
            showResizePreview(window.x, window.y, window.width, newHeight)
        }

        onReleased: {
            hideResizePreview()
            let delta = mouse.y - startY
            let newHeight = clamp(startHeight + delta, getMinHeight(), getMaxHeight())
            window.height = newHeight
        }
    }

    // ================================
    // 左边框拖动区域
    // ================================
    MouseArea {
        id: left_resize
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: window.resizeEdgeWidth
        cursorShape: Qt.SizeHorCursor
        visible: !window.fixSize && window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen

        property int startX
        property int startWidth
        property int startWindowX

        onPressed: {
            startX = mouse.x
            startWidth = window.width
            startWindowX = window.x
        }

        onPositionChanged: {
            if (!pressed) return
            var delta = mouse.x - startX
            var newWidth = clamp(startWidth - delta, getMinWidth(), getMaxWidth())
            var actualDelta = startWidth - newWidth
            showResizePreview(startWindowX + actualDelta, window.y, newWidth, window.height)
        }

        onReleased: {
            hideResizePreview()
            let delta = mouse.x - startX
            let newWidth = clamp(startWidth - delta, getMinWidth(), getMaxWidth())
            let actualDelta = startWidth - newWidth
            window.width = newWidth
            window.x = startWindowX + actualDelta
        }
    }

    // ================================
    // 右边框拖动区域
    // ================================
    MouseArea {
        id: right_resize
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: window.resizeEdgeWidth
        cursorShape: Qt.SizeHorCursor
        visible: !window.fixSize && window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen

        property int startX
        property int startWidth

        onPressed: {
            startX = mouse.x
            startWidth = window.width
        }

        onPositionChanged: {
            if (!pressed) return
            var delta = mouse.x - startX
            var newWidth = clamp(startWidth + delta, getMinWidth(), getMaxWidth())
            showResizePreview(window.x, window.y, newWidth, window.height)
        }

        onReleased: {
            hideResizePreview()
            let delta = mouse.x - startX
            let newWidth = clamp(startWidth + delta, getMinWidth(), getMaxWidth())
            window.width = newWidth
        }
    }

    // ================================
    // 左上角拖动区域
    // ================================
    MouseArea {
        id: top_left_resize
        anchors {
            top: parent.top
            left: parent.left
        }
        width: window.resizeEdgeWidth * 2
        height: window.resizeEdgeWidth * 2
        cursorShape: Qt.SizeFDiagCursor
        visible: !window.fixSize && window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen
        z: 100

        property int startX
        property int startY
        property int startWidth
        property int startHeight
        property int startWindowX
        property int startWindowY

        onPressed: {
            startX = mouse.x
            startY = mouse.y
            startWidth = window.width
            startHeight = window.height
            startWindowX = window.x
            startWindowY = window.y
        }

        onPositionChanged: {
            if (!pressed) return
            var deltaX = mouse.x - startX
            var deltaY = mouse.y - startY
            var newWidth = clamp(startWidth - deltaX, getMinWidth(), getMaxWidth())
            var newHeight = clamp(startHeight - deltaY, getMinHeight(), getMaxHeight())
            var actualDeltaX = startWidth - newWidth
            var actualDeltaY = startHeight - newHeight
            showResizePreview(startWindowX + actualDeltaX, startWindowY + actualDeltaY, newWidth, newHeight)
        }

        onReleased: {
            hideResizePreview()
            let deltaX = mouse.x - startX
            let deltaY = mouse.y - startY
            let newWidth = clamp(startWidth - deltaX, getMinWidth(), getMaxWidth())
            let newHeight = clamp(startHeight - deltaY, getMinHeight(), getMaxHeight())
            let actualDeltaX = startWidth - newWidth
            let actualDeltaY = startHeight - newHeight
            window.width = newWidth
            window.x = startWindowX + actualDeltaX
            window.height = newHeight
            window.y = startWindowY + actualDeltaY
        }
    }

    // ================================
    // 右上角拖动区域
    // ================================
    MouseArea {
        id: top_right_resize
        anchors {
            top: parent.top
            right: parent.right
        }
        width: window.resizeEdgeWidth * 2
        height: window.resizeEdgeWidth * 2
        cursorShape: Qt.SizeBDiagCursor
        visible: !window.fixSize && window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen
        z: 100

        property int startX
        property int startY
        property int startWidth
        property int startHeight
        property int startWindowY

        onPressed: {
            startX = mouse.x
            startY = mouse.y
            startWidth = window.width
            startHeight = window.height
            startWindowY = window.y
        }

        onPositionChanged: {
            if (!pressed) return
            var deltaX = mouse.x - startX
            var deltaY = mouse.y - startY
            var newWidth = clamp(startWidth + deltaX, getMinWidth(), getMaxWidth())
            var newHeight = clamp(startHeight - deltaY, getMinHeight(), getMaxHeight())
            var actualDeltaY = startHeight - newHeight
            showResizePreview(window.x, startWindowY + actualDeltaY, newWidth, newHeight)
        }

        onReleased: {
            hideResizePreview()
            let deltaX = mouse.x - startX
            let deltaY = mouse.y - startY
            let newWidth = clamp(startWidth + deltaX, getMinWidth(), getMaxWidth())
            let newHeight = clamp(startHeight - deltaY, getMinHeight(), getMaxHeight())
            let actualDeltaY = startHeight - newHeight
            window.width = newWidth
            window.height = newHeight
            window.y = startWindowY + actualDeltaY
        }
    }

    // ================================
    // 左下角拖动区域
    // ================================
    MouseArea {
        id: bottom_left_resize
        anchors {
            bottom: parent.bottom
            left: parent.left
        }
        width: window.resizeEdgeWidth * 2
        height: window.resizeEdgeWidth * 2
        cursorShape: Qt.SizeBDiagCursor
        visible: !window.fixSize && window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen
        z: 100

        property int startX
        property int startY
        property int startWidth
        property int startHeight
        property int startWindowX

        onPressed: {
            startX = mouse.x
            startY = mouse.y
            startWidth = window.width
            startHeight = window.height
            startWindowX = window.x
        }

        onPositionChanged: {
            if (!pressed) return
            var deltaX = mouse.x - startX
            var deltaY = mouse.y - startY
            var newWidth = clamp(startWidth - deltaX, getMinWidth(), getMaxWidth())
            var newHeight = clamp(startHeight + deltaY, getMinHeight(), getMaxHeight())
            var actualDeltaX = startWidth - newWidth
            showResizePreview(startWindowX + actualDeltaX, window.y, newWidth, newHeight)
        }

        onReleased: {
            hideResizePreview()
            let deltaX = mouse.x - startX
            let deltaY = mouse.y - startY
            let newWidth = clamp(startWidth - deltaX, getMinWidth(), getMaxWidth())
            let newHeight = clamp(startHeight + deltaY, getMinHeight(), getMaxHeight())
            let actualDeltaX = startWidth - newWidth
            window.width = newWidth
            window.x = startWindowX + actualDeltaX
            window.height = newHeight
        }
    }

    // ================================
    // 右下角拖动区域
    // ================================
    MouseArea {
        id: bottom_right_resize
        anchors {
            bottom: parent.bottom
            right: parent.right
        }
        width: window.resizeEdgeWidth * 2
        height: window.resizeEdgeWidth * 2
        cursorShape: Qt.SizeFDiagCursor
        visible: !window.fixSize && window.visibility !== Window.Maximized && window.visibility !== Window.FullScreen
        z: 100

        property int startX
        property int startY
        property int startWidth
        property int startHeight

        onPressed: {
            startX = mouse.x
            startY = mouse.y
            startWidth = window.width
            startHeight = window.height
        }

        onPositionChanged: {
            if (!pressed) return
            var deltaX = mouse.x - startX
            var deltaY = mouse.y - startY
            var newWidth = clamp(startWidth + deltaX, getMinWidth(), getMaxWidth())
            var newHeight = clamp(startHeight + deltaY, getMinHeight(), getMaxHeight())
            showResizePreview(window.x, window.y, newWidth, newHeight)
        }

        onReleased: {
            hideResizePreview()
            let deltaX = mouse.x - startX
            let deltaY = mouse.y - startY
            let newWidth = clamp(startWidth + deltaX, getMinWidth(), getMaxWidth())
            let newHeight = clamp(startHeight + deltaY, getMinHeight(), getMaxHeight())
            window.width = newWidth
            window.height = newHeight
        }
    }
    }
    // ================================
    // Win7 Aero风格预览窗口（窗口缩放时显示）
    // 模拟Win7拖拽缩放时的半透明"幽灵窗口"效果
    // ================================
    Window {
        id: resizePreviewWindow
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput | Qt.NoDropShadowWindowHint
        color: "transparent"
        visible: false

        Rectangle {
            id: previewRect
            anchors.fill: parent
            // 半透明浅色填充，模拟Win7 Aero Glass（透明度调低=更不透明=更明显）
            color: FluTheme.dark ? Qt.rgba(20, 20, 20, 0.85) : Qt.rgba(170, 200, 230, 0.75)
            // 灰色实线边框，与主页面颜色区分
            border.width: 1
            border.color: '#00aeff'
            radius: window.borderRadius
            clip: true

            // 顶部标题栏区域模拟（稍微深一点的半透明条）
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: ScreenTools.scaleNum(30)
                radius: parent.radius
                // 只让顶部圆角生效，底部不裁剪
                clip: true
                color: FluTheme.dark ? Qt.rgba(0, 0, 0, 0.3) : Qt.rgba(140, 170, 200, 0.35)
            }

            // 四边高光效果（模拟Aero玻璃边缘光泽）
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: parent.radius
                // 内部细亮线，模拟玻璃光泽
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    color: "transparent"
                    radius: parent.radius
                    border.width: 1
                    border.color: FluTheme.dark ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.3)
                }
            }
        }
    }

    // 显示/隐藏缩放预览窗口
    function showResizePreview(x, y, w, h) {
        resizePreviewWindow.x = x
        resizePreviewWindow.y = y
        resizePreviewWindow.width = Math.max(1, w)
        resizePreviewWindow.height = Math.max(1, h)
        resizePreviewWindow.visible = true
    }
    function hideResizePreview() {
        resizePreviewWindow.visible = false
    }
    function getMinWidth() { return window.minimumWidth > 0 ? window.minimumWidth : ScreenTools.scaleNum(200) }
    function getMaxWidth() { return window.maximumWidth > 0 ? window.maximumWidth : 10000 }
    function getMinHeight() { return window.minimumHeight > 0 ? window.minimumHeight : ScreenTools.scaleNum(200) }
    function getMaxHeight() { return window.maximumHeight > 0 ? window.maximumHeight : 10000 }
    function clamp(val, minVal, maxVal) { return Math.max(minVal, Math.min(maxVal, val)) }

    function hideLoading(){
        loader_loading.sourceComponent = undefined
    }
    function showSuccess(text,duration,moremsg){
        return info_bar.showSuccess(text,duration,moremsg)
    }
    function showInfo(text,duration,moremsg){
        return info_bar.showInfo(text,duration,moremsg)
    }
    function showWarning(text,duration,moremsg){
        return info_bar.showWarning(text,duration,moremsg)
    }
    function showError(text,duration,moremsg){
        return info_bar.showError(text,duration,moremsg)
    }
    function clearAllInfo(){
        return info_bar.clearAllInfo()
    }
    function moveWindowToDesktopCenter(){
        var availableGeometry = FluTools.desktopAvailableGeometry(window)
        window.setGeometry((availableGeometry.width-window.width)/2+Screen.virtualX,(availableGeometry.height-window.height)/2+Screen.virtualY,window.width,window.height)
    }
    function fixWindowSize(){
        if(fixSize){
            window.maximumWidth =  window.width
            window.maximumHeight =  window.height
            window.minimumWidth = window.width
            window.minimumHeight = window.height
        }
    }
    function setResult(data){
        if(_windowRegister){
            _windowRegister.setResult(data)
        }
    }
    function showLoading(text = "",cancel = true){
        if(text===""){
            text = qsTr("Loading...")
        }
        loader_loading.loadingText = text
        loader_loading.cancel = cancel
        loader_loading.sourceComponent = com_loading
    }
    function deleteLater(){
        FluTools.deleteLater(window)
    }
    function containerItem(){
        return layout_container
    }
}
