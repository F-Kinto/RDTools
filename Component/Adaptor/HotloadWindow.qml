import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Component.Login 1.0
import FluentUI 1.0
import FileWatcher 1.0
import Component.FluComponent 1.0
import ScreenTools 1.0

FluWindow {
    id:window
    title: "Hot Loader"
    width: ScreenTools.scaleNum(800)
    height: ScreenTools.scaleNum(600)
    minimumWidth: ScreenTools.scaleNum(520)
    minimumHeight: ScreenTools.scaleNum(200)
    // launchMode: FluWindowType.SingleTask

    function loadqml(url){
        loader.source = url
        // watcher.path = url
        window.show();
        loader.reload()
    }

    FileWatcher{
        id:watcher
        onFileChanged: {
            loader.reload()
        }
    }
    FluFrame{
        anchors.fill: parent
        FluRemoteLoader{
            id:loader
            anchors.fill: parent
            statusMode: FluStatusLayoutType.Success
            lazy: true
            errorItem: Item{
                FluText{
                    text:loader.itemLodaer().sourceComponent.errorString()
                    color:"red"
                    anchors.fill: parent
                    wrapMode: Text.WrapAnywhere
                    padding: ScreenTools.scaleNum(20)
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                }
            }
        }
        FluText{
            text: "Drag in a qml file"
            font: FluTextStyle.Title
            anchors.centerIn: parent
            visible: !loader.itemLodaer().item && loader.statusMode === FluStatusLayoutType.Success
        }
        Rectangle{
            radius: ScreenTools.scaleNum(4)
            anchors.fill: parent
            color: "#33333333"
            visible: drop_area.containsDrag
        }
        DropArea{
            id:drop_area
            anchors.fill: parent
            onEntered:
                (event)=>{
                    if(!event.hasUrls){
                        event.accepted = false
                        return
                    }
                    var url = getUrlByEvent(event)
                    if(url === ""){
                        event.accepted = false
                        return
                    }
                    var fileExtension = url.substring(url.lastIndexOf(".") + 1)
                    if (fileExtension !== "qml") {
                        event.accepted = false
                        return
                    }
                    return true
                }
            onDropped:
                (event)=>{
                    var url = getUrlByEvent(event)
                    if(url !== ""){
                        loader.source = url
                        watcher.path = url
                        loader.reload()
                    }
                }
        }
    }

    function getUrlByEvent(event){
        var url = ""
        if (event.urls.length === 0) {
            url = "file:///"+event.getDataAsString("text/plain")
        }else{
            url = event.urls[0].toString()
        }
        return url
    }

}
