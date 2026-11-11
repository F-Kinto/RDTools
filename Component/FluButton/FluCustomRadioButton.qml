import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.15 as T
import FluentUI 1.0
import ConfigureManager 1.0
import ScreenTools 1.0

// 自定义单选按钮组件 - 基于 Qt Quick Templates 的 T.RadioButton
// 支持 FluentUI 风格，包含完整的状态切换动画和主题适配
T.RadioButton {
    // ==================== 功能属性 ====================

    // 无障碍访问描述
    property string contentDescription: ""

    // 是否禁用组件
    property bool disabled: false

    // ==================== 边框颜色定义 ====================

    // 正常状态边框颜色（选中时为蓝色，未选中时根据主题变化）
    property color borderNormalColor: checked ? ThemeColorStyle.border_checked_color : ThemeColorStyle.border_nor_color

    // 悬停状态边框颜色（根据选中状态和主题动态变化）
    property color borderHoverColor: ThemeColorStyle.border_checked_color

    // 禁用状态边框颜色
    property color borderDisableColor: ThemeColorStyle.border_nor_color

    // ==================== 背景颜色定义 ====================

    // 正常状态背景颜色
    property color normalColor: "#FFFFFF"

    // 悬停状态背景颜色（根据选中状态和主题动态变化）
    property color hoverColor: "#EEF8FF"

    // 禁用状态背景颜色
    property color disableColor: "#F5F7FA"

    // ==================== 文字颜色定义 ====================

    // 根据主题和启用状态动态计算文字颜色
    property color textColor: !enabled ? ThemeColorStyle.text_disable_color : ThemeColorStyle.title_text_nor_color

    // ==================== 布局属性 ====================

    property real size: ScreenTools.scaleNum(18)                            // 单选按钮尺寸
    property bool mirrorMode:ConfigureManager.isRTLLayout                   // 镜像模式：控制整体旋转方向、圆角方向、图标旋转
    property var clickListener: function () {}                              // 点击回调函数
    property int fontSize: ScreenTools.scaleNum(10, true)                   // 字体大小
    property var fontFamily : ScreenTools.fontFamily                        // 字体族

    // ==================== 描述文本属性 ====================

    property string description: ""                                         // 描述文本，默认为空不显示
    property color descriptionColor: ThemeColorStyle.text_nor_color         // 描述文本颜色
    property int descriptionMaxLines: 2                                     // 描述文本最大行数
    property string descriptionObjName: ""                                  // 描述文本的objectName，供自动化测试定位
    property int descriptionFontSize: fontSize - 1       // 描述文本字体大小

    // ==================== 图标按钮属性 ====================

    property alias iconButton: trailingIconButton                           // alias暴露内部图标按钮，方便配置所有属性
    property string iconButtonObjName: ""                                   // 图标按钮的objectName，供自动化测试定位

    // ==================== 组件配置 ====================

    id: control
    enabled: !disabled  // 根据 disabled 属性控制启用状态

    // 隐式宽度计算：内容宽度和指示器宽度的最大值 + 左右内边距
    implicitWidth: Math.max(implicitContentWidth,
                            implicitIndicatorWidth) + leftPadding + rightPadding

    // 隐式高度计算：内容高度和指示器高度的最大值 + 上下内边距
    implicitHeight: Math.max(
                        implicitContentHeight,
                        implicitIndicatorHeight) + topPadding + bottomPadding

    horizontalPadding:ScreenTools.scaleNum(2)      // 水平内边距
    verticalPadding: ScreenTools.scaleNum(2)       // 垂直内边距
    spacing: ScreenTools.scaleNum(6)               // 指示器与文字的间距
    focusPolicy: Qt.TabFocus  // 支持 Tab 键聚焦

    // 字体设置
    //font: FluTextStyle.Body
    font.family: fontFamily               // 使用 fontFamily 定义的字体族
    font.pointSize: fontSize              // 使用 fontSize 属性设置字体大小

    // ==================== 无障碍访问设置 ====================

    Accessible.role: Accessible.RadioButton
    Accessible.name: control.text
    Accessible.description: contentDescription
    Accessible.onPressAction: control.clicked()

    // ==================== 背景区域 ====================

    background: Item {
        // 聚焦时显示焦点矩形
        FluFocusRectangle {
            visible: control.activeFocus
        }
    }

    // ==================== 指示器（单选按钮本体） ====================

    indicator: Rectangle {
        implicitWidth: control.size
        implicitHeight: control.size
        anchors.verticalCenter: parent.verticalCenter

        // 根据 mirrorMode 属性决定指示器位置（左或右）
        x: control.mirrorMode ? (control.width - width - control.rightPadding) : control.leftPadding

        radius: width / 2   // 圆形（半径为宽度的一半）

        border.width: 1     // 边框宽度

        // 边框宽度变化动画
        Behavior on border.width {
            enabled: FluTheme.animationEnabled
            NumberAnimation {
                duration: 167
                easing.type: Easing.OutCubic
            }
        }

        // 边框颜色根据状态动态切换
        border.color: {
            if (!enabled) {
                return borderDisableColor
            }
            if (hovered) {
                return borderHoverColor
            }
            return borderNormalColor
        }

        // 背景颜色根据状态动态切换
        color: {
            if (!enabled) {
                return disableColor
            }
            if (hovered) {
                return hoverColor
            }
            return normalColor
        }

        // ==================== 选中标记（圆形图标） ====================

        FluIcon {
            width: parent.height
            anchors.centerIn: parent

            // 根据交互状态缩放图标
            scale: {
                if(pressed){
                    return 5/10     // 按下时缩小到 50%
                }
                return hovered & enabled ? 7/10 : 6/10  // 悬停时 70%，正常 60%
            }

            iconSource: FluentIcons.FullCircleMask  // 实心圆形图标
            iconSize: ScreenTools.scaleNum(18) 
            visible: control.checked    // 仅选中时显示
            color: {
                if(!enabled){
                    return borderDisableColor
                }
                return borderNormalColor
            }

            // 缩放动画
            Behavior on scale{
                NumberAnimation{
                    duration: 167
                    easing.type: Easing.OutCubic
                }
            }

            // 位置变化动画
            Behavior on x  {
                enabled: FluTheme.animationEnabled
                NumberAnimation {
                    duration: 167
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // ==================== 内容区域（文字 + 描述 + 图标按钮） ====================
    // Control会给contentItem设置x/width/height绑定，直接设x会被覆盖导致与指示器堆叠
    // 解决方案：用Item包裹RowLayout，Control定位Item，RowLayout通过anchors margins内部偏移避开指示器

    contentItem: Item {
        // 传递隐式尺寸给Control，包含内容宽度和指示器偏移量，确保Control正确计算自身大小
        implicitWidth: contentRow.implicitWidth + contentRow.anchors.leftMargin + contentRow.anchors.rightMargin
        implicitHeight: contentRow.implicitHeight

        RowLayout {
            id: contentRow
            anchors.fill: parent
            // 用anchors margins代替原FluText的leftPadding/rightPadding，避免与指示器重叠
            // LTR：左边距=指示器宽度+间距，把内容推到指示器右侧
            // RTL：右边距=指示器宽度+间距，把内容推到指示器左侧
            anchors.leftMargin: control.mirrorMode ? 0 : (control.indicator.width + control.spacing)
            anchors.rightMargin: control.mirrorMode ? (control.indicator.width + control.spacing) : 0

            spacing: ScreenTools.scaleNum(12)

            // 按钮文本
            FluText {
                text: control.text
                font: control.font
                color: control.textColor
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
            }

            // 描述文本（常驻，默认为空时visible=false不占空间）
            FluText {
                id: descText
                visible: control.description !== ""
                text: control.description
                font.family: control.font.family
                font.pointSize: control.descriptionFontSize
                color: control.descriptionColor
                objectName: control.descriptionObjName
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                maximumLineCount: control.descriptionMaxLines
            }

            // 图标按钮（常驻，默认sourceImgUrl为空时visible=false不占空间）
            FluCustomIconButton {
                id: trailingIconButton
                visible: control.description === "" && trailingIconButton.sourceImgUrl !== ""
                objectName: control.iconButtonObjName
                display: Button.IconOnly
                buttonFillColor: ThemeColorStyle.privacy_text_color
                iconSize: ScreenTools.scaleNum(16)
                buttonWidth: ScreenTools.scaleNum(20)
                buttonHeight: ScreenTools.scaleNum(20)
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: ScreenTools.scaleNum(20)
                Layout.preferredHeight: ScreenTools.scaleNum(20)
                showHoverTip: true
            }
        }
    }

    // ==================== 事件处理 ====================

    // 切换状态时触发回调
    onToggled: {
        clickListener()
    }
}
