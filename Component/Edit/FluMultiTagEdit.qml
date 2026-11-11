import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import Component.Edit 1.0
import Component.FluComponent 1.0
import ConfigureManager 1.0

Rectangle {
    id: control
    color: "#FFFFFF"
    property int editHeight: 36
    property int totalHeight: editHeight
    property int itemHeight: 24
    property int itemSpacing: 4
    property int firstLineCount: 0
    width: 366
    height: totalHeight
    property bool isExpand: false
    property bool isMore: false
    property int tagFlowWidth: parent.width
    property var tagModel:[]
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    // 标签数据模型
    // ListModel {
    //     id: tagModel
    //     ListElement { text: "小型标签112312" }
    //     ListElement { text: "小型标签22312312312312" }
    //     ListElement { text: "小型标签3111" }
    //     ListElement { text: "小型标签4" }
    //     ListElement { text: "小型标签53333" }
    //     ListElement { text: "小型标签6" }
    //     ListElement { text: "小型标签7444" }
    //     ListElement { text: "小型标签85555555" }
    //     ListElement { text: "小型标签9" }
    //     ListElement { text: "小型标签1011" }
    // }
    
    // 标签容器
    Rectangle {
        anchors.fill: parent
        height: totalHeight
        color: "white"
        border.color: "#d9d9d9"
        border.width: 1
        radius: 4

        Row {
            anchors{
                fill: parent
                leftMargin: 8
                topMargin: 6
                rightMargin: 0
                bottomMargin: 6
            }
            spacing: itemSpacing
            // 使用Flow实现自动换行
            Flow {
                id: tagFlow
                width: tagFlowWidth
                height: parent.height
                spacing: itemSpacing
                clip: true

                onChildrenChanged: {
                    resetTimer()
                }

                Repeater {
                    id: repeater
                    model: tagModel
                    delegate: FluTagLabel {
                        tagText: model.text
                        tagIndex: index
                        closeVisible: isExpand
                        onDeleteItem: {
                            tagModel.remove(index)
                        } 
                        onLabelClick:{
                            isExpand = !isExpand;
                            resetTimer()
                        }
                    }
                }
            }

            Rectangle {
                id: moreLabel
                visible: isMore && !isExpand && (totalHeight == editHeight)
                //width: 30
                implicitWidth: 30
                height: 24
                radius: 4
                color: "#F0F2F5"
                
                Text {
                    anchors.centerIn: parent
                    text: " +" + (tagModel.count - firstLineCount) + "... "
                    color: ThemeColorStyle.text_nor_color
                    font.pointSize: 10
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        isExpand = !isExpand;
                        resetTimer()
                    }
                }
            }

            Item{
                width: parent.width - tagFlowWidth - moreLabel.width - expandButton.width - itemSpacing * 3
            }

        }
        FluIcon {
            id: expandButton
            width: 24
            height: 24
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.top: parent.top
            anchors.topMargin: 6
            iconSource:FluentIcons.ChevronDown
            iconSize: 14
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("展开按钮点击")
                }
            }
        }
    }

    Component.onCompleted: {
        printAllTagWidths()
    }

    function calculateLines() {
        if (tagFlow.children.length === 0) return
        var lineHeight = itemHeight + itemSpacing // 标签高度 + 间距
        var totalLines = Math.ceil(tagFlow.implicitHeight / lineHeight)
        totalHeight = isExpand ? editHeight + lineHeight * (totalLines - 1) : editHeight
    }

    function reCalcuTagWidth(){
        calculateLines()
        printAllTagWidths()
    }


    function printAllTagWidths() {
        firstLineCount = 0
        isMore = false
        var totalWidth = 0
        for (var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i)
            if(totalWidth + item.width > parent.width - 40)
            {
                firstLineCount = i
                isMore = true
                break;
            }
            else{
                totalWidth += item.width
            }
        }
        tagFlowWidth = isMore ? (totalWidth + firstLineCount * 4) : parent.width - 40
    }

    function resetTimer(){
        tagTimer.stop()
        tagTimer.running = true
    }

    Timer {
        id: tagTimer
        interval:50
        repeat:false
        running: false
        onTriggered: {
            reCalcuTagWidth()
            running: false
            tagTimer.stop()
        }
    }
}

