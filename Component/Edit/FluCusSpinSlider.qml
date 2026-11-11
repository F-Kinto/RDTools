import QtQuick 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import Component.Edit 1.0
import ConfigureManager 1.0
import ScreenTools 1.0

Item {
    id: control
    signal getTextValue(int value)
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
    property int itemWidth: ScreenTools.scaleNum(300) 
    property int itemHeight: ScreenTools.scaleNum(36) 
    property int recrRadius: ScreenTools.scaleNum(4) 
    property int indicatorWidth: ScreenTools.scaleNum(36)          // 加减数值图标宽度
    property int spinBoxMaxValue : 100      // 支持最大值
    property bool spinBoxVisible: true
    property int initValue:0
    property string suffix: ""              // 值后缀，如 "%"，透传给 Slider 和 SpinBox
    property bool spinBoxEditable: true     // SpinBox 是否可手动编辑，默认可编辑
    implicitWidth: itemWidth
    implicitHeight: itemHeight
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    onInitValueChanged:{
        spinBox.setText(initValue)
        slider.setText(initValue)
    }
    RowLayout {
        id: root
        anchors.fill: parent
        spacing: ScreenTools.scaleNum(16) 
        
        FluCusSlider{
            id: slider
            text: String(initValue)
            suffix: control.suffix
            disabled: control.disabled
            onUpdateTextValue:{
                spinBox.updateText(value)
                control.getTextValue(value)
            }
        }

        FluCusSpinBox{
            id: spinBox
            suffix: control.suffix
            editable: control.spinBoxEditable
            Layout.preferredWidth: ScreenTools.scaleNum(50) 
            Layout.fillWidth: true
            height: ScreenTools.scaleNum(36)
            disabled: control.disabled
            borderColor: control.borderColor
            normalColor: control.normalColor
            disableColor: control.disableColor
            hoverBgColor: control.hoverBgColor
            normalBgColor: control.normalBgColor
            disableBgColor: control.disableBgColor
            pressedBgColor: control.pressedBgColor
            indicatorVisible: spinBoxVisible
            visible: !control.disabled
            currentText: String(initValue)
            spinBoxMaxValue: 100
            indicatorWidth: ScreenTools.scaleNum(20) 
            onSignalUpdateText:{
                slider.updateValue(value)
                //control.getTextValue(value)
            }
        }
    }
}
