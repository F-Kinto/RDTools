/*********************************************************************
File : ReNameDialog.qml
Module : ReNameDialog
Authors: guangnan
date : 2023/07/17 16:00
Ver : 1.0.0
History:
guangnan 2023/07/17 1.0.0 build this module
********************************************************************/
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.2
import QtQuick.Layouts 1.15
import ScreenTools 1.0
import Component.Edit 1.0
import Component.Button 1.0
import Component.Login 1.0
import Component.FluButton 1.0
import Component.FluComponent 1.0
import VMS.Enum 1.0
import ConfigureManager 1.0
import InformationNotifier 1.0
import QtQuick.Window 2.15

FluModalDialog {
    id: dialog
    objectName: "exitRemindWindow"
    signal sendClose(int data);
    logoVisiable: false
    width: ScreenTools.scaleNum(380)
    height: ScreenTools.scaleNum(260)
    lineVisible: true

    LayoutMirroring.enabled: ConfigureManager.isRTLLayout
    LayoutMirroring.childrenInherit: true

    property bool noRemind: ConfigureManager.exitNoRemind
    property int closeEvent: ConfigureManager.closeButtonEvent

    Component {
        id: customContent

        Rectangle {
            anchors.fill: parent
            color: "white"
            ColumnLayout{
                anchors.fill: parent
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.scaleNum(20)
                anchors.right: parent.right
                anchors.rightMargin: ScreenTools.scaleNum(20)
                spacing:ScreenTools.scaleNum(10)
                Item {
                    Layout.fillWidth: true;
                    Layout.fillHeight: true
                }
  
                FluCustomRadioButton{
                    id:miniRadioButton
                    objectName: "miniRadioButton"
                    text:qsTr("Minimize to tray")
                    fontSize: ScreenTools.scaleNum(10, true)
                    textColor:ThemeColorStyle.title_text_nor_color
                    checked: closeEvent === 0 
                    onCheckedChanged:{
                        if(miniRadioButton.checked){
                            dialog.closeEvent = 0
                        }
                    }
                }
                FluCustomRadioButton{
                    id: exitRadioButton
                    objectName: "exitRadioButton"
                    text:qsTr("Exit program")
                    textColor: ThemeColorStyle.title_text_nor_color
                    fontSize: ScreenTools.scaleNum(10, true)
                    checked: closeEvent === 1
                    onCheckedChanged:{
                        if(exitRadioButton.checked){
                            dialog.closeEvent = 1
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true;
                    Layout.fillHeight: true
                }

                FluCustomCheckBox {
                    id: nodeCheckBox
                    objectName: "nodeCheckBox"
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: ScreenTools.scaleNum(16)
                    Layout.preferredHeight: ScreenTools.scaleNum(16)
                    Layout.bottomMargin: ScreenTools.scaleNum(16)
                    Layout.leftMargin: ScreenTools.scaleNum(4)
                    text: qsTr("Don't prompt again")
                    textColor:ThemeColorStyle.text_nor_color
                    checked: dialog.noRemind
                    borderDisableColor: ThemeColorStyle.border_checked_color
                    checkedDisableColor: ThemeColorStyle.border_checked_color
                    onCheckedChanged:{
                        dialog.noRemind = nodeCheckBox.checked
                    }
                }
            }
        }
    }
    
    onSigClicked: {
        if(data === 2)
        {
            // 点击确定
            ConfigureManager.setExitNoRemind(dialog.noRemind)
            ConfigureManager.setCloseButtonEvent(dialog.closeEvent)
            sendClose(1);
        }
        else{
            sendClose(0);
        }
    }
}
