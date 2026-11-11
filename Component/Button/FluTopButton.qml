import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0

FluIconButton{
    id: control
    iconSize: ScreenTools.scaleNum(30)
    padding: 0
    verticalPadding: 0
    horizontalPadding: 0
    rightPadding: 0
    iconSource: FluentIcons.ArrowUp8

    // 属性定义
    property var targetFlickable: parent  // 目标可滚动组件（Flickable/ListView等）
    property real scrollThresholdFactor: 2.0   // 滚动阈值因子（默认为组件高度的2倍）
    
    // 定位属性
    property real rightMargin: ScreenTools.scaleNum(20)
    property real bottomMargin: ScreenTools.scaleNum(20)

    anchors.right: targetFlickable.right
    anchors.rightMargin: rightMargin
    anchors.bottom: targetFlickable.bottom
    anchors.bottomMargin: bottomMargin

    
    // 提示文本
    text: qsTr("Back to top")
    
    // 可见性：当滚动超过阈值时显示
    visible: targetFlickable && targetFlickable.contentY > targetFlickable.height * scrollThresholdFactor
    
    // 进入动画
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
    opacity: visible ? 1 : 0
    
    onClicked: {
        if (targetFlickable) {
            // 使用动画平滑滚动到顶部
            scrollAnimation.to = 0
            scrollAnimation.start()
        }
    }
    
    // 平滑滚动动画
    NumberAnimation {
        id: scrollAnimation
        target: targetFlickable
        property: "contentY"
        duration: 300
        easing.type: Easing.InOutQuad
    }
}
