import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import Component.FluComponent 1.0
import Component.Button 1.0
import ScreenTools 1.0
import ConfigureManager 1.0

ShapeRectangle {
    signal clicked()
    /***********************同步 FluCustomIconButton 的属性***********************/ 
    property int display: Button.TextOnly

    // 文本按钮/背景 相关颜色设置
    property color textNormalColor: ThemeColorStyle.text_nor_color
    property color textDisableColor: ThemeColorStyle.text_disable_color
    property color textBtnHoverColor: textNormalColor
    property color textBtnPressedColor: textBtnHoverColor
    property color textBtnCheckedColor: textBtnPressedColor
    // 鼠标hover/点击/选中 背景色
    property color normalColor: "transparent"
    property color disableColor: "transparent"
    property color hoverColor: normalColor
    property color pressedColor:hoverColor
    property color isCheckedColor:hoverColor
    // 输入框边框相关属性
    property color borderNormalColor : ThemeColorStyle.border_nor_color
    property color borderFocusColor : borderNormalColor
    property int  borderRadius: ScreenTools.scaleNum(4)
    // 只显示图标不需要边框
    property bool isChecked: false

    property bool disabled: false
    property string contentDescription: ""


    // 文本的对齐方式
    property int alignmentValue: Qt.AlignHCenter
    property int leftOffset: ScreenTools.scaleNum(8)
    // 是否显示悬浮提示
    property bool showHoverTip: false

    // 左边图标的属性设置
    property string sourceImgUrl: ""
    property string sourceHoverImgUrl: sourceImgUrl
    property string sourcePressImgUrl: sourceHoverImgUrl

    // 图标大小,控件宽高以及字体大小
    property int fontSize: ScreenTools.scaleNum(10, true)
    property int buttonWidth: 0
    property int buttonHeight: control.display === Button.IconOnly ? buttonWidth : ScreenTools.scaleNum(32)
    property int iconSize: control.display === Button.IconOnly ? buttonWidth : ScreenTools.scaleNum(14)
    property int iconSource
    // 按钮左右边距边距之和
    property int btnTotalMargin: control.display === Button.TextOnly ? ScreenTools.scaleNum(14) : ScreenTools.scaleNum(40)

    property bool isBold: false
    // 最右边的粗边框，用于部分按钮选中之后最右边属性
    property bool rightBorderVisible: false
    // 文本 右边按钮属性，默认不可见
    property int drowBtnIsVisible: 0        // 0 不可见 1 左边可见 2 右边可见
    property string drowSourceImgUrl: ""
    property string text: ""
    /***********************同步 FluCustomIconButton 的属性 End***********************/ 

    property int buttonType: 0      // 0 四个角圆角 1 左边圆角右边直角 2 左边直角右边圆角 3 四个角直角
    property int topLeftRadiu: control.borderRadius
    property int topRightRadiu: control.borderRadius
    property int bottomLeftRadiu: control.borderRadius
    property int bottomRightRadiu: control.borderRadius
    property bool borderLeftVisible: true
    property bool borderRightVisible: true
    property bool borderTopVisible: true
    property bool borderBottomVisible: true

    // 镜像
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    // 边框以及圆角属性
    id: control
    implicitWidth: control.buttonWidth
    height: control.buttonHeight
    topLeftRadius: ConfigureManager.isRTLLayout ? control.topRightRadiu : control.topLeftRadiu
    bottomLeftRadius: ConfigureManager.isRTLLayout ? control.bottomRightRadiu : control.bottomLeftRadiu
    topRightRadius: ConfigureManager.isRTLLayout ? control.topLeftRadiu : control.topRightRadiu
    bottomRightRadius: ConfigureManager.isRTLLayout ? control.bottomLeftRadiu : control.bottomRightRadiu
    fillColor: {
        if (isChecked) return control.isCheckedColor
        if (cusButton.pressed) return control.pressedColor
        if (cusButton.hovered) return control.hoverColor
        return "transparent"
    }
    borderWidth: 1
    borderColor: {
        if (isChecked) return control.borderFocusColor
        if (cusButton.hovered || cusButton.pressed) return control.borderFocusColor
        return control.borderNormalColor
    }
    borderRight: ConfigureManager.isRTLLayout ? control.borderLeftVisible : control.borderRightVisible
    borderLeft: ConfigureManager.isRTLLayout ? control.borderRightVisible : control.borderLeftVisible
    borderTop: control.borderTopVisible
    borderBottom: control.borderBottomVisible
    z: 1 

    FluCustomIconButton{
        id: cusButton
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.rightMargin: 1
        anchors.leftMargin: 1
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        display: control.display
        // 文本按钮/背景 相关颜色设置
        textNormalColor: control.textNormalColor
        textDisableColor: control.textDisableColor
        textBtnHoverColor: control.textBtnHoverColor
        textBtnPressedColor: control.textBtnPressedColor
        textBtnCheckedColor: control.textBtnCheckedColor
        // 鼠标hover/点击/选中 背景色（内层 Button 自身的背景保持透明，
        // 外层 ShapeRectangle 的 fillColor 负责整个按钮的背景色变化）
        normalColor: "transparent"
        disableColor: control.disableColor
        hoverColor: "transparent"
        pressedColor: "transparent"
        isCheckedColor: "transparent"
        text: control.text
        // 输入框边框相关属性
        borderNormalColor : control.borderNormalColor
        borderFocusColor : control.borderFocusColor
        borderRadius: control.borderRadius
        // 圆角按钮不需要边框,直接使用外边框和外部填充颜色即可
        borderWidth: 0
        isChecked: control.isChecked
        disabled: control.disabled
        // 文本的对齐方式
        alignmentValue: control.alignmentValue
        leftOffset: control.leftOffset
        // 是否显示悬浮提示
        showHoverTip: control.showHoverTip
        // 左边图标的属性设置
        sourceImgUrl: control.sourceImgUrl
        // 图标大小,控件宽高以及字体大小
        fontSize: control.fontSize
        buttonWidth: control.buttonWidth - ScreenTools.scaleNum(2)
        buttonHeight: control.buttonHeight - ScreenTools.scaleNum(2)
        iconSize: control.iconSize
        iconSource: control.iconSource
        // 按钮左右边距边距之和
        btnTotalMargin: control.btnTotalMargin
        isBold: control.isBold
        // 最右边的粗边框，用于部分按钮选中之后最右边属性
        rightBorderVisible: control.rightBorderVisible
        // 文本 右边按钮属性，默认不可见
        drowBtnIsVisible: control.drowBtnIsVisible
        drowSourceImgUrl: control.drowSourceImgUrl
    }
    // 转发内层 Button 的 clicked 信号
    Connections {
        target: cusButton
        function onClicked() { control.clicked() }
    }
}