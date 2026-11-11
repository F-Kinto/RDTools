import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import FluentUI 1.0
import ScreenTools 1.0
import VMS.Enum 1.0

// 文件上传组件 - 包含上传按钮和上传列表弹窗
// 支持文件上传状态展示、进度显示、批量更新等功能
Item {
    id: control

    // ==================== 信号定义 ====================

    // 上传文件信号，外部连接此信号处理上传逻辑
    signal sendUploadFile()

    // ==================== 属性定义 ====================

    // 提示信息文本（支持的文件扩展名）
    property string message: qsTr("Supported file extensions")

    // 组件隐式尺寸
    implicitHeight: ScreenTools.scaleNum(32)
    implicitWidth: ScreenTools.scaleNum(340)

    // ==================== 上传按钮 ====================

    FluIconButton{
        id: ico_button
        anchors.left: parent.left
        width: ScreenTools.scaleNum(108)
        height: ScreenTools.scaleNum(32)

        iconSource: FluentIcons.Edit          // 编辑图标
        disabled: false
        iconSize: ScreenTools.scaleNum(14)

        text: qsTr("Upload Files")             // 按钮文本
        display: Button.TextBesideIcon        // 图标和文字并排显示

        // 按钮配色
        color: ThemeColorStyle.okBtn_bg_color                   // 蓝色背景
        textColor: ThemeColorStyle.okBtn_text_color                // 白色文字
        iconColor: ThemeColorStyle.okBtn_text_color               // 白色图标

        // 点击时触发上传信号
        onClicked: {
            control.sendUploadFile()
        }

        // 悬停且列表非空时打开弹窗
        onHoveredChanged:  {
            if(!hovered || !control.count())
                return
            popup.open()
        }
    }

    // ==================== 提示信息文本 ====================

    FluText{
        id: info_Text
        anchors.top: ico_button.bottom
        anchors.topMargin: ScreenTools.scaleNum(4)
        font.pointSize: ScreenTools.scaleNum(10)
        font.family: ScreenTools.fontFamily
        wrapMode: Text.NoWrap                 // 不换行
        text: control.message + ":.rar .zip .doc .docx .pdf .jpg..."
        textColor: ThemeColorStyle.text_nor_color                // 灰色文字
    }

    // ==================== 数据模型 ====================

    ListModel {
        id: com_listModel

        // 节点例子（注释参考）
        // ListElement{
        //     name: "图片 1"                          // 文件名
        //     path: "qrc:/app/image/app/windowIcon.png" // 文件路径
        //     info: "35"                              // 文件信息（如大小）
        //     status: VmsEnum.StatusEnum.Ready        // 上传状态
        //     progress: 30                            // 上传进度 (0-100)
        // }
    }

    // ==================== 上传列表弹窗 ====================

    FluPopup{
        id: popup
        width: ScreenTools.scaleNum(350)
        height: ScreenTools.scaleNum(250)
        modal: false                              // 非模态弹窗
        visible: false
        focus: false
        clip: true                                // 裁剪超出内容
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside  // ESC 或点击外部关闭
        parent: control
        x: 0
        // 弹窗位置：按钮 + 提示文本下方
        y: parent ? (ico_button.height + info_Text.height + ScreenTools.scaleNum(10)) : 0

        // 文件列表视图
        ListView {
            id: com_listView
            anchors.fill: parent
            spacing: ScreenTools.scaleNum(4)                           // 列表项间距
            model: com_listModel

            // 列表项委托
            delegate: Rectangle {
                width: popup.width
                height: ScreenTools.scaleNum(60)

                // 根据状态设置背景色
                color: VmsEnum.StatusEnum.Failed === model.status ? "#FFFFF2F0" : "#FFFAFAFD"

                RowLayout{
                    anchors.fill: parent

                    // 左侧：文件信息区域
                    Item{
                        Layout.fillHeight: true
                        RowLayout{
                            anchors{
                                left: parent.left
                                leftMargin: ScreenTools.scaleNum(6)
                                verticalCenter: parent.verticalCenter
                            }

                            // 文件缩略图
                            FluImage{
                                height: parent.height * 0.6
                                width: parent.height * 0.6
                                source: model.path
                                fillMode: Image.PreserveAspectCrop
                            }

                            // 文件名称和信息
                            ColumnLayout{
                                spacing: 0
                                FluText{
                                    text: model.name
                                    textColor: ThemeColorStyle.title_text_nor_color         // 深色文字
                                    font.pointSize: ScreenTools.scaleNum(10)
                                    font.family: ScreenTools.fontFamily
                                }
                                FluText{
                                    text: model.info
                                    textColor: ThemeColorStyle.text_nor_color          // 灰色文字
                                    font.pointSize: ScreenTools.scaleNum(10)
                                    font.family: ScreenTools.fontFamily
                                }
                            }
                        }
                    }

                    // 右侧：状态按钮
                    FluIconButton{
                        Layout.preferredHeight: ScreenTools.scaleNum(16)
                        Layout.preferredWidth: ScreenTools.scaleNum(16)
                        Layout.rightMargin: ScreenTools.scaleNum(6)
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        radius: width/2                             // 圆形按钮
                        verticalPadding: 0
                        horizontalPadding: 0

                        // 根据状态显示不同图标
                        iconSource: {
                            if(VmsEnum.StatusEnum.Success === model.status){
                                return FluentIcons.Accept           // 成功显示对勾
                            }
                            return FluentIcons.Cancel               // 失败显示取消
                        }

                        disabled: false
                        iconSize: ScreenTools.scaleNum(10)
                        display: Button.IconOnly

                        // 根据状态设置按钮颜色
                        color: {
                            if(VmsEnum.StatusEnum.Failed === model.status){
                                return "#FFFF4A4A"                  // 失败红色
                            }
                            else if(VmsEnum.StatusEnum.Success === model.status){
                                return ThemeColorStyle.okBtn_bg_color                  // 成功蓝色
                            }
                            return "#FFCAD2DD"                      // 其他灰色
                        }
                        iconColor: "#FFFFFFFF"

                        onClicked: {
                            // 点击处理（可扩展删除/重试等功能）
                        }
                    }
                }

                // 上传进度条（仅 Ready 状态显示）
                FluProgressBar{
                    anchors.bottom: parent.bottom
                    width: parent.width
                    strokeWidth: 2
                    duration: 100
                    value: model.progress/100                       // 进度值 (0-1)
                    indeterminate: false
                    color: "#FF00BA00"                              // 绿色进度条
                    visible: model.status === VmsEnum.StatusEnum.Ready
                }
            }
        }
    }

    // ==================== 数据管理函数 ====================

    // 根据文件名查找列表索引
    // @param targetName 目标文件名
    // @return 找到返回索引，未找到返回 -1
    function findListIndexByName(targetName){
        for(var i = 0; i < com_listModel.count; i++){
            if(com_listModel.get(i).name === targetName){
                return i;
            }
        }
        return -1;
    }

    // 根据文件名更新列表项
    // @param targetName 目标文件名
    // @param updateData 要更新的数据对象 {key: value, ...}
    // @return 更新成功返回 true，未找到返回 false
    function updateItemByName(targetName, updateData) {
        var itemIndex = findListIndexByName(targetName);
        if (itemIndex === -1) {
            return false;
        }
        for (var key in updateData) {
            com_listModel.setProperty(itemIndex, key, updateData[key]);
        }
        return true;
    }

    // 批量更新列表项
    // @param updateList 更新数据数组 [{name: "...", ...}, ...]
    function batchUpdateItems(updateList) {
        if (!Array.isArray(updateList) || updateList.length === 0) return;
        updateList.forEach(function(item) {
            if (!item.name) return;
            updateItemByName(item.name, item);
        });
    }

    // 创建列表项数据对象
    // @param name 文件名
    // @param path 文件路径
    // @param info 文件信息
    // @param progress 上传进度
    // @param status 上传状态
    // @return 数据对象
    function createItem(name, path, info, progress, status){
        return {name: name, path: path, info: info, progress: progress, status: status}
    }

    // 追加列表项（同名文件不重复添加）
    // @param name 文件名
    // @param path 文件路径
    // @param info 文件信息
    // @param progress 上传进度
    // @param status 上传状态
    function appendItem(name, path, info, progress, status){
        if(!name || !info)
            return;
        var existIndex = findListIndexByName(name);
        if(existIndex !== -1){
            // 已存在则选中该项
            com_listView.currentIndex = existIndex;
            return;
        }
        com_listModel.append(createItem(name, path, info, progress, status))
        var newItemIndex = com_listModel.count - 1
        com_listView.currentIndex = newItemIndex
        if(newItemIndex >= 0){
            com_listView.currentIndex = newItemIndex;
        }
    }

    // 设置整个列表（清空后批量添加）
    // @param list 数据数组
    function setItemList(list){
        com_listModel.clear()
        if(Array.isArray(list) && list.length > 0){
            com_listModel.append(list)
            com_listView.currentIndex = com_listModel.count - 1;
        } else {
            com_listView.currentIndex = -1;
        }
    }

    // 清空列表
    function clear(){
        com_listModel.clear()
        com_listView.currentIndex = -1;
    }

    // 获取列表项数量
    // @return 列表项数量
    function count(){
        return com_listView.count
    }
}
