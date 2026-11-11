import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import ScreenTools 1.0
import ConfigureManager 1.0
import VMS.Enum 1.0
import Component.FluButton 1.0

TextField{
    signal commit(string text)
    signal textChange();
    signal sendCodeClicked()    //验证码发送按钮
    signal search()           //搜索按钮
    property bool disabled: false
    // 输入框边框不同状态相关颜色设置
    property color normalColor: ThemeColorStyle.title_text_nor_color
    property color disableColor: ThemeColorStyle.text_disable_color
    property color placeholderNormalColor: ThemeColorStyle.placeholder_text_color
    property color placeholderDisableColor: ThemeColorStyle.text_disable_color
    property color borderNormalColor : ThemeColorStyle.border_nor_color
    property color borderErrorColor : ThemeColorStyle.border_error_color
    property color borderTypingColor : ThemeColorStyle.border_checked_color

    // 文本按钮/背景 相关颜色设置
    property color textBtnColor: ThemeColorStyle.privacy_text_color
    property color textBtnHoverColor: ThemeColorStyle.privacy_text_color
    property color textBtnPressedColor: ThemeColorStyle.privacy_text_color
    property color textBgColor: ThemeColorStyle.button_hover_bg_color
    property color textBgHoverColor: ThemeColorStyle.button_hover_bg_color
    property color textBgPressedColor:  ThemeColorStyle.privacy_rect_color
    property int  fontSize: ScreenTools.scaleNum(10, true)
    property bool isBold: false

    // 输入框边框相关属性
    property color backgroundColor: disabled ? rgba(0, 0, 0, 0.04) : "transparent"
    property int  borderRadius: ScreenTools.scaleNum(4)
    property int  borderWidth: 1
    property int  editWidth: ScreenTools.scaleNum(240)
    property int  editHeight: ScreenTools.scaleNum(36)

    // 0-常规, 1-验证码, 2-搜索按钮, 3-密码输入, 4-清空
    property int  rightMode: 0 
    property string cusPlaceholderText: rightMode == 1 ? qsTr("Varification code") : qsTr("Please enter")

    // 0-常规输入, 1-手机号码, 2-邮箱校验, 3-密码校验
    property int regularRuleMode: 0 
    // 验证数据是否合法(目前只验证了内容是否为空)
    property bool isValid: true      
    // 是否开始输入           
    property bool isStartInput: false           
    property color borderColor : (isStartInput && !isValid) ? borderErrorColor : control.activeFocus ? borderTypingColor : borderNormalColor

    // 镜像
    property bool isRTLLayout: ConfigureManager.isRTLLayout 
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    // 输入框前面的图标是否可见
    property bool frontIconVisible: false
    property string frontImgUrl: CommonPngImageStyle.closeButtonUrl_img
    property int iconSize: ScreenTools.scaleNum(18)
    // 切换密码明文密文
    property bool hidePwd: true
    //验证码按钮相关属性
    property bool sendCodeEnabled: true          // 发送验证码按钮是否可用
    property int countdownSeconds: 60             // 定时器倒计时时间（默认60秒）

    // 根据不同功能右边显示不同图标
    property string searchImgUrl: CommonPngImageStyle.searchImageUrl_img
    property string closeImgUrl: CommonImageStyle.tip_error_img
    property string openEyeImgUrl: CommonPngImageStyle.show_pwd_img
    property string closeEyeImgUrl: CommonPngImageStyle.hide_pwd_img
    property string sourceImgUrl:{
        if(rightMode === 4){
            return closeImgUrl
        }else if(rightMode === 3){
            return closeEyeImgUrl
        }else if(rightMode === 2){
            return searchImgUrl
        }
        return ""
    }
    // CAM720 选择国家区域代码相关
    property bool areaCodeVisible: false
    property string countryCode: "+1" //默认为美国区号代码,如果是搜索模型则设置为0
    property string regionCode: "US" //默认为美国区号代码,如果是搜索模型则设置为0
    readonly property string countryCodeText: countryCode
    property int currentIndex: 0
    function stopVerifyCodeTimer() {
        if(rightMode === 1) {
            countdownTimer.stopCountdown()
        }
    }
    selectionColor: ThemeColorStyle.privacy_text_color   // 全选文本时的颜色

    onTextChanged: {
        if(control.text.length > 0 && rightMode > 0 && regularRuleMode > 0){
            isValid = true
            isStartInput = true
        }
        else{
            isValid = false
        }
        control.textChange();
    }
    
    onIsRTLLayoutChanged:{
        countryPopup.resetPopPos()
    }
    font.family: ScreenTools.fontFamily
    font.pointSize: control.fontSize
    font.bold: control.isBold
    onHidePwdChanged: {
        if(rightMode === 3){
            sourceImgUrl = !hidePwd ? openEyeImgUrl : closeEyeImgUrl
        }
    }
    id:control
    implicitHeight : editHeight
    implicitWidth : editWidth
    padding: ScreenTools.scaleNum(8)
    enabled: !disabled
    color: !enabled ? disableColor : normalColor
    renderType: FluTheme.nativeText ? Text.NativeRendering : Text.QtRendering
    horizontalAlignment: Text.AlignLeft
    placeholderTextColor: !enabled ? placeholderDisableColor : placeholderNormalColor
    selectByMouse: true
    placeholderText: cusPlaceholderText
    echoMode: (rightMode === 3 && hidePwd) ? TextInput.Password : TextInput.Normal
    // 正则表达式
    validator: RegExpValidator {
        regExp: {
            if(regularRuleMode === 1)
                return /^[0-9]*$/
            if(regularRuleMode === 2 || regularRuleMode === 3)
                return /^[a-zA-Z0-9!#$%&'*+/=?^_`{|}()!~\.@-]*$/
            return /^[\s\S]*$/
        }
    }
    rightPadding: {
        if(isRTLLayout){
            var rPadding = ScreenTools.scaleNum(12)
            if(frontIconVisible){
                rPadding += ScreenTools.scaleNum(24)
            }
            if(areaCodeVisible){
                rPadding += ScreenTools.scaleNum(countryLabel.width)
            }
            return rPadding
        }
        else{
            if(rightMode === 2 || rightMode === 3 || rightMode === 4){
                return ScreenTools.scaleNum(36)
            }
            if(rightMode === 1){
                return textBtn.width + ScreenTools.scaleNum(16)
            }
            else{
                return ScreenTools.scaleNum(16)
            }
        }
    }
    leftPadding: {
        if(isRTLLayout){
            if(rightMode === 2 || rightMode === 3 || rightMode === 4){
                return ScreenTools.scaleNum(36)
            }
            if(rightMode === 1){
                return textBtn.width + ScreenTools.scaleNum(16)
            }
            else{
                return ScreenTools.scaleNum(16)
            }
        }
        else{
            var lPadding = ScreenTools.scaleNum(12)
            if(frontIconVisible){
                lPadding += ScreenTools.scaleNum(24)
            }
            if(areaCodeVisible){
                lPadding += ScreenTools.scaleNum(countryLabel.width)
            }
            return lPadding
        }
    }
    onActiveFocusChanged: {
        if (activeFocus) {
            if (isRTLLayout) {
                cursorPosition = 0;
            } else {
                cursorPosition = text.length;
            }
        }
    }
    // 导致边框以及背景颜色
    background: Rectangle {
        anchors.fill: parent
        color: backgroundColor
        border.width: borderWidth
        radius: borderRadius
        border.color: borderColor
    }

    MouseArea{
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        acceptedButtons: Qt.RightButton
        onClicked: {
            if(control.echoMode === TextInput.Password){
                return
            }
            if(control.readOnly && control.text === ""){
                return
            }
            menu_loader.popup()
        }
    }

    // 输入框前面的图标
    FluImage{
        id: frontIconLabel
        anchors{
            left: parent.left
            leftMargin: ScreenTools.scaleNum(8)
            verticalCenter: parent.verticalCenter
        }
        width: iconSize
        height: iconSize
        source: frontImgUrl
        visible: frontIconVisible
    }

    // CAM720 选择国家区域代码相关
    Item {
        id: countryLabel
        anchors{
            left: parent.left
            leftMargin: frontIconVisible ? ScreenTools.scaleNum(24) : ScreenTools.scaleNum(4)
            verticalCenter: parent.verticalCenter
        }
        width: ScreenTools.calculateTextWidth(countryCode) + ScreenTools.scaleNum(8)
        height: editHeight
        visible:areaCodeVisible
        // 国家区域代码
        MouseArea {
            width: parent.width
            height: parent.height
            hoverEnabled: true
            onClicked: {
                // 在这里添加点击处理逻辑
                var isOpen = countryPopup.opened
                if(isOpen){
                    countryPopup.close()
                }
                else{
                    countryPopup.open()
                }
            }
            
            // 悬停效果
            onEntered: areaLabel.color = ThemeColorStyle.privacy_text_color
            onExited: areaLabel.color = normalColor
            
            Label {
                id: areaLabel
                text: countryCode
                anchors.centerIn: parent
                font: control.font
                color: normalColor
            }
        }
    }

    RowLayout{
        height: parent.height
        anchors{
            right: parent.right
            rightMargin: ScreenTools.scaleNum(4)
        }
        spacing: 0
        // 清空内容
        FluCustomIconButton {
            id: iconBtn
            objectName: "iconBtn"
            display: Button.IconOnly
            buttonWidth: ScreenTools.scaleNum(28)
            buttonHeight: ScreenTools.scaleNum(28)
            iconSize: ScreenTools.scaleNum(20)
            sourceImgUrl: control.sourceImgUrl
            focusPolicy: Qt.NoFocus
            buttonFillColor: ThemeColorStyle.tab_text_nor_color
            Layout.alignment:Qt.AlignVCenter
            showHoverTip: true
            visible: rightMode === 4 ? control.text !== "" : rightMode > 1
            iconOnlyNeedHoverBg: true
            onClicked: {
                if(rightMode === 4){
                    control.clear()
                }
                else if(rightMode === 3){
                    hidePwd = !hidePwd
                }
                else if(rightMode === 2){
                    control.search()
                }
            }
        }

        // 发送验证码
        FluTextButton{
            id: textBtn
            objectName: "textBtn"
            Layout.preferredHeight: ScreenTools.scaleNum(24)
            Layout.alignment: Qt.AlignVCenter
            text: {
                if(countdownTimer.running) {
                    return qsTr("Get it again %1s").arg(countdownTimer.countdown)
                } else {
                    return qsTr("Send code")
                }
            }
            visible: rightMode === 1
            // 按钮可用条件：sendCodeEnabled 为真且倒计时未运行
            enabled: sendCodeEnabled && !countdownTimer.running
            focusPolicy: Qt.NoFocus     //禁止tab按键获取焦点
            normalColor: textBtnColor
            hoverColor: textBtnHoverColor
            pressedColor: textBtnPressedColor
            disableColor: control.disableColor
            backgroundHoverColor: textBgColor
            backgroundPressedColor: textBgHoverColor
            backgroundDisableColor: textBgPressedColor
            font: control.font

            onClicked: {
                // 点击时不立即禁用按钮，等待倒计时启动后再禁用
                control.sendCodeClicked();
            }
        }
    }

    // 倒计时定时器
    Timer {
        id: countdownTimer
        interval: 1000  // 1秒
        running: false
        repeat: true
        property int countdown: 0
        
        function startCountdown(seconds) {
            countdown = seconds
            sendCodeEnabled = false
            running = true
        }
        function stopCountdown() {
            if(running) {
                running = false
                sendCodeEnabled = true
                countdown = 0
            }
        }
        
        onTriggered: {
            countdown--
            if(countdown <= 0) {
                running = false
                sendCodeEnabled = true
                countdown = 0
            }
        }
    }

    FluLoader{
        id: menu_loader
        function popup(){
            sourceComponent = menu
        }
    }
    Component{
        id:menu
        FluTextBoxMenu{
            inputItem: control
            Component.onCompleted: {
                popup()
            }
            onClosed: {
                menu_loader.sourceComponent = undefined
            }
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
                    countryLoader.x=countryPopup.x + isRTLLayout ? ScreenTools.scaleNum(80) : ScreenTools.scaleNum(-20);
                    countryLoader.y=countryPopup.y;
                    countryLoader.item.resetAllMouseStates()
                    countryLoader.item.getCurrentCode()
                    countryLoader.item.currentCountryCode.connect(handleCountryCode);
                    countryLoader.item.currentRegionCode.connect(handleRegionCode);
                    countryLoader.item.currentSelectIndex.connect(handleCurrentIndex);
                }
            }
        }
        background: null
        Overlay.modal: null
        closePolicy: Popup.CloseOnPressOutside

        function resetPopPos()
        {
            countryLoader.x=countryPopup.x + isRTLLayout ? ScreenTools.scaleNum(80) : ScreenTools.scaleNum(-20);
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
    }
    function startVerifyCodeTimer(seconds) {
        if(rightMode === 1) {
            countdownTimer.startCountdown(seconds)
        }
    }
}
