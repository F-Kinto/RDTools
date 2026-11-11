import QtQuick 2.15
import QtQuick.Window 2.15
import RDTools.Public 1.0

/// 截屏选区 + 编辑覆盖层
Window {
    id: overlay
    objectName: "screencaptureOverlay"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    x: 0; y: 0
    width: Screen.width; height: Screen.height

    /* ═══════════ 阶段 ═══════════ */
    property string phase: "idle"   // idle | selecting | editing

    /* ═══════════ 选区 ═══════════ */
    property real selStartX: 0; property real selStartY: 0
    property real selW: 0;      property real selH: 0
    readonly property real selX: Math.min(selStartX, selStartX + selW)
    readonly property real selY: Math.min(selStartY, selStartY + selH)
    readonly property real selWidth:  Math.abs(selW)
    readonly property real selHeight: Math.abs(selH)

    /* ═══════════ 编辑状态 ═══════════ */
    property string toolMode: ""  // "" | pen | arrow | text | mosaic
    property var    drawOps: []
    property color  penColor:   "#ff0000"
    property real   penWidth:   3
    property color  arrowColor: "#ff0000"
    property real   arrowWidth: 3
    property color  textColor:  "#ff0000"
    property int    textSize:   18
    property string editImageSrc: ""  // 旋转后图片 URL

    readonly property string canvasTemp: ScreenCapture.tempDir() + "/rdtools_canvas_overlay.png"

    /* ──────── 1. 截屏背景 ──────── */
    Image {
        anchors.fill: parent
        source: ScreenCapture.capturedImagePath
        fillMode: Image.Pad; cache: false
    }

    /* ──────── 2. 暗色遮罩（4 矩形镂空） ──────── */
    Rectangle {                                  // 上
        color: Qt.rgba(0,0,0,0.35)
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: phase !== "idle" ? overlay.selY : parent.height
    }
    Rectangle {                                  // 下
        color: Qt.rgba(0,0,0,0.35)
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: phase !== "idle" ? parent.height - overlay.selY - overlay.selHeight : 0
        visible: phase !== "idle"
    }
    Rectangle {                                  // 左
        color: Qt.rgba(0,0,0,0.35)
        y: overlay.selY; height: overlay.selHeight; anchors.left: parent.left
        width: phase !== "idle" ? overlay.selX : 0; visible: phase !== "idle"
    }
    Rectangle {                                  // 右
        color: Qt.rgba(0,0,0,0.35)
        y: overlay.selY; height: overlay.selHeight; anchors.right: parent.right
        width: phase !== "idle" ? parent.width - overlay.selX - overlay.selWidth : 0
        visible: phase !== "idle"
    }

    /* ──────── 3. 编辑图覆盖（旋转后图片） ──────── */
    Image {
        x: overlay.selX; y: overlay.selY
        width: overlay.selWidth; height: overlay.selHeight
        source: overlay.editImageSrc
        visible: overlay.editImageSrc !== "" && overlay.phase === "editing"
        fillMode: Image.Pad; cache: false
    }

    /* ──────── 4. 选区边框 ──────── */
    Rectangle {
        x: overlay.selX; y: overlay.selY
        width: overlay.selWidth; height: overlay.selHeight
        color: "transparent"; border.color: "#0080ff"; border.width: 2
        visible: phase === "selecting"
    }

    /* ──────── 5. 编辑区域边框（虚线） ──────── */
    Rectangle {
        x: overlay.selX; y: overlay.selY
        width: overlay.selWidth; height: overlay.selHeight
        color: "transparent"; border.color: "#0080ff"; border.width: 1
        visible: phase === "editing"
    }

    /* ──────── 6. 尺寸标签 ──────── */
    Text {
        x: overlay.selX; y: overlay.selY + overlay.selHeight + 4
        text: Math.round(overlay.selWidth) + " x " + Math.round(overlay.selHeight)
        color: "white"; font.family: "微软雅黑"; font.pointSize: 10
        style: Text.Outline; styleColor: "black"
        visible: phase === "selecting" && overlay.selWidth > 40
    }

    /* ──────── 7. 提示文字 ──────── */
    Text {
        anchors.centerIn: parent
        text: "点击并拖动选择截屏区域\n按 Esc 取消"
        color: "white"; font.family: "微软雅黑"; font.pointSize: 10; font.bold: true
        style: Text.Outline; styleColor: "black"
        horizontalAlignment: Text.AlignHCenter
        visible: phase === "idle"
    }

    /* ──────── 8. Canvas 编辑层 ──────── */
    Canvas {
        id: editCanvas
        x: overlay.selX; y: overlay.selY
        width: overlay.selWidth; height: overlay.selHeight
        visible: phase === "editing"
        contextType: "2d"

        property var currentPreview: null

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            for (var i = 0; i < drawOps.length; i++)
                drawOp(ctx, drawOps[i]);
            if (currentPreview)
                drawOp(ctx, currentPreview);
        }

        onImageLoaded: {
            // 马赛克图像加载完成，触发重绘
            requestPaint();
        }
    }

    /* ──────── 9. 按钮悬浮提示 ──────── */
    Rectangle {
        id: btnTooltip
        visible: false; z: 25
        color: Qt.rgba(0,0,0,0.85); radius: 4
        border.width: 1; border.color: "#666"
        width: btnTooltipText.implicitWidth + 14
        height: btnTooltipText.implicitHeight + 8
        property point anchorPos: Qt.point(0, 0)
        x: anchorPos.x - width / 2
        y: anchorPos.y - height
        Text {
            id: btnTooltipText
            anchors.centerIn: parent
            color: "white"; font.family: "微软雅黑"; font.pointSize: 10
        }
    }
    function showTooltip(item, text) {
        btnTooltipText.text = text;          // 先设文本让 width/height 生效
        var pos = item.mapToItem(null, item.width / 2, -6);
        btnTooltip.anchorPos = pos;          // 绑定式定位，width 变化自动居中
        btnTooltip.visible = true;
    }

    /* ──────── 10. 工具栏 ──────── */
    Row {
        id: toolbar
        visible: phase === "editing"
        spacing: 3; z: 10
        x: overlay.selX + overlay.selWidth / 2 - width / 2
        y: {
            var below = overlay.selY + overlay.selHeight + 6;
            var above = overlay.selY - height - 6;
            return (below + height <= overlay.height) ? below
                 : (above >= 0) ? above : below;
        }

        // 完成
        Rectangle {
            id: btn1; width: 36; height: 30; radius: 4
            color: tb1.containsMouse ? "#d0d0d0" : "#f0f0f0"
            border.width: 1; border.color: "#aaa"
            Text { anchors.centerIn: parent; text: "☑️"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: doFinish(); onEntered: showTooltip(btn1, "完成"); onExited: btnTooltip.visible = false }
        }
        // 取消
        Rectangle {
            id: btn2; width: 36; height: 30; radius: 4
            color: tb2.containsMouse ? "#d0d0d0" : "#f0f0f0"
            border.width: 1; border.color: "#aaa"
            Text { anchors.centerIn: parent; text: "❌"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb2; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: doCancel(); onEntered: showTooltip(btn2, "取消"); onExited: btnTooltip.visible = false }
        }
        // 分隔
        Rectangle { width: 1; height: 24; color: "#ccc"; anchors.verticalCenter: parent.verticalCenter }

        // 画笔
        Rectangle {
            id: btn3; width: 36; height: 30; radius: 4
            color: tb3.containsMouse ? "#d0d0d0" : (toolMode === "pen" ? "#c8ddf0" : "#f0f0f0")
            border.width: 1; border.color: toolMode === "pen" ? "#4488cc" : "#aaa"
            Text { anchors.centerIn: parent; text: "✏️"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb3; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: toolMode = (toolMode === "pen" ? "" : "pen"); onEntered: showTooltip(btn3, "画笔标记"); onExited: btnTooltip.visible = false }
        }
        // 箭头
        Rectangle {
            id: btn4; width: 36; height: 30; radius: 4
            color: tb4.containsMouse ? "#d0d0d0" : (toolMode === "arrow" ? "#c8ddf0" : "#f0f0f0")
            border.width: 1; border.color: toolMode === "arrow" ? "#4488cc" : "#aaa"
            Text { anchors.centerIn: parent; text: "➡️"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb4; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: toolMode = (toolMode === "arrow" ? "" : "arrow"); onEntered: showTooltip(btn4, "箭头"); onExited: btnTooltip.visible = false }
        }
        // 文本
        Rectangle {
            id: btn5; width: 36; height: 30; radius: 4
            color: tb5.containsMouse ? "#d0d0d0" : (toolMode === "text" ? "#c8ddf0" : "#f0f0f0")
            border.width: 1; border.color: toolMode === "text" ? "#4488cc" : "#aaa"
            Text { anchors.centerIn: parent; text: "🔤"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb5; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: toolMode = (toolMode === "text" ? "" : "text"); onEntered: showTooltip(btn5, "添加文本"); onExited: btnTooltip.visible = false }
        }
        // 马赛克
        Rectangle {
            id: btn6; width: 36; height: 30; radius: 4
            color: tb6.containsMouse ? "#d0d0d0" : (toolMode === "mosaic" ? "#c8ddf0" : "#f0f0f0")
            border.width: 1; border.color: toolMode === "mosaic" ? "#4488cc" : "#aaa"
            Text { anchors.centerIn: parent; text: "🔲"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb6; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: toolMode = (toolMode === "mosaic" ? "" : "mosaic"); onEntered: showTooltip(btn6, "马赛克"); onExited: btnTooltip.visible = false }
        }
        // 分隔
        Rectangle { width: 1; height: 24; color: "#ccc"; anchors.verticalCenter: parent.verticalCenter }

        // 提取文字
        Rectangle {
            id: btn7; width: 36; height: 30; radius: 4
            color: tb7.containsMouse ? "#d0d0d0" : "#f0f0f0"
            border.width: 1; border.color: "#aaa"
            Text { anchors.centerIn: parent; text: "📝"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb7; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: doOCR(); onEntered: showTooltip(btn7, "提取文字"); onExited: btnTooltip.visible = false }
        }
        // 翻译
        Rectangle {
            id: btn8; width: 36; height: 30; radius: 4
            color: tb8.containsMouse ? "#d0d0d0" : "#f0f0f0"
            border.width: 1; border.color: "#aaa"
            Text { anchors.centerIn: parent; text: "🌐"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb8; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: doTranslate(); onEntered: showTooltip(btn8, "翻译"); onExited: btnTooltip.visible = false }
        }
        // 保存本地
        Rectangle {
            id: btn9; width: 36; height: 30; radius: 4
            color: tb9.containsMouse ? "#d0d0d0" : "#f0f0f0"
            border.width: 1; border.color: "#aaa"
            Text { anchors.centerIn: parent; text: "💾"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb9; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: doSave(); onEntered: showTooltip(btn9, "保存本地"); onExited: btnTooltip.visible = false }
        }
        // 旋转90°
        Rectangle {
            id: btn10; width: 36; height: 30; radius: 4
            color: tb10.containsMouse ? "#d0d0d0" : "#f0f0f0"
            border.width: 1; border.color: "#aaa"
            Text { anchors.centerIn: parent; text: "🔄"; font.family: "微软雅黑"; font.pointSize: 10 }
            MouseArea { id: tb10; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: doRotate(); onEntered: showTooltip(btn10, "旋转90°"); onExited: btnTooltip.visible = false }
        }
    }

    /* ──────── 10. 文本输入框 ──────── */
    TextInput {
        id: textInput
        visible: false; z: 20
        color: overlay.textColor
        font.family: "微软雅黑"; font.pixelSize: overlay.textSize; font.bold: true
        width: 200; height: overlay.textSize + 8
        horizontalAlignment: TextInput.AlignLeft
        cursorVisible: true

        onAccepted: commitText()
        onActiveFocusChanged: { if (!activeFocus && visible) commitText(); }
        Keys.onEscapePressed: { visible = false; text = ""; toolMode = ""; }

        function commitText() {
            if (text.length > 0) {
                drawOps = drawOps.concat([{
                    type: "text",
                    x: textInput.x - overlay.selX,
                    y: textInput.y - overlay.selY + font.pixelSize,
                    text: text,
                    color: overlay.textColor.toString(),
                    size: overlay.textSize
                }]);
                editCanvas.requestPaint();
            }
            visible = false; text = ""; toolMode = "";
        }
    }

    /* ──────── 11. 消息提示 ──────── */
    Rectangle {
        id: statusMsg
        visible: false; z: 30
        anchors.centerIn: parent
        color: Qt.rgba(0,0,0,0.75); radius: 8
        implicitWidth: statusText.implicitWidth + 28
        implicitHeight: statusText.implicitHeight + 14
        Text {
            id: statusText
            anchors.centerIn: parent
            color: "white"; font.family: "微软雅黑"; font.pointSize: 10; font.bold: true
            style: Text.Outline; styleColor: "black"
        }
    }
    Timer { id: statusTimer; interval: 2000; onTriggered: statusMsg.visible = false }

    /* ═══════════ 鼠标交互 ═══════════ */

    /* ── 选区 MouseArea ── */
    MouseArea {
        id: selectMouse
        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        visible: phase !== "editing"

        onPressed: {
            selStartX = mouse.x; selStartY = mouse.y;
            selW = 0; selH = 0;
            phase = "selecting";
        }
        onPositionChanged: {
            if (phase === "selecting") {
                selW = mouse.x - selStartX;
                selH = mouse.y - selStartY;
            }
        }
        onReleased: {
            if (phase === "selecting") {
                if (selWidth > 5 && selHeight > 5) {
                    phase = "editing"; toolMode = "";
                    drawOps = []; editImageSrc = "";
                    ScreenCapture.prepareEditBase(
                        Math.round(overlay.selX), Math.round(overlay.selY),
                        Math.round(overlay.selWidth), Math.round(overlay.selHeight));
                } else {
                    phase = "idle"; selW = 0; selH = 0;
                    ScreenCapture.cancelCapture();
                    // 由 captureCancelled 信号（延迟 100ms）统一隐藏，避免黑闪
                }
            }
        }
    }

    /* ── 编辑 MouseArea ── */
    property real mosaicSX: 0; property real mosaicSY: 0

    MouseArea {
        id: editMouse
        x: overlay.selX; y: overlay.selY
        width: overlay.selWidth; height: overlay.selHeight
        visible: phase === "editing" && toolMode !== "" && toolMode !== "text"
        cursorShape: Qt.CrossCursor; z: 5

        onPressed: {
            if (toolMode === "pen") {
                editCanvas.currentPreview = {
                    type: "pen",
                    points: [{x: mouse.x, y: mouse.y}],
                    color: overlay.penColor.toString(),
                    width: overlay.penWidth
                };
                editCanvas.requestPaint();
            } else if (toolMode === "arrow") {
                editCanvas.currentPreview = {
                    type: "arrow",
                    from: {x: mouse.x, y: mouse.y},
                    to:   {x: mouse.x, y: mouse.y},
                    color: overlay.arrowColor.toString(),
                    width: overlay.arrowWidth
                };
                editCanvas.requestPaint();
            } else if (toolMode === "mosaic") {
                overlay.mosaicSX = mouse.x; overlay.mosaicSY = mouse.y;
                editCanvas.currentPreview = { type: "mosaic", x: mouse.x, y: mouse.y, w: 0, h: 0 };
                editCanvas.requestPaint();
            }
        }
        onPositionChanged: {
            if (!pressed) return;
            if (toolMode === "pen" && editCanvas.currentPreview) {
                var pts = editCanvas.currentPreview.points;
                pts = pts.concat([{x: mouse.x, y: mouse.y}]);
                editCanvas.currentPreview = {
                    type: "pen", points: pts,
                    color: overlay.penColor.toString(),
                    width: overlay.penWidth
                };
                editCanvas.requestPaint();
            } else if (toolMode === "arrow" && editCanvas.currentPreview) {
                var f = editCanvas.currentPreview.from;
                editCanvas.currentPreview = {
                    type: "arrow", from: f, to: {x: mouse.x, y: mouse.y},
                    color: overlay.arrowColor.toString(),
                    width: overlay.arrowWidth
                };
                editCanvas.requestPaint();
            } else if (toolMode === "mosaic") {
                var sx = Math.min(overlay.mosaicSX, mouse.x);
                var sy = Math.min(overlay.mosaicSY, mouse.y);
                var sw = Math.abs(mouse.x - overlay.mosaicSX);
                var sh = Math.abs(mouse.y - overlay.mosaicSY);
                editCanvas.currentPreview = { type: "mosaic", x: sx, y: sy, w: sw, h: sh };
                editCanvas.requestPaint();
            }
        }
        onReleased: {
            if (toolMode === "pen" && editCanvas.currentPreview) {
                drawOps = drawOps.concat([editCanvas.currentPreview]);
                editCanvas.currentPreview = null;
                editCanvas.requestPaint();
            } else if (toolMode === "arrow" && editCanvas.currentPreview) {
                drawOps = drawOps.concat([editCanvas.currentPreview]);
                editCanvas.currentPreview = null;
                editCanvas.requestPaint();
            } else if (toolMode === "mosaic" && editCanvas.currentPreview) {
                if (editCanvas.currentPreview.w > 3 && editCanvas.currentPreview.h > 3) {
                    var m = editCanvas.currentPreview;
                    var src = ScreenCapture.mosaicRegion(Math.round(m.x), Math.round(m.y),
                                                         Math.round(m.w), Math.round(m.h), 12);
                    drawOps = drawOps.concat([{ type: "mosaic", x: m.x, y: m.y, w: m.w, h: m.h, src: src }]);
                }
                editCanvas.currentPreview = null;
                editCanvas.requestPaint();
            }
        }
    }

    /* ── 文本放置点击区 ── */
    MouseArea {
        id: textClickArea
        x: overlay.selX; y: overlay.selY
        width: overlay.selWidth; height: overlay.selHeight
        visible: phase === "editing" && toolMode === "text"
        cursorShape: Qt.IBeamCursor; z: 5

        onClicked: {
            textInput.x = overlay.selX + mouse.x;
            textInput.y = overlay.selY + mouse.y;
            textInput.visible = true;
            textInput.text = "";
            textInput.forceActiveFocus();
        }
    }

    /* ═══════════ 快捷键 ═══════════ */
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (phase === "editing") {
                if (textInput.visible) {
                    textInput.visible = false; textInput.text = ""; return;
                }
                if (toolMode !== "") {
                    toolMode = "";
                    editCanvas.currentPreview = null;
                    editCanvas.requestPaint();
                    return;
                }
                doCancel();
            } else {
                doCancel();
            }
        }
    }

    /* ═══════════ Canvas 绘制 ═══════════ */
    function drawOp(ctx, op) {
        if (!op) return;
        ctx.save();
        switch (op.type) {

        case "pen":
            if (op.points && op.points.length > 1) {
                ctx.strokeStyle = op.color || "#ff0000";
                ctx.lineWidth   = op.width || 3;
                ctx.lineCap     = "round";
                ctx.lineJoin    = "round";
                ctx.beginPath();
                ctx.moveTo(op.points[0].x, op.points[0].y);
                for (var i = 1; i < op.points.length; i++)
                    ctx.lineTo(op.points[i].x, op.points[i].y);
                ctx.stroke();
            }
            break;

        case "arrow":
            if (op.from && op.to) {
                ctx.strokeStyle = op.color || "#ff0000";
                ctx.fillStyle   = op.color || "#ff0000";
                ctx.lineWidth   = op.width || 3;
                ctx.lineCap     = "round";
                // 线段
                ctx.beginPath();
                ctx.moveTo(op.from.x, op.from.y);
                ctx.lineTo(op.to.x, op.to.y);
                ctx.stroke();
                // 箭头
                var dx = op.to.x - op.from.x;
                var dy = op.to.y - op.from.y;
                var len = Math.sqrt(dx * dx + dy * dy);
                if (len > 10) {
                    var hl = Math.min(20, len * 0.3);
                    var a  = Math.atan2(dy, dx);
                    ctx.beginPath();
                    ctx.moveTo(op.to.x, op.to.y);
                    ctx.lineTo(op.to.x - hl * Math.cos(a - Math.PI / 6),
                               op.to.y - hl * Math.sin(a - Math.PI / 6));
                    ctx.lineTo(op.to.x - hl * Math.cos(a + Math.PI / 6),
                               op.to.y - hl * Math.sin(a + Math.PI / 6));
                    ctx.closePath();
                    ctx.fill();
                }
            }
            break;

        case "text":
            if (op.text) {
                ctx.fillStyle = op.color || "#ff0000";
                ctx.font = "bold " + (op.size || 16) + "px sans-serif";
                ctx.fillText(op.text, op.x, op.y);
            }
            break;

        case "mosaic":
            if (op.w > 0 && op.h > 0) {
                if (op.src) {
                    if (editCanvas.isImageLoaded(op.src)) {
                        // 已像素化且图像已加载：绘制真实像素化图像
                        ctx.drawImage(op.src, op.x, op.y, op.w, op.h);
                    } else {
                        // 图像尚未加载，触发异步加载并画占位
                        if (!editCanvas.isImageLoading(op.src))
                            editCanvas.loadImage(op.src);
                        ctx.fillStyle = "rgba(180,180,180,0.7)";
                        ctx.fillRect(op.x, op.y, op.w, op.h);
                        ctx.strokeStyle = "#888";
                        ctx.lineWidth = 1;
                        ctx.strokeRect(op.x, op.y, op.w, op.h);
                    }
                } else {
                    // 预览中：半透明遮罩
                    ctx.fillStyle = "rgba(180,180,180,0.7)";
                    ctx.fillRect(op.x, op.y, op.w, op.h);
                    ctx.strokeStyle = "#888";
                    ctx.lineWidth = 1;
                    ctx.strokeRect(op.x, op.y, op.w, op.h);
                }
            }
            break;
        }
        ctx.restore();
    }

    /* ═══════════ 操作 ═══════════ */

    function doFinish() {
        editCanvas.currentPreview = null;
        editCanvas.requestPaint();
        finishTimer.start();
    }
    Timer {
        id: finishTimer; interval: 80
        onTriggered: {
            editCanvas.save(canvasTemp);
            overlay.phase = "idle";
            overlay.drawOps = [];
            overlay.editImageSrc = "";
            ScreenCapture.finishCapture(canvasTemp);
            // 不在此处设 overlay.visible = false，由 captureFinished 信号（延迟 100ms）统一隐藏，避免黑闪
        }
    }

    function doCancel() {
        phase = "idle"; drawOps = []; editImageSrc = "";
        editCanvas.currentPreview = null;
        ScreenCapture.cancelCapture();
        // 不在此处设 overlay.visible = false，由 captureCancelled 信号（延迟 100ms）统一隐藏，避免黑闪
    }

    function doSave() {
        editCanvas.currentPreview = null;
        editCanvas.requestPaint();
        saveTimer.start();
    }
    Timer {
        id: saveTimer; interval: 80
        onTriggered: {
            editCanvas.save(canvasTemp);
            ScreenCapture.compositeOnly(canvasTemp);
            var path = ScreenCapture.suggestSavePath();
            if (ScreenCapture.saveToFile(path)) {
                statusText.text = "已保存: " + path;
                statusMsg.visible = true;
                statusTimer.start();
            }
        }
    }

    function doRotate() {
        editCanvas.currentPreview = null;
        editCanvas.requestPaint();
        rotateTimer.start();
    }
    Timer {
        id: rotateTimer; interval: 80
        onTriggered: {
            editCanvas.save(canvasTemp);
            ScreenCapture.rotateEditImage(canvasTemp);
        }
    }

    function doOCR() {
        statusText.text = "提取文字功能开发中…"; statusMsg.visible = true; statusTimer.start();
    }

    function doTranslate() {
        statusText.text = "翻译功能开发中…"; statusMsg.visible = true; statusTimer.start();
    }

    /* ── 旋转结果回调 ── */
    Connections {
        target: ScreenCapture
        function onEditImageChanged() {
            if (ScreenCapture.editImagePath !== "") {
                overlay.editImageSrc = ScreenCapture.editImagePath;

                // 以原选区中心为基准，旋转后宽高互换
                var oldCX = overlay.selX + overlay.selWidth / 2;
                var oldCY = overlay.selY + overlay.selHeight / 2;
                var newW = ScreenCapture.editImageWidth;
                var newH = ScreenCapture.editImageHeight;

                // 新选区左上角 = 中心 - 新宽高一半，并限制不超出屏幕
                var newStartX = Math.max(0, Math.min(oldCX - newW / 2, overlay.width  - newW));
                var newStartY = Math.max(0, Math.min(oldCY - newH / 2, overlay.height - newH));

                overlay.selStartX = newStartX;
                overlay.selStartY = newStartY;
                overlay.selW = newW;
                overlay.selH = newH;

                overlay.drawOps = [];
                editCanvas.currentPreview = null;
                editCanvas.requestPaint();
            }
        }
    }

    onVisibleChanged: {
        if (visible) { requestActivate(); phase = "idle"; }
    }
}
