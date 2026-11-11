import QtQuick 2.15
import QtQuick.Controls 2.15
import ScreenTools 1.0

Item {
    id: root
    width: ScreenTools.scaleNum(300)
    height: ScreenTools.scaleNum(200)

    // 四个角半径
    property real topLeftRadius: ScreenTools.scaleNum(20)
    property real topRightRadius: ScreenTools.scaleNum(10)
    property real bottomRightRadius: ScreenTools.scaleNum(30)
    property real bottomLeftRadius: ScreenTools.scaleNum(15)

    // 样式
    property color fillColor: "red"
    property color borderColor: "transparent"
    property int borderWidth: 1

    // ====================== 新增：四条边独立开关 ======================
    property bool borderTop: true
    property bool borderRight: true
    property bool borderBottom: true
    property bool borderLeft: true
    // =================================================================

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var w = width;
            var h = height;
            var bw = root.borderWidth;
            var offset = bw / 2;

            var tl = Math.min(Math.max(root.topLeftRadius, 0), Math.min(w,h)/2);
            var tr = Math.min(Math.max(root.topRightRadius, 0), Math.min(w,h)/2);
            var br = Math.min(Math.max(root.bottomRightRadius, 0), Math.min(w,h)/2);
            var bl = Math.min(Math.max(root.bottomLeftRadius, 0), Math.min(w,h)/2);

            // -------------------------- 1. 先画填充区域（完整） --------------------------
            ctx.beginPath();
            ctx.moveTo(tl + offset, offset);
            ctx.lineTo(w - tr - offset, offset);
            ctx.arcTo(w - offset, offset, w - offset, tr + offset, tr);
            ctx.lineTo(w - offset, h - br - offset);
            ctx.arcTo(w - offset, h - offset, w - br - offset, h - offset, br);
            ctx.lineTo(bl + offset, h - offset);
            ctx.arcTo(offset, h - offset, offset, h - bl - offset, bl);
            ctx.lineTo(offset, tl + offset);
            ctx.arcTo(offset, offset, tl + offset, offset, tl);
            ctx.closePath();
            ctx.fillStyle = root.fillColor;
            ctx.fill();

            // -------------------------- 2. 分段画边框：只画需要的边 --------------------------
            if (bw <= 0) return;

            ctx.lineWidth = bw;
            ctx.strokeStyle = root.borderColor;

            // 上边
            if (root.borderTop) {
                ctx.beginPath();
                ctx.moveTo(tl + offset, offset);
                ctx.lineTo(w - tr - offset, offset);
                ctx.arcTo(w - offset, offset, w - offset, tr + offset, tr);
                ctx.stroke();
            }

            // 右边（你可以关闭）
            if (root.borderRight) {
                ctx.beginPath();
                ctx.moveTo(w - offset, tr + offset);
                ctx.lineTo(w - offset, h - br - offset);
                ctx.arcTo(w - offset, h - offset, w - br - offset, h - offset, br);
                ctx.stroke();
            }

            // 下边
            if (root.borderBottom) {
                ctx.beginPath();
                ctx.moveTo(w - br - offset, h - offset);
                ctx.lineTo(bl + offset, h - offset);
                ctx.arcTo(offset, h - offset, offset, h - bl - offset, bl);
                ctx.stroke();
            }

            // 左边
            if (root.borderLeft) {
                ctx.beginPath();
                ctx.moveTo(offset, h - bl - offset);
                ctx.lineTo(offset, tl + offset);
                ctx.arcTo(offset, offset, tl + offset, offset, tl);
                ctx.stroke();
            }
        }
    }

    // 重绘绑定（全）
    onTopLeftRadiusChanged: canvas.requestPaint()
    onTopRightRadiusChanged: canvas.requestPaint()
    onBottomRightRadiusChanged: canvas.requestPaint()
    onBottomLeftRadiusChanged: canvas.requestPaint()
    onFillColorChanged: canvas.requestPaint()
    onBorderColorChanged: canvas.requestPaint()
    onBorderWidthChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onBorderTopChanged: canvas.requestPaint()
    onBorderRightChanged: canvas.requestPaint()
    onBorderBottomChanged: canvas.requestPaint()
    onBorderLeftChanged: canvas.requestPaint()

    // 动画
    Behavior on topLeftRadius { NumberAnimation { duration: 200 } }
    Behavior on topRightRadius { NumberAnimation { duration: 200 } }
    Behavior on bottomRightRadius { NumberAnimation { duration: 200 } }
    Behavior on bottomLeftRadius { NumberAnimation { duration: 200 } }
}
