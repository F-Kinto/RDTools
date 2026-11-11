import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import VMS.Enum 1.0
import ConfigureManager 1.0
import ScreenTools 1.0

// 标签组件 - 支持多种样式、颜色、图标类型的可定制标签
// 可用于状态标识、分类标签、可关闭标签等场景
Rectangle{
    // ==================== 信号定义 ====================

    // 提交信号 - 通知外部标签操作
    // @param cmd 操作命令：0-关闭，1-添加，2-删除
    // @param text 标签文本内容
    signal commit(int cmd, string text)

    // ==================== 基本属性 ====================

    // 标签显示文本
    property string text: "Label1"

    // 是否禁用组件
    property bool disabled: false

    // 图标类型（参考 VmsEnum.LableTypeEnum）
    // - LabelOnly: 仅文字
    // - AddLable: 带添加按钮
    // - CloseLable: 带关闭按钮
    property int iconType: VmsEnum.LableTypeEnum.LabelOnly

    // 颜色显示类型（参考 VmsEnum.LableColorTypeEnum）
    // - BackgroundStyle: 背景着色，文字白色
    // - TextStyle: 背景半透明，文字着色
    property int colorDisplayType: VmsEnum.LableColorTypeEnum.BackgroundStyle

    // 半透明透明度（用于 TextStyle 模式）
    property real fadeAlpha: 0.5

    // ==================== 颜色定义 ====================

    // 预设颜色数组（随机选择用）
    property var colors : [ThemeColorStyle.privacy_text_color, ThemeColorStyle.tab_text_nor_color,ThemeColorStyle.privacy_error_color,"#00BA00","#FAB007"]

    // 正常状态文字颜色（根据主题切换）
    property color normalColor: FluTheme.dark ?  Qt.rgba(255/255,255/255,255/255,1) : Qt.rgba(27/255,27/255,27/255,1)

    // 禁用状态文字颜色
    property color disableColor: FluTheme.dark ? Qt.rgba(131/255,131/255,131/255,1) : Qt.rgba(160/255,160/255,160/255,1)

    // 占位符颜色定义
    property color placeholderNormalColor: FluTheme.dark ? Qt.rgba(210/255,210/255,210/255,1) : Qt.rgba(96/255,96/255,96/255,1)
    property color placeholderFocusColor: FluTheme.dark ? Qt.rgba(152/255,152/255,152/255,1) : Qt.rgba(141/255,141/255,141/255,1)
    property color placeholderDisableColor: FluTheme.dark ? Qt.rgba(131/255,131/255,131/255,1) : Qt.rgba(160/255,160/255,160/255,1)

    // 随机选择的颜色（从 colors 数组中随机选取）
    property color randomColor: colors[Math.floor(Math.random() * colors.length)]

    // 半透明颜色（用于 TextStyle 模式的背景）
    property color tintedColor: Qt.rgba(randomColor.r, randomColor.g, randomColor.b, fadeAlpha)

    // ==================== 样式属性 ====================

    property int borderWidth: 2           // 边框宽度
    property int fontSize: ScreenTools.scaleNum(10, true)             // 字体大小
    property bool isBold: false           // 是否加粗
    property int alignValue: Text.AlignHCenter  // 文字对齐方式
    property int textWrap: Text.NoWrap    // 文字换行
    property int elide: Text.ElideNone    // 文字省略模式
    property bool shadowVisible: false    // 是否显示阴影
    property int labelHeight: ScreenTools.scaleNum(24)          // 默认高度

    // ==================== 动态颜色计算 ====================

    // 当前背景颜色（根据 colorDisplayType 决定）
    property color currentBackgroundColor: {
        if(VmsEnum.LableColorTypeEnum.BackgroundStyle === colorDisplayType){
            return randomColor          // 背景着色模式：使用随机颜色
        }
        else if(VmsEnum.LableColorTypeEnum.TextStyle === colorDisplayType){
            return tintedColor          // 文字着色模式：使用半透明背景
        }
        return "transparent"
    }

    // 当前边框颜色
    property color currentBorderColor: {
        if(VmsEnum.LableColorTypeEnum.TextStyle === colorDisplayType){
            return tintedColor          // 文字着色模式：边框半透明
        }
        return randomColor              // 背景着色模式：边框使用随机颜色
    }

    // 当前文字颜色
    property color currentTextColor: {
        if(VmsEnum.LableColorTypeEnum.BackgroundStyle === colorDisplayType){
            return "#FFFFFF"            // 背景着色模式：文字白色
        }
        return randomColor              // 文字着色模式：文字使用随机颜色
    }

    // ==================== 组件配置 ====================

    id: control
    implicitHeight: labelHeight                 
    implicitWidth: com_Lable.length * 12  // 根据文字长度计算宽度
    enabled: !disabled                  // 根据 disabled 属性控制启用状态
    radius: ScreenTools.scaleNum(4)                           // 圆角半径
    color: currentBackgroundColor       // 背景颜色
    border.color: currentBorderColor    // 边框颜色
    border.width: borderWidth           // 边框宽度

    // ==================== 添加按钮 ====================

    FluIconButton{
        id: com_AddBtn
        anchors{
            left: parent.left
            leftMargin: ScreenTools.scaleNum(4)
            verticalCenter: parent.verticalCenter
        }
        width: parent.height / 2
        height: parent.height / 2

        iconSource: FluentIcons.Add     // 添加图标
        iconSize: ScreenTools.scaleNum(12)
        iconColor: currentTextColor     // 图标颜色跟随文字颜色
        verticalPadding: 0
        horizontalPadding: 0
        contentDescription: "Add"

        // 仅在 iconType 为 AddLable 时显示
        visible: control.iconType === VmsEnum.LableTypeEnum.AddLable

        // 点击时发送添加命令
        onClicked:{
            control.commit(1, "Add")
        }
    }

    // ==================== 标签文字 ====================

    FluText{
        id: com_Lable
        anchors{
            // 根据图标类型调整左侧锚点
            left: control.iconType === VmsEnum.LableTypeEnum.AddLable ? com_AddBtn.right : parent.left
            leftMargin: ScreenTools.scaleNum(5)
            // 根据图标类型调整右侧锚点
            right: control.iconType !== VmsEnum.LableTypeEnum.CloseLable ? parent.right : com_CloseBtn.left
            rightMargin: ScreenTools.scaleNum(5)
        }
        wrapMode: textWrap           // 不换行
        elide: control.elide         // 文字省略
        height: parent.height
        text: control.text
        font.family: ScreenTools.fontFamily   // 使用 ScreenTools 定义的字体
        font.pointSize: fontSize
        font.bold: isBold
        textColor: control.currentTextColor   // 使用动态计算的文字颜色
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: alignValue
        lineHeight: ScreenTools.scaleNum(1.2)                       // 行高
        lineHeightMode: Text.ProportionalHeight
    }

    // ==================== 关闭按钮 ====================

    FluIconButton{
        id: com_CloseBtn
        anchors{
            right: parent.right
            rightMargin: ScreenTools.scaleNum(5)
            verticalCenter: parent.verticalCenter
        }
        width: parent.height / 2
        height: parent.height / 2

        iconSource: FluentIcons.Cancel  // 关闭图标
        iconSize: ScreenTools.scaleNum(12)
        iconColor: currentTextColor
        verticalPadding: 0
        horizontalPadding: 0
        contentDescription: "Close"

        // 仅在 iconType 为 CloseLable 时显示
        visible: control.iconType === VmsEnum.LableTypeEnum.CloseLable

        // 点击时发送关闭/删除命令
        onClicked:{
            if(!control.readOnly){
                control.commit(2, control.text)   // 发送删除命令
            }
            control.commit(0, "Close")            // 发送关闭命令
        }
    }

    // ==================== 阴影效果 ====================

    FluShadow {
        radius: ScreenTools.scaleNum(4)
        color: currentBorderColor
        visible: shadowVisible          // 根据 shadowVisible 控制显示
    }
}
