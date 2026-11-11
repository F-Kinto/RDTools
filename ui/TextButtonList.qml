import QtQuick 2.15
import QtQuick.Controls 2.15
import Component.FluButton 1.0
import RDTools.Public 1.0

// 模块3：文本功能按钮列表
// 垂直布局，条目高度 28px，间距 12px，圆角 4px，按钮使用 Flu 控件
Rectangle {
    id: root

    color: Qt.rgba(1, 1, 1, 0.9)
    clip: true
    border.width: 1
    border.color: ThemeColorStyle.border_nor_color
    radius: ScreenTools.scaleNum(8)

    // 模块标题
    property string moduleTitle: "实用查询"

    property var textButtons: [
        "系统信息", "进程管理", "性能监控", "任务调度", "日志查看",
        "备份恢复", "数据导出", "设置", "帮助文档", "关于",
        "检查更新", "反馈", "快捷键", "主题切换", "语言切换",
        "导出日志", "重置布局", "全屏模式", "数据清理", "缓存管理",
        "插件管理", "开机自启", "最小化到托盘", "退出"
    ]

    property int horizPadding: ScreenTools.scaleNum(16)
    property int vertPadding: ScreenTools.scaleNum(16)

    // 按钮点击分发
    function handleButtonClick(name) {
        switch (name) {
        case "设置":
            SystemTools.openSystemInfo();
            break;
        case "系统信息":
            SystemTools.openSystemInfo();
            break;
        default:
            console.log("Text button:", name);
            break;
        }
    }

    // 标题
    Text {
        id: titleText
        anchors.left: parent.left
        anchors.leftMargin: horizPadding
        anchors.top: parent.top
        anchors.topMargin: vertPadding
        text: root.moduleTitle
        color: ThemeColorStyle.text_nor_color
        font.family: ScreenTools.fontFamily
        font.pointSize: ScreenTools.scaleNum(16, true)
        font.bold: true
    }

    ScrollView {
        anchors.fill: parent
        anchors.leftMargin: horizPadding
        anchors.rightMargin: horizPadding
        anchors.topMargin: titleText.height + titleText.anchors.topMargin + ScreenTools.scaleNum(8)
        anchors.bottomMargin: vertPadding
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            id: column

            width: parent.width - ScreenTools.scaleNum(32)
            spacing: ScreenTools.scaleNum(12)

            Repeater {
                model: root.textButtons

                FluCustomShapeButton {
                    buttonWidth: column.width
                    buttonHeight: ScreenTools.scaleNum(28)
                    borderRadius: ScreenTools.scaleNum(4)
                    text: modelData
                    textNormalColor: ThemeColorStyle.text_nor_color
                    textBtnHoverColor: ThemeColorStyle.privacy_text_color
                    normalColor: ThemeColorStyle.list_bg_nor_color
                    hoverColor: ThemeColorStyle.list_bg_hover_color
                    pressedColor: ThemeColorStyle.list_bg_hover_color
                    borderNormalColor: ThemeColorStyle.border_nor_color
                    borderFocusColor: ThemeColorStyle.border_checked_color
                    alignmentValue: Qt.AlignLeft
                    leftOffset: ScreenTools.scaleNum(12)
                    onClicked: {
                        root.handleButtonClick(text);
                    }
                }
            }
        }
    }
}
