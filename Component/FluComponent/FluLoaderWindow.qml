import QtQuick 2.12
import QtQml 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import FluentUI 1.0
Loader {
    id: loader
    property bool showPage: false
    property string sourceUrl: ""
    source: showPage ? sourceUrl : ""
    onShowPageChanged: {
        if(showPage && loader.item) {
            loader.item.close();
            loader.item.show();
        }
    }
    onLoaded: {
        if(loader.item && loader.showPage){
            loader.item.closing.connect((event)=>{
                loader.showPage = false;
            });
        }
    }
} 