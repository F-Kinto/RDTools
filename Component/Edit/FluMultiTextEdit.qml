import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import ConfigureManager 1.0
import Component.FluComponent 1.0

Rectangle {
    property bool disabled: false
    // 图标颜色相关颜色设置
    property color normalColor: ThemeColorStyle.text_nor_color
    property color disableColor: ThemeColorStyle.text_disable_color
    property bool isCtrlEnterForNewline: false
    property bool isReadOnly: false
    property string cusPlaceholderText: qsTr("Please enter")
    // 输入框相关属性
    property color borderNormalColor : ThemeColorStyle.border_nor_color
    property color borderTypingColor : ThemeColorStyle.border_checked_color
    property color borderColor : control.focus ? borderTypingColor : borderNormalColor
    property color backgroundColor: disabled ? rgba(0, 0, 0, 0.04) : "transparent"
    property int  borderRadius: 4
    property int  borderWidth: 1
    property int editWidth: 240
    property int editHeight: 120
    property int fontSize: ScreenTools.scaleNum(10, true)

    // 镜像
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    width: editWidth
    height: editHeight
    color: backgroundColor
    border.width: borderWidth
    radius: borderRadius
    border.color: borderColor
    signal commit(string text)

    Flickable {
        id: flickable
        visible: true
        clip: true
        anchors {
            right: parent.right
            rightMargin: 2
            top: parent.top
            topMargin: 1
        }
        width: parent.width
        height: parent.height - 2
        contentHeight: control.contentHeight + 40
        ScrollBar.vertical: FluCustomScrollBar {}

        TextArea{
            id:control
            enabled: !disabled
            color: !enabled ? disableColor : normalColor
            font.pointSize: fontSize
            font.family: "Microsoft YaHei UI"
            wrapMode: Text.WrapAnywhere
            padding: 8
            leftPadding: 12
            rightPadding: 12
            renderType: FluTheme.nativeText ? Text.NativeRendering : Text.QtRendering
            placeholderTextColor: ThemeColorStyle.placeholder_text_color
            placeholderText: cusPlaceholderText
            selectByMouse: true
            width: parent.width
            height: parent.height
            implicitWidth: parent.width
            implicitHeight: parent.height
            horizontalAlignment: Text.AlignLeft
            readOnly: isReadOnly
            lineHeight: 1.4                         // 行高
            lineHeightMode: Text.ProportionalHeight
            Keys.onEnterPressed: (event)=> d.handleCommit(event)
            Keys.onReturnPressed:(event)=> d.handleCommit(event)
            QtObject{
                id:d
                function handleCommit(event){
                    control.commit(control.text)
                    console.log("Commit:", control.text)
                }
            }
            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.RightButton
                onClicked: {
                    if(control.readOnly && control.text === ""){
                        return
                    }
                    menu_loader.popup()
                }
            }
            FluLoader{
                id: menu_loader
                function popup(){
                    sourceComponent = menu
                }
            }
            Component{
                id:menu
                FluTextBoxMenu{
                    Component.onCompleted: {
                        popup()
                    }
                    inputItem: control
                    onClosed: {
                        menu_loader.sourceComponent = undefined
                    }
                }
            }
        }
    }
}
