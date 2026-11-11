import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import Component.FluComponent 1.0
import FluentUI 1.0

Item {
    id: _root
    anchors.centerIn: parent

    Rectangle { 
        id: bgRect
        anchors.fill: parent
        radius: ScreenTools.scaleNum(4)
        color: Qt.rgba(0, 0, 0, 0.6)
    }
    // 组件的对外接口：控制动画是否运行
    property bool running: true

    // 组件的对外接口：动画速度（毫秒）
    property int duration: 1000

    // 组件的对外接口：颜色
    property color color: "#FFFFFF"
    property string title: qsTr("Loading...")

    // 字体大小
    property int fontSize: ScreenTools.scaleNum(12,true)
    // 图标尺寸大小
    property int iconSize: ScreenTools.scaleNum(100)
    // 文本图标间距
    property int iconSpacing: ScreenTools.scaleNum(24)
    // loading 图标
    property string sourceImg: CommonPngImageStyle.loading_img

    width: ScreenTools.scaleNum(200); 
    height: ScreenTools.scaleNum(200) // 默认尺寸
    clip: true // 防止旋转时边缘溢出

    function showLoading(loadingText = "") {
        if(!!loadingText){  
            _root.title = loadingText
        }
        spinAnim.running = true
        _root.visible = true
    }

    function hide() {
        spinAnim.running = false
        _root.visible = false 
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: iconSpacing

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Rectangle {
            implicitWidth:iconSize
            implicitHeight:iconSize
            Layout.alignment: Qt.AlignHCenter
            color: "transparent"
            Image {
                anchors.fill: parent
                source: sourceImg
                width: iconSize
                height: iconSize
                rotation: 0
                // 旋转动画
                NumberAnimation on rotation {
                    id: spinAnim
                    from: 0; to: 360
                    duration: _root.duration
                    loops: Animation.Infinite
                    running: _root.running
                    easing.type: Easing.Linear
                }
            }
        }

        FluCustomLable{
            objectName: "loadingTips"
            currentTextColor: _root.color
            Layout.fillWidth: true
            Layout.leftMargin: ScreenTools.scaleNum(12)
            Layout.rightMargin: ScreenTools.scaleNum(12)
            text: title
            currentBackgroundColor: "transparent"
            borderWidth: 0
            textWrap:Text.WrapAnywhere
            fontSize: _root.fontSize
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        
    }
  
}