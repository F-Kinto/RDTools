import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import ScreenTools 1.0
import ConfigureManager 1.0
import Component.FluComponent 1.0

FluTextBox{
    id:control
    // 是否能编辑
    property bool editAble: false

    // 文本颜色
    property color normalColor: ThemeColorStyle.text_nor_color
    property color disableColor: ThemeColorStyle.text_disable_color

    // 无焦点边框颜色 - 有焦点边框颜色
    property color borderNormalColor : ThemeColorStyle.border_nor_color
    property color borderTypingColor : ThemeColorStyle.border_checked_color
    property color borderColor : borderNormalColor
    property color backgroundColor: "transparent"

    // 宽高以及圆角边框属性
    property int  borderRadius: ScreenTools.scaleNum(4)
    property int  borderWidth: 1
    property int itemWidth: ScreenTools.scaleNum(240)
    property int itemHeight: ScreenTools.scaleNum(36)

    property int fontSize: ScreenTools.scaleNum(10, true)

    // 下拉框最大显示数量
    property int listMaxCount: 8
    property string currentText: ""
    property int curIndex: 0
    onCurIndexChanged: {
        if (control.model && curIndex >= 0 && curIndex < control.model.count) {
            var text = control.model.get(curIndex).text
            control.currentText = text
            control.text = text
        }
    }

    padding:ScreenTools.scaleNum(8)
    leftPadding: padding+ScreenTools.scaleNum(4)
    rightPadding: {
        var w = ScreenTools.scaleNum(30)
        if(control.cleanEnabled === false){
            w = 0
        }
        if(control.readOnly)
            w = 0
        return w+ScreenTools.scaleNum(10)
    }

    // 镜像
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    width: editWidth
    height: editHeight
    enabled: editAble
    cleanEnabled: false
    font.family: "Microsoft YaHei UI"
    font.pointSize: fontSize
    property int alginValue: 1   // 1:左对齐 2:居中 3:右对齐
    horizontalAlignment: alginValue === 1 ? TextInput.AlignLeft : alginValue === 2 ? TextInput.AlignHCenter : TextInput.AlignRight

    property string emptyText: qsTr("No matching content")
    property int autoSuggestBoxReplacement: FluentIcons.Search
    property bool showSuggestWhenPressed: false
    property var model:[]
    property var items:model


    signal itemClicked(string selectText, int index)
    background: Rectangle {
        implicitWidth: control.width
        implicitHeight: control.itemHeight
        color: "transparent"
        border.width: 0
        radius: borderRadius
        border.color: borderColor
    }
    Component.onCompleted: {
        list_view.model = control.model
    }

    onActiveFocusChanged: {
        if(!activeFocus){
            control_popup.visible = false
        }
    }

    Popup{
        id:control_popup
        focus: false
        width: parent.width < itemWidth ? parent.width + ScreenTools.scaleNum(30) : itemWidth
        height: Math.min(list_view.model.count * itemHeight, itemHeight * listMaxCount) + ScreenTools.scaleNum(6)
        x: -ScreenTools.scaleNum(6)
        y: itemHeight + ScreenTools.scaleNum(4)
        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from:0
                to:1
                duration: FluTheme.animationEnabled ? 83 : 0
            }
        }
        contentItem:ListView{
            id: list_view
            anchors{
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: ScreenTools.scaleNum(2)
                bottomMargin: ScreenTools.scaleNum(2)
                leftMargin: ScreenTools.scaleNum(2)
                rightMargin: ScreenTools.scaleNum(2)
            }
            clip: true
            property ListModel myModel: ListModel {}  // 自定义属性保存模型
            model: myModel
            boundsBehavior: ListView.StopAtBounds
            ScrollBar.vertical: FluCustomScrollBar {}
            delegate: FluDelegateItem {
                id: delegateItem
                objectName: "p_delegateItem_" + index
                isChecked: control.currentText == modelData
                text: modelData
                palette.text: control.palette.text
                alignType: alginValue === 1 ? Text.AlignLeft : alginValue === 2 ? Text.AlignHCenter : Text.AlignRight
                fontSize: control.fontSize
                hoverEnabled: control.hoverEnabled
                itemWidth: parent.width
                itemHeight: control.itemHeight
                onClicked:{
                    handleClick(text)
                    control_popup.visible = false
                }
            }
            Component.onCompleted: {
                if(list_view.model && curIndex >= 0 && curIndex < list_view.model.count){
                    var item = list_view.model.get(curIndex)
                    if(item !== undefined && item !== null){
                        handleClick(item.text)
                    }
                }
            }
        }

        background: Rectangle {
            id: rect_background
            implicitWidth: control.width
            height: control_popup.height
            color: backgroundColor
            border.width: 0
            radius: borderRadius
            border.color: ThemeColorStyle.border_nor_color
            FluShadow{
                radius: borderRadius
            }
        }
    }
    onTextChanged: {
        if(!editAble)
            return
        control.showSuggest()
        console.log(control.text)
    }
    onPressed: {
        if(control.showSuggestWhenPressed){
            control.showSuggest()
        }
    }
    function showSuggest(){
        if(control.text===""){
            list_view.model = control.model
        }
        else{
            filterModel(control.text)
        }
        control_popup.visible = true
    }
    function updateText(text){
        control.text = text
    }

    function showList(){
        control_popup.visible = !control_popup.visible
    }

    function listIsShow(isShow){
        return control_popup.visible
    }

    // 更新当前显示的文本（用于语言切换时强制刷新）
    function updateCurrentText(){
        if(control.model && control.curIndex >= 0 && control.curIndex < control.model.count){
            var text = control.model.get(control.curIndex).text
            control.currentText = text
            control.text = text
        }
    }

    function findIndexText(text1){
        for(var i=0;i<control.model.count;i++){
            var item = control.model.get(i)
            if(item.text === text1) {
                return i;
            }
        }
        return -1
    }

    function filterModel(text1){ 
        list_view.myModel.clear();
        for(var i=0;i<control.model.count;i++){
            var item = control.model.get(i)
            if(item.text.toLowerCase().includes(text1.toLowerCase())) {
                list_view.myModel.append({text: item.text});
            }
        }
        if(list_view.myModel.count === 0)
        {
            list_view.myModel.append({text: emptyText});
        }
        list_view.model = list_view.myModel
        list_view.currentIndex = -1
    }

    function handleClick(text){
        if(emptyText === text)
            return
        control.currentText = text
        updateText(control.currentText);
        var index = 0;
        for(var i = 0; i < list_view.model.count; i++){
            if(list_view.model.get(i).text === text){
                index = i;
                break;
            }
        }
        itemClicked(text,index);
        if(editAble && (list_view.myModel.count < control.model.count))
        {
            list_view.model = control.model
            showList()
        }
    }
}
