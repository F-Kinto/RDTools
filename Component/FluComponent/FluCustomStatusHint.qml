import QtQuick 2.12
import QtQml 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import FluentUI 1.0
import ScreenTools 1.0
import VMS.Enum 1.0

// 状态指示器组件 - 显示带颜色圆点的状态标识
// 用于展示任务/项目的当前状态（未开始、处理中、成功、失败、异常）
Item {
    // ==================== 属性定义 ====================

    // 状态类型（参考 VmsEnum.StatusEnum 枚举）
    // - 0: Ready/Not Started
    // - 1: Processing
    // - 2: Success
    // - 3: Failed
    // - 4: Exception
    property real statusType: VmsEnum.StatusEnum.Ready

    // 字体大小
    property real fontSize: ScreenTools.scaleNum(10, true)

    // 状态文本数组（按枚举索引对应）
    property var statusText: [
        qsTr("Not started"),   // 0 - 未开始
        qsTr("Processing"),    // 1 - 处理中
        qsTr("Success"),       // 2 - 成功
        qsTr("Failed"),        // 3 - 失败
        qsTr("Abnormal")      // 4 - 异常
    ]

    // 状态颜色（根据 statusType 动态计算）
    property color statusColor: {
        if(VmsEnum.StatusEnum.Processing === statusType){
            return ThemeColorStyle.privacy_text_color        // 蓝色 - 处理中
        }
        else if(VmsEnum.StatusEnum.Success === statusType){
            return "#00BA00"        // 绿色 - 成功
        }
        else if(VmsEnum.StatusEnum.Failed === statusType){
            return ThemeColorStyle.privacy_error_color       // 红色 - 失败
        }
        else if(VmsEnum.StatusEnum.Exception === statusType){
            return "#FAB007"        // 橙色 - 异常
        }
        return ThemeColorStyle.tab_text_nor_color            // 灰色 - 未开始/默认
    }

    // ==================== 组件配置 ====================

    id: control
    implicitHeight: ScreenTools.scaleNum(32)              // 默认高度
    implicitWidth: ScreenTools.scaleNum(64)               // 默认宽度

    // ==================== 布局容器 ====================

    RowLayout{
        anchors.fill: parent
        spacing: ScreenTools.scaleNum(10)                 // 圆点与文字的间距

        // 状态指示圆点
        Rectangle{
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: control.fontSize / 2    // 圆点高度为字体大小的一半
            Layout.preferredWidth: control.fontSize / 2     // 圆点宽度为字体大小的一半
            radius: height / 2                              // 圆形（半径为高度一半）
            color: statusColor                              // 使用状态颜色
        }

        // 状态文字
        FluText{
            Layout.alignment: Qt.AlignVCenter
            text: statusText[statusType]    // 根据 statusType 索引获取对应文本
            font.pointSize: control.fontSize
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
