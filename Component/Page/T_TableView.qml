import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Dialog 2.15
import FluentUI 1.0
import ScreenTools 1.0

FluContentPage{

    id:root
    title: "TableView"
    property int sortType: 0
    property int allCheckState: Qt.Checked
    property string nameKeyword: ""
    signal checkBoxChanged

    onNameKeywordChanged: {
        table_view.filter(function(item){
            if(item.name.includes(nameKeyword)){
                return true
            }
            return false
        })
    }

    Component.onCompleted: {
        loadData(1,1000)
    }

    onCheckBoxChanged: {
        updateAllCheck()
    }

    onSortTypeChanged: {
        table_view.closeEditor()
        if(sortType === 0){
            table_view.sort()
        }else if(sortType === 1){
            table_view.sort(
                        (l, r) =>{
                            var lage = Number(l.age)
                            var rage = Number(r.age)
                            if(lage === rage){
                                return l._key>r._key
                            }
                            return lage>rage
                        });
        }else if(sortType === 2){
            table_view.sort(
                        (l, r) => {
                            var lage = Number(l.age)
                            var rage = Number(r.age)
                            if(lage === rage){
                                return l._key>r._key
                            }
                            return lage<rage
                        });
        }
    }

    FluCustomTipDialog{
        id:custom_update_dialog
        property var text
        property var onAccpetListener
        title: "Modify the column name"
        negativeText: qsTr("Cancel")
        contentDelegate: Component{
            Item{
                implicitWidth: parent.width
                implicitHeight: ScreenTools.scaleNum(60)
                FluTextBox{
                    id:textbox_text
                    anchors.centerIn: parent
                    onTextChanged: {
                        custom_update_dialog.text = textbox_text.text
                    }
                }
                Component.onCompleted: {
                    textbox_text.text = custom_update_dialog.text
                    textbox_text.forceActiveFocus()
                }
            }
        }
        positiveText: qsTr("OK")
        onPositiveClicked:{
            if(custom_update_dialog.onAccpetListener){
                custom_update_dialog.onAccpetListener(custom_update_dialog.text)
            }
        }
        function showDialog(text,listener){
            custom_update_dialog.text = text
            custom_update_dialog.onAccpetListener = listener
            custom_update_dialog.open()
        }
    }

    FluMenu{
        id:pop_filter
        width: ScreenTools.scaleNum(200)
        height: ScreenTools.scaleNum(90)

        contentItem: Item{

            onVisibleChanged: {
                if(visible){
                    name_filter_text.text = root.nameKeyword
                    name_filter_text.cursorPosition = name_filter_text.text.length
                    name_filter_text.forceActiveFocus()
                }
            }

            FluTextBox{
                id:name_filter_text
                anchors{
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: ScreenTools.scaleNum(10)
                    rightMargin: ScreenTools.scaleNum(10)
                    topMargin: ScreenTools.scaleNum(10)
                }
                iconSource: FluentIcons.Search
            }

            FluButton{
                text: qsTr("Search")
                anchors{
                    bottom: parent.bottom
                    right: parent.right
                    bottomMargin: ScreenTools.scaleNum(10)
                    rightMargin: ScreenTools.scaleNum(10)
                }
                onClicked: {
                    root.nameKeyword = name_filter_text.text
                    pop_filter.close()
                }
            }

        }

        function showPopup(){
            table_view.closeEditor()
            pop_filter.popup()
        }

    }

    Component{
        id:com_checbox
        Item{
            FluCheckBox{
                anchors.centerIn: parent
                checked: true === options.checked
                animationEnabled: false
                clickListener: function(){
                    var obj = table_view.getRow(row)
                    obj.checkbox = table_view.customItem(com_checbox,{checked})
                    table_view.setRow(row,obj)
                    root.checkBoxChanged()
                }
            }
        }
    }

    Component{
        id:com_column_filter_name
        Item{
            FluText{
                text: "Name"
                anchors.centerIn: parent
                font.pointSize: ScreenTools.scaleNum(10)
                font.family: ScreenTools.fontFamily
            }
            FluIconButton{
                width: ScreenTools.scaleNum(20)
                height: ScreenTools.scaleNum(20)
                iconSize: ScreenTools.scaleNum(12)
                verticalPadding:0
                horizontalPadding:0
                iconSource: FluentIcons.Filter
                iconColor: {
                    if("" !== root.nameKeyword){
                        return FluTheme.primaryColor
                    }
                    return FluTheme.dark ?  Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
                }
                anchors{
                    right: parent.right
                    rightMargin: ScreenTools.scaleNum(4)
                    verticalCenter: parent.verticalCenter
                }
                onClicked: {
                    pop_filter.showPopup()
                }
            }
        }
    }

    Component{
        id:com_action
        Item{
            RowLayout{
                anchors.centerIn: parent
                FluFilledButton{
                    text: qsTr("Edit")
                    onClicked: {
                        var obj = table_view.getRow(row)
                        obj.name = "12345"
                        table_view.setRow(row,obj)
                        showSuccess(JSON.stringify(obj))
                    }
                }

                FluButton{
                    text: qsTr("Delete")
                    onClicked: {
                        table_view.closeEditor()
                        table_view.removeRow(row)
                    }
                }

                FluFilledButton{
                    text: "preView"
                    onClicked: {
                        var obj = table_view.getRow(row)
                        obj.name = "12345"
                        table_view.setRow(row,obj)
                        showSuccess(JSON.stringify(obj))
                    }
                }

                FluToggleSwitch{
                    text:"Text"
                }
            }
        }
    }


    Component{
        id:com_column_checbox
        Item{
            RowLayout{
                anchors.centerIn: parent
                FluText{
                    text: qsTr("All")
                    Layout.alignment: Qt.AlignVCenter
                    font.pointSize: ScreenTools.scaleNum(10)
                    font.family: ScreenTools.fontFamily
                }
                FluCheckBox {
                    Layout.alignment: Qt.AlignVCenter
                    checkState: root.allCheckState
                    animationEnabled: false
                    clickListener: function () {
                        root.allCheckState = checkState
                        for (let i = 0; i < table_view.rows; i++) {
                            const rowData = table_view.getRow(i)
                            rowData.checkbox = table_view.customItem(com_checbox, {"checked": checkState === Qt.Checked})
                            table_view.setRow(i, rowData)
                        }
                    }
                }
            }
        }
    }

    Component{
        id:com_combobox
        FluComboBox {
            anchors.fill: parent
            focus: true
            editText: display
            editable: true
            model: ListModel {
                ListElement { text: "100" }
                ListElement { text: "300" }
                ListElement { text: "500" }
                ListElement { text: "1000" }
            }
            Component.onCompleted: {
                currentIndex=["100","300","500","1000"].findIndex((element) => element === display)
                textBox.forceActiveFocus()
                textBox.selectAll()
            }
            onCommit: {
                editTextChaged(editText)
                tableView.closeEditor()
            }
        }
    }

    Component{
        id:com_auto_suggestbox
        FluAutoSuggestBox {
            id: textbox
            anchors.fill: parent
            focus: true
            Component.onCompleted: {
                var data = ["傲来国界花果山水帘洞","傲来国界坎源山脏水洞","大唐国界黑风山黑风洞","大唐国界黄风岭黄风洞","大唐国界骷髅山白骨洞","宝象国界碗子山波月洞","宝象国界平顶山莲花洞","宝象国界压龙山压龙洞","乌鸡国界号山枯松涧火云洞","乌鸡国界衡阳峪黑水河河神府"]
                var result = data.map(function(item) {
                    return {title: item};
                });
                items = result
                textbox.text= String(display)
                forceActiveFocus()
                selectAll()
            }
            onCommit: {
                editTextChaged(textbox.text)
                tableView.closeEditor()
            }
        }
    }

    Component{
        id:com_avatar
        Item{
            FluClip{
                anchors.centerIn: parent
                width: ScreenTools.scaleNum(40)
                height: ScreenTools.scaleNum(40)
                radius: [ScreenTools.scaleNum(20),ScreenTools.scaleNum(20),ScreenTools.scaleNum(20),ScreenTools.scaleNum(20)]
                Image{
                    anchors.fill: parent
                    source: options && options.avatar ? options.avatar : ""
                    sourceSize: Qt.size(80,80)
                }
            }
        }
    }

    Component{
        id:com_column_update_title
        Item{
            FluText{
                id:text_title
                text: {
                    if(options.title){
                        return options.title
                    }
                    return ""
                }
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                elide: Text.ElideRight
                font.pointSize: ScreenTools.scaleNum(10)
                font.family: ScreenTools.fontFamily
            }
            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    custom_update_dialog.showDialog(options.title,function(text){
                        var columnModel = model.display
                        columnModel.title = table_view.customItem(com_column_update_title,{"title":text})
                        model.display = columnModel
                    })
                }
            }
        }
    }

    Component{
        id:com_column_sort_age
        Item{
            FluText{
                text: "Age"
                anchors.centerIn: parent
                font.pointSize: ScreenTools.scaleNum(10)
                font.family: ScreenTools.fontFamily
            }
            ColumnLayout{
                spacing: 0
                anchors{
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: ScreenTools.scaleNum(4)
                }
                FluIconButton{
                    Layout.preferredWidth: ScreenTools.scaleNum(20)
                    Layout.preferredHeight: ScreenTools.scaleNum(15)
                    iconSize: ScreenTools.scaleNum(12)
                    verticalPadding:0
                    horizontalPadding:0
                    iconSource: FluentIcons.ChevronUp
                    iconColor: {
                        if(1 === root.sortType){
                            return FluTheme.primaryColor
                        }
                        return FluTheme.dark ?  Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
                    }
                    onClicked: {
                        if(root.sortType === 1){
                            root.sortType = 0
                            return
                        }
                        root.sortType = 1
                    }
                }
                FluIconButton{
                    Layout.preferredWidth: ScreenTools.scaleNum(20)
                    Layout.preferredHeight: ScreenTools.scaleNum(15)
                    iconSize: ScreenTools.scaleNum(12)
                    verticalPadding:0
                    horizontalPadding:0
                    iconSource: FluentIcons.ChevronDown
                    iconColor: {
                        if(2 === root.sortType){
                            return FluTheme.primaryColor
                        }
                        return FluTheme.dark ?  Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
                    }
                    onClicked: {
                        if(root.sortType === 2){
                            root.sortType = 0
                            return
                        }
                        root.sortType = 2
                    }
                }
            }
        }
    }

    FluFrame{
        id:layout_controls
        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: ScreenTools.scaleNum(20)
        }
        height: ScreenTools.scaleNum(60)

        Row{
            spacing: ScreenTools.scaleNum(6)
            anchors{
                left: parent.left
                leftMargin: ScreenTools.scaleNum(10)
                verticalCenter: parent.verticalCenter
            }

            FluButton{
                text: "Clear All"
                onClicked: {
                    table_view.dataSource = []
                }
            }

            FluButton{
                text: "Delete Selection"
                onClicked: {
                    var data = []
                    var rows = []
                    for (var i = 0; i < table_view.rows; i++) {
                        var item = table_view.getRow(i)
                        rows.push(item)
                        if (!item.checkbox.options.checked) {
                            data.push(item);
                        }
                    }
                    var sourceModel = table_view.sourceModel
                    for (i = 0; i < sourceModel.rowCount; i++) {
                        var sourceItem = sourceModel.getRow(i)
                        const foundItem = rows.find(item=> item._key === sourceItem._key)
                        if (!foundItem) {
                            data.push(sourceItem);
                        }
                    }
                    table_view.dataSource = data
                }
            }
            FluButton{
                text: "Add a row of Data"
                onClicked: {
                    table_view.appendRow(genTestObject())
                }
            }
            FluButton{
                text: "Insert a Row"
                onClicked: {
                    var index = table_view.currentIndex()
                    if(index !== -1){
                        var testObj = genTestObject()
                        table_view.insertRow(index,testObj)
                    }else{
                        showWarning("Focus not acquired: Please click any item in the form as the target for insertion!")
                    }
                }
            }
        }
    }

    FluTableView{
        id:table_view
        anchors{
            left: parent.left
            right: parent.right
            top: layout_controls.bottom
            bottom: gagination.top
        }
        anchors.topMargin: ScreenTools.scaleNum(6)
        onRowsChanged: {
            root.checkBoxChanged()
        }
        startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
        columnSource:[
            {
                title: table_view.customItem(com_column_checbox,{checked:true}),
                dataIndex: 'checkbox',
                frozen: true //固定表头
            },
            {
                title: table_view.customItem(com_column_checbox,{checked:true}),
                dataIndex: 'checkbox',
                frozen: true
            },
            {
                title: table_view.customItem(com_column_filter_name,{title:"Name"}),
                dataIndex: 'name',
                readOnly:true
            },
            {
                title: table_view.customItem(com_column_update_title,{title:"Avatar"}),
                dataIndex: 'avatar',
                width: ScreenTools.scaleNum(100),
                frozen:true
            },
            {
                title: table_view.customItem(com_column_sort_age,{sort:0}),
                dataIndex: 'age',
                editDelegate:com_combobox,
                width: ScreenTools.scaleNum(100),
                minimumWidth: ScreenTools.scaleNum(100),
                maximumWidth: ScreenTools.scaleNum(100)
            },
            {
                title: "Address",
                dataIndex: 'address',
                editDelegate: com_auto_suggestbox,
                width: ScreenTools.scaleNum(200),
                minimumWidth: ScreenTools.scaleNum(100),
                maximumWidth:ScreenTools.scaleNum(250)
            },
            {
                title: "Nickname",
                dataIndex: 'nickname',
                width: ScreenTools.scaleNum(100),
                minimumWidth: ScreenTools.scaleNum(80),
                maximumWidth: ScreenTools.scaleNum(200)
            },
            {
                title: "Long String",
                dataIndex: 'longstring',
                width: ScreenTools.scaleNum(200),
                minimumWidth:ScreenTools.scaleNum(100),
                maximumWidth: ScreenTools.scaleNum(300),
                editMultiline: true
            },
            {
                title: "Options",
                dataIndex: 'action',
                width:ScreenTools.scaleNum(260),
                frozen:true
            }
        ]
    }

    FluPagination{
        id:gagination
        anchors{
            bottom: parent.bottom
            left: parent.left
        }
        pageCurrent: 1
        itemCount: 100000
        pageButtonCount: 7
        __itemPerPage: 1000
        previousText: "<Previous"
        nextText: "Next>"
        onRequestPage:
            (page,count)=> {
                table_view.closeEditor()
                loadData(page,count)
                table_view.resetPosition()
            }
    }

    function genTestObject(){
        var ages = ["100", "300", "500", "1000"];
        function getRandomAge() {
            var randomIndex = Math.floor(Math.random() * ages.length);
            return ages[randomIndex];
        }
        var names = ["孙悟空", "猪八戒", "沙和尚", "唐僧","白骨夫人","金角大王","熊山君","黄风怪","银角大王"];
        function getRandomName(){
            var randomIndex = Math.floor(Math.random() * names.length);
            return names[randomIndex];
        }
        var nicknames = ["复海大圣","混天大圣","移山大圣","通风大圣","驱神大圣","齐天大圣","平天大圣"]
        function getRandomNickname(){
            var randomIndex = Math.floor(Math.random() * nicknames.length);
            return nicknames[randomIndex];
        }
        var addresses = ["傲来国界花果山水帘洞","傲来国界坎源山脏水洞","大唐国界黑风山黑风洞","大唐国界黄风岭黄风洞","大唐国界骷髅山白骨洞","宝象国界碗子山波月洞","宝象国界平顶山莲花洞","宝象国界压龙山压龙洞","乌鸡国界号山枯松涧火云洞","乌鸡国界衡阳峪黑水河河神府"]
        function getRandomAddresses(){
            var randomIndex = Math.floor(Math.random() * addresses.length);
            return addresses[randomIndex];
        }
        var avatars = ["qrc:/example/res/svg/avatar_1.svg", "qrc:/example/res/svg/avatar_2.svg", "qrc:/example/res/svg/avatar_3.svg", "qrc:/example/res/svg/avatar_4.svg","qrc:/example/res/svg/avatar_5.svg","qrc:/example/res/svg/avatar_6.svg","qrc:/example/res/svg/avatar_7.svg","qrc:/example/res/svg/avatar_8.svg","qrc:/example/res/svg/avatar_9.svg","qrc:/example/res/svg/avatar_10.svg","qrc:/example/res/svg/avatar_11.svg","qrc:/example/res/svg/avatar_12.svg"];
        function getAvatar(){
            var randomIndex = Math.floor(Math.random() * avatars.length);
            return avatars[randomIndex];
        }
        return {
            checkbox: table_view.customItem(com_checbox,{checked:true}),
            avatar:table_view.customItem(com_avatar,{avatar:getAvatar()}),
            name: getRandomName(),
            age:getRandomAge(),
            address: getRandomAddresses(),
            nickname: getRandomNickname(),
            longstring:"你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好",
            action: table_view.customItem(com_action),
            _minimumHeight:ScreenTools.scaleNum(50),
            _key:FluTools.uuid()
        }
    }
    function loadData(page,count){
        const dataSource = []
        for(var i=0;i<count;i++){
            dataSource.push(genTestObject())
        }
        table_view.dataSource = dataSource
        gagination.itemCount = dataSource.length
    }
    function updateAllCheck() {
        let checkedCount = 0
        for (let i = 0; i < table_view.rows; i++) {
            if (table_view.getRow(i).checkbox.options.checked) {
                checkedCount += 1
            }
        }
        if (checkedCount > 0 && checkedCount === table_view.rows) {
            root.allCheckState = Qt.Checked
        } else if (checkedCount > 0 && checkedCount < table_view.rows) {
            root.allCheckState = Qt.PartiallyChecked
        } else {
            root.allCheckState = Qt.Unchecked
        }
    }
}
