import QtQuick 2.15
import QtQuick.Controls 2.15
import RDTools.Public 1.0

// 模块1：大图功能按钮网格
// 按钮尺寸 100x100，圆角 4px，网格布局
Rectangle {
    id: root
    color: Qt.rgba(1, 1, 1, 0.9)
    clip: true
    border.width: 1
    border.color: ThemeColorStyle.border_nor_color
    radius: ScreenTools.scaleNum(8)

    // 模块标题
    property string moduleTitle: "网络工具"

    // 按钮列表
    property var bigIcons: [
        "摸鱼日历", "开发工具", "远程控制", "端口扫描", "文件传输",
        "代理设置", "安全审计", "权限管理", "告警中心", "配置同步"
    ]

    // 计算列数：宽度 / (按钮宽度 + 间距)，最少6列（不够时出水平滚动条）
    property int cellSize: ScreenTools.scaleNum(100)
    property int cellSpacing: ScreenTools.scaleNum(12)
    property int horizPadding: ScreenTools.scaleNum(16)
    property int vertPadding: ScreenTools.scaleNum(8)
    property int minColumns: 6
    property int columns: Math.max(minColumns, Math.floor((width - horizPadding * 2 + cellSpacing) / (cellSize + cellSpacing)))

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

    // 按钮点击分发
    function handleButtonClick(name) {
        switch (name) {
        case "摸鱼日历":
            Qt.openUrlExternally("https://zhou75i.github.io/moyu/");
            break;
        case "开发工具":
            Qt.openUrlExternally("https://moyu.pyigroup.cn/");
            break;
        case "端口扫描":
            SystemTools.openDeviceManager();
            break;
        case "性能监控":
            SystemTools.openTaskManagerPerformance();
            break;
        default:
            console.log("BigIcon button:", name);
            break;
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.leftMargin: horizPadding
        anchors.rightMargin: horizPadding
        anchors.topMargin: titleText.height + titleText.anchors.topMargin + ScreenTools.scaleNum(8)
        anchors.bottomMargin: vertPadding
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        GridLayoutContainer {
            id: grid
            columns: root.columns
            cellSize: root.cellSize
            cellSpacing: root.cellSpacing
            model: root.bigIcons
            buttonType: "big"
            onButtonClicked: function(name) {
                root.handleButtonClick(name);
            }
        }
    }
}
