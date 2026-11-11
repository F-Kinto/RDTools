import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import FluentUI 1.0
import ScreenTools 1.0
import QtQuick.Templates 2.15 as T
import ConfigureManager 1.0
import VMS.Enum 1.0
import Component.FluComponent 1.0

T.ComboBox {
    id: control
    signal commitIndex(int index)
    property bool disabled: false
    //文本颜色
    property color normalColor: ThemeColorStyle.text_nor_color
    property color disableColor: ThemeColorStyle.text_disable_color

    // 无焦点边框颜色 - 有焦点边框颜色
    property color borderNormalColor : ThemeColorStyle.border_nor_color
    property color borderTypingColor : ThemeColorStyle.border_checked_color
    property color borderColor : control.focus ? borderTypingColor : borderNormalColor
    property color backgroundColor: disabled ? "#F0F2F5" : "transparent"

    // 窗口属性, 圆角,边框,宽度高度
    property int  borderRadius: ScreenTools.scaleNum(4)
    property int  borderWidth: 1
    property int editWidth: ScreenTools.scaleNum(240)
    property int editHeight: ScreenTools.scaleNum(36)

    // 字体大小
    property int fontSize: ScreenTools.scaleNum(10, true)        
    property int iconWidth: ScreenTools.scaleNum(10)           

    // 下拉框最大支持显示的数量
    property int listMaxCount: 8      
    property int textAlginValue: 2   // 1:左对齐 2:居中 3:右对齐  
    //  初始化后默认的值的文本和索引
    property int curIndex: 0
    onCurIndexChanged: {
        text_field.curIndex = curIndex
    }
    implicitWidth: editWidth
    height: editHeight
    property alias textBox: text_field      // 输入框对象外部引用
    font.family: ScreenTools.fontFamily
    font.pointSize: fontSize
    enabled: !disabled

    // 镜像
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    leftPadding: {
        if(LayoutMirroring.enabled)
            return padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
        else
            return padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    }
    rightPadding: {
        if(LayoutMirroring.enabled)
            return padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
        else
            return padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    }
    
    delegate: FluDelegateItem {
        width: ListView.view.width
        text: modelData
        fontSize: control.fontSize
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        alignType: Text.AlignHCenter
        itemWidth: editWidth - ScreenTools.scaleNum(8)
        itemHeight: ScreenTools.scaleNum(30)
    }
    focusPolicy:Qt.TabFocus
    inputMethodHints: Qt.ImhNoPredictiveText

    indicator: FluCustomSvg{
        id: icon
        objectName: "icon"
        x: control.mirrored ? control.padding : control.width - width - control.padding - ScreenTools.scaleNum(8)
        y: control.topPadding + (control.availableHeight - height) / 2
        opacity: enabled ? 1 : 0.3
        imageWidth: ScreenTools.scaleNum(16)
        imageHeight: ScreenTools.scaleNum(16)
        sourceImage: CommonImageStyle.arrow_down_img
        fillColorFirst: "#CAD2DD"
        onClicked: {
            text_field.showList() 
        }
    }

    contentItem: FluAutoMatchBox {
        id: text_field
        objectName: "text_field"
        model: control.model
        editAble: false
        borderRadius: control.borderRadius
        itemWidth: control.editWidth - ScreenTools.scaleNum(10)
        itemHeight: ScreenTools.scaleNum(34)
        fontSize: control.font.pointSize
        alginValue: textAlginValue
        normalColor: control.normalColor
        disableColor: control.disableColor
        borderNormalColor : control.borderNormalColor
        borderTypingColor : control.borderTypingColor
        borderColor : control.borderColor
        backgroundColor: control.backgroundColor
        curIndex : control.curIndex
        onItemClicked:{
            control.displayText = selectText
            control.currentIndex = index
            control.curIndex = index
            control.commitIndex(index)
        }
    }
    // 导致边框以及背景颜色
    background: Rectangle {
        anchors.fill: parent
        color: control.backgroundColor
        border.width: borderWidth
        radius: borderRadius
        border.color: {
            if(text_field.listIsShow() || backMouseArea.containsMouse || control.focus)
                return control.borderTypingColor
            else
                return control.borderColor
        }
        MouseArea {
            id: backMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                text_field.showList()
            }
        }
    }
}
