import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import FluentUI 1.0
import ConfigureManager 1.0
import ScreenTools 1.0

T.Slider {
    id: control
    objectName: "slider"
    signal updateTextValue(string value)
    property bool tooltipEnabled: true
    property bool disabled: false
    property string suffix: ""              // 值后缀，如 "%"，仅影响显示不影响内部数值
    property string text: String(control.value)
    property int itemWidth: ScreenTools.scaleNum(200)
    property int itemHeiitt: ScreenTools.scaleNum(24)
    property color normalBgColor:  "#D6EFFF"
    property color selectBgColor:  ThemeColorStyle.privacy_text_color
    property color disableBgColor:  ThemeColorStyle.text_disable_color
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    enabled: !disabled
    to:100
    stepSize:1
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitHandleHeight + topPadding + bottomPadding)
    padding: ScreenTools.scaleNum(6)
    handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
        implicitWidth: ScreenTools.scaleNum(20)
        implicitHeight: ScreenTools.scaleNum(20)
        radius: ScreenTools.scaleNum(10)
        color: "#FFFFFF"
        FluShadow{
            radius: ScreenTools.scaleNum(10)
        }
        FluIcon{
            width: ScreenTools.scaleNum(10)
            height: ScreenTools.scaleNum(10)
            Behavior on scale{
                NumberAnimation{
                    duration: 167
                    easing.type: Easing.OutCubic
                }
            }
            iconSource: FluentIcons.FullCircleMask
            iconSize: ScreenTools.scaleNum(10)
            scale:{
                if(control.pressed){
                    return 0.9
                }
                return control.hovered ? 1.2 : 1
            }
            iconColor: disabled ? disableBgColor : selectBgColor
            anchors.centerIn: parent
        }
    }
    background: Item {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? itemWidth : ScreenTools.scaleNum(6)
        implicitHeight: control.horizontal ? ScreenTools.scaleNum(6) : iemWidth
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight
        Rectangle{
            anchors.fill: parent
            anchors.margins: 1
            radius: ScreenTools.scaleNum(2)
            color: disabled ? disableBgColor : normalBgColor
        }
        scale: control.horizontal && control.mirrored ? -1 : 1
        Rectangle {
            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : ScreenTools.scaleNum(6)
            height: control.horizontal ? ScreenTools.scaleNum(6) : control.position * parent.height
            radius: ScreenTools.scaleNum(4)
            color: disabled ? disableBgColor : selectBgColor
        }
    }
    FluTooltip{
        parent: control.handle
        margins: ScreenTools.scaleNum(6)
        padding: ScreenTools.scaleNum(6)
        font.family: ScreenTools.fontFamily
        font.pointSize: ScreenTools.scaleNum(10, true)
        background: Rectangle {
            color: FluTheme.dark ? Qt.rgba(50/255,49/255,48/255,1) : Qt.rgba(1,1,1,1)
            radius: ScreenTools.scaleNum(4)
            FluShadow{
                radius: ScreenTools.scaleNum(4)
            }
        }
        visible: control.tooltipEnabled && (control.pressed || control.hovered)
        text: control.value + control.suffix
    }

    onPressedChanged: {
        if (!control.pressed) {
            updateTextValue(value.toString())
        }
    }

    function updateValue(value) {
        if(value !== control.value)
        {
            if (value < control.minimum)
                value = control.minimum
            else if (value > control.maximum)
                value = control.maximum
            control.value = value
        }
    }

    function setText(str) {
        control.value = parseInt(str)
    }
}
