import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import InformationNotifier 1.0
import ConfigureManager 1.0
import Component.TeamManage 1.0
import Component.SystemInfo 1.0
import Component.Login 1.0
import Component.Dialog 1.0
import Component.FluButton 1.0
import Component.Adaptor 1.0
import Component.Button 1.0
import ScreenTools 1.0
import VMS.Enum 1.0
import Component.GeetestHandler 1.0
import GeetestHandler 1.0

FluRectangle{
    // =========================
    // 对外暴露的属性（可由外部自定义标题栏行为/显示）
    // =========================
    signal titlePositionChanged(var point)

    property string title: ""                                   // 窗口标题文本
    property string teamManagerText : showTeamManager ? ConfigureManager.topTeamName : qsTr("Not joined a team") // 团队管理入口显示文本
    property string activeInformationText : qsTr("Active infor") // 活跃信息入口文本
    property string loginAndLogoutText : InformationNotifier.isLogin
                                     ? ConfigureManager.userAccount
                                     : qsTr("Not logged in")        // 登录状态文本（已登录显示账号）
    property string settingsText : qsTr("Client Settings")          // 设置入口文本
    property string darkText : "Dark"                               // 深色模式文本
    property string lightText : "Light"                             // 浅色模式文本
    property string minimizeText : qsTr("Minimize")                 // 最小化按钮提示文本
    property string restoreText : qsTr("Restore")                   // 还原按钮提示文本
    property string maximizeText : qsTr("Maximize")                 // 最大化按钮提示文本
    property string closeText : qsTr("Close")                       // 关闭按钮提示文本
    property string stayTopText : qsTr("Pin to top")                      // 置顶按钮提示文本
    property string stayTopCancelText : qsTr("Unpin")            // 取消置顶提示文本

    // =========================
    // 功能入口显示开关（外部可配置）
    // =========================
    property bool showTeamManager: false//ConfigureManager.topTeamName.length
    property bool showActiveInformation: true
    property bool showLoginAndLogout: InformationNotifier.isLogin // 登录后显示下拉；否则显示登录按钮
    property bool showSettings: true
    property bool showDark: false
    property bool showClose: true
    property bool showMinimize: true
    property bool showMaximize: true
    property bool showStayTop: false
    property bool titleVisible: true
    property bool activeInformationButtonCheck:false
    property real dropDownMenuSpacing: ScreenTools.scaleNum(6)
    property real dropDownMenuVerticalMargin: ScreenTools.scaleNum(6)
    property real dropDownMenuHorizontalMargin: 0
    // 保存当通过 isItemShowFullScreen 进入全屏前的窗口状态，用于还原
    property var savedWindowVisibility: undefined

    // =========================
    // 图标相关
    // =========================
    property url icon                                         // 左侧图标
    property int iconSize: ScreenTools.scaleNum(20)                                 // 图标尺寸
    property bool isMac: FluTools.isMacos()                    // 是否 macOS（用于按钮布局差异）

    // =========================
    // 对外暴露内部按钮对象（方便外部连接信号/改样式）
    // =========================
    property alias buttonStayTop: btn_stay_top
    property alias buttonMinimize: btn_minimize
    property alias buttonMaximize: btn_maximize
    property alias buttonClose: btn_close
    property alias buttonDark: btn_dark
    property alias buttonSettings: btn_settings
    property alias buttonLoginAndLogout: btn_loginAndLogout
    property alias buttonActiveInformation: btn_activeInformation
    property alias layoutMacosButtons: layout_macos_buttons
    property alias layoutStandardbuttons: layout_standard_buttons

    // =========================
    // 事件回调（以函数属性形式暴露，便于外部覆写）
    // =========================
    property var maxClickListener : function(){
        // 最大化/全屏行为：
        // - macOS：用全屏切换模拟最大化逻辑
        // - Windows/Linux：最大化或全屏之间切换（依赖 isItemShowFullScreen 外部变量）
        if(FluTools.isMacos()){
            if (d.win.visibility === Window.FullScreen || d.win.visibility === Window.Maximized)
                d.win.showNormal()
            else
                d.win.showFullScreen()
        }else{
            if (isItemShowFullScreen) {
                // 进入由外部控制的全屏：先保存当前窗口状态（仅在未保存时）
                if (savedWindowVisibility === undefined || savedWindowVisibility === null) {
                    savedWindowVisibility = d.win.visibility
                }
                d.win.showFullScreen()
            }
            else {
                // 外部取消全屏：若有保存的状态则按保存状态还原
                if (savedWindowVisibility !== undefined && savedWindowVisibility !== null) {
                    if (savedWindowVisibility === Window.Maximized) {
                        // 先恢复到 normal 再最大化，避免状态不同步导致属性不一致
                        d.win.showNormal()
                        Qt.callLater(function() { d.win.showMaximized() })
                    } else if (savedWindowVisibility === Window.FullScreen) {
                        d.win.showFullScreen()
                    } else {
                        d.win.showNormal()
                    }
                    savedWindowVisibility = undefined
                } else {
                    if (d.win.visibility === Window.FullScreen || d.win.visibility === Window.Maximized) {
                        d.win.showNormal()
                    } else {
                        d.win.showMaximized()
                    }
                }
            }

            d.hoverMaxBtn = false
        }
    }

    property var minClickListener: function(){
        // 最小化：如果是子窗口（有 transientParent）则最小化父窗口，否则最小化自己
        if(d.win.transientParent != null){
            d.win.transientParent.showMinimized()
        }else{
            d.win.showMinimized()
        }
    }

    property var closeClickListener : function(){
        // 显示关闭提示弹窗
        if(!ConfigureManager.exitNoRemind){
            exitNoReMindLoader.showPage = !exitNoReMindLoader.showPage
        }
        else{
            // 关闭：这里是 hide（隐藏窗口）而不是 close（关闭/退出）
            ConfigureManager.closeButtonEvent===0?d.win.hide():d.win.close()
        }
    }

    property var stayTopClickListener: function(){
        // 置顶仅对 FluWindow 生效
        if(d.win instanceof FluWindow){
            d.win.stayTop = !d.win.stayTop
        }
    }

    property var darkClickListener: function(){
        // 切换主题深浅
        if(FluTheme.dark){
            FluTheme.darkMode = FluThemeType.Light
        }else{
            FluTheme.darkMode = FluThemeType.Dark
        }
    }

    // property var teamManageClickListener: function(){
    //     // 延迟创建设置窗口（单例复用），再 show/raise/激活
    //     if (!teamManageWindowInstance) {
    //         teamManageWindowInstance = teamManageWindowComponent.createObject(control);
    //         if (!teamManageWindowInstance) {
    //             console.error(qsTr("Failed to create the TeamManager window"));
    //             return;
    //         }
    //     }

    //     teamManageWindowInstance.show();
    //     teamManageWindowInstance.raise();
    //     teamManageWindowInstance.requestActivate();
    // }

    // property var createTeamClickListener: function(){
    //     // 延迟创建设置窗口（单例复用），再 show/raise/激活
    //     if (!createTeamWindowInstance) {
    //         createTeamWindowInstance = createTeamWindowComponent.createObject(control);
    //         if (!createTeamWindowInstance) {
    //             console.error(qsTr("Failed to create the Team window"));
    //             return;
    //         }
    //     }

    //     createTeamWindowInstance.show();
    //     createTeamWindowInstance.raise();
    //     createTeamWindowInstance.requestActivate();
    // }

    property var settingsClickListener: function(){
        // Loader 懒加载：首次创建，后续复用同一实例
        if (settingWindowLoader.item) {
            settingWindowLoader.item.show()
            settingWindowLoader.item.raise()
            settingWindowLoader.item.requestActivate()
            return
        }

        settingWindowLoader.active = true
    }

    property var loginClickListener: function(){
        if(ScreenTools.isQiaoAn){
            FluRouter.navigate("/login")
        }
        if(ScreenTools.isLianXiang){
           DispatchManager.loginObj.signalLoginOperate(VmsEnum.LoginType.eNotLogin);
        }
    }

    property var activeInformationClickListener: function(){
        // 点击“活跃信息”按钮时的逻辑（当前未实现；悬停已用 Popup 展示）
        if(activeInformationButtonCheck){
            DispatchManager.showActiveInfoBox = false
            activeInformationButtonCheck = false
            activeInfoPopup.close()
        }
        else{
            DispatchManager.showActiveInfoBox = true
            activeInformationButtonCheck = true
            activeInfoPopup.open()
        }
    }

    // 窗口单例缓存
    property var createTeamWindowInstance: null
    property var teamManageWindowInstance: null

    property var geestestWindow: null   //安全验证页面
    //顶部左/右圆角, Win7下禁用圆角以避免黑角问题
    radius:[ScreenTools.isWin7System?0: ScreenTools.scaleNum(12),ScreenTools.isWin7System?0:ScreenTools.scaleNum(12),0,0]

    // =========================
    // 活跃信息 Popup 自动关闭定时器（鼠标离开后延迟关闭）
    // =========================
    Timer {
        id: closeTimer
        interval: 200
        onTriggered: {
            activeInfoPopup.close()
            DispatchManager.showActiveInfoBox= false;
        }
    }

    // =========================
    // 活跃信息浮层（悬停在按钮上打开）
    // =========================

    FluPopup {
        id: activeInfoPopup
        width: ScreenTools.scaleNum(166)
        height: ScreenTools.scaleNum(176)
        modal: false
        visible: false
        focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        parent: control.parent

        onClosed: {
            activeInformationButtonCheck = false
        }

        // 浮层内容页
        ActiveInfoPage {
            id: activeInfoContent
            objectName: "p_activeInfoContent"
            anchors.fill: parent
        }

        // 在 Popup 内部移动鼠标：进入停止关闭计时；离开启动关闭计时
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                if (closeTimer.running){
                    closeTimer.stop()
                }
            }
            onExited: {
                if(activeInformationButtonCheck) return
                closeTimer.start()
            }
        }

        // Popup 即将显示时：根据按钮全局坐标定位到按钮下方
        onAboutToShow: {
            var btnGlobalPos = btn_activeInformation_container.mapToGlobal(0, 0);
            var popupParentPos = control.parent.mapFromGlobal(btnGlobalPos.x, btnGlobalPos.y);
            activeInfoPopup.x = popupParentPos.x;
            activeInfoPopup.y = popupParentPos.y + btn_activeInformation_container.height + 2;
        }
    }

    // 根 id
    id:control
    color: Qt.rgba(0,0,0,0)
    height: visible ? ScreenTools.scaleNum(30) : 0                           // 不可见时高度为 0，避免占位
    opacity: visible                                   // 这里用 bool 当 opacity（0/1）
    z: 65535                                           // 保证标题栏在最上层

    // =========================
    // 内部状态容器（避免污染根属性）
    // =========================
    Item{
        id:d
        property var hitTestList: []                   // 预留：命中测试区域列表
        property bool hoverMaxBtn: false               // 最大化 hover 状态（部分逻辑使用）
        property var win: Window.window                // 当前所属 Window
        property bool stayTop: {
            if(d.win instanceof FluWindow){
                return d.win.stayTop
            }
            return false
        }
        // 当前是否处于“还原态”（已最大化或全屏）
        property bool isRestore: win && (Window.Maximized === win.visibility || Window.FullScreen === win.visibility)
        // 是否可调整大小：通过 min/max 限制判断
        property bool resizable: win && !(win.height === win.maximumHeight && win.height === win.minimumHeight
                                        && win.width === win.maximumWidth && win.width === win.minimumWidth)

        // 工具函数：判断一个全局点是否落在 item 的全局矩形内
        function containsPointToItem(point,item){
            var pos = item.mapToGlobal(0,0)
            var rect = Qt.rect(pos.x,pos.y,item.width,item.height)
            if(point.x>rect.x && point.x<(rect.x+rect.width) && point.y>rect.y && point.y<(rect.y+rect.height)){
                return true
            }
            return false
        }
    }

    // =========================
    // 左侧：图标 + 标题（mac 居中，其它系统左对齐）
    // =========================
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents:true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property point clickPos: "0, 0"
        property bool pressed: false
        onPressed: {
            if(mouse.button == Qt.LeftButton){
                clickPos = Qt.point(mouseX, mouseY);
                pressed=true;
            }
        }
        onPositionChanged: {
            if(pressed){
                var mousePos = Qt.point(mouseX-clickPos.x, mouseY-clickPos.y);
                titlePositionChanged(mousePos)
            }
        }
        onReleased: {
            pressed=false;
        }
        onDoubleClicked: {
            if(d.resizable && showMaximize){
                maxClickListener()
            }
        }
    }
    Row{
        anchors{
            verticalCenter: parent.verticalCenter
            left: isMac ? undefined : parent.left
            leftMargin: isMac ? undefined : ScreenTools.scaleNum(10)
            horizontalCenter: isMac ? parent.horizontalCenter : undefined
        }
        spacing: ScreenTools.scaleNum(10)
        Image{
            objectName: "logoImage"
            width: control.iconSize
            height: control.iconSize
            // 图片加载成功才显示
            visible: status === Image.Ready ? true : false
            source: control.icon
            anchors.verticalCenter: parent.verticalCenter
        }
        FluText {
            objectName: "title"
            text: title
            visible: control.titleVisible
            color:ThemeColorStyle.title_text_nor_color
            font.pointSize: ScreenTools.scaleNum(12, true)
            font.family: ScreenTools.fontFamily
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // =========================
    // HotLoader 测试窗口（动态加载组件并在关闭时回收显示状态）
    // =========================
    Loader{
        id: testLoader
        property bool show : false
        sourceComponent: show ? hotItem : undefined
        onLoaded: {
            if(testLoader.item && testLoader.show){
                // 监听子窗口 closing，关闭后把 show 置回 false
                testLoader.item.closing.connect((event)=>{
                    testLoader.show = false;
                });
            }
        }
        onShowChanged: {
            if(testLoader.item && testLoader.show){
                testLoader.item.show();
            }
        }
    }

    // 组件预览窗口加载器
    FluLoaderWindow{
        id: loaderWindow
        sourceUrl: "../Adaptor/TestComponetView.qml"
    }

    // HotloadWindow 的组件定义
    Component{
        id: hotItem
        HotloadWindow{
        }
    }

    // =========================
    // macOS 风格的三色按钮（关闭/最小化/最大化）
    // =========================
    Component{
        id:com_macos_buttons
        RowLayout{
            FluImageButton{
                Layout.preferredHeight: ScreenTools.scaleNum(12)
                Layout.preferredWidth: ScreenTools.scaleNum(12)
                normalImage: "../Image/btn_close_normal.png"
                hoveredImage: "../Image/btn_close_hovered.png"
                pushedImage: "../Image/btn_close_pushed.png"
                visible: showClose
                onClicked: closeClickListener()
            }
            FluImageButton{
                Layout.preferredHeight: ScreenTools.scaleNum(12)
                Layout.preferredWidth: ScreenTools.scaleNum(12)
                normalImage: "../Image/btn_min_normal.png"
                hoveredImage: "../Image/btn_min_hovered.png"
                pushedImage: "../Image/btn_min_pushed.png"
                onClicked: minClickListener()
                visible: showMinimize
            }
            FluImageButton{
                Layout.preferredHeight: ScreenTools.scaleNum(12)
                Layout.preferredWidth: ScreenTools.scaleNum(12)
                normalImage: "../Image/btn_max_normal.png"
                hoveredImage: "../Image/btn_max_hovered.png"
                pushedImage: "../Image/btn_max_pushed.png"
                onClicked: maxClickListener()
                visible: d.resizable && showMaximize
            }
        }
    }

    // =========================
    // 右侧：标准按钮区（功能入口 + 窗口控制按钮）
    // =========================
    RowLayout{
        id:layout_standard_buttons
        height: parent.height
        anchors.right: parent.right
        spacing: ScreenTools.scaleNum(16)

        // “组件预览”入口：切换 loaderWindow.showPage
        FluText {
            text: "组件预览"
            visible: ScreenTools.isDebug
            color:ThemeColorStyle.title_text_nor_color
            font.pointSize: ScreenTools.scaleNum(10, true)
            font.family: ScreenTools.fontFamily
            Layout.alignment: Qt.AlignVCenter
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    loaderWindow.showPage = !loaderWindow.showPage
                }
            }
        }

        // “HotLoader”入口：打开 testLoader
        FluText {
            text: "HotLoader"
            visible: ScreenTools.isDebug
            color:ThemeColorStyle.title_text_nor_color
            font.pointSize: ScreenTools.scaleNum(10, true)
            font.family: ScreenTools.fontFamily
            Layout.alignment: Qt.AlignVCenter
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    testLoader.show = true
                }
            }
        }

        // 分割线
        FluDivider{
            visible: ScreenTools.isDebug
            Layout.preferredWidth: ScreenTools.scaleNum(2)
            Layout.preferredHeight: ScreenTools.scaleNum(16)
            Layout.alignment: Qt.AlignVCenter
            orientation: Qt.Vertical
        }

        FluCustomIconButton {
            id: imageVip
            objectName: "imageVip"
            Layout.alignment: Qt.AlignCenter
            buttonWidth: ScreenTools.scaleNum(Math.max(ScreenTools.calculateTextWidth(imageVip.text, imageVip.font.pointSize) + 64, 120))
            buttonHeight: ScreenTools.scaleNum(34)
            font.pointSize: ScreenTools.scaleNum(10, true)
            display: Button.TextBesideIcon
            visible: showLoginAndLogout
            textNormalColor: "#805C09"
            borderWidth : 0
            alignmentValue: Qt.AlignLeft
            iconSize: ScreenTools.scaleNum(28)
            borderRadius: buttonHeight / 2
            sourceImgUrl: CommonPngImageStyle.valueAddedServicesButton_normalImage_img
            text: qsTr("Value-Added Services")
            showHoverTip: true
            gradientMode: 2
            gradientStartColor: ScreenTools.isLianXiang ? "#FFF2D2" : "#FFEEC2"
            gradientMidColor: ScreenTools.isLianXiang ? "#FFF2D2" : "#FFF9EB"
            gradientEndColor: ScreenTools.isLianXiang ? "#FFEDBF" : "#FFEEC2"
            onClicked:{
                ConfigureManager.pageType = 0;
                isShowVipWebViewManager++;
            }
        }

        // 分割线
        FluDivider{
            Layout.preferredWidth: ScreenTools.scaleNum(2)
            Layout.preferredHeight: ScreenTools.scaleNum(16)
            Layout.alignment: Qt.AlignVCenter
            orientation: Qt.Vertical
            visible: imageVip.visible
        }

        // 团队管理下拉按钮
        FluCustomDropDownButton{
            id:btn_teamSettings
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            Layout.alignment: Qt.AlignVCenter
            rightPadding: ScreenTools.scaleNum(2)
            iconSource: FluentIcons.Contact
            iconSize: ScreenTools.scaleNum(15)
            menuSpacing: control.dropDownMenuSpacing
            menuTopAndBottomMargin: control.dropDownMenuVerticalMargin
            menuLeftAndRightMargin: control.dropDownMenuHorizontalMargin
            visible: showLoginAndLogout && showTeamManager
            text:control.teamManagerText
            iconDelegate: Image{ sourceSize: Qt.size(32, 32) ; width: ScreenTools.scaleNum(20); height: ScreenTools.scaleNum(20); source: VmsToolPngStyle.content_avatar_img}
            disabled: false
            display: Button.TextBesideIcon

            FluMenuItem{
                text: qsTr("Create team")
                //onClicked: createTeamClickListener()
            }
            FluMenuItem{
                text: qsTr("Disband team")
                onClicked: {
                    //disbandDialog.open()
                }
            }
            FluMenuItem{
                text: qsTr("Team settings")
                //onClicked: teamManageClickListener()
            }
            // DisbandTeamPopup{
            //     id:disbandDialog
            //     companyName: ConfigureManager.topTeamName
            //     teamId: ConfigureManager.topTeamId
            //     //teamPhone: teamPhone
            //     password: ConfigureManager.userPasswd
            // }
        }

        // 登录后：账号下拉菜单（修改密码/团队设置/退出）
        FluCustomDropDownButton{
            id:btn_loginAndLogout
			objectName: "btn_loginAndLogout"
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            Layout.alignment: Qt.AlignVCenter
            iconSource: FluentIcons.Contact
            iconColor: ThemeColorStyle.okBtn_bg_color
            iconSize: ScreenTools.scaleNum(15)
            menuSpacing: control.dropDownMenuSpacing
            menuTopAndBottomMargin: control.dropDownMenuVerticalMargin
            menuLeftAndRightMargin: control.dropDownMenuHorizontalMargin
            visible: showLoginAndLogout
            text:control.loginAndLogoutText
            iconDelegate: Image{ sourceSize: Qt.size(32, 32) ; width: ScreenTools.scaleNum(28); height: ScreenTools.scaleNum(28); source: VmsToolPngStyle.content_avatar_img}
            menuBackground:Rectangle {
                        implicitWidth: ScreenTools.scaleNum(150)
                        implicitHeight: ScreenTools.scaleNum(36)
                        color:"#FFFFFF"
                        border.width: 0
                        radius: ScreenTools.scaleNum(12)
                        FluShadow{}
                    }
            disabled: false
            display: Button.TextBesideIcon

           FluCustomIconButton{ 
                objectName: "p_changePasswordMenuItem"
                text: qsTr("Change password")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                textNormalColor: ThemeColorStyle.title_text_nor_color
                textBtnHoverColor: ThemeColorStyle.privacy_text_color
                display: Button.TextBesideIcon
                buttonHeight: ScreenTools.scaleNum(ScreenTools.isQiaoAn ? 56 : 0)
                iconSize: ScreenTools.scaleNum(16)
                alignmentValue: Qt.AlignLeft
                sourceImgUrl: CommonImageStyle.menu_pwd
                borderWidth: 0
                borderRadius: 4
                visible: ScreenTools.isQiaoAn
                fontSize: ScreenTools.scaleNum(10, true)
                onClicked: {
                    // 切换到修改密码页
                    changePasswordDialog.open()
                    btn_loginAndLogout.closeMenu()
                }
            }
            // FluMenuItem{
            //     text: qsTr("Team Settings")
            //     onClicked: teamManageClickListener()
            // }
            FluCustomIconButton{ 
                objectName: "p_logoutMenuItem"
                text: qsTr("Log Out")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                textNormalColor: ThemeColorStyle.title_text_nor_color
                textBtnHoverColor: ThemeColorStyle.privacy_text_color
                display: Button.TextBesideIcon
                buttonHeight: ScreenTools.scaleNum(56)
                iconSize: ScreenTools.scaleNum(16)
                alignmentValue: Qt.AlignLeft
                sourceImgUrl: CommonImageStyle.menu_logout
                borderWidth: 0
                borderRadius: 4
                fontSize: ScreenTools.scaleNum(10, true)
                onClicked: {
                    dialog.open()
                    btn_loginAndLogout.closeMenu()
                }
            }
            FluCustomTipDialog{
                id:dialog
                title: qsTr("Prompt")
                message: qsTr("All online playback devices will stop. Are you sure you want to exit?")
                negativeText: qsTr("Cancel")
                onNegativeClicked:{
                    //showSuccess(qsTr("Click the Cancel Button"))
                }
                positiveText: qsTr("OK")
                onPositiveClicked:{
                    do{
                        if(ScreenTools.isQiaoAn){
                            DispatchManager.loginObj.logOut();
                            break;
                        }
                        if(ScreenTools.isLianXiang){
                            DispatchManager.loginObj.logOut();
                            DispatchManager.loginObj.logOutLianXiang();
                            break;
                        }
                    }while(0);
                }
            }
        }

        // 未登录：显示一个“登录”图标按钮
        FluCustomIconButton {
            id:btn_login
			objectName: "btn_login"
            Layout.preferredWidth: ScreenTools.scaleNum(32)
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            sourceImgUrl: CommonPngImageStyle.main_title_avatar_nor_Btn_img
            Layout.alignment: Qt.AlignVCenter
            iconSize: ScreenTools.scaleNum(20)
            visible: !showLoginAndLogout
            display: Button.IconOnly
            text:control.loginAndLogoutText
            hoverTipText: control.loginAndLogoutText
            hoverColor: FluTheme.itemHoverColor
            showHoverTip: true
            iconOnlyNeedHoverBg: true
            onClicked: loginClickListener()
        }

        // 分割线
        FluDivider{
            Layout.preferredWidth: ScreenTools.scaleNum(11)
            Layout.preferredHeight: ScreenTools.scaleNum(16)
            Layout.alignment: Qt.AlignVCenter
            orientation: Qt.Vertical
        }

        // 活跃信息按钮容器：用于定位 Popup + hover 触发展示/关闭
        Item {
            id: btn_activeInformation_container
            Layout.preferredWidth: ScreenTools.scaleNum(32)
            Layout.preferredHeight: ScreenTools.scaleNum(32)

            FluCustomIconButton{
                id:btn_activeInformation
                objectName: "btn_activeInformation"
                sourceImgUrl: CommonImageStyle.cpu_img
                iconSize: ScreenTools.scaleNum(20)
                anchors.fill: parent
                display: Button.IconOnly
                Layout.alignment: Qt.AlignVCenter
                visible: showActiveInformation
                text:control.activeInformationText
                buttonFillColor: ThemeColorStyle.title_text_nor_color
                onClicked: activeInformationClickListener()
            }

            // 悬停打开 activeInfoPopup；离开延迟关闭（200ms）
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                acceptedButtons: Qt.NoButton

                onEntered: {
                    if(activeInformationButtonCheck) return
                    if (closeTimer.running) {
                        closeTimer.stop()
                    }
                    activeInfoPopup.open()
                    DispatchManager.showActiveInfoBox = true
                    btn_activeInformation.buttonFillColor = ThemeColorStyle.privacy_text_color
                }

                onExited: {
                    btn_activeInformation.buttonFillColor = ThemeColorStyle.title_text_nor_color
                    if(activeInformationButtonCheck) return
                    closeTimer.start()
                }
            }
        }

        // 设置按钮（弹出/显示设置窗口）
        FluCustomIconButton{
            id:btn_settings
			objectName: "btn_settings"
            Layout.preferredWidth: ScreenTools.scaleNum(32)
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            display: Button.IconOnly
            sourceImgUrl: CommonImageStyle.setting_img
            iconSize: ScreenTools.scaleNum(20)
            hoverColor: FluTheme.itemHoverColor
            Layout.alignment: Qt.AlignVCenter
            visible: showSettings
            textNormalColor: ThemeColorStyle.title_text_nor_color
            textBtnHoverColor: ThemeColorStyle.privacy_text_color
            text:control.settingsText
            showHoverTip: true
            iconOnlyNeedHoverBg: true
            onClicked: settingsClickListener()
        }

        // 分割线
        FluDivider{
            Layout.preferredWidth: ScreenTools.scaleNum(2)
            Layout.preferredHeight: ScreenTools.scaleNum(16)
            Layout.alignment: Qt.AlignVCenter
            orientation: Qt.Vertical
        }

        // 深浅色切换（当前默认隐藏 showDark=false）
        FluIconButton{
            id:btn_dark
            Layout.preferredWidth: ScreenTools.scaleNum(32)
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            padding: 0
            verticalPadding: 0
            horizontalPadding: 0
            rightPadding: ScreenTools.scaleNum(2)
            iconSource: FluTheme.dark ? FluentIcons.Brightness : FluentIcons.QuietHours
            Layout.alignment: Qt.AlignVCenter
            iconSize: ScreenTools.scaleNum(10)
            visible: showDark
            text: FluTheme.dark ? control.lightText : control.darkText
            radius: 0
            iconColor:ThemeColorStyle.title_text_nor_color
            onClicked:()=> darkClickListener(btn_dark)
        }

        // 置顶（仅 FluWindow 时可用）
        FluIconButton{
            id:btn_stay_top
            Layout.preferredWidth: ScreenTools.scaleNum(32)
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            padding: 0
            verticalPadding: 0
            horizontalPadding: 0
            iconSource : FluentIcons.Pinned
            Layout.alignment: Qt.AlignVCenter
            iconSize: ScreenTools.scaleNum(10)
            visible: {
                if(!(d.win instanceof FluWindow)){
                    return false
                }
                return showStayTop
            }
            text:d.stayTop ? control.stayTopCancelText : control.stayTopText
            radius: 0
            iconColor: d.stayTop ? FluTheme.primaryColor : ThemeColorStyle.title_text_nor_color
            onClicked: stayTopClickListener()
        }

        // Windows/Linux：最小化
        FluCustomIconButton{
            id:btn_minimize
			objectName: "btn_minimize"
            Layout.preferredWidth: ScreenTools.scaleNum(32)
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            display: Button.IconOnly
            Layout.alignment: Qt.AlignVCenter
            iconSize: ScreenTools.scaleNum(20)
            sourceImgUrl: CommonImageStyle.min_img
            text:minimizeText
            visible: !isMac && showMinimize
            hoverColor: FluTheme.itemHoverColor
            buttonFillColor: ThemeColorStyle.title_text_nor_color
            showHoverTip: true
            iconOnlyNeedHoverBg: true
            onClicked: minClickListener()
        }

        // Windows/Linux：最大化/还原
        FluCustomIconButton{
            id:btn_maximize
            objectName: "btn_maximize"
            property bool hover: btn_maximize.hovered
            Layout.preferredWidth: ScreenTools.scaleNum(32)
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            display: Button.IconOnly
            Layout.alignment: Qt.AlignVCenter
            sourceImgUrl: d.isRestore ? CommonImageStyle.restore_img : CommonImageStyle.max_img
            visible: d.resizable && !isMac && showMaximize
            text:d.isRestore?restoreText:maximizeText
            iconSize: ScreenTools.scaleNum(20)
            buttonFillColor: ThemeColorStyle.title_text_nor_color
            hoverColor: FluTheme.itemHoverColor
            showHoverTip: true
            iconOnlyNeedHoverBg: true
            onClicked: maxClickListener()
        }

        // Windows/Linux：关闭
        FluCustomIconButton{
            id:btn_close
			objectName: "btn_close"
            Layout.preferredWidth: ScreenTools.scaleNum(32)
            Layout.preferredHeight: ScreenTools.scaleNum(32)
            iconSize: ScreenTools.scaleNum(20)
            display: Button.IconOnly
            Layout.alignment: Qt.AlignVCenter
            text:closeText
            visible: !isMac && showClose
            sourceImgUrl: CommonImageStyle.close_img
            hoverColor: ThemeColorStyle.privacy_error_color
            buttonFillColor: ThemeColorStyle.title_text_nor_color
            showHoverTip: true
            iconOnlyNeedHoverBg: true
            onClicked: closeClickListener()
        }
    }

    // macOS 左侧三按钮加载器（仅 macOS 加载）
    // =========================
    FluLoader{
        id:layout_macos_buttons
        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: ScreenTools.scaleNum(10)
        }
        sourceComponent: isMac ? com_macos_buttons : undefined
    }

    // =========================
    // 设置窗口组件（用于 Loader 懒加载）
    // =========================
    Component {
        id: settingWindowComponent
        AppSettingPage {

        }
    }

    Loader {
        id: settingWindowLoader
        active: false
        sourceComponent: settingWindowComponent
        onLoaded: {
            if (!item) {
                console.error(qsTr("Failed to open the client settings window."));
                return;
            }

            item.closing.connect(function() {
                settingWindowLoader.active = false
            })
            item.show()
            item.raise()
            item.requestActivate()
        }
    }

	// 点击关闭按钮时的确定弹窗
    FluLoaderWindow{
        id:exitNoReMindLoader
        sourceUrl: "qrc:/Component/Dialog/FluExitAppDialog.qml"

        onLoaded: {
            if(exitNoReMindLoader.item && exitNoReMindLoader.showPage){
                exitNoReMindLoader.item.closing.connect((event)=>{
                    exitNoReMindLoader.showPage = false;
                });
                exitNoReMindLoader.item.sendClose.connect(function(data){
                    exitNoReMindLoader.showPage = false;
                    if(data!==0){
                        if(ConfigureManager.closeButtonEvent === 0){
                            d.win.hide()
                        } else {
                            Qt.callLater(() => {
                                d.win.close()
                            })
                        }
                    }
                })
            }
        }
    }

    // Component {
    //     id: createTeamWindowComponent
    //     CreateTeam {
    //         onCloseButtonClicked: {
    //             // 创建团队页关闭回调（当前未处理）
    //         }
    //     }
    // }

    // Component {
    //     id: teamManageWindowComponent
    //     TeamManageMainPage {
    //         onCloseButtonClicked: {
    //             // 团队管理页关闭回调（当前未处理）
    //         }
    //     }
    // }

    Popup {
        id: changePasswordDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: ScreenTools.scaleNum(500)
        height: ScreenTools.scaleNum(540)
        closePolicy: Popup.CloseOnEscape
        padding: 0

        background: Rectangle {
            color: "#F4F7FF"
            radius: ScreenTools.scaleNum(12)
            border.width: 1
            border.color: "#E0E5F0"
        }

        contentItem: FluForgetPwdPage {
            objectName: "p_fluForgetPwdPage"
            standaloneMode: true
            onFinishCallback: function() { changePasswordDialog.close() }
        }
    }

    //安全验证页面
    Connections {
        target: GeetestHandler
        function onIsActiveChanged() {
            if (!InformationNotifier.isLogin) {
                return;   // 登录窗口存活期间，不重复处理
            }
            if(GeetestHandler.isActive){
                createGeetestWindow()
            }else{
                destroyGeetestWindow()
            }
        }
    }

    function createGeetestWindow() {
        console.log("[AppBar] Create Geetest window...")
        if(geestestWindow){
            geestestWindow.show()
            return;
        }
        
        var component = Qt.createComponent("qrc:/Component/GeetestHandler/GeetestHandlerItem.qml")
        if (component.status === Component.Ready) {
            geestestWindow = component.createObject(null, {
                "visible": true,
                "modality": Qt.ApplicationModal
            })
            console.log("[AppBar] Geetest window created successfully.")
        } else {
            component.statusChanged.connect(function(status) {
                if (status === Component.Ready) {
                    createGeetestWindow()
                } else if (status === Component.Error) {
                    console.log("[AppBar] Component loading error:", component.errorString())
                }
            })
        }
    }
    
    function destroyGeetestWindow() {
        if(GeetestHandler.isActive){
            GeetestHandler.cancelVerification()
        }
        if(geestestWindow){
            geestestWindow.visible = false
            geestestWindow.destroy()
            geestestWindow = null
        }
    }
}
