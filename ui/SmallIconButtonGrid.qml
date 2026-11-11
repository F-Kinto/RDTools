import QtQuick 2.15
import QtQuick.Controls 2.15
import RDTools.Public 1.0

// 模块2：小图功能按钮网格
// 按钮尺寸 48x48，圆角 4px，网格布局
Rectangle {
    id: root
    color: Qt.rgba(1, 1, 1, 0.9)
    clip: true
    border.width: 1
    border.color: ThemeColorStyle.border_nor_color
    radius: ScreenTools.scaleNum(8)

    // 模块标题
    property string moduleTitle: "开发工具"

    property var smallIcons: [
        "编码", "哈希", "格式化", "脚本执行", "环境检测",
        "诊断工具", "版本更新", "压缩", "加密", "解密",
        "校验", "替换", "对比", "开发者选项", "调试"
    ]

    property int cellSize: ScreenTools.scaleNum(48)
    property int cellSpacing: ScreenTools.scaleNum(10)
    property int horizPadding: ScreenTools.scaleNum(16)
    property int vertPadding: ScreenTools.scaleNum(16)
    property int minColumns: 8
    property int columns: Math.max(minColumns, Math.floor((width - horizPadding * 2 + cellSpacing) / (cellSize + cellSpacing)))

    // 按钮点击分发
    function handleButtonClick(name) {
        switch (name) {
        case "截图":
            ScreenCapture.startCapture();
            break;
        default:
            console.log("SmallIcon button:", name);
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
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        GridLayoutContainer {
            id: grid
            columns: root.columns
            cellSize: root.cellSize
            cellSpacing: root.cellSpacing
            model: root.smallIcons
            buttonType: "small"
            onButtonClicked: function(name) {
                root.handleButtonClick(name);
            }
        }
    }
}
