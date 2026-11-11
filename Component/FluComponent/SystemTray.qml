import QtQuick 2.12
import QtQuick.Window 2.12
import SystemTray 1.0
import ConfigureManager 1.0
import TranslatorManager 1.0
Item {
    id: systemTray
    
    // 属性定义
    property var window: null
    property string iconName: ConfigureManager.getProgramLogoUrl()
    property string tooltip: ConfigureManager.getProgramAppName()
    
    // 信号定义
    signal activated(int reason)
    signal quitRequested()
    signal restoreRequested()
    
    Component.onCompleted: {
        // 初始化托盘图标
        SystemTray.createTrayIcon()
        SystemTray.setTrayIcon(iconName)
        SystemTray.setTrayTooltip(tooltip)
    }
    
    // 显示托盘消息
    function showMessage(title, message, icon = "info", timeout = 5000) {
        SystemTray.showTrayMessage(title, message, icon, timeout)
    }
    
    // 显示托盘图标
    function show() {
        SystemTray.showTray()
    }
    
    // 隐藏托盘图标
    function hide() {
        SystemTray.hideTray()
    }

    function remove() {
        SystemTray.removeTray()
    }

    Connections {
        target: SystemTray
        function onActivated(reason){
            systemTray.activated(reason)
        }
        function onQuitRequested(){
            systemTray.quitRequested()
        }
        function onRestoreRequested(){
            systemTray.restoreRequested()
        }
    }

    Connections {
        target: TranslatorManager
        function onLanguageChanged(){
            SystemTray.setIsRightToLeft(ConfigureManager.isRTLLayout)
        }
    }
}
