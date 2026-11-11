import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import Component.FluComponent 1.0
import ScreenTools 1.0
import QtGraphicalEffects 1.15

/****************使用方法*******************/
// 图片+文字水平布局使用情况如下
// | --图--文本----------------- |            display: Button.TextBesideIcon  + 其他自定义属性
// | --图--文本--------图片按钮-- |            display: Button.TextBesideIcon, drowBtnIsVisible: 2 , drowSourceImgUrl: you imageUrl + 其他自定义属性
// | ---------图--文本---------- |            display: Button.TextBesideIcon + 其他自定义属性
// | ------------图------------- |            display: Button.IconOnly + 其他自定义属性
// | -----------文本------------ |            不需要修改属性
// | --文本------------图片按钮-- |            alignmentValue: Qt.AlignLeft, drowBtnIsVisible: 2 , drowSourceImgUrl: you imageUrl + 其他自定义属性
// | --------文本--图片按钮------ |            drowBtnIsVisible: 2 , drowSourceImgUrl: you imageUrl + 其他自定义属性
// | -图片按钮---文本------------ |            drowBtnIsVisible: 1 , drowSourceImgUrl: you imageUrl + 其他自定义属性
// | -图片按钮---图----文本------ |            drowBtnIsVisible: 1 , display: Button.TextBesideIcon, drowSourceImgUrl: you imageUrl + 其他自定义属性
/****************使用方法*********************/

