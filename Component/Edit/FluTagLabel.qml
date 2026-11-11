import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import ConfigureManager 1.0

Rectangle{
    signal deleteItem(string tagtext, int index)
    signal labelClick()
    property color normalColor: ThemeColorStyle.text_nor_color
    property int  fontSize: ScreenTools.scaleNum(10, true)
    // 输入框边框相关属性
    property color borderColor :  ThemeColorStyle.border_nor_color
    property color backgroundColor:  "#F0F2F5"
    property int  borderRadius: 4
    property int  borderWidth: 0
    property string tagText: "我是标签"
    property int  tagIndex: 0
    // 右边关闭按钮是否可见
    property bool closeVisible: false
    // 镜像
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    id:control
    // 关键：使用implicitWidth让控件自动计算合适的宽度
    implicitWidth: contentRow.implicitWidth + 8
    height: 24
    color: backgroundColor
    border.width: borderWidth
    radius: borderRadius
    border.color: borderColor

    // 改用普通Row而非RowLayout，避免布局冲突
    Row {
        id: contentRow
        // 居中显示，同时设置左右内边距
        anchors.centerIn: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        spacing: 4
        
        Label{
            text: tagText
            font.family: "Microsoft YaHei UI"
            font.pointSize: fontSize
            color: normalColor
            // 确保Label的隐式宽度正确计算
            verticalAlignment: Text.AlignVCenter
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                enabled: true
                onClicked:{
                    control.labelClick()
                }
            }
        }
        
        FluIconButton{
            iconSource: FluentIcons.Cancel
            iconSize: 10
            width: 16
            height: 16
            visible: closeVisible
            iconColor: ThemeColorStyle.text_nor_color
            verticalPadding: 0
            horizontalPadding: 0
            // 按钮垂直居中
            anchors.verticalCenter: parent.verticalCenter
            onClicked:{
                control.deleteItem(tagText,tagIndex)
            }
        }
    }
}