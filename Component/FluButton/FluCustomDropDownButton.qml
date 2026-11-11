import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.15 as T
import FluentUI 1.0
import ConfigureManager 1.0
import ScreenTools 1.0
import Component.FluComponent 1.0

// 下拉按钮组件 - 基于 FluButton 封装
// 支持图标、文本、下拉菜单，智能调整菜单展开方向
FluButton {
    // 显示模式：仅图标
    display: Button.IconOnly

    // ==================== 属性定义 ====================

    property int iconSize: ScreenTools.scaleNum(20)                     // 图标尺寸
    property int iconSource                                             // 图标资源 ID
    property bool disabled: false                                       // 是否禁用
    property Component iconDelegate: com_icon                           // 图标委托组件
    property int radius: ScreenTools.scaleNum(4)                        // 圆角半径
    property int textAlignment: Qt.AlignVCenter | Qt.AlignHCenter       //文字对齐方向（默认水平垂直居中）
    property real contentSpacing: ScreenTools.scaleNum(6)
    property real menuSpacing: ScreenTools.scaleNum(6)
    property real menuTopAndBottomMargin: ScreenTools.scaleNum(8)
    property real menuLeftAndRightMargin: ScreenTools.scaleNum(4)
    // 外部通过传入 Component 自定义菜单背景样式
    property Component menuBackground: com_menuBackground

    // ==================== 背景颜色定义 ====================

    property color hoverColor: FluTheme.itemHoverColor    // 悬停背景色
    property color pressedColor: FluTheme.itemPressColor  // 按下背景色
    property color normalColor: FluTheme.itemNormalColor  // 正常背景色
    property color disableColor: FluTheme.itemNormalColor // 禁用背景色

    // 根据启用状态和悬停状态动态计算背景色
    property color color: {
        if(!enabled){
            return disableColor
        }
        return hovered ? hoverColor : normalColor
    }

    // ==================== 图标颜色定义 ====================

    // 根据主题和启用状态动态计算图标颜色
    property color iconColor: {
        if(FluTheme.dark){
            if(!enabled){
                return Qt.rgba(130/255,130/255,130/255,1)
            }
            return Qt.rgba(1,1,1,1)
        }else{
            if(!enabled){
                return Qt.rgba(161/255,161/255,161/255,1)
            }
            return Qt.rgba(0,0,0,0)
        }
    }

    font.pointSize: ScreenTools.scaleNum(10, true)
    font.family: ScreenTools.fontFamily

    // ==================== 文字颜色定义 ====================

    // 根据主题和启用状态动态计算文字颜色
    property color textColor: {
        if(FluTheme.dark){
            if(!enabled){
                return Qt.rgba(130/255,130/255,130/255,1)
            }
            return Qt.rgba(1,1,1,1)
        }else{
            if(!enabled){
                return Qt.rgba(161/255,161/255,161/255,1)
            }
            return Qt.rgba(0,0,0,1)
        }
    }

    //UI镜像使能(兼容海外客户UI从右到左布局)
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    // ==================== 组件配置 ====================

    id: control

    // 默认属性别名，用于传递菜单内容
    default property alias contentData: menu.contentData

    rightPadding: ScreenTools.scaleNum(36)         // 右侧内边距（预留下拉箭头空间）
    verticalPadding: 0        // 垂直内边距
    horizontalPadding: ScreenTools.scaleNum(12)     // 水平内边距

    // 下拉箭头图标（固定在右侧）
    FluIcon{
        iconSource: FluentIcons.ChevronDown   // 向下箭头图标
        iconSize: ScreenTools.scaleNum(15)
        anchors{
            right: parent.right
            rightMargin: ScreenTools.scaleNum(10)
            verticalCenter: parent.verticalCenter
        }
        iconColor: control.textColor
    }

    // 内部数据对象
    Item{
        id: d
        property var window: Window.window    // 获取当前窗口引用
    }

    // ==================== 点击事件处理 ====================

    onClicked: {
        // 菜单非空时才展开
        if(menu.count !== 0){
            // 计算按钮相对于根项的位置
            var pos = control.mapToItem(null, 0, 0)

            // 计算菜单总高度：项高 + 项间距 + 菜单上下边距
            var itemHeight = ScreenTools.scaleNum(36)
            var containerHeight = menu.count * itemHeight
            if(menu.count > 1){
                containerHeight += (menu.count - 1) * menu.spacing
            }
            containerHeight += menu.topPadding + menu.bottomPadding

            // 智能判断菜单展开方向
            if(d.window.height > pos.y + control.height + containerHeight){
                // 下方空间充足，向下展开
                menu.y = control.height
            }else if(pos.y > containerHeight){
                // 上方空间充足，向上展开
                menu.y = -containerHeight
            }else{
                // 空间不足，调整到可视区域
                menu.y = d.window.height - (pos.y + containerHeight)
            }

            // 打开菜单
            menu.open()
        }
    }

    // ==================== 下拉菜单 ====================

    FluMenu{
        id: menu
        objectName: "menu"
        modal: false          // 非模态菜单
        width: control.width  // 菜单宽度与按钮一致
        spacing: control.menuSpacing
        topPadding: control.menuTopAndBottomMargin
        bottomPadding: control.menuTopAndBottomMargin
        leftPadding: control.menuLeftAndRightMargin
        rightPadding: control.menuLeftAndRightMargin
        // background 必须是 Item，这里用 Loader 承载 Component，兼容外部样式注入
        background: Loader {
            id: menuBackgroundLoader
            anchors.fill: parent
            sourceComponent: control.menuBackground ? control.menuBackground : com_menuBackground
        }
    }

    // ==================== 菜单背景模板 ====================

    Component{
        id: com_menuBackground
        Rectangle {
            implicitWidth: ScreenTools.scaleNum(150)
            implicitHeight: ScreenTools.scaleNum(36)
            color:FluTheme.dark ? Qt.rgba(45/255,45/255,45/255,1) : Qt.rgba(252/255,252/255,252/255,1)
            border.color: FluTheme.dark ? Qt.rgba(26/255,26/255,26/255,1) : Qt.rgba(191/255,191/255,191/255,1)
            border.width: 1
            radius: ScreenTools.scaleNum(4)
            FluShadow{}
        }
    }

    // ==================== 背景区域 ====================

    background: Rectangle{
        radius: control.radius
        color: control.color

        // 聚焦时显示焦点矩形
        FluFocusRectangle{
            visible: control.activeFocus
        }
    }

    // ==================== 图标组件模板 ====================

    Component{
        id: com_icon
        FluIcon {
            id: text_icon
            font.family: ScreenTools.fontFamily
            iconSize: control.iconSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconColor: control.iconColor
            iconSource: control.iconSource
        }
    }

    // ==================== 横向布局模板（图标 + 文字） ====================

    Component{
        id: com_row
        RowLayout{
            spacing: control.contentSpacing
            FluLoader{
                sourceComponent: iconDelegate
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.TextOnly
            }
            FluText{
                text: control.text
                Layout.alignment: textAlignment
                Layout.rightMargin: ScreenTools.scaleNum(30)    // 右侧留空给下拉箭头
                visible: display !== Button.IconOnly
                color: control.textColor
                font: control.font
            }
        }
    }

    // ==================== 纵向布局模板（图标在上，文字在下） ====================

    Component{
        id: com_column
        ColumnLayout{
            spacing: control.contentSpacing
            FluLoader{
                sourceComponent: iconDelegate
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.TextOnly
            }
            FluText{
                text: control.text
                Layout.alignment: textAlignment
                visible: display !== Button.IconOnly
                color: control.textColor
                font: control.font
            }
        }
    }

    // ==================== 内容区域 ====================

    // 根据 display 属性动态选择布局模板
    contentItem: FluLoader{
        sourceComponent: {
            if(display === Button.TextUnderIcon){
                return com_column
            }
            return com_row
        }
    }

    // ==================== 工具提示 ====================

    // FluCustomTooltip{
    //     id: tool_tip
    //     // objectName: "tool_tip"
    //     targetItem: control
    //     visible: {
    //         // 文字为空时不显示提示
    //         if(control.text === ""){
    //             return false
    //         }
    //         return hovered
    //     }
    //     text: control.text
    //     delay: 1000    // 延迟 1 秒显示
    // }

    function closeMenu(){
        menu.close()
    }
}
