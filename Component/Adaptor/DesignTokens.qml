pragma Singleton
import QtQuick 2.15
import QtQuick.Window 2.15

/*
 * VMS喵眼精灵 - 设计系统 Design Tokens
 * 从 Figma 设计稿提取的公共元素，提供 px 到 pointSize 的自动转换
 * 
 * 使用方式:
 *   1. 直接获取 pointSize: font.pointSize: DesignTokens.fontPointSize.base
 *   2. 转换 px 到 pointSize: font.pointSize: DesignTokens.pxToPointSize(14)
 */

QtObject {
    id: root

    // ==================== 颜色系统 Color System ====================
    
    readonly property var color: QtObject {
        // 主色调 Primary Colors (从 Figma 设计稿提取)
        readonly property string primaryDefault: "#0099FF"      // 主色/默认
        readonly property string primaryLight: "#E5F5FF"        // 主色/浅色
        readonly property string primaryHover: "#4DB7FF"        // 主色/悬停
        readonly property string primaryClicked: "#0099FF"      // 主色/点击

        // 字体颜色 Text Colors (从 Figma 设计稿提取)
        readonly property string textPrimary: "#1D1F21"         // 字体/主色
        readonly property string textSecondary1: "#6D7682"      // 字体/次级1
        readonly property string textSecondary2: "#989EA6"      // 字体/次级2
        readonly property string textDisabled: "#C6C9CC"        // 字体/禁用
        readonly property string textLink: "#0099FF"            // 字体/链接
        readonly property string textWhite: "#FFFFFF"           // 字体/白色（深色背景用）

        // 背景颜色 Background Colors (从 Figma 设计稿提取)
        readonly property string bgPage: "#F5F7FA"              // 页面背景
        readonly property string bgCard: "#FFFFFF"              // 卡片背景
        readonly property string bgHover: "#F5F5F5"             // 悬停背景
        readonly property string bgSelected: "#E5F5FF"          // 选中背景
        readonly property string bgMask: "#73000000"            // 遮罩层 (45%透明度)

        // 功能色 Auxiliary Colors
        readonly property string success: "#52C41A"             // 成功
        readonly property string warning: "#FAAD14"             // 警告
        readonly property string error: "#FF4D4F"               // 错误
        readonly property string info: "#1890FF"                // 信息

        // 中性色 Neutral Colors
        readonly property string pureWhite: "#FFFFFF"            // 纯白
        readonly property string veryLightGray: "#FAFAFA"        // 极浅灰
        readonly property string lightGray: "#F5F5F5"            // 浅灰
        readonly property string bgGray: "#F0F0F0"               // 背景灰
        readonly property string borderGray: "#CAD2DD"           // 边框灰
        readonly property string disabledGray: "#BFBFBF"         // 禁用灰
        readonly property string secondaryTextGray: "#8C8C8C"    // 次级文字灰
        readonly property string bodyGray: "#595959"             // 正文灰
        readonly property string darkGray: "#434343"             // 深灰
        readonly property string titleGray: "#262626"            // 标题灰
        readonly property string veryDarkGray: "#1F1F1F"         // 极深灰
        readonly property string nearBlack: "#141414"            // 近黑
        readonly property string pureBlack: "#000000"            // 纯黑

        // 分割线和边框 (从 Figma 设计稿提取)
        readonly property string divider: "#EDEFF2"             // 通用/分割
        readonly property string border: "#CAD2DD"              // 通用/描边
        readonly property string primaryBorder: "#0099FF"       // 主色/边框
    }

    // ==================== 字体系统 Typography ====================
    
    // 字体家族 Font Family
    readonly property var fontFamily: QtObject {
        readonly property var cn: ["PingFang SC", "Microsoft YaHei", "Hiragino Sans GB", "sans-serif"]
        readonly property var en: ["SF Pro Display", "Helvetica Neue", "Arial", "sans-serif"]
    }
    
    // 字体大小 - px 值 (设计稿原始值)
    readonly property var fontSize: QtObject {
        readonly property int px36: 36          // 大标题/Display
        readonly property int px24: 24          // 标题/Title
        readonly property int px20: 20          // 副标题/Subtitle
        readonly property int px16: 16          // 大号文字/Large
        readonly property int px14: 14          // 基础文字/Base
        readonly property int px12: 12          // 小号文字/Small
        readonly property int px10: 10          // 迷你文字/Mini
    }
    
    // 字体大小 - pointSize 值 (QML 直接使用)
    readonly property var fontPointSize: QtObject {
        readonly property int pt27: 27          // 对应 36px
        readonly property int pt18: 18          // 对应 24px
        readonly property int pt15: 15          // 对应 20px
        readonly property int pt12: 12          // 对应 16px
        readonly property int pt11: 11          // 对应 14px (四舍五入)
        readonly property int pt9: 9            // 对应 12px
        readonly property int pt8: 8            // 对应 10px (四舍五入)
    }
    
    // 字重 Font Weight
    readonly property var fontWeight: QtObject {
        readonly property int regular: Font.Normal      // 400
        readonly property int medium: Font.Medium       // 500
        readonly property int semibold: Font.DemiBold   // 600
        readonly property int bold: Font.Bold           // 700
    }
    
    // 行高 Line Height (倍数)
    readonly property var lineHeight: QtObject {
        readonly property real tight: 1.25      // 紧凑
        readonly property real normal: 1.5      // 正常
        readonly property real loose: 1.75      // 宽松
    }

    // ==================== 间距系统 Spacing ====================
    
    // 基础间距 (4px 网格)
    readonly property var spacing: QtObject {
        readonly property int s0: 0
        readonly property int s4: 4           // 迷你
        readonly property int s8: 8           // 小
        readonly property int s12: 12         // 较小
        readonly property int s16: 16         // 中
        readonly property int s20: 20         // 较大
        readonly property int s24: 24         // 大
    }

    // ==================== 圆角系统 Border Radius ====================
    
    readonly property var radius: QtObject {
        readonly property int radius0: 0
        readonly property int radius2: 2           // 小圆角
        readonly property int radius4: 4           // 基础圆角
        readonly property int radius8: 8           // 中等圆角
        readonly property int radius12: 12         // 大圆角
        readonly property int radius16: 16         // 超大圆角
        readonly property int radius24: 24         // 2倍大圆角
        readonly property int radius50: 50         // 全圆角/胶囊
        readonly property string percent100: "100%"  // 圆形
    }

    // ==================== 图标尺寸 Icon Sizes ====================
    
    readonly property var iconSize: QtObject {
        readonly property int size10: 10      // 超小
        readonly property int size12: 12      // 小
        readonly property int size14: 14      // 基础
        readonly property int size16: 16      // 中
        readonly property int size20: 20      // 大
        readonly property int size24: 24      // 超大
        readonly property int size32: 32      // 2倍大
        readonly property int size48: 48      // 3倍大
    }

    // ==================== 组件高度 Component Heights ====================
    
    readonly property var height: QtObject {
        readonly property int btn24: 24
        readonly property int btn28: 28
        readonly property int btn32: 32
        readonly property int btn40: 40
        readonly property int input32: 32
        readonly property int input40: 40
        readonly property int header64: 64
        readonly property int tab48: 48
    }

    // ==================== 过渡动画 Transition ====================
    
    readonly property var duration: QtObject {
        readonly property int instant: 0
        readonly property int fast: 100
        readonly property int normal: 200
        readonly property int slow: 300
        readonly property int slower: 400
    }
    
    readonly property var easing: QtObject {
        readonly property var linear: Easing.Linear
        readonly property var inQuad: Easing.InQuad
        readonly property var outQuad: Easing.OutQuad
        readonly property var inOutQuad: Easing.InOutQuad
        readonly property var outBack: Easing.OutBack  // 弹性效果
    }

    // ==================== Z-Index 层级 ====================
    
    readonly property var zIndex: QtObject {
        readonly property int dropdown: 1000
        readonly property int sticky: 1020
        readonly property int fixed: 1030
        readonly property int modalBackdrop: 1040
        readonly property int modal: 1050
        readonly property int popover: 1060
        readonly property int tooltip: 1070
        readonly property int toast: 1080
    }

    // ==================== 工具函数 Utility Functions ====================
    
    /*
     * 将 px 转换为 pointSize
     * 转换公式: pointSize = px * 0.75 (基于 96 DPI)
     * 
     * 参数:
     *   px: 设计稿中的像素值
     *   round: 是否四舍五入 (默认 true)
     * 
     * 返回:
     *   转换后的 pointSize 值
     * 
     * 使用示例:
     *   font.pointSize: DesignTokens.pxToPointSize(14)  // 返回 10.5 或 11
     */
    function pxToPointSize(px, round = false) {
        if (round === undefined) round = true
        var pointSize = px * 0.75
        return round ? Math.round(pointSize) : pointSize
    }
    
    /*
     * 根据设计稿 px 值获取最接近的预设 pointSize
     * 
     * 使用示例:
     *   font.pointSize: DesignTokens.getFontPointSize(14)  // 返回 11
     */
    function getFontPointSize(px) {
        switch (px) {
            case 36: return fontPointSize.pt27
            case 24: return fontPointSize.pt18
            case 20: return fontPointSize.pt15
            case 16: return fontPointSize.pt12
            case 14: return fontPointSize.pt11
            case 12: return fontPointSize.pt9
            case 10: return fontPointSize.pt8
            default: return pxToPointSize(px)
        }
    }
    
    /*
     * 创建字体对象
     * 
     * 使用示例:
     *   font: DesignTokens.createFont(14, Font.Medium)
     */
    function createFont(pxSize, weight, family) {
        if (weight === undefined) weight = fontWeight.regular
        if (family === undefined) family = fontFamily.cn
        return Qt.font({
            pointSize: getFontPointSize(pxSize),
            weight: weight,
            family: family
        })
    }
}
