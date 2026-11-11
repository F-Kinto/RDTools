#include "screentools.h"

#include <cmath>
#include <QFontMetrics>
#include <QGuiApplication>
#include <QRect>
#include <QScreen>
#include <QSysInfo>

#include <Windows.h>

ScreenTools* ScreenTools::m_instance = nullptr;

ScreenTools::ScreenTools(QObject* parent) : QObject(parent)
{
    reset();
}

ScreenTools::~ScreenTools() {}

ScreenTools* ScreenTools::instance()
{
    if (!m_instance)
        m_instance = new ScreenTools();
    return m_instance;
}

/**
 * @brief 初始化 / 重新计算所有适配参数（屏幕切换或 DPI 变化后可再次调用）
 */
void ScreenTools::reset()
{
    m_mbxPixelRatio = getCurrentDevicePixelRatio();
    m_scaleInt      = static_cast<int>(m_mbxPixelRatio * 100) / 100;
    m_scaleFrac     = static_cast<int>(m_mbxPixelRatio * 100) % 100;
    getScreenWidHeight();
    m_fontFamily   = "微软雅黑";
    m_isWin7System = getSystemIsWin7();
    getOutOfScreen();
}

/**
 * @brief 读取系统 DPI 缩放比
 *
 * 用 GetDpiForSystem 动态取（Win10 1607+ 才有该导出），
 * 取不到时返回 1.0，保证老系统也能启动。
 */
qreal ScreenTools::getCurrentDevicePixelRatio() const
{
    HMODULE hUser32 = GetModuleHandleA("user32.dll");
    if (!hUser32) {
        hUser32 = LoadLibraryA("user32.dll");
        if (!hUser32)
            return 1.0;
    }
    typedef UINT(WINAPI * GetDpiForSystemFunc)();
    auto pGetDpiForSystem = (GetDpiForSystemFunc)GetProcAddress(hUser32, "GetDpiForSystem");
    if (pGetDpiForSystem) {
        UINT dpi = pGetDpiForSystem();
        if (dpi > 0)
            return dpi / 96.0;
    }
    return 1.0;
}

qreal ScreenTools::getDevicePixelRatio() const
{
    auto scale = getCurrentDevicePixelRatio();
    return (scale < 1.5 && scale > 1.0) ? scale : 1.0;
}

/**
 * @brief 供 QML 使用的缩放比
 *
 * Qt 默认按四舍五入处理缩放（125% 被当成 100%，150%/175% 被当成 200%），
 * 所以这里只对 1.0 < dpi < 1.5 的区间做补偿，其余交给 Qt 默认处理。
 */
qreal ScreenTools::mbxPixelRatio() const
{
    return (m_mbxPixelRatio < 1.5 && m_mbxPixelRatio > 1.0) ? m_mbxPixelRatio : 1.0;
}

qreal ScreenTools::realMbxPixelRatio() const
{
    return m_mbxPixelRatio;
}

const QString& ScreenTools::fontFamily() const
{
    return m_fontFamily;
}

void ScreenTools::setFontFamily(const QString& f)
{
    m_fontFamily = f;
    emit fontFamilyChanged();
}

bool ScreenTools::isWin7System() const
{
    return m_isWin7System;
}

bool ScreenTools::getSystemIsWin7()
{
    if (QSysInfo::productType() != "windows")
        return false;
    // Windows 7 内核版本号为 6.1
    return QSysInfo::kernelVersion().startsWith("6.1");
}

/**
 * @brief 判断屏幕是否小于最低要求（1280x756），并计算相对 1920 的换算系数
 */
bool ScreenTools::getOutOfScreen()
{
    QScreen* screen = QGuiApplication::primaryScreen();
    if (!screen)
        return m_outOfScreen;

    QRect screenGeometry = screen->geometry();
    int   scale          = (m_scaleFrac > 25 ? m_scaleInt + 1 : m_scaleInt);
    int   screenWidth    = screenGeometry.width() * scale;
    int   screenHeight   = screenGeometry.height() * scale;

    m_testScale = qRound((screenGeometry.width() / 1920.0) * 100.0) / 100.0;
    if (screenWidth < 1920)
        m_testScale = qRound((1.0 / scale) * 100.0) / 100.0;

    m_outOfScreen = (1280 > screenWidth || 756 > screenHeight);
    return m_outOfScreen;
}

/**
 * @brief 设计尺寸换算：设计稿像素 -> 当前屏幕像素
 *
 * - 屏幕小于最低要求时整体再乘 0.8，避免控件挤在一起
 * - isFont 为 true 时，小屏（缩放 1.25）额外除以 1.25，避免字体偏大
 */
int ScreenTools::scaleNum(int originValue, bool isFont)
{
    auto scaleFrac = ScreenTools::instance()->m_scaleFrac;
    auto scale2    = 1.0;
    if (scaleFrac > 0 && scaleFrac < 50)
        scale2 = 1.25;

    if (ScreenTools::instance()->m_outOfScreen) {
        if (isFont)
            return qRound(originValue * ScreenTools::instance()->m_testScale * 0.8 / scale2);
        return qRound(originValue * ScreenTools::instance()->m_testScale * 0.8);
    }
    if (isFont)
        return qRound((originValue * ScreenTools::instance()->m_testScale) / scale2);
    return qRound(originValue * ScreenTools::instance()->m_testScale);
}

