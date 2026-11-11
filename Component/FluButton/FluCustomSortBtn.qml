import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Component.Button 1.0
import Component.FluComponent 1.0
import FluentUI 1.0
import ScreenTools 1.0

Item{
	id: root
	signal clickValue(int value) // 0 - default  1 - up升序  2 - down降序
	property color textColor: ThemeColorStyle.title_text_nor_color
	property int itemWidth: ScreenTools.scaleNum(16)
	property int itemHeight: ScreenTools.scaleNum(16)
	// 表头内容
	property string headText: ""
	property int fontSize: ScreenTools.scaleNum(10, true)
	property bool isBold: false
	FluText{
		id: textLabel
		objectName: "textLabel"
		text: headText
		anchors.left: parent.left
		anchors.leftMargin: ScreenTools.scaleNum(10)
		anchors.verticalCenter: parent.verticalCenter
		font.family: ScreenTools.fontFamily
		font.pointSize: fontSize
		font.bold: isBold
		textColor: root.textColor
	}
	ColumnLayout{
		spacing: 0
		anchors{
			left: textLabel.right
			verticalCenter: parent.verticalCenter
			leftMargin: ScreenTools.scaleNum(8)
		}

		FluCustomSvg{
			objectName: "upImg"
			imageWidth: root.itemWidth
			imageHeight: root.itemHeight
			Layout.alignment: Qt.AlignVCenter
			needBg: true
			sourceImage: CommonImageStyle.arrow_down_img
			fillColorFirst: (hovered || pressed) ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.tab_text_nor_color
			rotation: 180
			onClicked: {
				root.clickValue(1)
			}
		}
		FluCustomSvg{
			objectName: "downImg"
			imageWidth: root.itemWidth
			imageHeight: root.itemHeight
			needBg: true
			Layout.alignment: Qt.AlignVCenter
			sourceImage: CommonImageStyle.arrow_down_img
			fillColorFirst: (hovered || pressed) ? ThemeColorStyle.privacy_text_color : ThemeColorStyle.tab_text_nor_color
			onClicked: {
				root.clickValue(2)
			}
		}
	}
}
