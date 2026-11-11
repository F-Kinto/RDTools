import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.qmlmodels 1.0
import Component.Edit 1.0
import Component.FluComponent 1.0
import ConfigureManager 1.0
import FluentUI 1.0
import ScreenTools 1.0
import Component.Button 1.0
Rectangle {
    readonly property alias rows: table_view.rows
    readonly property alias columns: table_view.columns
    readonly property alias current: d.current
    property FluTableModel sourceModel:FluTableModel {
        columnSource: control.columnSource
    }
    property var columnSource: []
    property var dataSource
    property color borderColor: tableViewBorderVisible ? ThemeColorStyle.border_nor_color : "transparent" //
    property bool horizonalHeaderVisible: true
    property bool verticalHeaderVisible: true
    property int startRowIndex: 1
    property alias view: table_view
    // 选中行边框颜色和填充颜色
    property color selectedBorderColor: borderColor
    property color selectedColor: ThemeColorStyle.privacy_color
    // 文本对齐方式
    property int alginType: Text.AlignLeft
    property int headAlginType: Text.AlignHCenter
    property int wrapType: Text.WrapAnywhere
    // 字体大小和属性
    property int fontSize: ScreenTools.scaleNum(10, true)
    property int headFontSize: ScreenTools.scaleNum(10, true)
    property bool headIsBold: true      //表头是否加粗

    property color activeBgColor: FluTheme.frameActiveColor //背景颜色  
    property color doubleLineBgColor: activeBgColor     //偶数数行的填充颜色
    property color itemBorderColor: borderColor
    // 表头背景颜色和填充颜色
    property color headBgColor: Qt.rgba(247/255,247/255,247/255,1)

    signal verScroolBarVisibleChanged(bool isVisible)
    property bool vecScrollBarIsShow: false

    // 以下为新增表格属性
    property bool rowHeightResizeAble: false                                // 是否可拖动行高
    property bool columnWidthResizeAble: false                              // 是否可拖动列宽, RTL拉动宽暂未适配,禁止拖动
    property bool tableViewBorderVisible: true                              // 表格默认边框是否可见
    property bool horizontalScroolVisible: true                             // 水平滚动条是否可见
    property bool rowNumberVisible: false                                   // 行号是否可见


    property var columnWidthProvider: function(column) {
        if(!control || !control.columnSource || column < 0 || column >= control.columnSource.length){
            return ScreenTools.scaleNum(100)
        }
        var columnModel = control.columnSource[column]
        if(!columnModel){
            return d.defaultItemWidth
        }
        var width = columnModel.width
        if(width){
            return width
        }
        var minimumWidth = columnModel.minimumWidth
        if(minimumWidth){
            return minimumWidth
        }
        return d.defaultItemWidth
    }
    property var rowHeightProvider: function(row) {
        if(!control){
            return d.defaultItemHeight
        }
        var rowModel = control.getRow(row)
        if(!rowModel){
            return d.defaultItemHeight
        }
        var height = rowModel.height
        if(height){
            return height
        }
        var minimumHeight = rowModel._minimumHeight
        if(minimumHeight){
            return minimumHeight
        }
        return d.defaultItemHeight
    }
    id:control
    color: {
        if(Window.active){
            return activeBgColor
        }
        return activeBgColor
    }
    onColumnSourceChanged: {
        if(columnSource.length!==0){
            var columns= []
            var headerRow = {}
            var offsetX = 0
            for(var i=0;i<=columnSource.length-1;i++){
                var item = columnSource[i]
                if(!item.width){
                    item.width = d.defaultItemWidth
                }
                item.x = offsetX
                offsetX = offsetX + item.width
                var column = Qt.createQmlObject('import Qt.labs.qmlmodels 1.0;TableModelColumn{}',sourceModel);
                column.display = item.dataIndex
                columns.push(column)
                headerRow[item.dataIndex] = item
            }
            header_column_model.columns = columns
            header_column_model.rows = [headerRow]
        }
    }
    Component.onDestruction: {
        // 停止所有定时器
        timer_horizontal_force_layout.stop()
        timer_vertical_force_layout.stop()  
        // 先关闭编辑器
        control.closeEditor()
        
        // 断开 table_view 的 model
        if(table_view)
            table_view.model = null

        // 断开 table_sort_model 的 model 绑定
        if(table_sort_model)
            table_sort_model.model = null
        
        // 清理 header 模型
        if(header_column_model)
            header_column_model.clear()
        if(header_row_model)
            header_row_model.clear()
        
        // 最后清理 sourceModel 和 dataSource
        if(sourceModel)
            sourceModel.clear()
        dataSource = []
        
        table_view.contentY = 0
    }
    QtObject{
        id:d
        property var current
        property int rowHoverIndex: -1
        property int defaultItemWidth: ScreenTools.scaleNum(100)
        property int defaultItemHeight: ScreenTools.scaleNum(42)
        property var editDelegate
        property var editPosition
        property int currentRowIndex: -1
        signal tableItemLayout(int column)
        function getEditDelegate(column){
            var obj =control.columnSource[column].editDelegate
            if(obj){
                return obj
            }
            if(control.columnSource[column].editMultiline === true){
                return com_edit_multiline
            }
            return com_edit
        }
    }
    onDataSourceChanged: {
        sourceModel.clear()
        dataSource.forEach(function(item) {
            item._key = item._key || FluTools.uuid()
        })
        sourceModel.rows = dataSource
    }
    TableModel{
        id: header_column_model
        TableModelColumn { display : "title"}
    }
    TableModel{
        id: header_row_model
        TableModelColumn { display: "rowIndex" }
    }
    FluTableSortProxyModel{
        id: table_sort_model
        model: control.sourceModel
    }
    Component{
        id:com_edit
        FluTextEdit{
            id:text_box
            readOnly: true === control.columnSource[column].readOnly
            text: control.columnSource[column].readOnly ? "" : String(display)
            rightPadding: ScreenTools.scaleNum(10)
            leftPadding: ScreenTools.scaleNum(10)
            fontSize: control.fontSize
            borderWidth: control.columnSource[column].readOnly ? 0 : 1
            cusPlaceholderText: ""
            backgroundColor:readOnly ? "transparent" : "#FFFFFF"
            Component.onCompleted: {
                if(!readOnly){
                    forceActiveFocus()
                    selectAll()
                }
            }
            onCommit: {
                if(!readOnly){
                    editTextChaged(text_box.text)
                }
                control.closeEditor()
            }
        }
    }
    Component{
        id:com_edit_multiline
        Item{
            anchors.fill: parent
            Flickable{
                id:item_scroll
                clip: true
                anchors.fill: parent
                ScrollBar.vertical: multiline_text_srcoll_bar
                boundsBehavior: Flickable.StopAtBounds
                TextArea.flickable: FluMultilineTextBox {
                    id:multiline_text_box
                    text: String(display)
                    readOnly: true === control.columnSource[column].readOnly
                    verticalAlignment: TextInput.AlignVCenter
                    isCtrlEnterForNewline: true
                    Component.onCompleted: {
                        forceActiveFocus()
                        selectAll()
                    }
                    rightPadding: ScreenTools.scaleNum(34)
                    onCommit: {
                        if(!readOnly){
                            editTextChaged(multiline_text_box.text)
                        }
                        control.closeEditor()
                    }
                }
            }
            FluIconButton{
                iconSource:FluentIcons.ChromeClose
                iconSize: ScreenTools.scaleNum(10)
                width: ScreenTools.scaleNum(20)
                height: ScreenTools.scaleNum(20)
                padding: 0
                verticalPadding: 0
                horizontalPadding: 0
                visible: {
                    if(text_box.readOnly)
                        return false
                    return text_box.text !== ""
                }
                anchors{
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: ScreenTools.scaleNum(15)
                }
                onClicked:{
                    text_box.text = ""
                }
            }
            FluCustomScrollBar{
                id:multiline_text_srcoll_bar
                anchors{
                    right: parent.right
                    rightMargin: ScreenTools.scaleNum(5)
                    top: parent.top
                    bottom: parent.bottom
                    topMargin: ScreenTools.scaleNum(3)
                    bottomMargin: ScreenTools.scaleNum(3)
                }
            }
        }
    }
    Component{
        id:com_text
        FluText {
            id:item_text
            objectName: "item_text"
            text: String(display)
            elide: Text.ElideRight
            wrapMode: wrapType
            font.pointSize: control.fontSize
            font.family: ScreenTools.fontFamily
            textColor: columnModel ? (columnModel.textColor ? columnModel.textColor : ThemeColorStyle.title_text_nor_color) : ThemeColorStyle.title_text_nor_color
            anchors{
                fill: parent
                leftMargin: ScreenTools.scaleNum(10)
                rightMargin: ScreenTools.scaleNum(10)
                topMargin: ScreenTools.scaleNum(6)
                bottomMargin: ScreenTools.scaleNum(6)
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: alginType
            MouseArea{
                acceptedButtons: Qt.NoButton
                id: hover_handler
                hoverEnabled: true
                anchors.fill: parent
            }
            FluTooltip{
                text: item_text.text
                width: Math.min(implicitWidth, ScreenTools.scaleNum(320))
                x: parent ? (parent.width - width) / 2 : 0
                margins: ScreenTools.scaleNum(6)
                padding: ScreenTools.scaleNum(6)
                font.family: ScreenTools.fontFamily
                font.pointSize: ScreenTools.scaleNum(10, true)
                background: Rectangle {
                    color: FluTheme.dark ? Qt.rgba(50/255,49/255,48/255,1) : Qt.rgba(1,1,1,1)
                    radius: ScreenTools.scaleNum(4)
                    FluShadow{
                        radius: ScreenTools.scaleNum(4)
                    }
                }
                delay: 200
                visible: item_text.contentWidth < item_text.implicitWidth &&  hover_handler.containsMouse
            }
        }
    }
    Component{
        id:com_table_delegate
        MouseArea{
            id:item_table_mouse
            objectName: columnModel ? ("body_" + row + "_" + columnModel.dataIndex) : ""
            property var _model: model
            property bool isMainTable: TableView.view == table_view
            property var currentTableView: TableView.view
            property bool isHide: {
                if(isMainTable && columnModel && columnModel.frozen){
                    return true
                }
                if(!isMainTable && currentTableView && columnModel){
                    if(currentTableView.dataIndex !== columnModel.dataIndex)
                        return true
                }
                return false
            }
            property bool isRowSelected: {
                if(!rowModel)
                    return false
                if(d.current){
                    if(rowModel._key === d.current._key)
                    {
                        d.currentRowIndex = row
                    }
                    return rowModel._key === d.current._key
                }
                return false
            }
            property bool editVisible: {
                if(!rowModel)
                    return false
                if(d.editPosition && d.editPosition._key === rowModel._key && d.editPosition.column === column){
                    return true
                }
                return false
            }
            implicitWidth: {
                var _wid = isHide ? Number.MIN_VALUE : TableView && TableView.view ? TableView.view.width : Number.MIN_VALUE
                return _wid >= 0 ? _wid : ScreenTools.scaleNum(10)
            }
            visible: !isHide
            TableView.onPooled: {
                if(d.editPosition && d.editPosition.row === row && d.editPosition.column === column){
                    control.closeEditor()
                }
            }
            hoverEnabled: true
            onEntered: {
                d.rowHoverIndex = row
            }
            onExited: {
                if(isRowSelected){
                    d.currentRowIndex = row
                }
            }
            onWidthChanged: {
                updatePosition()
            }
            onHeightChanged: {
                updatePosition()
            }
            onXChanged: {
                updatePosition()
            }
            onYChanged: {
                updatePosition()
            }
            function updatePosition(){
                if(editVisible){
                    updateEditPosition()
                }
                if(isMainTable){
                    updateTableItem()
                }
            }
            function updateEditPosition(){
                var obj = {}
                obj._key = rowModel._key
                obj.column = column
                obj.row = row
                obj.x = item_table_mouse.x
                obj.y = item_table_mouse.y + 1
                obj.width = item_table_mouse.width
                obj.height = item_table_mouse.height - ScreenTools.scaleNum(2)
                d.editPosition = obj
            }
            function updateTableItem(){
                var columnModel = control.columnSource[column]
                if(columnModel.x !== item_table_mouse.x || columnModel.y !== item_table_mouse.y){
                    columnModel.x = item_table_mouse.x
                    columnModel.y = item_table_mouse.y
                    d.tableItemLayout(column)
                }
            }
            //行顔色設置
            Rectangle{
                anchors.fill: parent
                color:{
                    if(item_table_mouse.isRowSelected){
                        return control.selectedColor
                    }
                    if(d.rowHoverIndex === row || item_table_mouse.isRowSelected){
                        return selectedColor
                    }
                    return "#FFFFFF" // (row%2!==0) ? control.color : doubleLineBgColor
                }
                MouseArea{
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onPressed:{
                        control.closeEditor()
                    }
                    onCanceled: {
                    }
                    onReleased: {
                    }
                    onDoubleClicked:{
                        if(item_table_loader.isObject){
                            return
                        }
                        loader_edit.display = item_table_loader.display
                        d.editDelegate = d.getEditDelegate(column)
                        item_table_mouse.updateEditPosition()
                    }
                    onClicked:(event)=>{
                            d.current = rowModel
                            control.closeEditor()
                            event.accepted = true
                        }
                }
                FluLoader{
                    id: item_table_loader
                    property var tableView: control
                    property var model: item_table_mouse._model
                    property var display: {
                        if(!model || !model.rowModel || !model.columnModel) return ""
                        return model.rowModel[model.columnModel.dataIndex]
                    }
                    property var rowModel : model ? model.rowModel : null
                    property var columnModel : model ? model.columnModel : null
                    property int row : model ? model.row : -1
                    property int column: model ? model.column : -1
                    property bool isObject: display && typeof(display) == "object"
                    property var options: {
                        if(isObject && display){
                            return display.options
                        }
                        return {}
                    }
                    anchors.fill: parent
                    sourceComponent: {
                        if(!item_table_mouse.visible || !model || !rowModel) return undefined
                        if(isObject){
                            return display.comId
                        }
                        return com_text
                    }
                }
                FluLoader{
                    id: loader_edit
                    property var tableView: control
                    property var display
                    property int column: {
                        if(d.editPosition){
                            return d.editPosition.column
                        }
                        return 0
                    }
                    property int row: {
                        if(d.editPosition){
                            return d.editPosition.row
                        }
                        return 0
                    }
                    anchors{
                        fill: parent
                        margins: 1
                    }
                    signal editTextChaged(string text)
                    sourceComponent: {
                        if(item_table_mouse.visible && d.editPosition && d.editPosition.column === model.column && d.editPosition.row === model.row){
                            return d.editDelegate
                        }
                        return undefined
                    }
                    onEditTextChaged:
                        (text)=>{
                            var obj = control.getRow(row)
                            obj[control.columnSource[column].dataIndex] = text
                            control.setRow(row,obj)
                        }
                    z:999
                }
                //单元格左右侧边框
                Item{
                    anchors.fill: parent
                    Rectangle{
                        width: 1
                        height: parent.height
                        anchors.left: parent.left
                        color: control.selectedBorderColor
                        visible: control.tableViewBorderVisible && (column === 0 || (!ConfigureManager.isRTLLayout ? column !== 0 : column !== control.columns - 1))
                    }
                    Rectangle{
                        width: 1
                        height: parent.height
                        anchors.right: parent.right
                        color: control.selectedBorderColor
                        visible: control.tableViewBorderVisible && (ConfigureManager.isRTLLayout ? column === 0 : column === control.columns - 1)
                    }
                    Rectangle{
                        width: parent.width
                        height: 1
                        anchors.top: parent.top
                        color: control.selectedBorderColor
                        visible: false
                    }
                    Rectangle{
                        width: parent.width
                        height: 1
                        anchors.bottom: parent.bottom
                        color: tableViewBorderVisible ? control.selectedBorderColor : control.itemBorderColor
                        visible: control.vecScrollBarIsShow ? (row !== control.rows - 1) : true
                    }
                }
            }
        }
    }

    MouseArea{
        id:layout_mouse_table
        hoverEnabled: true
        anchors{
            left: header_vertical.right
            top: header_horizontal.bottom
            right: parent.right
            bottom: parent.bottom
        }
        onExited: {
            d.rowHoverIndex = -1
        }
        onCanceled: {
            d.rowHoverIndex = -1
        }
        TableView {
            id:table_view
            boundsBehavior: Flickable.StopAtBounds
            anchors.fill: parent
            ScrollBar.horizontal:scroll_bar_h
            ScrollBar.vertical:scroll_bar_v
            columnWidthProvider: control.columnWidthProvider
            rowHeightProvider: control.rowHeightProvider
            model: table_sort_model
            clip: true
            onRowsChanged: {
                control.closeEditor()
                table_view.flick(0,1)
            }
            delegate: com_table_delegate
            onWidthChanged: {
                Qt.callLater(forceLayout)
            }
        }
    }

    Component{
        id: com_column_header_delegate
        FluRectangle{
            id: column_item_control
            objectName: "header_" + columnModel.dataIndex
            property var currentTableView : TableView.view
            readonly property real cellPadding: ScreenTools.scaleNum(8)
            property bool canceled: false
            property var _model: model
            readonly property var columnModel : control.columnSource[_index]
            readonly property int _index : {
                const isDataIndex = (element) => {
                    return element.dataIndex === display.dataIndex
                }
                return control.columnSource.findIndex(isDataIndex)
            }
            readonly property bool isHeaderHorizontal: TableView.view == header_horizontal
            readonly property bool isHide: {
                if(isHeaderHorizontal){
                    return false
                }
                if(!isHeaderHorizontal && columnModel && currentTableView){
                    if(currentTableView.dataIndex !== columnModel.dataIndex)
                        return true
                }
                return false
            }
            visible: !isHide
            implicitWidth: {
                if(isHide){
                    return Number.MIN_VALUE
                }
                if(column_item_control.isHeaderHorizontal){
                    return (item_column_loader.item && item_column_loader.item.implicitWidth) + (cellPadding * 2)
                }
                return Math.max(TableView.view ? TableView.view.width : Number.MIN_VALUE, Number.MIN_VALUE)
            }
            implicitHeight: {
                if(column_item_control.isHeaderHorizontal){
                    return ScreenTools.scaleNum(56) //Math.max(ScreenTools.scaleNum(56), (item_column_loader.item&&item_column_loader.item.implicitHeight) + (cellPadding * 2))
                }
                return Math.max(TableView.view ? TableView.view.height : Number.MIN_VALUE, Number.MIN_VALUE)
            }
            color: headBgColor
            property real topLeftRadius: 0//column === 0 ? 12 : 0
            property real topRightRadius: 0//column === control.columns - 1 ? 12 : 0
            property real bottomRightRadius: 0
            property real bottomLeftRadius: 0
            radius: [topLeftRadius, topRightRadius, bottomRightRadius, bottomLeftRadius]
            Rectangle{
                visible: row !== 0
                border.color: control.borderColor
                width: parent.width
                height: 1
                anchors.top: parent.top
                color: control.borderColor
            }
            Rectangle{
                border.color: control.borderColor
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color:control.borderColor
                visible: row !== 0
            }
            Rectangle{
                border.color: control.borderColor
                width: 1
                height: parent.height
                anchors.left: parent.left
                color:control.borderColor
                visible: control.tableViewBorderVisible && (row !== 0 && column_item_control._index !== 0)
            }

            //表头中间竖线
            Rectangle{
                border.color: control.borderColor
                width: 1
                visible: false
                height: control.tableViewBorderVisible ? parent.height : parent.height / 2
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: control.tableViewBorderVisible ? control.borderColor : "#DCDCDC"
                // visible: control.tableViewBorderVisible ?  false
                //          : (ConfigureManager.isRTLLayout ? column_item_control._index !== 0 : column_item_control._index !== table_view.columns - 1)
            }
            MouseArea{
                id:column_item_control_mouse
                anchors.fill: parent
                anchors.rightMargin: ScreenTools.scaleNum(6)
                hoverEnabled: true
                onCanceled: {
                    column_item_control.canceled = true
                }
                onContainsMouseChanged: {
                    if(!containsMouse){
                        column_item_control.canceled = false
                    }
                }
                onClicked:
                    (event)=>{
                        control.closeEditor()
                    }
            }
            FluLoader{
                id:item_column_loader
                property var model: column_item_control._model
                property var display: model.display.title
                property var tableView: table_view
                property var sourceModel: control.sourceModel
                property bool isObject: typeof(display) == "object"
                property var options:{
                    if(isObject){
                        return display.options
                    }
                    return {}
                }
                property int column: column_item_control._index
                width: parent.width
                height: parent.height
                sourceComponent: {
                    if(isObject){
                        return display.comId
                    }
                    return com_column_text
                }
            }
            MouseArea{
                property point clickPos: "0,0"
                height: parent.height
                width: ScreenTools.scaleNum(6)
                anchors.right: parent.right
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                visible: columnModel && !columnModel.frozen && !(columnModel.width === columnModel.minimumWidth && columnModel.width === columnModel.maximumWidth && columnModel.width)
                cursorShape: control.columnWidthResizeAble ? Qt.SplitHCursor : Qt.ArrowCursor
                preventStealing: true
                onPressed :
                    (mouse)=>{
                        if(control.columnWidthResizeAble){
                            FluTools.setOverrideCursor(Qt.SplitHCursor)
                            clickPos = Qt.point(mouse.x, mouse.y)
                        }
                    }
                onReleased:{
                    FluTools.restoreOverrideCursor()
                }
                onCanceled: {
                    FluTools.restoreOverrideCursor()
                }
                onPositionChanged:
                    (mouse)=>{
                        if(!pressed || !control.columnWidthResizeAble){
                            return
                        }
                        var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                        var minimumWidth = columnModel.minimumWidth
                        var maximumWidth = columnModel.maximumWidth
                        var w = columnModel.width
                        if(!w){
                            w = d.defaultItemWidth
                        }
                        if(!minimumWidth){
                            minimumWidth = d.defaultItemWidth
                        }
                        if(!maximumWidth){
                            maximumWidth = 65535
                        }
                        columnModel.width = Math.min(Math.max(minimumWidth, w + delta.x),maximumWidth)
                        table_view.forceLayout()
                        header_horizontal.forceLayout()
                    }
            }
        }
    }
    Component{
        id:com_row_header_delegate
        Rectangle{
            id:item_control
            readonly property real cellPadding: ScreenTools.scaleNum(8)
            property bool canceled: false
            property var rowModel: control.getRow(row)
            implicitWidth: rowNumberVisible ? Math.max(ScreenTools.scaleNum(30), row_text.implicitWidth + (cellPadding * 2)) : 1
            implicitHeight: ScreenTools.scaleNum(56) //row_text.implicitHeight + (cellPadding * 2)
            color:{
                if(d.rowHoverIndex === row  || d.currentRowIndex === row){
                    return selectedColor
                }
                return (row%2!==0) ? control.color : doubleLineBgColor
            }
            Rectangle{
                border.color: control.borderColor
                width: parent.width
                height: 1
                anchors.top: parent.top
                visible: false
                color: tableViewBorderVisible ? control.borderColor : control.itemBorderColor
            }
            Rectangle{
                border.color: control.borderColor
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                visible: true
                color: tableViewBorderVisible ? control.borderColor : control.itemBorderColor
            }
            Rectangle{
                border.color: control.borderColor
                width: control.rowNumberVisible ? 1 : 0
                height: parent.height
                anchors.left: parent.left
                color:  control.borderColor
                visible: control.tableViewBorderVisible && control.rowNumberVisible
            }
            Rectangle{
                border.color: control.borderColor
                width: 1
                height: parent.height
                anchors.right: parent.right
                color: control.borderColor
                visible: control.tableViewBorderVisible
            }
            FluText{
                id:row_text
                anchors.centerIn: parent
                text: model.display
                textColor: control.rowNumberVisible ? ThemeColorStyle.title_text_nor_color : "transparent"
                font.pointSize: ScreenTools.scaleNum(10, true)
                font.family: ScreenTools.fontFamily
            }
            MouseArea{
                id:item_control_mouse
                anchors.fill: parent
                anchors.bottomMargin: ScreenTools.scaleNum(6)
                hoverEnabled: true
                onCanceled: {
                    item_control.canceled = true
                }
                onContainsMouseChanged: {
                    if(!containsMouse){
                        item_control.canceled = false
                    }
                }
                onClicked:
                    (event)=>{
                        control.closeEditor()
                    }
            }
            MouseArea{
                property point clickPos: "0,0"
                height: ScreenTools.scaleNum(6)
                width: parent.width
                anchors.bottom: parent.bottom
                acceptedButtons: Qt.LeftButton
                cursorShape: control.rowHeightResizeAble ? Qt.SplitVCursor : Qt.ArrowCursor
                preventStealing: true
                visible: {
                    if(rowModel === null)
                        return false
                    return !(rowModel.height === rowModel._minimumHeight && rowModel.height === rowModel._maximumHeight && rowModel.height)
                }
                onPressed :
                    (mouse)=>{
                        if(control.rowHeightResizeAble){
                            FluTools.setOverrideCursor(Qt.SplitVCursor)
                            clickPos = Qt.point(mouse.x, mouse.y)
                        }
                    }
                onReleased:{
                    FluTools.restoreOverrideCursor()
                }
                onCanceled: {
                    FluTools.restoreOverrideCursor()
                }
                onPositionChanged:
                    (mouse)=>{
                        if(!pressed || !control.rowHeightResizeAble){
                            return
                        }
                        var rowModel = control.getRow(row)
                        var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                        var minimumHeight = rowModel._minimumHeight
                        var maximumHeight = rowModel._maximumHeight
                        var h = rowModel.height
                        if(!h){
                            h = d.defaultItemHeight
                        }
                        if(!minimumHeight){
                            minimumHeight = d.defaultItemHeight
                        }
                        if(!maximumHeight){
                            maximumHeight = 65535
                        }
                        rowModel.height = Math.min(Math.max(minimumHeight, h + delta.y),maximumHeight)
                        control.setRow(row,rowModel)
                        table_view.forceLayout()
                    }
            }
        }
    }
    Component{
        id:com_column_text
        FluText {
            id: column_text
            objectName: "column_text"
            text: String(display)
            anchors.fill: parent
            horizontalAlignment: headAlginType
            verticalAlignment: Text.AlignVCenter
            color: ThemeColorStyle.title_text_nor_color
            font.pointSize: control.headFontSize
            font.family: ScreenTools.fontFamily
            font.bold: control.headIsBold
            anchors{
                fill: parent
                leftMargin: ScreenTools.scaleNum(10)
                rightMargin: ScreenTools.scaleNum(10)
                topMargin: ScreenTools.scaleNum(6)
                bottomMargin: ScreenTools.scaleNum(6)
            }
        }
    }
    Item{
        id: header_vertical_column
        Rectangle{ 
            anchors.fill: parent
            color:headBgColor
        }
        anchors{
            top: header_horizontal.top
            bottom: header_horizontal.bottom
            left: parent.left
            right: header_vertical.right
        }
        Rectangle{
            border.color: control.borderColor
            width: parent.width
            height: 1
            anchors.top: parent.top
            color:control.borderColor
        }
        Rectangle{
            border.color: control.borderColor
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color:control.borderColor
        }
        Rectangle{
            border.color: control.borderColor
            width: control.rowNumberVisible ? 1 : 0
            height: parent.height
            anchors.left: parent.left
            color:control.borderColor
            visible: control.tableViewBorderVisible && control.rowNumberVisible
        }
        Rectangle{
            border.color: control.borderColor
            width: 1
            height: parent.height
            anchors.right: parent.right
            color:control.borderColor
            visible: control.tableViewBorderVisible
        }
    }
    TableView {
        id: header_horizontal
        model: header_column_model
        anchors{
            left: header_vertical.right
            right: layout_mouse_table.right
            top: parent.top
        }
        visible: control.horizonalHeaderVisible
        height: visible ? Math.max(1, contentHeight) : 0
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        syncDirection: Qt.Horizontal
        ScrollBar.horizontal:scroll_bar_h_2
        columnWidthProvider: table_view.columnWidthProvider
        syncView: table_view.rows === 0 ? null : table_view
        onContentXChanged:{
            timer_horizontal_force_layout.restart()
        }
        Timer{
            id:timer_horizontal_force_layout
            interval: 50
            onTriggered: {
                header_horizontal.forceLayout()
            }
        }
        delegate: com_column_header_delegate
    }
    TableView {
        id: header_vertical
        boundsBehavior: Flickable.StopAtBounds
        anchors{
            top: layout_mouse_table.top
            left: parent.left
        }
        visible: control.verticalHeaderVisible
        implicitWidth: visible ? Math.max(1, contentWidth) : 0
        implicitHeight: syncView ? syncView.height : 0
        syncDirection: Qt.Vertical
        syncView: table_view
        clip: true
        model: header_row_model
        delegate: com_row_header_delegate
        onContentYChanged:{
            timer_vertical_force_layout.restart()
        }
        Connections{
            target: table_view
            enabled: table_view !== null
            function onRowsChanged(){
                if(!table_view) return
                header_vertical.updateRowIndex()
            }
        }
        Connections {
            target: control
            enabled: control !== null
            function onStartRowIndexChanged(){
                header_vertical.updateRowIndex()
            }
        }
        Timer{
            id:timer_vertical_force_layout
            interval: 50
            onTriggered: {
                header_vertical.forceLayout()
            }
        }
        function updateRowIndex(){
            header_row_model.rows = Array.from({length: table_view.rows}, (_, i) => ({rowIndex:i+control.startRowIndex}))
        }
    }
    Item{
        anchors{
            left: header_vertical.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        Component{
            id: com_table_frozen
            Rectangle{
                id: item_column_frozen_loader
                anchors.fill: parent
                color: {
                    if(Window.active){
                        return activeBgColor
                    }
                    return activeBgColor
                }
                visible: table_view.rows !== 0
                Rectangle{
                    z:99
                    anchors.fill: parent
                    border.color: Qt.rgba(191/255,191/255,191/255,0.3)
                    FluShadow{
                        radius: 0
                        anchors.fill: parent
                    }
                    color: "#00000000"
                }
                TableView{
                    property string dataIndex: columnModel.dataIndex
                    id: item_table_frozen
                    interactive: false
                    clip: true
                    anchors{
                        left: parent.left
                        right: parent.right
                    }
                    contentWidth: width
                    height: table_view.height
                    y: header_horizontal.height
                    boundsBehavior: TableView.StopAtBounds
                    model: table_view.model
                    delegate: table_view.delegate
                    syncDirection: Qt.Vertical
                    syncView: table_view
                }
                TableView {
                    property string dataIndex: columnModel.dataIndex
                    id:item_table_frozen_header
                    model: header_column_model
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: false
                    clip: true
                    contentWidth: width
                    anchors{
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: item_table_frozen.top
                    }
                    delegate: com_column_header_delegate
                    Component.onCompleted: {
                        item_table_frozen_header.forceLayout()
                    }
                }
                Connections{
                    target: table_view
                    enabled: table_view !== null && item_table_frozen_header !== null
                    function onWidthChanged() {
                        if(!table_view || !item_table_frozen_header) return
                        item_table_frozen_header.forceLayout()
                    }
                }
            }
        }
        Repeater{
            Component.onCompleted: {
                model = control.columnSource
            }
            delegate: FluLoader{
                id: item_column_frozen_loader
                readonly property int _index : model.index
                readonly property var columnModel : control.columnSource[_index]
                readonly property bool isHide:{
                    if(columnModel.frozen){
                        return false
                    }
                    return true
                }
                Connections{
                    target: d
                    enabled: d !== null && item_column_frozen_loader !== null
                    function onTableItemLayout(column){
                        if(!d || !item_column_frozen_loader) return
                        if(item_column_frozen_loader._index === column){
                            Qt.callLater(updateLayout)
                        }
                    }
                }
                Connections{
                    target: table_view
                    enabled: table_view !== null
                    function onContentXChanged(){
                        if(!table_view) return
                        Qt.callLater(updateLayout)
                    }
                }
                function updateLayout(){
                    width = Qt.binding(() => table_view.columnWidthProvider(_index))
                    x = Qt.binding(function(){
                        var minX = 0
                        var maxX = table_view.width-width
                        for(var i=0;i<_index;i++){
                            var item = control.columnSource[i]
                            if(item.frozen){
                                minX = minX + table_view.columnWidthProvider(i)
                            }
                        }
                        for(i=_index+1;i<control.columnSource.length;i++){
                            item = control.columnSource[i]
                            if(item.frozen){
                                maxX =  maxX - table_view.columnWidthProvider(i)
                            }
                        }
                        return Math.min(Math.max(columnModel.x - table_view.contentX,minX),maxX)}
                    )
                }
                Component.onCompleted: {
                    updateLayout()
                }
                height: control.height
                visible: !item_column_frozen_loader.isHide
                sourceComponent: item_column_frozen_loader.isHide ? undefined : com_table_frozen
            }
        }
    }
    FluCustomScrollBar {
        id: scroll_bar_h
        anchors{
            left: layout_mouse_table.left
            right: parent.right
            bottom: layout_mouse_table.bottom
        }
        visible: horizontalScroolVisible && table_view.rows !== 0
        z:999
    }
    FluCustomScrollBar {
        id: scroll_bar_h_2
        anchors{
            left: layout_mouse_table.left
            right: parent.right
            bottom: layout_mouse_table.bottom
        }
        visible: horizontalScroolVisible && table_view.rows === 0
        z:999
    }
    FluCustomScrollBar {
        id: scroll_bar_v
        anchors{
            top: layout_mouse_table.top
            bottom: layout_mouse_table.bottom
            right: parent.right
        }
        z:999
        onSizeChanged: {
            vecScrollBarIsShow = scroll_bar_v.size < 1.0
            control.verScroolBarVisibleChanged(vecScrollBarIsShow)
        }
    }
    function closeEditor(){
        d.editPosition = undefined
        d.editDelegate = undefined
    }
    function resetPosition(){
        scroll_bar_h.position = 0
        scroll_bar_v.position = 0
    }
    function customItem(comId,options={}){
        var o = {}
        o.comId = comId
        o.options = options
        return o
    }
    function sort(callback=undefined){
        if(callback){
            table_sort_model.setComparator(function(left,right){
                return callback(sourceModel.getRow(left),sourceModel.getRow(right))
            })
        }else{
            table_sort_model.setComparator(undefined)
        }
    }
    function filter(callback=undefined){
        if(callback){
            table_sort_model.setFilter(function(index){
                return callback(sourceModel.getRow(index))
            })
        }else{
            table_sort_model.setFilter(undefined)
        }
    }
    function setRow(rowIndex,obj){
        if(rowIndex>=0 && rowIndex<table_view.rows){
            table_view.model.setRow(rowIndex,obj)
        }
    }
    function getRow(rowIndex){
        if(table_view && table_view.model && rowIndex >= 0 && rowIndex < table_view.rows){
            return table_view.model.getRow(rowIndex)
        }
        return null
    }
    function removeRow(rowIndex,rows=1){
        if(table_view && table_view.model && rowIndex>=0 && rowIndex<table_view.rows){
            table_view.model.removeRow(rowIndex,rows)
        }
    }
    function insertRow(rowIndex,obj){
        if(table_view && sourceModel && rowIndex>=0 && rowIndex<=table_view.rows){
            sourceModel.insertRow(rowIndex,obj)
        }
    }
    function currentIndex(){
        var index = -1
        if(!d.current){
            return index
        }
        for (var i = 0; i <= sourceModel.rowCount-1; i++) {
            var sourceItem = sourceModel.getRow(i);
            if(sourceItem._key === d.current._key){
                index = i
                break
            }
        }
        return index
    }
    function appendRow(obj){
        if(sourceModel){
            sourceModel.appendRow(obj)
        }
    }

    function removeAllRows() {
        if (sourceModel && sourceModel.removeRow) {
            var count = sourceModel.rowCount
            
            for (var i = count - 1; i >= 0; i--) {
                sourceModel.removeRow(i)  // 从后往前删
            }
            return
        }
    }

    function getIndexById(id, type) {
        if (!sourceModel || !id) {
            return -1
        }
        
        var rowCount = sourceModel.rowCount
        
        for (var i = 0; i < rowCount; i++) {
            var rowId = null
            var rowType = null
            
            if (sourceModel.getRow) {
                var row = sourceModel.getRow(i)
                rowId = row ? row.deviceID : null
                rowType = row ? row.deviceType : null
            } 
            if (rowId && rowId.toString() === id.toString() && type === rowType) {
                return i
            }
        }
        
        return -1
    }
}