void ScreenTools::getScreenWidHeight()
{
    QScreen* screen = QGuiApplication::primaryScreen();
    if (!screen)
        return;

    QRect screenGeometry = screen->geometry();
    int   width          = screenGeometry.width() * (m_scaleFrac > 25 ? m_scaleInt + 1 : m_scaleInt);
    int   height         = screenGeometry.height() * (m_scaleFrac > 25 ? m_scaleInt + 1 : m_scaleInt);

    // 设计尺寸上限 1344x756；分辨率不够时直接跟随屏幕
    m_screenWidth  = qMin(1344, width);
    m_screenHeight = qMin(756, height);

    emit signalScreenWidthChanged();
    emit signalScreenHeightChanged();

    setRectWidthScale();
    setRectHeightScale();
}

int ScreenTools::screenWidth() const
{
    return m_screenWidth;
}

void ScreenTools::setScreenWidth(int s)
{
    m_screenWidth = s;
    emit signalScreenWidthChanged();
}

int ScreenTools::screenHeight() const
{
    return m_screenHeight;
}

void ScreenTools::setScreenHeight(int s)
{
    m_screenHeight = s;
    emit signalScreenHeightChanged();
}

/**
 * @brief 窄屏补偿：屏幕宽度不足 1200 时窗口宽度放大 1.2 倍
 */
void ScreenTools::setRectWidthScale()
{
    m_rectWidthScale = (m_screenWidth < 1200) ? (std::round(1.2 * 100.0) / 100.0) : 1.0;
    emit signalRectWidthScaleChanged();
}

qreal ScreenTools::rectWidthScale() const
{
    return m_rectWidthScale;
}

qreal ScreenTools::rectHeightScale() const
{
    return m_rectHeightScale;
}

/**
 * @brief 矮屏补偿：屏幕高度不足 756 时窗口高度放大 1.05 倍
 */
void ScreenTools::setRectHeightScale()
{
    m_rectHeightScale = (m_screenHeight < 756) ? (std::round(1.05 * 100.0) / 100.0) : 1.0;
    emit signalRectHeightScaleChanged();
}

bool ScreenTools::isDebug() const
{
    return m_isDebug;
}

void ScreenTools::setDebug(bool debug)
{
    if (m_isDebug == debug)
        return;
    m_isDebug = debug;
    emit isDebugChanged();
}

// 联相 / 乔安皮肤：RDTools 只有一套界面，固定返回 false
bool ScreenTools::isLianXiang() const
{
    return false;
}

bool ScreenTools::isQiaoAn() const
{
    return false;
}

QStringList ScreenTools::regionList() const
{
    return QStringList();
}

bool ScreenTools::imageIsSvgSource(const QString& imageUrl)
{
    return imageUrl.endsWith(".svg", Qt::CaseInsensitive);
}

/**
 * @brief 按指定字号测量单行文本宽度
 */
int ScreenTools::calculateTextWidth(const QString& text, const int fontSize, bool bold, bool isPixelFont)
{
    QFont font(ScreenTools::instance()->fontFamily());
    if (isPixelFont)
        font.setPixelSize(fontSize > 0 ? fontSize : 10);
    else
        font.setPointSize(fontSize > 0 ? fontSize : 10);
    font.setBold(bold);

    QFontMetrics fm(font);
    return fm.horizontalAdvance(text);
}

/**
 * @brief 计算文本在限定宽度内折行后的行数
 */
int ScreenTools::calculateLineCount(const QString& text, const QFont& font, int maxWidth)
{
    if (text.isEmpty() || maxWidth <= 0)
        return 0;

    QFontMetrics fm(font);
    int          textHeight = fm.boundingRect(4, 4, maxWidth, 0, Qt::TextWrapAnywhere | Qt::AlignLeft, text).height();
    int          lineHeight = fm.height();
    return (textHeight + lineHeight - 1) / lineHeight; // 向上取整
}

/**
 * @brief 计算文本折行后的多行高度
 */
int ScreenTools::calculateMultiLineHeight(const QString& text, const int fontSize, int maxWidth, bool bold, bool isPixelFont)
{
    QFont font(ScreenTools::instance()->fontFamily());
    if (isPixelFont)
        font.setPixelSize(fontSize > 0 ? fontSize : 10);
    else
        font.setPointSize(fontSize > 0 ? fontSize : 10);
    font.setBold(bold);

    QFontMetrics fm(font);
    int          lineCount = calculateLineCount(text, font, maxWidth);
    return lineCount * (fm.height() + 5);
}

/**
 * @brief 多段文本取最宽的一段，用于多列文本对齐
 */
int ScreenTools::calculateMultiTextWidth(const QString& text, const QString& text2, const QString& text3, const QString& text4,
                                         const int fontSize, bool bold, bool isPixelFont)
{
    QString max1   = text.length() >= text2.length() ? text : text2;
    QString max2   = text3.length() >= text4.length() ? text3 : text4;
    QString maxStr = max1.length() > max2.length() ? max1 : max2;
    return calculateTextWidth(maxStr, fontSize, bold, isPixelFont);
}
