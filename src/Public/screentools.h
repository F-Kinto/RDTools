#ifndef SCREENTOOLS_H
#define SCREENTOOLS_H

#include <QFont>
#include <QObject>
#include <QString>
#include <QStringList>

/**
 * @brief 分辨率 / DPI 适配工具（单例，注册给 QML 使用）
 *
 * 移植自 IPCamConfigTools 的 ScreenTools，只保留界面适配相关部分：
 *  - 系统 DPI 缩放比（getCurrentDevicePixelRatio）
 *  - 设计尺寸上限（screenWidth / screenHeight）
 *  - 统一数值缩放接口 scaleNum（QML 中所有固定像素值都走它）
 *  - 小屏补偿系数 rectWidthScale / rectHeightScale
 */
class ScreenTools : public QObject {
    Q_OBJECT
    Q_PROPERTY(qreal realMbxPixelRatio READ realMbxPixelRatio NOTIFY pixelRatioChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(bool isWin7System READ isWin7System NOTIFY isWin7SystemChanged)
    Q_PROPERTY(int screenWidth READ screenWidth NOTIFY signalScreenWidthChanged)
    Q_PROPERTY(int screenHeight READ screenHeight NOTIFY signalScreenHeightChanged)
    Q_PROPERTY(qreal rectWidthScale READ rectWidthScale NOTIFY signalRectWidthScaleChanged)
    Q_PROPERTY(qreal rectHeightScale READ rectHeightScale NOTIFY signalRectHeightScaleChanged)
    Q_PROPERTY(bool isDebug READ isDebug WRITE setDebug NOTIFY isDebugChanged)
    Q_PROPERTY(bool isLianXiang READ isLianXiang CONSTANT)
    Q_PROPERTY(bool isQiaoAn READ isQiaoAn CONSTANT)
    Q_PROPERTY(QStringList regionList READ regionList CONSTANT)

  public:
    ~ScreenTools();

    static ScreenTools* instance();
    void                reset();

    // 系统 DPI 缩放比（125% -> 1.25）；GetDpiForSystem 不可用时返回 1.0
    qreal getCurrentDevicePixelRatio() const;
    // 仅对 1.0 < dpi < 1.5 生效，其它情况按 1.0 处理（与 Qt 默认取整规则对齐）
    qreal getDevicePixelRatio() const;
    qreal mbxPixelRatio() const;
    qreal realMbxPixelRatio() const;

    const QString& fontFamily() const;
    void           setFontFamily(const QString& f);
    bool           isWin7System() const;
    bool           getSystemIsWin7();

    /**
     * @brief 设计尺寸换算：把设计稿像素值换算为当前屏幕下的像素值
     * @param originValue 设计稿中的像素值
     * @param isFont 为 true 时按字体维度换算（小屏时额外做 1/1.25 补偿）
     */
    Q_INVOKABLE static int scaleNum(int originValue = 10, bool isFont = false);

    // ===== 文本尺寸计算（Flu 系列控件排版时使用）=====
    Q_INVOKABLE static int     calculateTextWidth(const QString& text, const int fontSize = 10, bool bold = false, bool isPixelFont = false);
    Q_INVOKABLE static int     calculateMultiLineHeight(const QString& text, const int fontSize, int maxWidth, bool bold = false, bool isPixelFont = false);
    Q_INVOKABLE static int     calculateLineCount(const QString& text, const QFont& font, int maxWidth);
    Q_INVOKABLE static int     calculateMultiTextWidth(const QString& text, const QString& text2 = "", const QString& text3 = "", const QString& text4 = "",
                                                       const int fontSize = 10, bool bold = false, bool isPixelFont = false);
    Q_INVOKABLE static bool    imageIsSvgSource(const QString& imageUrl);

    bool        isDebug() const;
    void        setDebug(bool debug);
    bool        isLianXiang() const;
    bool        isQiaoAn() const;
    QStringList regionList() const;

    bool  getOutOfScreen();
    int   screenWidth() const;
    void  setScreenWidth(int s);
    int   screenHeight() const;
    void  setScreenHeight(int s);
    void  getScreenWidHeight();
    qreal rectWidthScale() const;
    void  setRectWidthScale();
    qreal rectHeightScale() const;
    void  setRectHeightScale();

  signals:
    void isDebugChanged();
    void fontFamilyChanged();
    void pixelRatioChanged();
    void isWin7SystemChanged();
    void signalScreenWidthChanged();
    void signalScreenHeightChanged();
    void signalRectWidthScaleChanged();
    void signalRectHeightScaleChanged();

  private:
    explicit ScreenTools(QObject* parent = nullptr);

    static ScreenTools* m_instance;

    int     m_screenWidth  = 1344; // 窗口设计宽度（超过屏幕时取屏幕宽度）
    int     m_screenHeight = 756;  // 窗口设计高度（超过屏幕时取屏幕高度）
    QString m_fontFamily;

    qreal m_mbxPixelRatio = 1.0;
    bool  m_isWin7System  = false;

    bool m_outOfScreen = false; // 屏幕小于最低要求（1280x756）
    int  m_scaleInt    = 1;     // DPI 缩放比整数部分
    int  m_scaleFrac   = 0;     // DPI 缩放比小数部分（百分比整数）

    qreal m_rectWidthScale  = 1.0;
    qreal m_rectHeightScale = 1.0;

    qreal m_testScale = 1.0; // 相对 1920 宽度的换算系数

    bool m_isDebug = false;  // 调试模式（Flu 控件用它控制悬浮提示等调试信息）
};

#endif // SCREENTOOLS_H
