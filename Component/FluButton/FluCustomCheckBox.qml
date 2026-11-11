import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.15 as T
import FluentUI 1.0
import ConfigureManager 1.0
import ScreenTools 1.0

// 自定义复选框组件 - 基于 Qt Quick Templates 的 T.CheckBox
// 支持 FluentUI 风格，包含完整的状态切换动画和主题适配
T.CheckBox {
    // ==================== 功能属性 ====================

    // 是否禁用组件
    property bool disabled: false

    // 无障碍访问描述
    property string contentDescription: ""

    // ==================== 边框颜色定义 ====================

    property color borderNormalColor: checked ? ThemeColorStyle.border_checked_color : ThemeColorStyle.border_nor_color  // 正常状态边框
    property color bordercheckedColor: ThemeColorStyle.border_checked_color        // 选中状态边框
    property color borderHoverColor: ThemeColorStyle.border_checked_color  // 悬停状态边框
    property color borderDisableColor: ThemeColorStyle.border_nor_color  // 禁用状态边框
    property color borderPressedColor: ThemeColorStyle.border_checked_color  // 按下状态边框

    // ==================== 背景颜色定义 ====================

    property color normalColor: "#FFFFFF" // 正常背景
    property color checkedColor: ThemeColorStyle.privacy_text_color              // 选中背景
    property color hoverColor: ThemeColorStyle.privacy_rect_color // 悬停背景
    property color checkedHoverColor: ThemeColorStyle.privacy_text_color  // 选中悬停背景
    property color checkedPreesedColor: ThemeColorStyle.privacy_text_color  // 选中按下背景
    property color checkedDisableColor: ThemeColorStyle.privacy_rect_color  // 选中禁用背景
    property color disableColor: ThemeColorStyle.privacy_rect_color  // 禁用背景

    // ==================== 文字颜色定义 ====================

    // 根据主题和启用状态动态计算文字颜色
    property color textColor: !enabled ? ThemeColorStyle.text_disable_color :ThemeColorStyle.title_text_nor_color

    // ==================== 布局属性 ====================

    property real size: ScreenTools.scaleNum(18)                          // 复选框尺寸
    property bool textRight: !ConfigureManager.isRTLLayout  // 文字是否在右侧（支持 RTL 布局）
    property bool animationEnabled: FluTheme.animationEnabled  // 是否启用动画
    property var clickListener: function () {}      // 点击回调函数
    property real fontSize: ScreenTools.scaleNum(10,true)   // 字体大小，外部可覆盖

    // onCheckedChanged: {
    //     // 触发点击回调函数
    //     control.clicked()
    // }

    // ==================== 组件配置 ====================

    id: control
    hoverEnabled: true
    enabled: !control.disabled  // 根据 disabled 属性控制启用状态

    // 隐式宽度计算：内容宽度和指示器宽度的最大值 + 左右内边距
    implicitWidth: Math.max(implicitContentWidth,
                            implicitIndicatorWidth) + leftPadding + rightPadding

    // 隐式高度计算：内容高度和指示器高度的最大值 + 上下内边距
    implicitHeight: Math.max(
                        implicitContentHeight,
                        implicitIndicatorHeight) + topPadding + bottomPadding

    spacing: ScreenTools.scaleNum(6)              // 指示器与文字的间距
    focusPolicy: Qt.ClickFocus
    font.family: ScreenTools.fontFamily
    font.pointSize: control.fontSize

    // ==================== 无障碍访问设置 ====================

    Accessible.role: Accessible.CheckBox
    Accessible.name: control.text
    Accessible.description: control.contentDescription
    Accessible.onPressAction: control.clicked()

    // ==================== 背景区域 ====================

    background: Item {
        // 聚焦时显示焦点矩形
        FluFocusRectangle {
            radius: ScreenTools.scaleNum(4)
            visible: control.activeFocus
        }

        // 增加透明背景点击效果, 否则点击文本部分无效
        Rectangle { 
            width: ScreenTools.scaleNum(implicitContentWidth + leftPadding + rightPadding)
            height: ScreenTools.scaleNum(parent.height)
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // control.clicked()
                    // control.toggle() 
                }
            }
        }
    }

    // ==================== 指示器（复选框本体） ====================

    indicator: Rectangle {
        id: indicatorRect
        implicitWidth: control.size
        implicitHeight: control.size
        anchors.verticalCenter: parent.verticalCenter

        // 根据 textRight 属性决定指示器位置（左或右）
        x: control.textRight ? control.leftPadding : control.width - width - control.rightPadding

        radius: ScreenTools.scaleNum(4)   // 圆角

        // 边框颜色根据状态动态切换
        border.color: {
            if (!enabled) {
                return borderDisableColor
            }
            if (checked) {
                return bordercheckedColor
            }
            if (pressed) {
                return borderPressedColor
            }
            if (hovered) {
                return borderHoverColor
            }
            return borderNormalColor
        }
        border.width: 1

        // 背景颜色根据选中状态和交互状态动态切换
        color: {
            if (checkState === Qt.Checked
                    || checkState === Qt.PartiallyChecked) {
                if (!enabled) {
                    return checkedDisableColor
                }
                if (pressed) {
                    return checkedPreesedColor
                }
                if (hovered) {
                    return checkedHoverColor
                }
                return checkedColor
            }
            if (!enabled) {
                return disableColor
            }
            if (hovered) {
                return hoverColor
            }
            return normalColor
        }

        // ==================== 勾选标记绘制（Canvas） ====================

        Canvas {
            id: markCanvas

            // 描边进度（用于动画）
            property real strokeProgress: 0.0

            // 描边颜色（根据主题切换黑白）
            property color strokeColor: FluTheme.dark ? "#000000" : "#FFFFFF"

            anchors.centerIn: parent
            width: size - ScreenTools.scaleNum(6)
            height: width

            // 未选中状态时隐藏
            visible: state !== "unchecked"

            // 根据 checkState 确定当前状态
            state: {
                if (checkState === Qt.Checked) {
                    return "checked"
                } else if (checkState === Qt.PartiallyChecked) {
                    return "partially"
                }
                return "unchecked"
            }

            // ==================== 状态定义 ====================

            states: [
                State {
                    name: "checked"
                    PropertyChanges {
                        target: markCanvas
                        strokeProgress: 1.0
                    }
                },
                State {
                    name: "partially"
                    PropertyChanges {
                        target: markCanvas
                        strokeProgress: 1.0
                    }
                },
                State {
                    name: "unchecked"
                    PropertyChanges {
                        target: markCanvas
                        strokeProgress: 0.0
                    }
                }
            ]

            // 状态变化时请求重绘
            onStateChanged: {
                if (state !== "unchecked") {
                    requestPaint()
                }
            }

            onStrokeProgressChanged: requestPaint()
            onStrokeColorChanged: requestPaint()

            // ==================== Canvas 绘制逻辑 ====================

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.save()
                ctx.strokeStyle = strokeColor
                ctx.lineWidth = 2.0
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                if (state === "checked") {
                    // 绘制对勾标记（✓）
                    const startX = width * 0.15, startY = height * 0.5
                    const midX = width * 0.4, midY = height * 0.75
                    const endX = width - startX, endY = height * 0.3

                    // 计算两段线的长度
                    const line1Width = Math.sqrt(Math.pow(midX - startX, 2) + Math.pow(midY - startY, 2))
                    const line2Width = Math.sqrt(Math.pow(endX - midX, 2) + Math.pow(endY - midY, 2))
                    const totalLen = line1Width + line2Width
                    const drawLen = totalLen * strokeProgress

                    ctx.beginPath()
                    ctx.moveTo(startX, startY)

                    // 根据进度分段绘制，实现动画效果
                    if (drawLen < line1Width) {
                        // 绘制第一段
                        const ratio = drawLen / line1Width
                        ctx.lineTo(startX + (midX - startX) * ratio, startY + (midY - startY) * ratio)
                    } else {
                        // 绘制第二段
                        ctx.lineTo(midX, midY)
                        const ratio2 = (drawLen - line1Width) / line2Width
                        ctx.lineTo(midX + (endX - midX) * ratio2, midY + (endY - midY) * ratio2)
                    }
                } else if (state === "partially") {
                    // 绘制横线标记（-）用于部分选中状态
                    const totalWidth = width * 0.6
                    const halfWidth = (totalWidth / 2) * strokeProgress
                    const centerX = width / 2
                    const centerY = height / 2

                    ctx.beginPath()
                    ctx.moveTo(centerX - halfWidth, centerY)
                    ctx.lineTo(centerX + halfWidth, centerY)
                }

                ctx.stroke()
                ctx.restore()
            }

            // ==================== 动画行为 ====================

            Behavior on strokeProgress {
                enabled: control.animationEnabled
                NumberAnimation {
                    duration: 167
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // ==================== 内容区域（文字） ====================

    contentItem: FluText {
        text: control.text
        font.family: ScreenTools.fontFamily
        font.pointSize: control.fontSize
        color: control.textColor

        // 根据 textRight 调整内边距
        leftPadding: control.textRight ? control.indicator.width + control.spacing : 0
        rightPadding: control.textRight ? 0 : control.indicator.width + control.spacing

        verticalAlignment: Text.AlignVCenter
    }
    // ==================== 事件处理 ====================
    // 切换状态时触发回调
    onToggled: {
        clickListener()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            control.toggle() 
            control.clicked()
        }
    }
}
