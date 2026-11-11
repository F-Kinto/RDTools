import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import FluentUI 1.0
import QtQuick.Layouts 1.15
import ConfigureManager 1.0
import ScreenTools 1.0
import TranslatorManager 1.0

Item {
    id: control
    signal commitIndexText(string text, int index)
    property bool disabled: false
    // 文本颜色
    property color normalColor: ThemeColorStyle.text_nor_color
    property color disableColor: ThemeColorStyle.text_disable_color
    property color textNormalColor: ThemeColorStyle.text_nor_color
    // 边框颜色 无焦点-有焦点
    property color borderColor : ThemeColorStyle.border_nor_color
    // 背景填充色
    property color backgroundColor: disabled ? "#F0F2F5" : "transparent" 

    // 边框属性 宽高以及圆角
    property int  borderRadius: ScreenTools.scaleNum(4)
    property int  borderWidth: 1
    property int editWidth: ScreenTools.scaleNum(300)
    property int editHeight: ScreenTools.scaleNum(36)
    // 字体大小
    property int fontSize: ScreenTools.scaleNum(10, true)

    property bool buttonVisible:false                                                               // 右边工具按钮是否可见
    property string searchImgUrl: CommonPngImageStyle.searchImageUrl_img        // 搜索图标
    
    // 下拉框属性调整
    property bool isCombox: false           // 是否显示下拉框
    property var comboModel: null           // 下拉框数据源
    property int comboWidth: ScreenTools.scaleNum(80)             // 下拉框宽度
    property int curIndex: 0               // 下拉框当前选中项
    property int defaultIndex: 0               // 下拉框当前选中项
    property var placeholderTextList:[qsTr("Search for device name/ID"), qsTr("Search device name"), qsTr("Search device ID")]
    onComboModelChanged: {
        languageTimer.start()
    }

    width: editWidth
    height: editHeight
    // 镜像
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    // 导致边框以及背景颜色
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        border.width: borderWidth
        radius: borderRadius
        border.color: borderColor
    }

    // 核心布局：使用RowLayout实现横向排列，自动分配空间
    RowLayout {
        anchors.fill: parent
        spacing: 0  // 控件间间距
        
        Label{
            id: label
            visible: !isCombox
            Layout.preferredWidth: ScreenTools.scaleNum(64)
            Layout.preferredHeight: ScreenTools.scaleNum(34)
            Layout.leftMargin: ScreenTools.scaleNum(2)
            text: "https://"
            font.family: "Microsoft YaHei UI"
            font.pointSize: fontSize
            background:Rectangle{
                color: "#FAFAFD"
                radius: ScreenTools.scaleNum(4)
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // 1. 下拉选择框 (ComboBox)
        FluComboBoxEdit {
            id: customCombo
            Layout.leftMargin: 1
            Layout.rightMargin: 1
            Layout.topMargin: 1
            Layout.bottomMargin: 1
            borderWidth: 0
            Layout.preferredWidth: comboWidth
            editWidth: comboWidth           // 首选宽度
            editHeight: control.height - ScreenTools.scaleNum(6)          // 填充高度
            backgroundColor: "#FAFAFD"
            normalColor: ThemeColorStyle.tab_text_nor_color
            curIndex: control.defaultIndex
            fontSize: control.fontSize
            font:label.font
            padding: 0
            iconWidth: ScreenTools.scaleNum(10)
            visible: isCombox
            model: control.comboModel
            onCommitIndex:{
                control.curIndex = index
                commitIndexText(searchInput.text, control.curIndex)
            }
        }
        Item{
            Layout.preferredWidth: 1
            Layout.preferredHeight: control.height - 2
            Rectangle{
                anchors.fill: parent
                color: "#CAD2DD"
            }
        }

        // 2. 输入框 (TextField)
        FluTextEdit{
            id: searchInput
            objectName: "searchInput"
            Layout.fillWidth: true
            Layout.fillHeight: true
            cusPlaceholderText: placeholderTextList[control.curIndex]
            borderWidth: 0
            borderRadius: 0
            borderNormalColor: control.borderColor
            font:label.font
            rightMode: 0
            onTextChange:{
                commitIndexText(searchInput.text, control.curIndex)
            }
        }


        FluIconButton{
            id: iconBtn
            iconDelegate:Image{ sourceSize: Qt.size(32, 32); width: ScreenTools.scaleNum(20); height: ScreenTools.scaleNum(20); source: searchImgUrl }
            iconSize: ScreenTools.scaleNum(16)
            Layout.preferredWidth: ScreenTools.scaleNum(36)
            Layout.preferredHeight: ScreenTools.scaleNum(34)
            Layout.alignment: Qt.AlignVCenter
            verticalPadding: 0
            horizontalPadding: 0
            visible: buttonVisible
            font:label.font
            onClicked:{
                console.log("关键词：", searchInput.text)
            }
        }
    }

    function resetWidth(){
        if(comboModel){
            var maxWidth = 0
            for(var i = 0; i < comboModel.count; i++)
            {
                maxWidth = Math.max(maxWidth, ScreenTools.calculateTextWidth(comboModel.get(i).text, ScreenTools.scaleNum(8, true)))
            }
            comboWidth = Math.max(ScreenTools.scaleNum(100), maxWidth + ScreenTools.scaleNum(40))
        }
    }

    Timer {
        id: languageTimer
        interval: 100
        repeat:false
        running: false
        onTriggered: {
            resetWidth()
            // 强制更新下拉框显示的当前文本
            if(customCombo && customCombo.textBox){
                customCombo.textBox.updateCurrentText()
            }
            languageTimer.stop()
        }
    }
    // 监听语言切换
    Connections {
        target: TranslatorManager
        function onLanguageChanged() {
            if(!languageTimer.running)
                languageTimer.start()
        }
    }

    function resetSearch(){
        searchInput.text = ""
        commitIndexText(searchInput.text, curIndex)
    }
}
