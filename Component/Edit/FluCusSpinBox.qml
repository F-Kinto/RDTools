import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import FluentUI 1.0
import ConfigureManager 1.0
import ScreenTools 1.0

T.SpinBox {
    id: control
    signal signalUpdateText(int value)
    property bool disabled: false
    // 文本颜色
    property color normalColor: ThemeColorStyle.title_text_nor_color
    property color disableColor: ThemeColorStyle.text_disable_color
    // 输入框不同状态下背景颜色
    property color hoverBgColor: "#FAFAFD"
    property color normalBgColor: "transparent"
    property color disableBgColor: ThemeColorStyle.bg_disable_color
    property color pressedBgColor: "#F0F2F5"
    // 边框颜色
    property color borderColor: ThemeColorStyle.border_nor_color
    property int itemWidth: ScreenTools.scaleNum(80)
    property int itemHeight: ScreenTools.scaleNum(36)
    property int recrRadius: ScreenTools.scaleNum(4)
    property int indicatorWidth: ScreenTools.scaleNum(36)         // 加减数值图标宽度
    property int spinBoxMaxValue : 100      // 支持最大值
    property bool indicatorVisible: true
    property string suffix: ""              // 值后缀，如 "%"，仅影响显示不影响内部数值
    property string currentText: "0"
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    implicitWidth: itemWidth
    implicitHeight: itemHeight
    leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
    rightPadding: padding + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))
    editable: true    //是否支持手动输入
    focusPolicy: editable ? Qt.StrongFocus : Qt.NoFocus
    enabled: !disabled
    from: 0                         // 最小值
    to: spinBoxMaxValue             // 最大值
    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }
    font.family: "Microsoft YaHei UI"
    font.pointSize: ScreenTools.scaleNum(8, true)

    contentItem: TextInput {
        id: textInput
        objectName: "textInput"
        z: -10
        text: control.suffix.length > 0 && (!textInput.activeFocus || !control.editable) ? (currentText + control.suffix) : currentText
        clip: width < implicitWidth
        padding: ScreenTools.scaleNum(6)
        font: control.font
        color: !enabled ? control.disableColor : control.normalColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
    }

    up.indicator: FluClip {
        x: control.mirrored ? 0 : control.width - width
        height: control.height
        implicitWidth: indicatorVisible ? indicatorWidth : 0
        implicitHeight: itemHeight
        radius: [0,ScreenTools.scaleNum(4),ScreenTools.scaleNum(4),0]
        visible: indicatorVisible
        Rectangle{
            anchors.fill: parent
            border.width: 1
            border.color: borderColor
            color: {
                if(control.up.pressed){
                    return control.pressedBgColor
                }
                if(control.up.hovered){
                    return control.hoverBgColor
                }
                return control.normalBgColor
            }
            Rectangle {
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: parent.width / 3
                height: 2
                color: enabled ? FluTheme.dark ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1) : FluColors.Grey90
            }
            Rectangle {
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 2
                height: parent.width / 3
                color: enabled ? FluTheme.dark ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1) : FluColors.Grey90
            }
        }
    }


    down.indicator: FluClip {
        x: control.mirrored ? parent.width - width : 0
        height: control.height
        implicitWidth: indicatorVisible ? indicatorWidth : 0
        implicitHeight: itemHeight
        radius: [ScreenTools.scaleNum(4),0,0,ScreenTools.scaleNum(4)]
        visible: indicatorVisible
        Rectangle{
            anchors.fill: parent
            border.width: 1
            border.color: borderColor
            color: {
                if(control.down.pressed){
                    return control.pressedBgColor
                }
                if(control.down.hovered){
                    return control.hoverBgColor
                }
                return control.normalBgColor
            }
            Rectangle {
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: parent.width / 3
                height: ScreenTools.scaleNum(2)
                color: enabled ? FluTheme.dark ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1) : FluColors.Grey90
            }
        }
    }

    background: Rectangle {
        anchors.fill: parent
        radius: recrRadius
        border.width: 1
        border.color: borderColor
        color: {
            if(!contentItem.enabled){
                return control.disableBgColor
            }
            if(contentItem.hovered){
                return control.hoverBgColor
            }
            return control.normalBgColor
        }
    }

    onActiveFocusChanged: {
        if(!activeFocus)
        {
            if(textInput.text == "" || currentText == "")
                currentText = "0"
            if(parseInt(currentText) > 100)
                currentText = "100"
            signalUpdateText(parseInt(currentText))
        }
    }

    onDisplayTextChanged: {
        signalUpdateText(parseInt(currentText))
        currentText = control.displayText
    }

    function updateText(value) {
        if (currentText != value) {
            currentText = value;
            control.value = parseInt(value)
        }
    }

    function setText(str) {
        currentText = str
        control.value = parseInt(str)
    }
}
