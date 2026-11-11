import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import ScreenTools 1.0
import Component.FluComponent 1.0

FluLoader{
	id: root
	signal clicked()
    signal updateImage(bool isHover)
    property string normalImageUrl: ""
    property string hoverImageUrl: normalImageUrl
    property string pressedImageUrl: hoverImageUrl
    property string tooltipText: ""
    property bool toolTipVisible: false
    property bool isChecked: false
    property bool needAutoScale: false          // 是否需要自动缩放, 默认不自动缩放, 部分图片自动缩放后变得模糊
	property int imageWidth: ScreenTools.scaleNum(16)
	property int imageHeight: ScreenTools.scaleNum(16)
    property bool clickChangeImageEnable: false
    onIsCheckedChanged: {
        root.updateImage()
    }

    function updateSourceImg(isHover){
        root.updateImage(isHover)
    }
	

	sourceComponent: Loader {
		width: imageWidth
		height: imageHeight
		sourceComponent: FluCustomImage{
			id: control
			normalImageUrl: root.normalImageUrl
			hoverImageUrl: root.hoverImageUrl
			pressedImageUrl: root.pressedImageUrl
			tooltipText: root.tooltipText
			toolTipVisible: root.toolTipVisible
			width: imageWidth
			height: imageHeight
			isChecked: root.isChecked
			needAutoScale: root.needAutoScale
			clickChangeImageEnable: root.clickChangeImageEnable
			onClicked: {
				root.clicked()
			}
			Connections {
				target: root
				function onUpdateImage(isHover) {
					control.updateSourceImg(isHover)
				}
			}
		}
	}
}