Button {
    display: Button.TextOnly
    signal drawIconClicked()
    signal statusChanged(bool isHover)
    readonly property alias isHovered: control.hovered
    property bool iconOnlyNeedHoverBg: false                    // 仅图标按钮是否需要背景

    /***************按钮 文本颜色 属性设置*************************/
    property color textNormalColor: ThemeColorStyle.cancelBtn_text_color                 // 文本按钮正常颜色
    property color textDisableColor: textNormalColor            // 文本按钮禁用颜色
    property color textBtnHoverColor: textNormalColor           // 文本按钮 hover 颜色
    property color textBtnPressedColor: textBtnHoverColor       // 文本按钮 点击 颜色
    property color textBtnCheckedColor: textBtnPressedColor     // 文本按钮 选中 颜色
    /***************按钮 文本颜色 属性设置 End*************************/

    /***************按钮 背景颜色 属性设置*************************/
    property color normalColor: "transparent"                   // 背景按钮正常颜色
    property color disableColor: control.display === Button.IconOnly ? "transparent" : ThemeColorStyle.text_disable_color        // 背景按钮禁用颜色 
    property color hoverColor:{                                 // 背景按钮 hover 颜色
        var colorStr = normalColor.toString().toUpperCase()
        if(control.display === Button.IconOnly && !iconOnlyNeedHoverBg){                // 图标按钮(仅显示图标) 不需要hover颜色, 必要时可设置一张hover图片
            return "transparent"
        }
        if(colorStr === "#00000000" || colorStr === "#FFFFFF"){ // 如果按钮 normalColor 是透明或者纯白色, 则背景hover统一设置为浅灰色
            return ThemeColorStyle.button_hover_bg_color
        }
        else{
            return Qt.rgba(normalColor.r, normalColor.g, normalColor.b, 0.7)    // 其他颜色鼠标hover时则按透明度0.7来设置
        }
    }
    property color pressedColor:hoverColor                      // 背景按钮 点击 颜色   
    property color isCheckedColor:pressedColor                    // 背景按钮 选中 颜色
    /***************按钮 背景颜色 属性设置*************************/

    /*************************背景颜色 渐变模式**********************************/
    property int gradientMode: 0                                                        // 按钮渐变模式 0 不使用渐变 1 从上到下 2 从左到右
    property color gradientStartColor : "#FFFFFF"                                     // 渐变开始颜色
    property color gradientMidColor : gradientStartColor                                // 渐变中间颜色
    property color gradientEndColor : gradientStartColor                                // 渐变结束颜色
    /*************************背景颜色 渐变模式**********************************/

    /***************按钮 边框 属性设置*************************/
    property color borderNormalColor : ThemeColorStyle.border_nor_color                                 // 边框正常颜色
    property color borderFocusColor : borderNormalColor                             // 边框获得焦点颜色
    property int  borderRadius: ScreenTools.scaleNum(4)                                                 // 边框圆角
    property int  borderWidth: control.display === Button.IconOnly  ? 0 : 1         // 边框1显示隐藏, 只显示图标不需要边框
    /***************按钮 边框 属性设置END************************/

    /***************按钮 其他属性设置*************************/
    property bool isChecked: false                                // 是否选中, 针对于部分双形态按钮的属性(类似于伪开关按钮)
    property bool disabled: false                                 // 是否禁用
    property string contentDescription: ""
    property Component iconDelegate: com_icon                     // 图标组件,可自定义布局

    property int alignmentValue: Qt.AlignHCenter                  // 文本对齐方式, 针对于按钮图标-文本 左对齐或者居中对齐
    property int leftOffset: ScreenTools.scaleNum(6)              // 文本左边距, 针对于文本图标左对齐时,文本图标之间的 额外边距
    property int iconOffset: 0                                    // 图标左边距, 针对于图标文本居中对齐时, 图标与左边距之间的 额外边距
    property bool showHoverTip: false                             // 是否显示悬浮提示, 针对于需要悬浮提示的按钮
    property string hoverTipText: control.text                    // 悬浮提示文本

    property string sourceImgUrl: ""                              // 左边图标资源
    property string sourceDisableImgUrl: sourceImgUrl             // 左边禁用图标资源
    property string sourceHoverImgUrl: sourceImgUrl               // 左边hover图标资源
    property string sourcePressImgUrl: sourceHoverImgUrl          // 左边点击/选中图标资源
    property int iconSource: -1                                   // 字体图标源(兼容FluIconButton), 设置后优先使用FluIcon渲染
    property color iconColor: control.textColor                   // 字体图标颜色(兼容FluIconButton)


    property int fontSize: ScreenTools.scaleNum(10, true)                                                                           // 字体大小
    property bool isBold: false                                                                                                     // 是否加粗
    property bool imageAutoScale: false                                                                                             // 图片是否自动缩放
    // 供外部调用的属性
    property alias buttonFontSize: control.fontSize                                                                                 // 字体大小
    property int buttonWidth: control.display === Button.IconOnly ? ScreenTools.scaleNum(32) : ScreenTools.scaleNum(64)             // 按钮宽度
    property int buttonHeight: control.display === Button.IconOnly ? buttonWidth : ScreenTools.scaleNum(32)                         // 按钮高度
    property int iconSize: control.display === Button.IconOnly ? buttonWidth : ScreenTools.scaleNum(16)                             // 图标大小
    property int btnTotalMargin: control.display === Button.TextOnly ? ScreenTools.scaleNum(14) : ScreenTools.scaleNum(36)          // 按钮左右边距边距之和
    property bool rightBorderVisible: false                                             // 边缘的粗边框，用于部分按钮选中之后最左边属性
    property int drowBtnIsVisible: 0                                                    // 图标按钮是否可见 0 不可见 1 左边可见 2 右边可见
    property string drowSourceImgUrl: ""                                                // 图标按钮资源
    property bool freshIcon: false                                                      // 刷新图标
    property int rotateAngle: 0                                                         // 旋转角度,主要针对于drowSourceImgUrl辅助图标为箭头的情况
    property bool mainIconNeedRotate: false                                             // 主图标是否需要旋转
    property color borderColor: {
        if(!enabled){
            return ThemeColorStyle.border_nor_color
        }
        if(pressed || hovered){
            return borderFocusColor
        }
        return borderNormalColor
    }
    property color color: {
        if(!enabled){
            return disableColor
        }
        if(isChecked){
            return isCheckedColor
        }
        if(pressed){
            return pressedColor
        }
        return hovered ? hoverColor : normalColor
    }

    property color textColor: !enabled ? textDisableColor : pressed ? textBtnPressedColor : isChecked ? textBtnCheckedColor : hovered ? textBtnHoverColor : textNormalColor
    /********************************SVG图片填充颜色属性设置*******************************/
    property color buttonFillColor: textColor === "#00000000" ? borderColor : textColor                                             // SVG按钮填充颜色

    font.family: ScreenTools.fontFamily
    font.pointSize: fontSize
    font.bold: isBold;
    implicitWidth: {
        if(control.display === Button.IconOnly)
            return buttonWidth
        else
            if (drowBtnIsVisible != 0) 
                return Math.max(ScreenTools.calculateTextWidth(control.text, fontSize, false, false) + iconSize + btnTotalMargin, buttonWidth)
            else
                return Math.max(ScreenTools.calculateTextWidth(control.text, fontSize, false, false) + btnTotalMargin, buttonWidth)
    }
    implicitHeight: buttonHeight

    onHoveredChanged: {
        control.statusChanged(hovered)
    }

    Accessible.role: Accessible.Button
    Accessible.name: control.text
    Accessible.description: contentDescription
    Accessible.onPressAction: control.clicked()
    id:control
    focusPolicy:Qt.ClickFocus
    padding: 0
    verticalPadding: control.display === Button.IconOnly ? ScreenTools.scaleNum(4) : ScreenTools.scaleNum(2) 
    horizontalPadding: control.display === Button.IconOnly ? ScreenTools.scaleNum(4) : ScreenTools.scaleNum(2) 
    enabled: !disabled

    background: Loader {
        id: bgLoader
        sourceComponent: gradientMode === 0 ? solidBg : gradientBg
    }

    Component {
        id: gradientBg
        Rectangle {
            id: gradientRect
            property bool startEquitEndColor: control.gradientStartColor.toString().toUpperCase() === control.gradientEndColor.toString().toUpperCase()
            anchors.fill: parent
            radius: borderRadius
            border.width: borderWidth
            border.color: borderColor
            clip: true
            gradient: Gradient {
                orientation: control.gradientMode === 1 ? Gradient.Vertical : Gradient.Horizontal
                GradientStop { id: stop1; position: 0.0; color: control.hovered ? gradientRect.startEquitEndColor ? control.gradientMidColor : control.gradientEndColor : control.gradientStartColor }
                GradientStop { id: stop2; position: 0.5; color: (control.hovered && gradientRect.startEquitEndColor) ? control.gradientStartColor : control.gradientMidColor }
                GradientStop { id: stop3; position: 1.0; color: control.hovered ? gradientRect.startEquitEndColor ? control.gradientMidColor : control.gradientStartColor : control.gradientEndColor }
            }
        }
    }

    Component {
        id: solidBg
        Rectangle {
            anchors.fill: parent
            radius: borderRadius
            color: control.color
            border.width: borderWidth
            border.color: borderColor
        }
    }
    Component{
        id:com_icon
        Loader {
            id: iconLoader
            property bool isSvg: ScreenTools.imageIsSvgSource(sourceImgUrl)
            width: iconSize
            height: iconSize
            sourceComponent: control.iconSource >= 0 ? fluIconComponent : isSvg ? customImageComponentSvg : customImageComponent

            Component {
                id: fluIconComponent
                FluIcon {
                    id: text_icon
                    //font.pointSize: control.iconSize
                    iconSize: control.iconSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    iconColor: control.iconColor
                    iconSource: control.iconSource
                }
            }

            Component {
                id: customImageComponentSvg

                FluCustomSvg{
                    id:svgImage
                    imageWidth: iconSize
                    imageHeight: iconSize
                    isChecked: control.isChecked
                    sourceImage: sourceImgUrl
                    fillColorFirst: buttonFillColor
                    rotation: mainIconNeedRotate ? rotateAngle : 0
                    visible: ScreenTools.imageIsSvgSource(sourceImgUrl)
                    onClicked:{
                        tool_tip.visible = false
                        control.clicked()
                    }
                }
            }

            Component {
                id: customImageComponent

                FluCustomImage {
                    id: iconImg
                    objectName: "iconImg"
                    normalImageUrl: !control.enabled ? sourceDisableImgUrl : sourceImgUrl
                    hoverImageUrl: sourceHoverImgUrl
                    pressedImageUrl: sourcePressImgUrl
                    isChecked: control.isChecked
                    clickChangeImageEnable: freshIcon
                    width: iconSize
                    height: iconSize
                    needAutoScale: imageAutoScale
                    visible: !ScreenTools.imageIsSvgSource(sourceImgUrl)
                    onClicked:{
                        tool_tip.visible = false
                        control.clicked()
                    }
                    Connections{
                        target:control
                        function onStatusChanged(isHover){
                            iconImg.updateSourceImg(isHover)
                        }
                    }
                }
            }
        }
    }

    Component{
        id:com_row
        RowLayout{
            anchors.fill: parent
            spacing: leftOffset//spacItem.visible ? ScreenTools.scaleNum(6) : 0
            Item{
                id: spacItem
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: display == Button.TextBesideIcon && alignmentValue !== Qt.AlignLeft && iconOffset >= 0
            }

            FluCustomSvg{
                id:drawIcon
                objectName: "drawIcon"
                imageWidth: iconSize
                imageHeight: iconSize
                Layout.alignment: Qt.AlignVCenter | alignmentValue
                Layout.leftMargin: ScreenTools.scaleNum(6)
                sourceImage: drowSourceImgUrl
                fillColorFirst: buttonFillColor
                rotation: rotateAngle
                visible: (drowBtnIsVisible === 1) && alignmentValue == Qt.AlignLeft
                onClicked:{
                    control.drawIconClicked()
                }
            }
            FluLoader{
                sourceComponent: iconDelegate
                Layout.alignment: Qt.AlignVCenter | alignmentValue
                Layout.leftMargin: iconOffset + (alignmentValue == Qt.AlignLeft ? ScreenTools.scaleNum(6) : 0)
                visible: display !== Button.TextOnly
            }
            FluText{
                id:textLabel
                text:control.text
                Layout.leftMargin: alignmentValue == Qt.AlignLeft ? leftOffset : 0
                Layout.rightMargin: alignmentValue == Qt.AlignLeft ? leftOffset : 0
                Layout.alignment: Qt.AlignVCenter | alignmentValue
                visible: display !== Button.IconOnly
                color: control.textColor
                font: control.font
            }
            Item{
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: (drawIcon != 0) && (alignmentValue == Qt.AlignLeft || display == Button.TextBesideIcon)
            }

            FluCustomSvg{
                id:drawIcon1
                imageWidth: iconSize
                imageHeight: iconSize
                Layout.alignment: Qt.AlignVCenter | alignmentValue
                Layout.rightMargin: leftOffset
                sourceImage: drowSourceImgUrl
                fillColorFirst: buttonFillColor
                rotation: rotateAngle
                visible: (drowBtnIsVisible === 2) && alignmentValue == Qt.AlignLeft
                onClicked:{
                    tool_tip.visible = false
                    control.clicked()
                }
            }
        }
    }
    Component{
        id:com_column
        ColumnLayout{
            FluLoader{
                sourceComponent: iconDelegate
                Layout.alignment: alignmentValue | Qt.AlignHCenter
                visible: display !== Button.TextOnly
            }
            FluText{
                text:control.text
                Layout.alignment: alignmentValue | Qt.AlignHCenter
                visible: display !== Button.IconOnly
                color: control.textColor
                font: control.font
            }
        }
    }
    Rectangle{ 
        width: ScreenTools.scaleNum(3) 
        height: parent.height
        color: textBtnPressedColor
        anchors.left: parent.left
        anchors.leftMargin: 0
        visible: rightBorderVisible && isChecked
    }
    contentItem:FluLoader{
        sourceComponent: {
            if(display === Button.TextUnderIcon){
                return com_column
            }
            return com_row
        }
    }
    FluTooltip{
        id:tool_tip
        margins: ScreenTools.scaleNum(6)
        padding: ScreenTools.scaleNum(6)
        width: Math.min(implicitWidth, ScreenTools.scaleNum(320))
        x: parent ? (parent.width - width) / 2 : 0
        font.family: ScreenTools.fontFamily
        font.pointSize: ScreenTools.scaleNum(10, true)
        background: Rectangle {
            color: FluTheme.dark ? Qt.rgba(50/255,49/255,48/255,1) : Qt.rgba(1,1,1,1)
            radius: ScreenTools.scaleNum(4)
            FluShadow{
                radius: ScreenTools.scaleNum(4)
            }
        }
        visible: {
            // 兼容FluIconButton: IconOnly模式下自动显示tooltip
            if(control.iconSource >= 0 && control.display === Button.IconOnly){
                if(control.text === ""){
                    return false
                }
                return hovered
            }
            // 原有FluCustomIconButton逻辑: 通过showHoverTip控制
            if(control.hoverTipText === ""){
                return false
            }
            return hovered && control.showHoverTip
        }
        text: (control.iconSource >= 0 && control.display === Button.IconOnly) ? control.text : control.hoverTipText
    }
}
