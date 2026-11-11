import QtQuick 2.15
import ScreenTools 1.0
import ConfigureManager 1.0
import ScreenTools 1.0
import FluentUI 1.0
import QtQuick.Layouts 1.15

Item {
    id: tipItem
    property string tip: qsTr("The current computer load is too high. It is recommended to close some unnecessary programs.")
    property string tip1: qsTr("Unusual system load detected. We recommend reducing the live stream quality or the number of video recordings.")
    property string lBtnText: qsTr("Don't prompt again")
    property string rBtnText: qsTr("Got it")

    property bool lefttBtnVisible: true
    property bool rightBtnVisible: true

    property int widthOffset: 0
    property int heightOffset: ScreenTools.scaleNum(52)
    property int lBtnWidth: Math.max(ScreenTools.calculateTextWidth(lBtnText, ScreenTools.scaleNum(10, true)) + ScreenTools.scaleNum(12), ScreenTools.scaleNum(76))
    property int rBtnWidth: Math.max(ScreenTools.calculateTextWidth(rBtnText, ScreenTools.scaleNum(10, true)) + ScreenTools.scaleNum(12), ScreenTools.scaleNum(76))
    property int tipType: 1  //1: 负载警告 2: 其他提示

    signal leftBtnClicked()
    signal rightBtnClicked()

    width: ScreenTools.scaleNum(630) + widthOffset
    height: heightOffset
    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true
    
    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF";
        radius: ScreenTools.scaleNum(8)
        border.color: "#E5E5E5"
        border.width: 1
        
    }

    MouseArea {
        anchors.fill: parent  
        propagateComposedEvents: false  
    }

    Text {
        id: tipText
        color: "#333333"
        anchors.left: parent.left;
        anchors.leftMargin: ScreenTools.scaleNum(16)
        anchors.verticalCenter: parent.verticalCenter
        width: ScreenTools.scaleNum((lefttBtnVisible ? 400 : 560))
        //height: parent.height
        text: tipType == 1 ? tip : tip1
        font.family: ScreenTools.fontFamily
        font.pointSize:  ScreenTools.scaleNum(12,true)
        wrapMode:Text.WrapAnywhere
        verticalAlignment: Text.AlignVCenter
    }

    Row {
        spacing: ScreenTools.scaleNum(12)
        anchors.left: parent.left;
        anchors.leftMargin: ScreenTools.scaleNum(450) 
        anchors.verticalCenter: parent.verticalCenter

        FluButton {
            id: _leftBtn
            width: lBtnWidth
            height: ScreenTools.scaleNum(28)
            text: lBtnText
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(12, true)
            textColor:  "#0199FB"
            background:  Rectangle {
                radius: ScreenTools.scaleNum(4)
                border.color: "#0199FB"
                border.width: 1
                color: "transparent"
                opacity: _leftBtn.hovered ? 0.7 : 1
            }
            onClicked:{
                leftBtnClicked();
            }
        }

        FluButton {
            id: _rightBtn
            width: rBtnWidth
            height: ScreenTools.scaleNum(28)
            text: rBtnText
            textColor: "#FFFFFF"
            font.family: ScreenTools.fontFamily
            font.pointSize: ScreenTools.scaleNum(12, true)
            background:Rectangle {
                radius: ScreenTools.scaleNum(4)
                color: ThemeColorStyle.okBtn_bg_color
                opacity: _rightBtn.hovered ? 0.7 : 1
            }
            onClicked:{
                rightBtnClicked();
            }
        }

    }

    function resetSize() {
        lBtnWidth = Math.max(ScreenTools.calculateTextWidth(lBtnText, ScreenTools.scaleNum(10, true)) + ScreenTools.scaleNum(12), ScreenTools.scaleNum(72))
        rBtnWidth = Math.max(ScreenTools.calculateTextWidth(rBtnText, ScreenTools.scaleNum(10, true)) + ScreenTools.scaleNum(12), ScreenTools.scaleNum(72))
        widthOffset = lBtnWidth + rBtnWidth - ScreenTools.scaleNum(144)
        heightOffset = ScreenTools.calculateTextWidth(tipText.text) > ScreenTools.scaleNum(lefttBtnVisible ? 400 : 560) ? ScreenTools.scaleNum(74) : ScreenTools.scaleNum(52)
    }
    
}
