/*********************************************************************
File : LineEdit.qml
Module : Edit
Authors: guangnan
date : 2023/07/13 16:00
Ver : 1.0.0
History:
guangnan 2023/07/13 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtQuick.Controls 2.15
import ScreenTools 1.0
import QtQuick.Layouts 1.15
import ConfigureManager 1.0
Rectangle {
    id:control
    signal rightButtonClicked(bool isChecked);
    signal textChanged();
    property real editWidth: 262
    property real editHeight: 40
    property url iconUrl:CommonPngImageStyle.searchImageUrl_img
    property url disableIconUrl: ""
    property color activeColor: "#9747ff"
    property color enableColor: "gray"
    property string placeholderText: "test"
    property color editTextColor: "black"
    property int editTextFontPointSize: 10
    property color placeholderTextColor: ThemeColorStyle.placeholder_text_color
    readonly property alias editText: textField.text
    property var validator: null
    property bool isPwd: false
    property url rightOPenImageUrl: CommonPngImageStyle.searchImageUrl_img
    property url rightCloseImageUrl: CommonPngImageStyle.searchImageUrl_img
    property bool isShowRightImage: true
    property alias editTextField: textField
    property bool isShowLeftImage: true
    property string fontFmaily: ScreenTools.fontFamily
    property real rightImageWidth: 20
    property real rightImageHeight: 20
    property real leftImageWidth: 20
    property real leftImageHeight: 20
    property real buttonBorderWidth: 2
    property real leftImageMargin: 5
    property real leftImageToTextFieldMargin: 5
    property real eyeImageRightMargin: 16
    property real buttonRadius: 4
    property alias theRightEyeIsOpen: pwdEye.isOpen
    property alias theLogoObj: logo
    property bool isRename: false
    property bool areaCodeVisible:false
    property bool isSearchModel: false
    property string countryCode: isSearchModel ? "0" : "+1" //默认为美国区号代码,如果是搜索模型则设置为0
    property string regionCode: isSearchModel ? "0" : "US" //默认为美国区号代码,如果是搜索模型则设置为0
    readonly property string countryCodeText: countryCode
    property url searchImageUpUrl: CommonPngImageStyle.searchImageUrl_img
    property url searchImageDownUrl: CommonPngImageStyle.searchImageUrl_img
    property string defaultText: ""
    property bool isRTLLayout: ConfigureManager.isRTLLayout
   
    property int currentIndex: 0
    implicitWidth: editWidth
    implicitHeight: editHeight
    border.width: buttonBorderWidth
    border.color: textField.focus?activeColor:enableColor
    radius: buttonRadius
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    RowLayout{
        anchors.fill: parent
        spacing: 0
        Item{
            width: leftImageMargin
            height: editHeight

        }
        Item{
            width: leftImageWidth
            height: leftImageHeight
            Layout.alignment: Qt.AlignVCenter
            visible:isShowLeftImage
            Image{
                id:logo
                source: iconUrl
                width: leftImageWidth
                height: leftImageHeight
                anchors.centerIn: parent
            }
        }
        Item{
            width: leftImageToTextFieldMargin
            height: editHeight
        }
        
        Item {
            width: 30
            height: editHeight
            implicitHeight: editHeight
            visible:areaCodeVisible
            Layout.alignment: Qt.AlignVCenter
            // 国家区域代码
            MouseArea {
                //id: areaLabel
                width: parent.width
                height: parent.height
                hoverEnabled: true
                onClicked: {
                    // 在这里添加点击处理逻辑
                    var isOpen = countryPopup.opened
                    if(isOpen){
                        countryPopup.close()
                    }
                    else
                    {
                        countryPopup.open()
                    }
                }
                
                // 悬停效果
                onEntered: areaLabel.color = "#009DFF"
                onExited: areaLabel.color = editTextColor
                
                Label {
                    id: areaLabel
                    text: countryCode
                    anchors.centerIn: parent
                    font.pointSize: editTextFontPointSize
                    font.family: control.fontFmaily
                    color: editTextColor
                    visible: !isSearchModel
                }
                Image{
                    id:searchLogo
                    source: countryPopup.visible ? searchImageDownUrl : searchImageUpUrl
                    width: rightImageWidth
                    height: rightImageHeight
                    anchors.centerIn: parent
                    visible: isSearchModel
                }
            }
        }


        TextField{
            id:textField
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            placeholderText: control.placeholderText
            color: editTextColor
            font.pointSize : editTextFontPointSize
            placeholderTextColor:control.placeholderTextColor
            selectByMouse:true
            font.family: control.fontFmaily
            validator:control.validator?control.validator:textField.validator
            echoMode:isPwd && !pwdEye.isOpen ?TextInput.Password:TextInput.Normal
            horizontalAlignment: Text.AlignLeft
            text: defaultText
            
            // 光标位置修正
            onActiveFocusChanged: {
                if (activeFocus) {
                    if (ConfigureManager.isRTLLayout) {
                        cursorPosition = 0;
                    } else {
                        cursorPosition = text.length;
                    }
                }
            }
            background: Rectangle {
                implicitWidth: editWidth-logo.width-10-control.border.width*2-pwdEye.width
                implicitHeight: editHeight-10-control.border.width*2
                color: "transparent"
                border.color: "transparent"
            }
            onTextChanged: {
                control.textChanged();
            }
        }
        Image{
            id:pwdEye
            property bool isOpen: false
            Layout.preferredWidth: rightImageWidth
            Layout.preferredHeight: rightImageHeight
            Layout.maximumWidth: rightImageWidth
            Layout.maximumHeight: rightImageHeight
            source: isOpen ? rightOPenImageUrl:rightCloseImageUrl
            Layout.alignment: Qt.AlignVCenter    
            visible: isRename ? (textField.text.length && isShowRightImage) : isShowRightImage
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if(!isRename){
                        pwdEye.isOpen=!pwdEye.isOpen;
                        rightButtonClicked(pwdEye.isOpen);
                    }
                    else{
                        textField.clear()
                    }
                }
            }

        }
        Item{
            width: eyeImageRightMargin
            height: editHeight
        }
    }

    Popup {
        id:countryPopup
        y: areaLabel.y + areaLabel.height
        modal: true
        onOpened: {
            // Popup打开时重置所有鼠标状态  --若没有这个处理，窗口第一次打开时会有一个随机item的悬浮事件为true
            if (countryLoader.status === Loader.Ready && countryLoader.item) {
                countryLoader.item.resetAllMouseStates();
            }
        }
        Loader{
            id:countryLoader
            source:"qrc:/Component/Edit/CustomAreaDialog.qml"
            onStatusChanged: {
                if(status == Loader.Ready){
                    countryLoader.item.isSearch = isSearchModel
                    if(isSearchModel)
                        countryLoader.item.dialogWidth = parent.width
                    countryLoader.x=countryPopup.x + ConfigureManager.isRTLLayout ? 80 : (-20);
                    countryLoader.y=countryPopup.y;
                    countryLoader.item.resetAllMouseStates()
                    countryLoader.item.getCurrentCode()
                    countryLoader.item.currentCountryCode.connect(handleCountryCode);
                    countryLoader.item.currentRegionCode.connect(handleRegionCode);
                    countryLoader.item.currentSelectIndex.connect(handleCurrentIndex);
                }
            }
        }
        background: null // 完全移除背景
        Overlay.modal: null // 完全移除遮罩
        closePolicy: Popup.CloseOnPressOutside

        function resetPopPos()
        {
            countryLoader.x=countryPopup.x + ConfigureManager.isRTLLayout ? 80 : (-20);
        }
    }

    function handleCountryCode(code)
    {
        countryCode = code
        countryPopup.close()
    }

    function handleRegionCode(code)
    {
        regionCode = code
    }

    function handleCurrentIndex(index)
    {
        currentIndex = index
        if(isSearchModel)
        {
            if(currentIndex == 1){
                placeholderText = qsTr("Search device name")
                countryCode = "1"
            }
            else if(currentIndex == 2){
                placeholderText = qsTr("Search device ID")
                countryCode = "2"
            }
            else{
                placeholderText = qsTr("Search for device name/ID")
                countryCode = "0"
            }
        }
    }
    onWidthChanged: {
        if(isSearchModel && countryLoader.item)
        {
            countryLoader.item.dialogWidth = parent.width
        }  
    }
    onIsRTLLayoutChanged:
    {
        countryPopup.resetPopPos()
    }
}
