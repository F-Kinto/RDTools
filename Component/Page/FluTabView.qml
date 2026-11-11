import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Component.Button 1.0
import FluentUI 1.0
import ScreenTools 1.0 
import ConfigureManager 1.0 

Item{
    property int currentIndex: 0
    property alias _listView: listView
    property Component itemDelegate: iconBtnDelegate //textDelegate 
    ListView{
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: ScreenTools.scaleNum(4)
        model: 10
        delegate: itemDelegate
    }

    Component{
        id: textDelegate    
        Item{
            width: Math.max(txt.width, ScreenTools.scaleNum(60))
            height: ScreenTools.scaleNum(40)
            FluText{
                id: txt
                text: "Tab" + index
                color: currentIndex === index ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.text_nor_color
                anchors.centerIn: parent
                font.pointSize: ScreenTools.scaleNum(12, true)
                font.family: ScreenTools.fontFamily
                elide: Text.ElideRight

            }
            

            Rectangle{
                visible: currentIndex === index
                color: ThemeColorStyle.privacy_text_color
                width: parent.width
                height: ScreenTools.scaleNum(2)
                anchors.bottom: parent.bottom
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    currentIndex = index
                }
            }
        }
    }

    Component{
        id: iconBtnDelegate    
        Item{
            width: Math.max(btn.width, ScreenTools.scaleNum(90))
            height: ScreenTools.scaleNum(50)
            FluIconButton{
                id: btn
                width: ScreenTools.scaleNum(90)
                display: Button.TextBesideIcon
                text: "Tab" + index
                textColor: currentIndex === index ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.text_nor_color
                color: "transparent"
                iconDelegate: imgDelegate

            }

            Component{
                id: imgDelegate
                Image{ 
                    source: ConfigureManager.getProgramLogoUrl()
                }
            }

            Rectangle{
                visible: currentIndex === index
                color: ThemeColorStyle.privacy_text_color
                width: parent.width - ScreenTools.scaleNum(4)
                height: ScreenTools.scaleNum(2)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    currentIndex = index
                }
            }
        }
    }
}
