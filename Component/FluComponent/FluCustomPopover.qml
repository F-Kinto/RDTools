import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import FluentUI 1.0
import ScreenTools 1.0
import Component.FluComponent 1.0

// 自定义弹窗组件 - 支持标题、消息内容和自定义内容区域
// 用于显示提示、确认、信息展示等场景
Popup {
    id: control

    // ==================== 属性定义 ====================

    // 弹窗标题
    property string title: ""

    // 弹窗消息内容
    property string message: ""

    // 消息文本格式（参考 Qt.TextFormat 枚举）
    // - Text.AutoText: 自动识别
    // - Text.PlainText: 纯文本
    // - Text.RichText: 富文本
    property int messageTextFormart: Text.AutoText

    // 自定义内容委托组件（可扩展弹窗内容）
    property var contentDelegate: Component{
        Item{
            // 默认空组件，外部可传入自定义内容
        }
    }

    // ==================== 尺寸和位置 ====================

    implicitWidth: ScreenTools.scaleNum(180)                          // 默认宽度
    implicitHeight: layout_content.height       // 高度根据内容自适应

    // 水平居中显示
    x: parent ? (parent.width - implicitWidth) / 2 : 0

    // 垂直位置（父容器中心偏下 6 像素）
    y: parent ? (parent.height + ScreenTools.scaleNum(6)) : 0

    // ==================== 弹窗行为 ====================

    // 关闭策略：ESC 键或点击父容器外部关闭
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    focus: true                                 // 获取焦点
    modal: false                                // 非模态弹窗（不阻塞其他交互）

    // ==================== 进入/退出动画 ====================

    // 进入动画：淡入效果
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            duration: FluTheme.animationEnabled ? ScreenTools.scaleNum(82) : 0    // 根据主题动画设置
            from: 0
            to: 1
        }
    }

    // 退出动画：淡出效果
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            duration: FluTheme.animationEnabled ? ScreenTools.scaleNum(82) : 0
            from: 1
            to: 0
        }
    }

    // ==================== 消息内容组件 ====================

    Component{
        id: com_message

        // 可滚动文本区域（消息内容过长时显示滚动条）
        Flickable{
            id: sroll_message
            contentHeight: text_message.height
            contentWidth: width
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            width: parent.width
            // 高度根据消息内容动态计算，最大 300 像素
            height: message === "" ? 0 : Math.min(text_message.height, ScreenTools.scaleNum(300))

            ScrollBar.vertical: FluCustomScrollBar {}     // 垂直滚动条

            FluText{
                id: text_message
                font.pointSize: ScreenTools.scaleNum(10)
                font.family: ScreenTools.fontFamily
                wrapMode: Text.WordWrap             // 自动换行
                text: message
                textColor: ThemeColorStyle.text_nor_color               // 灰色文字
                width: parent.width
                topPadding: ScreenTools.scaleNum(10)
                leftPadding: ScreenTools.scaleNum(20)
                rightPadding: ScreenTools.scaleNum(20)
                bottomPadding: ScreenTools.scaleNum(4)
            }
        }
    }

    // ==================== 背景区域 ====================

    background: FluRectangle{
        id: layout_content
        width: parent.width
        // 高度根据列布局内容自适应
        height: layout_column.childrenRect.height
        radius: [ScreenTools.scaleNum(4), ScreenTools.scaleNum(4), ScreenTools.scaleNum(4), ScreenTools.scaleNum(4)]                        // 四角圆角

        // 根据主题切换背景色
        color: FluTheme.dark ? Qt.rgba(43/255,43/255,43/255,1) : Qt.rgba(1,1,1,1)

        ColumnLayout{
            id: layout_column
            width: parent.width
            spacing: ScreenTools.scaleNum(10)                             // 子项间距

            // 标题区域
            Item{
                Layout.fillWidth: true
                Layout.preferredHeight: text_title.height + ScreenTools.scaleNum(4)

                FluText{
                    id: text_title
                    font.pointSize: ScreenTools.scaleNum(10)
                    font.family: ScreenTools.fontFamily
                    text: title
                    textColor: ThemeColorStyle.title_text_nor_color          // 深色文字
                    topPadding: ScreenTools.scaleNum(10)
                    leftPadding: ScreenTools.scaleNum(20)
                    rightPadding: ScreenTools.scaleNum(20)
                    wrapMode: Text.WordWrap         // 自动换行
                }

                // 标题下方分隔线
                Rectangle{
                    anchors.top: text_title.bottom
                    anchors.topMargin: ScreenTools.scaleNum(10)
                    height: ScreenTools.scaleNum(2)
                    width: parent.width
                    color: ThemeColorStyle.border_nor_color               // 浅灰色分隔线
                }
            }

            // 消息内容区域
            FluLoader{
                sourceComponent: com_message
                Layout.fillWidth: true
                // 根据加载状态设置高度
                Layout.preferredHeight: status === Loader.Ready ? item.height : ScreenTools.scaleNum(50)
            }

            // 自定义内容区域
            FluLoader{
                sourceComponent: control.visible ? control.contentDelegate : undefined
                Layout.fillWidth: true

                // 根据加载状态动态调整高度
                onStatusChanged: {
                    if(status === Loader.Ready){
                        Layout.preferredHeight = item.implicitHeight
                    } else {
                        Layout.preferredHeight = 0
                    }
                }
            }
        }

        // 阴影效果
        FluShadow{
            radius: ScreenTools.scaleNum(4)
        }
    }
}
