import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.15

Item {
    id: root

    // 公开属性
    property var menuModel: []
    property int iconSize: ScreenTools.scaleNum(20)
    property int menuWidth: ScreenTools.scaleNum(200)
    property int borderWidth: 1
    property string borderColor: "#E0E0E0"
    property string backgroundColor: "white"
    property bool showSeparator: false

    signal menuItemClicked(string menuId)

    Popup {
        id: contextMenu
        width: menuWidth
        height: Math.min(menuListView.contentHeight, ScreenTools.scaleNum(400))
        padding: 0
        margins: 0

        background: Rectangle {
            color: root.backgroundColor
            border.width: root.borderWidth
            border.color: root.borderColor
            radius: ScreenTools.scaleNum(4)
        }

        contentItem: ListView {
            id: menuListView
            model: root.menuModel
            clip: true
            spacing: 0
            currentIndex: -1

            delegate: Item {
                width: menuListView.width
                height: ScreenTools.scaleNum(36)

                property bool isHovered: mouseArea.containsMouse
                property bool isPressed: mouseArea.pressed

                Rectangle {
                    anchors.fill: parent
                    color: isPressed ? "#CCE4FF" : (isHovered ? "#E5F0FF" : "transparent")
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: ScreenTools.scaleNum(12)
                    anchors.rightMargin: ScreenTools.scaleNum(12)
                    spacing: ScreenTools.scaleNum(8)

                    Image {
                        source: modelData.icon || ""
                        sourceSize.width: root.iconSize
                        sourceSize.height: root.iconSize
                        visible: source.toString() !== ""
                        Layout.preferredWidth: root.iconSize
                        Layout.preferredHeight: root.iconSize
                    }

                    Text {
                        text: modelData.text
                        color: modelData.enabled === false ? ThemeColorStyle.text_disable_color : ThemeColorStyle.title_text_nor_color
                        font.pointSize: ScreenTools.scaleNum(10, true)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // 分隔线
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#E0E0E0"
                    visible: root.showSeparator && index > 0
                    anchors.bottom: parent.bottom
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: modelData.enabled !== false
                    
                    onClicked: {
                        contextMenu.close()
                        root.menuItemClicked(modelData.menuId)
                    }
                }
            }
        }
    }

    function popup(item, localX, localY) {
        if (!item || menuModel.length === 0) return
        
        var itemPos = item.mapToItem(null, localX, localY)
        var windowObj = root.Window.window
        
        if (!windowObj) {
            var globalPos = item.mapToGlobal(localX, localY)
            contextMenu.x = globalPos.x
            contextMenu.y = globalPos.y
            contextMenu.open()
            return
        }
        
        var windowPos = windowObj.contentItem.mapFromItem(null, itemPos.x, itemPos.y)
        
        // 边界检测
        windowPos.x = Math.min(Math.max(windowPos.x, 0), windowObj.width - menuWidth)
        windowPos.y = Math.min(Math.max(windowPos.y, 0), windowObj.height - ScreenTools.scaleNum(100))
        
        contextMenu.x = windowPos.x
        contextMenu.y = windowPos.y
        contextMenu.open()
    }

    function close() {
        contextMenu.close()
    }
}