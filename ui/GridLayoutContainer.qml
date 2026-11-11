import QtQuick 2.15
import QtQuick.Controls 2.15
import Component.FluButton 1.0
import RDTools.Public 1.0

// 通用网格布局容器 - 用于大图和小图按钮
// 通过 columns, cellSize, cellSpacing, model, buttonType 参数配置
Item {
    id: root

    signal buttonClicked(string name)

    property int columns: 6
    property int cellSize: 100
    property int cellSpacing: 12
    property var model: []
    property string buttonType: "big"  // "big" or "small"

    // 大按钮：图标区域 + 下方文字，高度比 cellSize 多出文字行高
    readonly property int bigTextHeight: ScreenTools.scaleNum(20)
    readonly property int cellHeight: buttonType === "big" ? cellSize + bigTextHeight : cellSize

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    Grid {
        id: container

        columns: root.columns
        spacing: root.cellSpacing

        Repeater {
            model: root.model

            // 按钮统一使用 Flu 控件（圆角 + 边框 + 悬浮/点击态由控件自身处理）
            FluCustomShapeButton {
                width: root.cellSize
                height: root.cellHeight
                buttonWidth: root.cellSize
                buttonHeight: root.cellHeight
                borderRadius: ScreenTools.scaleNum(4)
                text: modelData
                // 大按钮：图片下方显示文字；小按钮：仅文字
                display: root.buttonType === "big" ? Button.TextUnderIcon : Button.TextOnly
                // 显示内容使用常规文本颜色
                textNormalColor: ThemeColorStyle.text_nor_color
                textBtnHoverColor: ThemeColorStyle.privacy_text_color
                normalColor: ThemeColorStyle.list_bg_nor_color
                hoverColor: ThemeColorStyle.list_bg_hover_color
                pressedColor: ThemeColorStyle.list_bg_hover_color
                borderNormalColor: ThemeColorStyle.border_nor_color
                borderFocusColor: ThemeColorStyle.border_checked_color
                fontSize: ScreenTools.scaleNum(root.buttonType === "big" ? 10 : 9, true)
                isBold: root.buttonType === "big"
                alignmentValue: Qt.AlignHCenter
                onClicked: {
                    console.log(root.buttonType + " button clicked:", text);
                    root.buttonClicked(text);
                }
            }
        }
    }
}
