// 说明：该组件是一个云台（PTZ）方向控制面板。
// - 组件对外发出 sendCmd(direction) 信号：按下时立即发一次，按住则定时重复发送，松开/取消则发送 -1（停止）
// - 通过 collapseBtnCheck 控制展开/折叠显示方向盘
// - 通过 mirrorMode 控制整体旋转与圆角方向（镜像模式）
// - 通过 Canvas 仅做“圆形命中测试”，确保只有圆形区域可点击（四角点击无效）

import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import ScreenTools 1.0
import VMS.Enum 1.0
import Component.FluButton 1.0
import Component.FluComponent 1.0
import QtGraphicalEffects 1.15

Rectangle {
    // 对外信号：方向命令（0/1/2/3 或枚举值；-1 表示停止）
    signal sendCmd(int direction)
    signal refreshHoverState()

    // ======= 可配置属性 =======
    property int ptzSize: ScreenTools.scaleNum(200)                  // 控件整体尺寸（用于 implicitWidth/Height）
    property int squareSize: ptzSize - ptzSize/4// 内部方向盘正方形边长（小于整体尺寸）
    property int directionType: -1              // 当前方向：-1停止；其余使用 VmsEnum.DirectionTypeEnum.*
    property real fadeAlpha: 0.5                // 按下时背景透明度（用于“按下态”效果）
    property bool upDownBtnEnabled: false       // 上/下按钮是否禁用（注意：代码里是 enabled: !upDownBtnEnabled）
    property bool isPressed: false              // 是否处于按住状态（用于启动/停止连发定时器）
    property bool collapseBtnCheck: false       // 是否展开方向盘（true 展开；false 折叠）
    property bool mirrorMode:false              // 镜像模式：控制整体旋转方向、圆角方向、图标旋转
    property color ptzColor: "#F5F7FA"          // 按钮默认底色
    property color icoColor: "#333333"          // 图标颜色

    function clearHoverState() {
        hoverUp.visible = false
        hoverRight.visible = false
        hoverLeft.visible = false
        hoverDown.visible = false
    }

    // ======= 按住连发逻辑 =======
    // isPressed 变化：按下 -> 启动连发；松开 -> 停止连发并发送“停止”
    onIsPressedChanged:{
        if(isPressed){
            pressTimer.start()
        }
        else{
            pressTimer.stop()
            directionType = -1
            control.sendCmd(directionType);
        }
    }

    // 按住时每 200ms 重复发送当前 directionType（实现“云台持续移动”）
    Timer{
        id:pressTimer
        interval: 200
        repeat: true
        running: false
        onTriggered:{
            control.sendCmd(directionType);
        }
    }

    // ======= 根容器 =======
    id:control
    implicitWidth: ptzSize
    // 展开时高度为 ptzSize；折叠时仅显示顶部区域（用 collapseBtn 的高度）
    implicitHeight: collapseBtnCheck ? ptzSize : titleBar.height
    color: "#FFFFFF"

    Item{
        id:titleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.max(ptzText.implicitHeight, collapseBtn.height) + ScreenTools.scaleNum(12 * 2)

        // 标题文本
        FluText{
            id:ptzText
            objectName: "ptzText"
            anchors.left: parent.left
            anchors.leftMargin: ScreenTools.scaleNum(12)
            anchors.top: parent.top
            anchors.topMargin: ScreenTools.scaleNum(12)
            height: collapseBtn.height
            text: qsTr("PTZ Control")
            verticalAlignment:Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(10,true)
        }

        // 折叠/展开按钮
        FluCustomIconButton{
            id:collapseBtn
            objectName: "collapseBtn"
            // 根据状态切换图标与文本
            display: Button.IconOnly
            iconSource: collapseBtnCheck ? FluentIcons.ChevronDown : FluentIcons.ChevronUp
            anchors.right: parent.right
            anchors.rightMargin: ScreenTools.scaleNum(6)
            anchors.verticalCenter: parent.verticalCenter
            text: !collapseBtnCheck ? qsTr("Expand") : qsTr("Collapse")
            width: ScreenTools.scaleNum(24)
            height: ScreenTools.scaleNum(24)
            iconSize: ScreenTools.scaleNum(16)
            iconOnlyNeedHoverBg: true
            textBtnHoverColor: ThemeColorStyle.privacy_text_color
            onClicked:{
                collapseBtnCheck = !collapseBtnCheck
            }
        }

        MouseArea{
            objectName: "titleBarMa"
            anchors.fill: parent
            z: -1
            onDoubleClicked: {
                // 双击标题栏：展开/折叠方向盘
                collapseBtnCheck = !collapseBtnCheck
            }
        }
    }

    // // 方向盘容器：居中显示，整体旋转 45 度（镜像时 -45 度）以组成菱形视觉效果
    Item {
        id:ptzControl
        anchors.centerIn: parent
        anchors.verticalCenterOffset: ScreenTools.scaleNum(20)
        rotation: mirrorMode ? -45 : 45
        // 仅在展开时显示
        visible: control.collapseBtnCheck

        // ========= 正方形方向盘承载容器 =========
        Item {
            id: squareContainer
            width: control.squareSize
            height: control.squareSize
            anchors.centerIn: parent
            clip: true

            // 圆形遮罩
            FluRectangle {
                color: "#FFFFFF"
                width: control.squareSize / 3
                height: control.squareSize / 3
                anchors.centerIn:parent
                radius: [height/2, height/2, height/2, height/2]
                z:7
            }

            Rectangle {
                id: square
                anchors.centerIn: parent
                width: control.squareSize / 3
                height: control.squareSize / 3
                color: "#FFFFFF"
                radius: height / 2
                opacity: 0.8
                z:10000
            }

            // ========= 命中遮罩（仅用于圆形点击区域判断）=========
            Item {
                id: hitMask
                anchors.fill: parent
                visible: false

                function hit(x, y) {
                    if (x < 0 || y < 0 || x >= width || y >= height) return false
                    
                    // 计算圆心
                    const centerX = width / 2
                    const centerY = height / 2
                    // 计算半径
                    const radius = Math.min(width, height) / 2
                    
                    // 利用勾股定理计算点击点到圆心的距离平方，判断是否在圆内
                    const distanceSquared = Math.pow(x - centerX, 2) + Math.pow(y - centerY, 2)
                    return distanceSquared <= Math.pow(radius, 2)
                }
            }

            // ========= 上按钮（画面左上象限，旋转后视觉为“上”）=========
            FluRectangle {
                id: btn_up
                color: control.ptzColor
                width: control.squareSize / 2
                height: control.squareSize / 2
                anchors.top: parent.top
                anchors.left: parent.left
                z: (directionType == VmsEnum.DirectionTypeEnum.Up) ? 10 : 1000

                // 通过 radius 数组分别设置四角圆角
                // mirrorMode 时互换圆角位置，保证外轮廓圆滑一致
                radius: [mirrorMode ? 0 : control.squareSize / 2, mirrorMode ? control.squareSize / 2 : 0, 0, 0]

                // 注意：这里写的是 enabled: !upDownBtnEnabled（变量名语义与逻辑相反）
                enabled: !upDownBtnEnabled

                // 按钮图标（根据 rotation 微调方向）
                FluIcon{
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.topMargin: -parent.height/8
                    anchors.leftMargin: -parent.height/8
                    iconSource: FluentIcons.CaretSolidUp
                    iconColor: control.icoColor
                    iconSize: ScreenTools.scaleNum(12)
                    rotation: mirrorMode ? 45 : -45
                    visible: !upDownBtnEnabled
                }

                // 鼠标交互：按下先做圆形命中测试，通过后才触发颜色变化和发送命令
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: (mouse)=> {
                        // 将点击点映射到 squareContainer 坐标系用于 hitMask 判断
                        const p = mapToItem(squareContainer, mouse.x, mouse.y)
                        if (!hitMask.hit(p.x, p.y)) return
                        clearHoverState()
                        // 按下态：降低透明度
                        //btn_up.color = Qt.rgba(control.ptzColor.r, control.ptzColor.g, control.ptzColor.b, fadeAlpha)
                        // 设置方向并立即发送一次
                        directionType = VmsEnum.DirectionTypeEnum.Up
                        hoverUp.visible = true
                        control.sendCmd(directionType);
                        // 开启“按住连发”
                        isPressed = true
                    }
                    onReleased:{
                        // 恢复颜色并停止（会在 onIsPressedChanged 里发送 -1）
                        //btn_up.color = control.ptzColor
                        isPressed = false
                    }
                    onEntered: {
                        const p = mapToItem(squareContainer, mouseX, mouseY)
                        const inMask = hitMask.hit(p.x, p.y)
                        if (!inMask) return
                        clearHoverState()
                        directionType = VmsEnum.DirectionTypeEnum.Up
                        hoverUp.visible = true
                    }
                    onPositionChanged: (mouse)=> {
                        const p = mapToItem(squareContainer, mouse.x, mouse.y)
                        const inMask = hitMask.hit(p.x, p.y)
                        if (inMask) {
                            clearHoverState()
                            directionType = VmsEnum.DirectionTypeEnum.Up
                            hoverUp.visible = true
                        } else {
                            hoverUp.visible = false
                        }
                    }
                    onExited: {
                        hoverUp.visible = false
                    }
                }
            }
            Item {
                id: hoverUp
                anchors.fill: parent
                visible: false
                z: 99
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: hoverUp.width
                        height: hoverUp.height
                        radius: hoverUp.width / 2
                        color: "white"
                        antialiasing: true
                    }
                }

                FluCustomSvg{
                    id: svgUp
                    anchors.fill: parent
                    imageWidth: control.squareSize
                    imageHeight: control.squareSize
                    svgType : VmsEnum.SvgColorTypeEnum.GradientColor
                    sourceImage: CommonImageStyle.ptz_up_img
                    rotation: mirrorMode ? 45 : -45
                    hoverEnabled: false
                    opacity: 0.6

                    fillColorFirst: {
                        if(directionType == -1){
                            return control.ptzColor
                        }
                        if(isPressed && directionType === VmsEnum.DirectionTypeEnum.Up){
                            return ThemeColorStyle.ptz_press_bg_color
                        }
                        return ThemeColorStyle.ptz_hover_bg_color
                    }
                    fillColorSecond:fillColorFirst
                }
            }

            // ========= 右按钮（画面右上象限，旋转后视觉为“右”）=========
            FluRectangle {
                id: btn_right
                color: control.ptzColor
                width: control.squareSize / 2
                height: control.squareSize / 2
                anchors.top: parent.top
                anchors.right: parent.right
                radius: [mirrorMode ? control.squareSize / 2 : 0, mirrorMode ? 0 : control.squareSize / 2, 0, 0]
                z: (directionType == VmsEnum.DirectionTypeEnum.Right) ? 10 : 1000

                FluIcon{
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.topMargin: -parent.height/8
                    anchors.rightMargin: -parent.height/8
                    iconSource: FluentIcons.CaretSolidRight
                    iconColor: control.icoColor
                    iconSize: ScreenTools.scaleNum(12)
                    rotation: mirrorMode ? -135 : -45
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: (mouse)=> {
                        const p = mapToItem(squareContainer, mouse.x, mouse.y)
                        if (!hitMask.hit(p.x, p.y)) return
                        clearHoverState()

                        //btn_right.color = Qt.rgba(control.ptzColor.r, control.ptzColor.g, control.ptzColor.b, fadeAlpha)
                        directionType = VmsEnum.DirectionTypeEnum.Right
                        hoverRight.visible = true
                        control.sendCmd(directionType);
                        isPressed = true
                    }
                    onReleased:{
                        //btn_right.color = control.ptzColor
                        isPressed = false
                    }
                    onEntered: {
                        const p = mapToItem(squareContainer, mouseX, mouseY)
                        const inMask = hitMask.hit(p.x, p.y)
                        if (!inMask) return
                        clearHoverState()
                        directionType = VmsEnum.DirectionTypeEnum.Right
                        hoverRight.visible = true
                    }
                    onPositionChanged: (mouse)=> {
                        const p = mapToItem(squareContainer, mouse.x, mouse.y)
                        const inMask = hitMask.hit(p.x, p.y)
                        if (inMask) {
                            clearHoverState()
                            directionType = VmsEnum.DirectionTypeEnum.Right
                            hoverRight.visible = true
                        } else {
                            hoverRight.visible = false
                        }
                    }
                    onExited: {
                        hoverRight.visible = false
                    }
                }
            }
            Item {
                id: hoverRight
                anchors.fill: parent
                visible: false
                z: 99
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: hoverRight.width
                        height: hoverRight.height
                        radius: hoverRight.width / 2
                        color: "white"
                        antialiasing: true
                    }
                }

                FluCustomSvg{
                    anchors.fill: parent
                    imageWidth: control.squareSize
                    imageHeight: control.squareSize
                    svgType : VmsEnum.SvgColorTypeEnum.GradientColor
                    sourceImage: CommonImageStyle.ptz_right_img
                    rotation: mirrorMode ? -135 : -45
                    hoverEnabled: false
                    opacity: 0.6

                    fillColorFirst: {
                        if(directionType == -1){
                            return control.ptzColor
                        }
                        if(isPressed && directionType === VmsEnum.DirectionTypeEnum.Right){
                            return ThemeColorStyle.ptz_press_bg_color
                        }
                        return ThemeColorStyle.ptz_hover_bg_color
                    }
                    fillColorSecond:fillColorFirst
                }
            }

            // ========= 左按钮（画面左下象限，旋转后视觉为“左”）=========
            FluRectangle {
                id: btn_left
                color: control.ptzColor
                width: control.squareSize / 2
                height: control.squareSize / 2
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                radius: [0, 0, mirrorMode ? control.squareSize / 2 : 0, mirrorMode ? 0 : control.squareSize / 2]
                z: (directionType == VmsEnum.DirectionTypeEnum.Left) ? 10 : 1000

                FluIcon{
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.bottomMargin: -parent.height/8
                    anchors.leftMargin: -parent.height/8
                    iconSource: FluentIcons.CaretSolidLeft
                    iconColor: control.icoColor
                    iconSize: ScreenTools.scaleNum(12)
                    rotation: mirrorMode ? -135 : -45
                }

                // 注意：此处原代码里 MouseArea 嵌套了一个 MouseArea（多余且容易引发事件问题）
                // 这里保持原结构仅做注释说明：建议只保留一个 MouseArea。
                MouseArea{
                    anchors.fill: parent
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onPressed: (mouse)=> {
                            const p = mapToItem(squareContainer, mouse.x, mouse.y)
                            if (!hitMask.hit(p.x, p.y)) return
                            clearHoverState()

                            //btn_left.color = Qt.rgba(control.ptzColor.r, control.ptzColor.g, control.ptzColor.b, fadeAlpha)
                            directionType = VmsEnum.DirectionTypeEnum.Left
                            hoverLeft.visible = true
                            control.sendCmd(directionType);//"#CFECFF" "#59BDFF"
                            isPressed = true
                        }
                        onReleased:{
                            //btn_left.color = control.ptzColor
                            isPressed = false
                        }
                        onEntered: {
                            const p = mapToItem(squareContainer, mouseX, mouseY)
                            const inMask = hitMask.hit(p.x, p.y)
                            if (!inMask) return
                            clearHoverState()
                            directionType = VmsEnum.DirectionTypeEnum.Left
                            hoverLeft.visible = true
                        }
                        onPositionChanged: (mouse)=> {
                            const p = mapToItem(squareContainer, mouse.x, mouse.y)
                            const inMask = hitMask.hit(p.x, p.y)
                            if (inMask) {
                                clearHoverState()
                                directionType = VmsEnum.DirectionTypeEnum.Left
                                hoverLeft.visible = true
                            } else {
                                hoverLeft.visible = false
                            }
                        }
                        onExited: {
                            hoverLeft.visible = false
                        }
                    }
                }
            }
            Item {
                id: hoverLeft
                anchors.fill: parent
                visible: false
                z: 99
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: hoverLeft.width
                        height: hoverLeft.height
                        radius: hoverLeft.width / 2
                        color: "white"
                        antialiasing: true
                    }
                }

                FluCustomSvg{
                    anchors.fill: parent
                    imageWidth: control.squareSize
                    imageHeight: control.squareSize
                    svgType : VmsEnum.SvgColorTypeEnum.GradientColor
                    sourceImage: CommonImageStyle.ptz_left_img
                    rotation: mirrorMode ? -135 : -45
                    hoverEnabled: false
                    opacity: 0.6

                    fillColorFirst: {
                        if(directionType == -1){
                            return control.ptzColor
                        }
                        if(isPressed && directionType === VmsEnum.DirectionTypeEnum.Left){
                            return ThemeColorStyle.ptz_press_bg_color
                        }
                        return ThemeColorStyle.ptz_hover_bg_color
                    }
                    fillColorSecond:fillColorFirst
                }
            }

            // ========= 下按钮（画面右下象限，旋转后视觉为“下”）=========
            FluRectangle {
                id: btn_down
                color: control.ptzColor
                width: control.squareSize / 2
                height: control.squareSize / 2
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                radius: [0, 0, mirrorMode ? 0 : control.squareSize / 2, mirrorMode ? control.squareSize / 2 : 0]
                z: (directionType == VmsEnum.DirectionTypeEnum.Down) ? 10 : 1000

                // 同上：变量名 upDownBtnEnabled 与 enabled: !upDownBtnEnabled 逻辑相反
                enabled: !upDownBtnEnabled

                FluIcon{
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.bottomMargin: -parent.height/8
                    anchors.rightMargin: -parent.height/8
                    iconSource: FluentIcons.CaretSolidDown
                    iconColor: control.icoColor
                    iconSize: ScreenTools.scaleNum(12)
                    rotation: mirrorMode ? 45 : -45
                    visible: !upDownBtnEnabled
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: (mouse)=> {
                        const p = mapToItem(squareContainer, mouse.x, mouse.y)
                        if (!hitMask.hit(p.x, p.y)) return
                        clearHoverState()

                        //btn_down.color = Qt.rgba(control.ptzColor.r, control.ptzColor.g, control.ptzColor.b, fadeAlpha)
                        directionType = VmsEnum.DirectionTypeEnum.Down
                        hoverDown.visible = true
                        control.sendCmd(directionType);
                        isPressed = true
                    }
                    onReleased:{
                        //btn_down.color = control.ptzColor
                        isPressed = false
                    }
                    onEntered: {
                        const p = mapToItem(squareContainer, mouseX, mouseY)
                        const inMask = hitMask.hit(p.x, p.y)
                        if (!inMask) return
                        clearHoverState()
                        directionType = VmsEnum.DirectionTypeEnum.Down
                        hoverDown.visible = true
                    }
                    onPositionChanged: (mouse)=> {
                        const p = mapToItem(squareContainer, mouse.x, mouse.y)
                        const inMask = hitMask.hit(p.x, p.y)
                        if (inMask) {
                            clearHoverState()
                            directionType = VmsEnum.DirectionTypeEnum.Down
                            hoverDown.visible = true
                        } else {
                            hoverDown.visible = false
                        }
                    }
                    onExited: {
                        hoverDown.visible = false
                    }
                }
            }
            Item {
                id: hoverDown
                anchors.fill: parent
                visible: false
                z: 99
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: hoverDown.width
                        height: hoverDown.height
                        radius: hoverDown.width / 2
                        color: "white"
                        antialiasing: true
                    }
                }

                FluCustomSvg{
                    anchors.fill: parent
                    imageWidth: control.squareSize
                    imageHeight: control.squareSize
                    svgType : VmsEnum.SvgColorTypeEnum.GradientColor
                    sourceImage: CommonImageStyle.ptz_down_img
                    rotation: mirrorMode ? 45 : -45
                    hoverEnabled: false
                    opacity: 0.6

                    fillColorFirst: {
                        if(directionType == -1){
                            return control.ptzColor
                        }
                        if(isPressed && directionType === VmsEnum.DirectionTypeEnum.Down){
                            return ThemeColorStyle.ptz_press_bg_color
                        }
                        return ThemeColorStyle.ptz_hover_bg_color
                    }
                    fillColorSecond:fillColorFirst
                }
            }
        }
    }
}
