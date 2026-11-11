import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import Component.Button 1.0 
import Component.Page 1.0
import ScreenTools 1.0
import Component.FluComponent 1.0

Item {
    id: control
    
    property bool isExpend: true
    property var headerModel: [
    ]
    ColumnLayout {
        Rectangle {
            id: content
            width: ScreenTools.scaleNum(300)
            height: ScreenTools.scaleNum(36)
            color: "#ffffff"
            border.width: 1 
            border.color: ThemeColorStyle.privacy_text_color
            radius: ScreenTools.scaleNum(8)
            RowLayout {
                anchors.fill: parent
                spacing: ScreenTools.scaleNum(4)

                Loader {
                    width: content.width - ScreenTools.scaleNum(80)
                    Layout.alignment: Qt.AlignVCenter
                    sourceComponent: com_header  
                }

                FluCustomSvg{
                    imageWidth: ScreenTools.scaleNum(16)
                    imageHeight: ScreenTools.scaleNum(16)
                    Layout.alignment: Qt.AlignVCenter
                    sourceImage: CommonImageStyle.list_arrow_down_img
                    rotation: !isExpend ? 180 : 0
                    fillColorFirst: ThemeColorStyle.border_nor_color
                    onClicked: {
                        isExpend = !isExpend
                    }
                }
                Item {
                    width: ScreenTools.scaleNum(8)
                }
            }
        }

        Component {
            id: com_header
            ListView {
                id: headerView
                anchors.fill: parent
                orientation: ListView.Horizontal
                model: getCheckedLeafNodes(treeView.model.selectionModel())
                spacing: ScreenTools.scaleNum(4)
                header: Item{ width: ScreenTools.scaleNum(4)}
                footer: Item{ width: ScreenTools.scaleNum(40)}

                delegate: FluButton {
                    width: ScreenTools.scaleNum(60)
                    height: ScreenTools.scaleNum(24)
                    font.family: ScreenTools.fontFamily
                    font.pointSize: ScreenTools.scaleNum(10, true)
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.title
                    normalColor: "#F0F2F5"
                    textColor: "#6D7682"
                }

                ScrollBar.horizontal: ScrollBar {
                    id: horizontalScrollBar
                    active: true
                    policy: ScrollBar.AsNeeded // 内容不够长时自动隐藏，够了才显示
                    background: Rectangle {
                        height: ScreenTools.scaleNum(40)
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        radius: ScreenTools.scaleNum(4)
                    }
                    contentItem: Rectangle {
                        implicitWidth: ScreenTools.scaleNum(40) // 滑块最小宽度
                        color: "transparent"
                        radius: ScreenTools.scaleNum(4)
                        opacity: 0.8
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            drag.target: parent
                        }
                    }
                }

                Connections {
                    target: treeView.model
                    onDataChanged:{
                        headerView.model = getCheckedLeafNodes(treeView.model.selectionModel());
                    }
                }
            }
        }
    
        CustomTreeView{
            id: treeView
            visible: isExpend
            width: ScreenTools.scaleNum(300)
            height: ScreenTools.scaleNum(300)
        }
    }

    function getCheckedLeafNodes(nodeList) {
        var result = [];
        var seenIds = new Set(); // 防止 __parent 引用导致的重复

        function traverse(nodes) {
            if (!nodes || !Array.isArray(nodes) || nodes.length === 0) {
                return;
            }

            for (var i = 0; i < nodes.length; i++) {
                var node = nodes[i];

                // 1. 统一获取真实数据对象 (兼容 node.data 结构)
                var realNode = (node.data && typeof node.data === 'object') ? node.data : node;

                // 2. 获取关键属性
                var id = realNode.id || node.id;
                var children = realNode.children || node.children;

                // 兼容 checked 位置 (可能在 node 上，也可能在 realNode 上)
                var isChecked = (node.checked === true) || (realNode.checked === true);

                // 3. 判断是否为叶子节点
                // 条件：children 存在且是数组，且长度为 0
                var isLeaf = Array.isArray(children) && children.length === 0;

                // 4. 核心逻辑：如果是叶子节点 && 已选中 && 未重复
                if (isLeaf && isChecked && id && !seenIds.has(id)) {
                    seenIds.add(id);
                    result.push({
                    id: id,
                    title: realNode.title || node.title || "Untitled",
                    depth: realNode.depth !== undefined ? realNode.depth : (node.depth || 0),
                    parentId: realNode.__parent ? (realNode.__parent.data ? realNode.__parent.data.id : realNode.__parent.id) : null
                    });
                }

                // 5. 递归：如果不是叶子节点，继续深入查找子节点
                // 注意：即使当前节点没选中，也要检查它的孩子，因为孩子可能选中
                if (!isLeaf && Array.isArray(children) && children.length > 0) {
                    traverse(children);
                }

            // 注意：这里不需要遍历 __parent，因为我们是自上而下查找叶子节点
            }
        }

        traverse(nodeList);
        return result;
    }

}
