import QtQuick 2.12
import QtQuick.Controls 2.12
import ScreenTools 1.0
import FluentUI 1.0
import QtQuick.Layouts 1.15
import Qt.labs.folderlistmodel 2.15
import InfoInterface 1.0
import FileWatcher 1.0
import Component.FluComponent 1.0
FluCustomWindow{
    id: testView
    width: ScreenTools.scaleNum(400)
    height: ScreenTools.scaleNum(600)
    color: "black"

    property string qmlPath: ""

    property var dataList: []

    FileWatcher{
        id:watcher
    }

    Component.onCompleted: {
        var result = watcher.getFiles("C:/Users/admin/Desktop/code/VsQt/trunk/VmsTools_v2/VmsTools/Component/");
        dataList = result;
        
        console.log("dataList length:", Object.keys(dataList).length)
    }

    RowLayout{
        id: testLayout
        anchors.fill: parent
        spacing: ScreenTools.scaleNum(8)

        Item {
            width: ScreenTools.scaleNum(8)
        }

        ListView{
            id: testList
            anchors.fill: parent
            width: ScreenTools.scaleNum(200)
            model: Object.keys(dataList)
            property int curIdx: index
            delegate: Column{
                width: ScreenTools.scaleNum(200)
                spacing: ScreenTools.scaleNum(4)
                property int curindex: -1
                Text {
                    id: txt
                    text: modelData
                    font.pointSize: InfoInterface.pointSize
                    color: InfoInterface.textColor
                    font.family: ScreenTools.fontFamily
                    elide: Text.ElideLeft
                }

                Repeater{
                    model: dataList[modelData]
                    delegate: FluCopyableText {
                        anchors.left: parent.left
                        anchors.leftMargin: ScreenTools.scaleNum(20)
                        text: modelData.fileName
                        font.pointSize: InfoInterface.pointSize
                        color: testList.curIdx === testList.currentIndex && curindex === index ? "#0099FF" : InfoInterface.textColor
                        font.family: ScreenTools.fontFamily
                        // elide: Text.ElideLeft
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                timer.restart()
                                curindex = index
                                timer.tempPath = "file:///" + modelData.filePath.replace(/\\/g, "/");
                                console.log("Loading QML:", qmlPath)
                            }
                        }
                    }
                } 
            
            }

            footer:Item {
                height: ScreenTools.scaleNum(100)
            }
            ScrollBar.vertical: FluCustomScrollBar {}
        }

        Timer {
            id: timer
            interval: 1000
            property string tempPath: ""
            onTriggered: {
                qmlPath = tempPath
                tempPath = ""
                hotloadWindow.loadqml(qmlPath);
            }
        }

        // Loader{
        //     id: testLoader
        //     width: parent.width - testList.width - testLayout.spacing
        //     source: qmlPath
        // }

        HotloadWindow{
            id: hotloadWindow
            title: "预览界面"
            visible: false
        }
    }
}
