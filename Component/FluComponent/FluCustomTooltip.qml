import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Templates 2.15 as T
import FluentUI 1.0
import ScreenTools 1.0

// 自定义工具提示组件 - 基于 T.ToolTip 封装
// 支持箭头方向控制，带阴影效果的黑色提示框
T.ToolTip {
    // ==================== 属性定义 ====================

    // 气泡位置自动决策：true-显示在目标上方，false-显示在目标下方
    readonly property bool tooltipAboveTarget: {
        if (targetItem && parent) {
            var p = targetItem.mapToItem(parent, 0, 0)
            var needHeight = implicitHeight + offset
            var spaceAbove = p.y
            var spaceBelow = parent.height - (p.y + targetItem.height)

            // 优先选择剩余空间更大的方向，再判断是否能容纳气泡
            if (spaceAbove >= needHeight && spaceAbove >= spaceBelow) {
                return true
            }
            if (spaceBelow >= needHeight && spaceBelow > spaceAbove) {
                return false
            }
            if (spaceAbove >= needHeight) {
                return true
            }
            if (spaceBelow >= needHeight) {
                return false
            }
            // 上下都不够时，优先剩余空间更大的方向
            return spaceAbove >= spaceBelow
        }
        return true
    }

    // 气泡最终上下标识（基于最终几何位置）
    // true: 气泡在目标上方, false: 气泡在目标下方
    readonly property bool tooltipActualAboveTarget: {
        if (targetItem && parent) {
            var p = targetItem.mapToItem(parent, 0, 0)
            var targetCenterY = p.y + targetItem.height / 2
            var tooltipCenterY = y + height / 2
            return tooltipCenterY < targetCenterY
        }
        return tooltipAboveTarget
    }

    // 箭头图标尺寸
    property real icoSize: ScreenTools.scaleNum(14)

    // 提示框与目标控件的最小间距
    property real offset: 0

    // 箭头中心点（tooltip 内部坐标）
    readonly property real arrowCenterX: {
        if (targetItem && parent) {
            var p = targetItem.mapToItem(parent, 0, 0)
            var targetCenterInParent = p.x + targetItem.width / 2
            var centerInTooltip = targetCenterInParent - x
            var minCenter = icoSize / 2
            var maxCenter = width - icoSize / 2
            return Math.max(minCenter, Math.min(maxCenter, centerInTooltip))
        }
        return width / 2
    }

    // 触发提示框的目标控件（用于精确定位箭头）
    property Item targetItem: null

    // ==================== 组件配置 ====================

    id: control

    // 水平居中显示（优先相对于目标控件，回退到原父容器逻辑）
    x: {
        if (targetItem && parent) {
            var p = targetItem.mapToItem(parent, 0, 0)
            return p.x + (targetItem.width - implicitWidth) / 2
        }
        return parent ? (parent.width - implicitWidth) / 2 : 0
    }

    // 垂直位置：根据箭头方向调整
    // 箭头向上时，提示框显示在触发元素上方
    y: {
        if (targetItem && parent) {
            var p = targetItem.mapToItem(parent, 0, 0)
            if (tooltipAboveTarget) {
                return p.y - implicitHeight - offset
            }
            return p.y + targetItem.height + offset
        }
        if (tooltipAboveTarget) {
            return -implicitHeight - offset
        }
        return offset
    }

    // 隐式宽度计算：背景宽度和内容宽度的最大值 + 内边距
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)

    // 隐式高度计算：背景高度和内容高度的最大值 + 内边距 + 箭头高度
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding) + icoSize

    margins: ScreenTools.scaleNum(6) // 外边距
    padding: ScreenTools.scaleNum(6) // 内边距
    font.pointSize: ScreenTools.scaleNum(10, true)
    font.family: ScreenTools.fontFamily

    // 关闭策略：ESC 键、点击外部、释放外部时关闭
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    // ==================== 内容区域 ====================

    contentItem: FluText {
        text: control.text // 提示文本
        font: control.font
        wrapMode: Text.Wrap // 自动换行

        // 根据箭头方向调整顶部边距
        anchors.top: parent.top
        anchors.topMargin: ScreenTools.scaleNum((tooltipActualAboveTarget ? ScreenTools.scaleNum(4) : ScreenTools.scaleNum(18)) + 1)

        textColor: "#FFFFFF" // 白色文字
    }

    // ==================== 背景区域 ====================

    background: Item{
        anchors.fill: parent
        clip: true
        Column{
            anchors.fill: parent
            spacing: 0
            // 箭头图标（三角形指示器下）
            FluIcon {
                id: icoDown
                width: icoSize
                height: icoSize
                iconSize: icoSize
                visible: !tooltipActualAboveTarget
                // 根据方向切换图标（当前项目图标字形中 Up/Down 与视觉方向相反）
                iconSource: FluentIcons.FlickDown
                color: "#000000" // 黑色箭头
                x: Math.round(arrowCenterX - width / 2)
            }

            // 提示框主体（圆角矩形）
            Rectangle {
                id: rec
                width: parent.width
                height: Math.max(0, parent.height - icoSize) // 高度减去箭头高度（防止极端场景出现负值）
                color: "#000000" // 黑色背景
                radius: ScreenTools.scaleNum(4) // 圆角半径
                anchors.horizontalCenter: parent.horizontalCenter

                // 阴影效果
                FluShadow{
                    radius: ScreenTools.scaleNum(4)
                }
            }

            // 箭头图标（三角形指示器上）
            FluIcon {
                id: icoTop
                width: icoSize
                height: icoSize
                iconSize: icoSize
                visible: tooltipActualAboveTarget
                // 根据方向切换图标（当前项目图标字形中 Up/Down 与视觉方向相反）
                iconSource: FluentIcons.FlickUp
                color: "#000000" // 黑色箭头
                x: Math.round(arrowCenterX - width / 2)
            }
        }
    }
}
