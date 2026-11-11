import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import FluentUI 1.0
import ScreenTools 1.0
import ConfigureManager 1.0

T.ItemDelegate {
    id: control
    signal clicked(string strText)
    property int rectRadius: ScreenTools.scaleNum(4)
    property color normalColor: ThemeColorStyle.list_text_nor_color
    property color hoverColor: ThemeColorStyle.list_text_hover_color
    property color selectColor: ThemeColorStyle.list_text_select_color
    property color disableColor: ThemeColorStyle.list_text_disable_color
    property color normalBgColor: ThemeColorStyle.list_bg_nor_color
    property color hoverBgColor: ThemeColorStyle.list_bg_hover_color
    property color selectBgColor: ThemeColorStyle.list_bg_select_color
    property bool isChecked: false
    property int fontSize: ScreenTools.scaleNum(10, true)
    property int itemWidth: ScreenTools.scaleNum(100)
    property int itemHeight: ScreenTools.scaleNum(32)
    property int alignType: Text.AlignLeft
    hoverEnabled: true
    implicitWidth: itemWidth
    implicitHeight: itemHeight
    padding: 0
    verticalPadding: ScreenTools.scaleNum(6)
    horizontalPadding: ScreenTools.scaleNum(4)
    icon.color: control.palette.text
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    contentItem:FluText {
        id: deleText
        text: control.text
        font.family: "Microsoft YaHei UI"
        color: isChecked ? selectColor : normalColor
        font.pointSize: fontSize
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: alignType
        anchors.left: alignType === Text.AlignLeft ? parent.left : undefined
        anchors.leftMargin: alignType === Text.AlignLeft ? ScreenTools.scaleNum(12) : 0
    }
    background: Rectangle {
        id: background
        implicitWidth: itemWidth
        implicitHeight: itemHeight
        radius: rectRadius
        color:isChecked ? selectBgColor : normalBgColor
        visible: true
    }
    onIsCheckedChanged: {
        updateBgColor()
    }
    MouseArea{
        anchors.fill: parent
        hoverEnabled: control.hoverEnabled
        onClicked: {
            control.clicked(control.text)
        }
        onEntered: {
            background.color = isChecked ? selectBgColor : hoverBgColor
            deleText.color = isChecked ? selectColor : hoverColor
        }
        onExited: {
            updateBgColor()
        }
    }
    function updateBgColor() {
        background.color = isChecked ? selectBgColor : normalBgColor
        deleText.color = isChecked ? selectColor : normalColor
    }
}
