import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import ScreenTools 1.0
import Component.FluButton 1.0

// 胶囊底 - 双选项切换按钮组件
// 用于在两个选项之间进行切换，支持自定义文本、图标和配色
Rectangle {
    // 发送选中命令信号，参数 1 表示左侧选中，2 表示右侧选中
    signal sendCmd(int cmd)
    // ==================== 属性定义 ====================

    // 当前选中项：1-左侧，2-右侧
    property int  itemSelected: 1
    // 左右按钮显示的文本
    property string leftText: "left"
    property string rightText: "Right"
    // 左右按钮的图标资源
    property var    leftIcon: VmsToolPngStyle.main_title_cardSwitchBg_cloudBtn_checkedImage_img
    property var    rightIcon: VmsToolPngStyle.main_title_cardSwitchBg_cloudBtn_normalImage_img
	// 字体大小
    property int    fontSize: ScreenTools.scaleNum(10, true)
    property bool   rightVisible: true  // 右侧按钮是否可见（根据是否支持云存储控制）
    property var alignValue: Qt.AlignLeft  // 文本对齐方式

    // ==================== 配色定义 ====================

    property color segBgColor: ThemeColorStyle.privacy_rect_color     // 胶囊背景浅灰
    property color selectedColor: "#FFFFFF"     // 选中块白色（可按产品色调整）
    property color selectedTextColor: ThemeColorStyle.privacy_text_color // 选中文字颜色
    property color normalTextColor: ThemeColorStyle.text_nor_color   // 未选中文字灰色
    // 控制图标-文字间距
    property int iconTextSpacing: ScreenTools.scaleNum(2)

    property int displayMode: Button.TextBesideIcon
    property int borderRadius: height / 2
    property int margin: ScreenTools.scaleNum(6)

    // ==================== 组件主体 ====================
    id: control
    width: ScreenTools.scaleNum(220)
    height: ScreenTools.scaleNum(32)
    color: segBgColor
    radius: height/2

	// 水平布局容器，用于排列左右两个按钮
    RowLayout {
        anchors.fill: parent
        anchors.margins: control.margin// 边距，留出胶囊背景边
        spacing: 1	// 按钮之间无间距

        FluCustomIconButton {
            objectName: "leftBtn"
            text: leftText
            Layout.fillHeight: true
            Layout.preferredWidth: rightVisible ? parent.width / 2 : parent.width   // 占一半宽度
            borderWidth: 0
            borderRadius: control.borderRadius
            display: displayMode 
            isChecked: itemSelected == 1
            normalColor: "transparent"
            isCheckedColor: selectedColor
            textBtnCheckedColor: selectedTextColor
            alignmentValue: alignValue
            sourceImgUrl: leftIcon
            fontSize:control.fontSize
            iconSize: ScreenTools.scaleNum(24)
            onClicked: {
                sendCmd(1)
            }
        }

        FluCustomIconButton {
            objectName: "rightBtn"
            text: rightText
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width / 2   // 占一半宽度
            borderWidth: 0
            borderRadius: control.borderRadius
            display: displayMode
            isChecked: itemSelected == 2
            normalColor: "transparent"
            isCheckedColor: selectedColor
            textBtnCheckedColor: selectedTextColor
            alignmentValue: alignValue
            sourceImgUrl: rightIcon
            fontSize:control.fontSize
            visible: rightVisible
            iconSize: ScreenTools.scaleNum(24)
            onClicked: {
                sendCmd(2)
            }
        }

    }
    function updateCurrentPage(data)
    {
        sendCmd(data)
    }
}
