import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import ScreenTools 1.0

// 时间轴组件 - 支持多种布局模式的步骤进度展示
// 可用于流程引导、时间线、步骤导航等场景
Item{
    // ==================== 属性定义 ====================

    // 布局模式（参考 FluTimelineType 枚举）
    // - Left: 时间轴在左侧，内容在右侧
    // - Right: 时间轴在右侧，内容在左侧
    // - Alternate: 交替布局（奇偶行左右切换）
    property int mode: FluTimelineType.Right

    // 节点图标尺寸
    property real icoSize: ScreenTools.scaleNum(32)

    // 当前选中的步骤索引（-1 表示未选中）
    property real currentSelectStep: -1

    // 数据模型别名（外部可绑定 model）
    property alias model: repeater.model

    // 连接线颜色（根据主题切换）
    property color lineColor: FluTheme.dark ? Qt.rgba(80/255,80/255,80/255,1) : Qt.rgba(210/255,210/255,210/255,1)

    // ==================== 组件配置 ====================

    id: control
    implicitWidth: ScreenTools.scaleNum(380)                  // 默认宽度
    implicitHeight: layout_column.height  // 高度根据内容自适应

    // ==================== 内部数据对象 ====================

    QtObject{
        id: d

        // 是否为左侧布局模式
        property bool isLeft: control.mode === FluTimelineType.Left

        // 是否为右侧布局模式
        property bool isRight: control.mode === FluTimelineType.Right

        // 是否为交替布局模式
        property bool isAlternate: control.mode === FluTimelineType.Alternate

        // 是否包含标签（检查模型中是否有 lable 字段）
        property bool hasLable: {
            if(!model){
                return false
            }
            for(var i = 0; i < model.count; i++){
                var lable = model.get(i).lable
                if(lable !== undefined && lable !== ""){
                    return true
                }
            }
            return false
        }

        // 节点布局状态名称（决定节点位置）
        property string stateName: {
            if(hasLable){
                return "Center"         // 有标签时节点居中
            }
            if(isRight){
                return "Right"          // 右侧模式节点靠右
            }
            if(isAlternate){
                return "Center"         // 交替模式节点居中
            }
            return "Left"               // 默认左侧模式节点靠左
        }
    }

    // ==================== 节点组件模板 ====================

    Component{
        id: com_dot

        // 节点列（包含圆点按钮和连接线）
        Column{
            property int currentIndex: parent.itemIndex   // 当前步骤索引
            spacing: ScreenTools.scaleNum(6)

            // 步骤圆点按钮
            Rectangle{
                id: btn_textRectangle
                width: icoSize
                height: icoSize
                radius: width / 2               // 圆形
                clip: true
                border.width: 1

                // 边框颜色：已选中步骤为蓝色，未选中为灰色
                border.color: currentIndex <= currentSelectStep ? ThemeColorStyle.privacy_text_color : control.lineColor

                // 步骤数字按钮
                FluTextButton{
                    id: btn_text
                    anchors.centerIn: parent
                    clip: true
                    text: currentIndex          // 显示步骤序号
                    textColor: currentIndex <= currentSelectStep ? ThemeColorStyle.privacy_text_color : control.lineColor

                    // 点击时更新选中步骤
                    onClicked: {
                        currentSelectStep = currentIndex
                    }
                }
            }

            // 连接线（垂直线）
            Rectangle{
                id: rect_line
                color: currentIndex <= currentSelectStep ? ThemeColorStyle.privacy_text_color : control.lineColor
                height: btn_textRectangle.height * 3    // 线高度为圆点的 3 倍
                width: 2
                x: btn_textRectangle.width/2 - 1        // 居中对齐
                visible: currentIndex < repeater.count-1  // 最后一个节点不显示连接线
            }
        }
    }

    // ==================== 标签组件模板 ====================

    Component{
        id: com_lable

        FluText{
            property int currentIndex: parent.itemIndex
            height: icoSize
            wrapMode: Text.WordWrap

            // 根据布局模式调整文字对齐
            horizontalAlignment: isRight ? Qt.AlignRight : Qt.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pointSize: ScreenTools.scaleNum(10)
            font.family: ScreenTools.fontFamily

            // 显示模型中的 lable 字段
            text: {
                if(modelData.lable){
                    return modelData.lable
                }
                return ""
            }

            // 文字颜色：已选中步骤为蓝色，未选中为灰色
            color: currentIndex <= currentSelectStep ? ThemeColorStyle.privacy_text_color : control.lineColor
        }
    }

    // ==================== 文本内容组件模板 ====================

    Component{
        id: com_text

        FluText{
            property int currentIndex: parent.itemIndex
            height: icoSize
            wrapMode: Text.WordWrap
            horizontalAlignment: isRight ? Qt.AlignRight : Qt.AlignLeft
            verticalAlignment: Text.AlignVCenter

            // 显示模型中的 text 字段（支持富文本）
            text: modelData.text
            textFormat: Text.RichText
            font.pointSize: ScreenTools.scaleNum(10)
            font.family: ScreenTools.fontFamily

            // 文字颜色：已选中步骤为黑色，未选中为灰色
            color: currentIndex <= currentSelectStep ? ThemeColorStyle.title_text_nor_color : control.lineColor
        }
    }

    // ==================== 主布局容器 ====================

    Column{
        id: layout_column
        spacing: ScreenTools.scaleNum(6)                             // 步骤间距
        width: control.width
        height: repeater.count === 0 ? 1 : childrenRect.height

        // 步骤重复器
        Repeater{
            id: repeater

            // 每个步骤的容器
            Item{
                id: item_layout
                width: layout_column.width
                height: item_loader.height

                // ==================== 节点加载器 ====================

                FluLoader{
                    id: item_loader
                    property int itemIndex: index   // 步骤索引
                    state: d.stateName              // 根据状态决定位置

                    // 位置状态定义
                    states: [
                        State {
                            name: "Left"
                            AnchorChanges {
                                target: item_loader
                                anchors.left: item_layout.left
                            }
                        },
                        State {
                            name: "Right"
                            AnchorChanges {
                                target: item_loader
                                anchors.right: item_layout.right
                            }
                        },
                        State {
                            name: "Center"
                            AnchorChanges {
                                target: item_loader
                                anchors.horizontalCenter: item_layout.horizontalCenter
                            }
                        }
                    ]

                    // 加载节点组件（支持自定义 dot 委托）
                    sourceComponent: {
                        if(model.dot)
                            return model.dot()
                        return com_dot
                    }
                }

                // ==================== 标签加载器 ====================

                FluLoader{
                    property var modelData: control.model.get(index)
                    property bool isRight: state === "Right"
                    property int itemIndex: index
                    id: loader_lable

                    // 根据状态决定标签位置（与节点相反）
                    state: {
                        if(d.isRight){
                            return "Left"
                        }
                        if(d.isAlternate){
                            if(index % 2 === 0){
                                return "Right"
                            } else {
                                return "Left"
                            }
                        }
                        return "Right"
                    }

                    // 加载标签组件（支持自定义 lableDelegate）
                    sourceComponent: {
                        if(!modelData){
                            return undefined
                        }
                        var lableDelegate = model.lableDelegate
                        if(lableDelegate instanceof Function && lableDelegate() instanceof Component){
                            return lableDelegate()
                        }
                        return com_lable
                    }

                    // 标签位置状态定义
                    states: [
                        State {
                            name: "Left"
                            AnchorChanges {
                                target: loader_lable
                                anchors.left: item_loader.right
                                anchors.right: item_layout.right
                            }
                            PropertyChanges {
                                target: loader_lable
                                anchors.leftMargin: ScreenTools.scaleNum(14)
                                anchors.rightMargin: ScreenTools.scaleNum(14)
                            }
                        },
                        State {
                            name: "Right"
                            AnchorChanges {
                                target: loader_lable
                                anchors.right: item_loader.left
                                anchors.left: item_layout.left
                            }
                            PropertyChanges {
                                target: loader_lable
                                anchors.leftMargin: ScreenTools.scaleNum(14)
                                anchors.rightMargin: ScreenTools.scaleNum(14)
                            }
                        },
                        State {
                            name: "Center"
                            AnchorChanges {
                                target: loader_lable
                                anchors.right: item_loader.left
                                anchors.left: item_layout.left
                            }
                            PropertyChanges {
                                target: loader_lable
                                anchors.leftMargin: ScreenTools.scaleNum(14)
                                anchors.rightMargin: ScreenTools.scaleNum(14)
                            }
                        }
                    ]
                }

                // ==================== 文本内容加载器 ====================

                FluLoader{
                    id: loader_text
                    property var modelData: control.model.get(index)
                    property bool isRight: state === "Right"
                    property int itemIndex: index

                    // 根据状态决定文本位置
                    state: {
                        if(d.isRight){
                            return "Right"
                        }
                        if(d.isAlternate){
                            if(index % 2 === 0){
                                return "Left"
                            } else {
                                return "Right"
                            }
                        }
                        return "Left"
                    }

                    // 加载文本组件（支持自定义 textDelegate）
                    sourceComponent: {
                        if(!modelData){
                            return undefined
                        }
                        var textDelegate = model.textDelegate
                        if(textDelegate instanceof Function && textDelegate() instanceof Component){
                            return textDelegate()
                        }
                        return com_text
                    }

                    // 文本位置状态定义
                    states: [
                        State {
                            name: "Left"
                            AnchorChanges {
                                target: loader_text
                                anchors.left: item_loader.right
                                anchors.right: item_layout.right
                            }
                            PropertyChanges {
                                target: loader_text
                                anchors.leftMargin: ScreenTools.scaleNum(14)
                                anchors.rightMargin: ScreenTools.scaleNum(14)
                            }
                        },
                        State {
                            name: "Right"
                            AnchorChanges {
                                target: loader_text
                                anchors.right: item_loader.left
                                anchors.left: item_layout.left
                            }
                            PropertyChanges {
                                target: loader_text
                                anchors.leftMargin: ScreenTools.scaleNum(14)
                                anchors.rightMargin: ScreenTools.scaleNum(14)
                            }
                        },
                        State {
                            name: "Center"
                            AnchorChanges {
                                target: loader_text
                                anchors.right: item_loader.left
                                anchors.left: item_layout.left
                            }
                            PropertyChanges {
                                target: loader_text
                                anchors.leftMargin: ScreenTools.scaleNum(14)
                                anchors.rightMargin: ScreenTools.scaleNum(14)
                            }
                        }
                    ]
                }
            }
        }
    }
}
