import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import ScreenTools 1.0

// 开关按钮组件 - 基于 Button 封装的 Toggle Switch
// 支持选中/未选中状态切换，带滑动动画效果
Button {
    // 按钮文本（根据选中状态切换）
    text: checked ? qsTr("Enable") : qsTr("Disable")

    // ==================== 功能属性 ====================

    // 是否禁用组件
    property bool disabled: false

    // 无障碍访问描述
    property string contentDescription: ""

    // ==================== 背景颜色定义 ====================

    // 禁用状态背景色（根据选中状态和主题变化）
    property color disableColor: checked ? FluTheme.dark ? Qt.rgba(82/255,82/255,82/255,1) : "#A7D4FF" : FluTheme.dark ? Qt.rgba(82/255,82/255,82/255,1) : Qt.rgba(233/255,233/255,233/255,1)

    // 选中状态背景色（蓝色）
    property color checkColor: ThemeColorStyle.privacy_text_color

    // 悬停状态背景色
    property color hoverColor: FluTheme.dark ? Qt.rgba(62/255,62/255,62/255,1) : Qt.rgba(150/255,150/255,150/255,1)

    // 正常状态背景色
    property color normalColor: FluTheme.dark ? Qt.rgba(50/255,50/255,50/255,1) : Qt.rgba(150/255,150/255,150/255,1)

    // ==================== 边框颜色定义 ====================

    // 正常状态边框颜色
    property color borderNormalColor: FluTheme.dark ? Qt.rgba(161/255,161/255,161/255,1) : "#979797"

    // 选中状态边框颜色
    property color borderCheckColor: ThemeColorStyle.border_checked_color

    // 禁用状态边框颜色
    property color borderDisableColor: FluTheme.dark ? Qt.rgba(50/255,50/255,50/255,1) : Qt.rgba(200/255,200/255,200/255,1)

    // ==================== 滑块（圆点）颜色定义 ====================

    // 正常状态滑块颜色
    property color dotNormalColor: FluTheme.dark ? Qt.rgba(208/255,208/255,208/255,1) : "#FFFFFF"

    // 选中状态滑块颜色
    property color dotCheckColor: FluTheme.dark ? Qt.rgba(0/255,0/255,0/255,1) : Qt.rgba(255/255,255/255,255/255,1)

    // 禁用状态滑块颜色
    property color dotDisableColor: FluTheme.dark ? Qt.rgba(50/255,50/255,50/255,1) : Qt.rgba(150/255,150/255,150/255,1)

    // ==================== 布局属性 ====================

    property real textSpacing: ScreenTools.scaleNum(6)          // 文字与开关的间距
    property bool textRight: true         // 文字是否在右侧
    property bool textVisible: true       // 是否显示文字

    // ==================== 文字颜色定义 ====================

    // 根据主题和启用状态动态计算文字颜色
    property color textColor: !enabled ? ThemeColorStyle.text_disable_color : ThemeColorStyle.title_text_nor_color

    // ==================== 点击回调 ====================

    // 点击时切换选中状态
    property var clickListener : function(){
        checked = !checked
    }

    // ==================== 组件配置 ====================

    id: control

    // ==================== 无障碍访问设置 ====================

    Accessible.role: Accessible.Button
    Accessible.name: control.text
    Accessible.description: contentDescription
    Accessible.onPressAction: control.clicked()

    // 启用状态控制
    enabled: !disabled

    // 支持 Tab 键聚焦
    focusPolicy: Qt.TabFocus

    // 点击时触发回调
    onClicked: clickListener()

    // 内边距设置
    padding: 0
    horizontalPadding: 0

    // 禁用 checkable 属性（使用自定义 checked 状态）
    onCheckableChanged: {
        if(checkable){
            checkable = false
        }
    }

    // ==================== 背景区域 ====================

    background : Item{
        implicitHeight: ScreenTools.scaleNum(20)     // 开关高度
        implicitWidth: ScreenTools.scaleNum(40)      // 开关宽度
    }

    // ==================== 内容区域 ====================

    contentItem: RowLayout{
        spacing: control.textSpacing    // 开关与文字的间距

        // 根据 textRight 设置布局方向
        layoutDirection: control.textRight ? Qt.LeftToRight : Qt.RightToLeft

        // 开关本体（胶囊形状轨道）
        Rectangle {
            id: control_backgound
            implicitWidth: background.implicitWidth
            implicitHeight: background.implicitHeight
            radius: height / 2    // 圆角为高度一半，形成胶囊形状

            // 聚焦时显示焦点矩形
            FluFocusRectangle{
                visible: control.activeFocus
                radius: parent.radius
            }

            // 背景颜色根据状态动态切换
            color: {
                if(!enabled){
                    return disableColor
                }
                if(checked){
                    return checkColor
                }
                if(hovered){
                    return hoverColor
                }
                return normalColor
            }

            // 边框宽度
            border.width: 1

            // 边框颜色根据状态动态切换
            border.color: {
                if(!enabled){
                    return borderDisableColor
                }
                if(checked){
                    return borderCheckColor
                }
                return borderNormalColor
            }

            // 滑块（圆形图标）
            FluIcon {
                width: parent.height
                // 根据选中状态切换滑块位置（左/右）
                x: checked ? control_backgound.width - width : 0

                // 根据交互状态缩放滑块
                scale: {
                    if(pressed){
                        return 5/10     // 按下时缩小到 50%
                    }
                    return hovered & enabled ? 7/10 : 6/10  // 悬停 70%，正常 60%
                }

                iconSource: FluentIcons.FullCircleMask  // 实心圆形
                iconSize: ScreenTools.scaleNum(20) 

                // 滑块颜色根据状态动态切换
                color: {
                    if(!enabled){
                        return dotDisableColor
                    }
                    if(checked){
                        return dotCheckColor
                    }
                    return dotNormalColor
                }

                // 缩放动画
                Behavior on scale{
                    NumberAnimation{
                        duration: 167
                        easing.type: Easing.OutCubic
                    }
                }

                // 位置移动动画（滑块滑动效果）
                Behavior on x  {
                    enabled: FluTheme.animationEnabled
                    NumberAnimation {
                        duration: 167
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // 文字标签
        FluText{
            id: btn_text
            text: control.text
            Layout.alignment: Qt.AlignVCenter
            visible: textVisible && text !== ""    // 文字非空且 textVisible 为真时显示
            color: control.textColor
            font.pointSize: ScreenTools.scaleNum(10, true)
            font.family: ScreenTools.fontFamily
        }
    }
}
