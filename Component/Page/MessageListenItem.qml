import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import Component.FluComponent 1.0
import Component.FluButton 1.0
import Component.FluDeviceManager 1.0
import InformationNotifier 1.0
import VMS.Enum 1.0
import ConfigureManager 1.0
import ScreenTools 1.0
Item{
    clip: true
    property var deviceShareMap: DispatchManager.deviceObj.deviceShareMap
   
    ListView{
        id: deviceList
        anchors.fill: parent
        spacing: ScreenTools.scaleNum(6)
        model: Object.values(deviceShareMap)
        delegate: FluShareDeviceTip{
            objectName: "shareDeviceTip" + index
            visible: true
            result: modelData
        }
    }

    FluText {
        visible: Object.values(deviceShareMap).length === 0
        text: qsTr("No messages")
        anchors.centerIn: parent
        width: parent.width - 32
        font.pointSize: ScreenTools.scaleNum(12, true)
        font.family: ScreenTools.fontFamily
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode:Text.WrapAnywhere
    }
}

/*
    {
        {"", QVariantMap{}},
        {"N3X8YMK9JL7XGKPA111A", QVariantMap{
            {"close_status", 0},
            {QStringLiteral("create_date"), QStringLiteral("20260727")},
            {QStringLiteral("create_time"), QStringLiteral("2026-07-27 13:40:13")},
            {QStringLiteral("device_id"), QStringLiteral("N3X8YMK9JL7XGKPA111A")},
            {QStringLiteral("device_name"), QStringLiteral("B14")},
            {QStringLiteral("extra_field"), QStringLiteral("[201,202,203,204,205]")},
            {QStringLiteral("id"), QStringLiteral("3F_7c3e829dce803791bd83830e3e97909c_20260727_1785130813322_49cebcee")},
            {QStringLiteral("initiator_user_account"), QStringLiteral("180****6449")},
            {QStringLiteral("initiator_user_id"), QStringLiteral("1d38b00daaeb31a5863f78c86866c673")},
            {"read_flag", 0},
            {QStringLiteral("request_params"), requestParams},
            {QStringLiteral("share_title"), QStringLiteral("来自180****6449的设备分享邀请")},
            {"status", 0},
            {"supType", 1},
            {QStringLiteral("target_user_account"), QStringLiteral("133****9556")},
            {QStringLiteral("target_user_id"), QStringLiteral("7c3e829dce803791bd83830e3e97909c")},
            {QStringLiteral("title"), QStringLiteral("180****6449想要分享设备给您")},
            {"type", 1},
            {QStringLiteral("user_role"), QStringLiteral("receiver")},
            {"visible", 1}
        }},
        {"N3X8YMK9JL7XGKPA111A1", QVariantMap{
            {"close_status", 0},
            {QStringLiteral("create_date"), QStringLiteral("20260727")},
            {QStringLiteral("create_time"), QStringLiteral("2026-07-27 13:40:13")},
            {QStringLiteral("device_id"), QStringLiteral("N3X8YMK9JL7XGKPA111A")},
            {QStringLiteral("device_name"), QStringLiteral("B14")},
            {QStringLiteral("extra_field"), QStringLiteral("[201,202,203,204,205]")},
            {QStringLiteral("id"), QStringLiteral("3F_7c3e829dce803791bd83830e3e97909c_20260727_1785130813322_49cebcee")},
            {QStringLiteral("initiator_user_account"), QStringLiteral("180****6449")},
            {QStringLiteral("initiator_user_id"), QStringLiteral("1d38b00daaeb31a5863f78c86866c673")},
            {"read_flag", 0},
            {QStringLiteral("request_params"), requestParams},
            {QStringLiteral("share_title"), QStringLiteral("来自180****6449的设备分享邀请")},
            {"status", 0},
            {"supType", 1},
            {QStringLiteral("target_user_account"), QStringLiteral("133****9556")},
            {QStringLiteral("target_user_id"), QStringLiteral("7c3e829dce803791bd83830e3e97909c")},
            {QStringLiteral("title"), QStringLiteral("180****6449想要分享设备给您")},
            {"type", 1},
            {QStringLiteral("user_role"), QStringLiteral("receiver")},
            {"visible", 1}
        }},
        {"N3X8YMK9JL7XGKPA111A2", QVariantMap{
            {"close_status", 0},
            {QStringLiteral("create_date"), QStringLiteral("20260727")},
            {QStringLiteral("create_time"), QStringLiteral("2026-07-27 13:40:13")},
            {QStringLiteral("device_id"), QStringLiteral("N3X8YMK9JL7XGKPA111A")},
            {QStringLiteral("device_name"), QStringLiteral("B14")},
            {QStringLiteral("extra_field"), QStringLiteral("[201,202,203,204,205]")},
            {QStringLiteral("id"), QStringLiteral("3F_7c3e829dce803791bd83830e3e97909c_20260727_1785130813322_49cebcee")},
            {QStringLiteral("initiator_user_account"), QStringLiteral("180****6449")},
            {QStringLiteral("initiator_user_id"), QStringLiteral("1d38b00daaeb31a5863f78c86866c673")},
            {"read_flag", 0},
            {QStringLiteral("request_params"), requestParams},
            {QStringLiteral("share_title"), QStringLiteral("来自180****6449的设备分享邀请")},
            {"status", 0},
            {"supType", 1},
            {QStringLiteral("target_user_account"), QStringLiteral("133****9556")},
            {QStringLiteral("target_user_id"), QStringLiteral("7c3e829dce803791bd83830e3e97909c")},
            {QStringLiteral("title"), QStringLiteral("180****6449想要分享设备给您")},
            {"type", 1},
            {QStringLiteral("user_role"), QStringLiteral("receiver")},
            {"visible", 1}
        }},
        {"N3X8YMK9JL7XGKPA111A3", QVariantMap{
            {"close_status", 0},
            {QStringLiteral("create_date"), QStringLiteral("20260727")},
            {QStringLiteral("create_time"), QStringLiteral("2026-07-27 13:40:13")},
            {QStringLiteral("device_id"), QStringLiteral("N3X8YMK9JL7XGKPA111A")},
            {QStringLiteral("device_name"), QStringLiteral("B14")},
            {QStringLiteral("extra_field"), QStringLiteral("[201,202,203,204,205]")},
            {QStringLiteral("id"), QStringLiteral("3F_7c3e829dce803791bd83830e3e97909c_20260727_1785130813322_49cebcee")},
            {QStringLiteral("initiator_user_account"), QStringLiteral("180****6449")},
            {QStringLiteral("initiator_user_id"), QStringLiteral("1d38b00daaeb31a5863f78c86866c673")},
            {"read_flag", 0},
            {QStringLiteral("request_params"), requestParams},
            {QStringLiteral("share_title"), QStringLiteral("来自180****6449的设备分享邀请")},
            {"status", 0},
            {"supType", 1},
            {QStringLiteral("target_user_account"), QStringLiteral("133****9556")},
            {QStringLiteral("target_user_id"), QStringLiteral("7c3e829dce803791bd83830e3e97909c")},
            {QStringLiteral("title"), QStringLiteral("180****6449想要分享设备给您")},
            {"type", 1},
            {QStringLiteral("user_role"), QStringLiteral("receiver")},
            {"visible", 1}
        }}
    };
*/
