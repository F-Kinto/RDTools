import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import ScreenTools 1.0

Button {
    id: control
    
    // --- 新增属性：左右文本 ---
    property string textOn: qsTr("Enable")      // 开启时显示的文本
    property string textOff: qsTr("Disable")     // 关闭时显示的文本
    // ------------------------
    property bool textVisible: true     // 是否显示文字
    property int itemWidth: ScreenTools.scaleNum(56)
    property int itemHeight: ScreenTools.scaleNum(28)

    property bool disabled: false
    property string contentDescription: ""
    
    // 颜色定义 (保持原样)
    property color disableColor: Qt.rgba(0,0,0,0.25)
    property color checkColor: ThemeColorStyle.privacy_text_color
    property color hoverColor: FluTheme.dark ? Qt.rgba(62/255,62/255,62/255,1) : Qt.rgba(240/255,240/255,240/255,1)
    property color normalColor:Qt.rgba(0,0,0,0.25)
    property color borderNormalColor: FluTheme.dark ? Qt.rgba(161/255,161/255,161/255,1) : Qt.rgba(141/255,141/255,141/255,1)
    property color borderCheckColor: FluTheme.primaryColor
    property color borderDisableColor: FluTheme.dark ? Qt.rgba(50/255,50/255,50/255,1) : Qt.rgba(200/255,200/255,200/255,1)
    property color dotNormalColor: FluTheme.dark ? Qt.rgba(208/255,208/255,208/255,1) : Qt.rgba(93/255,93/255,93/255,1)
    property color dotCheckColor: FluTheme.dark ? Qt.rgba(0/255,0/255,0/255,1) : Qt.rgba(255/255,255/255,255/255,1)
    property color dotDisableColor: FluTheme.dark ? Qt.rgba(50/255,50/255,50/255,1) : Qt.rgba(150/255,150/255,150/255,1)
    
    property real textSpacing: 8 // 稍微增加间距，防止文字太贴
    property bool textRight: true // true: 文字在右 (开关在左); false: 文字在左 (开关在右)
    
    property color textColor: "#FFFFFF"

    property var clickListener: function(){
        checked = !checked
    }

    Accessible.role: Accessible.Button
    Accessible.name: control.text
    Accessible.description: contentDescription
    Accessible.onPressAction: control.clicked()
    
    enabled: !disabled
    focusPolicy: Qt.TabFocus
    onClicked: clickListener()
    
    padding: 0
    horizontalPadding: 0

    
    // 防止外部错误设置 checkable
    onCheckableChanged: {
        if(checkable){ checkable = false }
    }

    background: Item {
        implicitHeight: itemHeight
        implicitWidth: itemWidth
    }

    contentItem: RowLayout {
        spacing: control.textSpacing
        // 控制整体排列方向：
        // textRight=true (默认): LeftToRight -> [开关] [文字]
        // textRight=false: RightToLeft -> [文字] [开关] (注意：RTL模式下视觉顺序会反转)
        layoutDirection: control.textRight ? Qt.LeftToRight : Qt.RightToLeft
        
        Rectangle {
            id: control_backgound
            implicitWidth: background.implicitWidth
            implicitHeight: background.implicitHeight
            radius: height / ScreenTools.scaleNum(2)
            
            FluFocusRectangle {
                visible: control.activeFocus
                radius: parent.radius
            }
            
            color: {
                if(!enabled) return disableColor
                if(checked) return checkColor
                if(hovered) return hoverColor
                return normalColor
            }
            
            border.width: 1
            border.color: {
                if(!enabled) return borderDisableColor
                if(checked) return borderCheckColor
                return borderNormalColor
            }

            FluText {
                id: btn_text
                // --- 关键修改：根据 checked 状态切换文本 ---
                text: control.checked ? control.textOn : control.textOff
                x: checked ?  ScreenTools.scaleNum(8)  : (control_backgound.width - width) - ScreenTools.scaleNum(8)
                
                Layout.alignment: Qt.AlignVCenter
                // visible: text !== "" && control.checked
                color: control.textColor
                visible: control.textVisible
                
                // 可选：给文字颜色也加个渐变动画，更丝滑
                Behavior on color {
                    enabled: FluTheme.animationEnabled
                    ColorAnimation { duration: 167; easing.type: Easing.OutCubic }
                }
            }

            // 滑块 (使用 FluIcon 模拟圆形滑块)
            FluIcon {
                width: parent.height
                Layout.alignment: Qt.AlignVCenter
                // 核心移动逻辑
                x: checked ? (control_backgound.width - width) : 0
                
                scale: {
                    if(pressed) return 8/10
                    return (hovered && enabled) ? 7/10 : 8/10
                }
                
                iconSource: FluentIcons.FullCircleMask
                iconSize: itemHeight
                color: {
                    if(!enabled) return dotDisableColor
                    if(checked) return dotCheckColor
                    return dotNormalColor
                }
                
                Behavior on scale {
                    NumberAnimation { duration: 167; easing.type: Easing.OutCubic }
                }
                
                Behavior on x {
                    enabled: FluTheme.animationEnabled
                    NumberAnimation {
                        duration: 167
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        
    }

    FluText {
        // --- 关键修改：根据 checked 状态切换文本 ---
        text: control.checked ? control.textOn : control.textOff
        
        Layout.alignment: Qt.AlignVCenter
        visible: control.textVisible && text !== "" 
        color: control.textColor
        
        // 可选：给文字颜色也加个渐变动画，更丝滑
        Behavior on color {
            enabled: FluTheme.animationEnabled
            ColorAnimation { duration: 167; easing.type: Easing.OutCubic }
        }
    }
}
