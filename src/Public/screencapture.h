#ifndef SCREENCAPTURE_H
#define SCREENCAPTURE_H

#include <QObject>
#include <QPixmap>

/**
 * @brief 截屏工具（单例，注册给 QML 使用）
 *
 * 流程: startCapture() → 隐藏窗口 → 截屏 → captureStarted 信号
 *       → QML 显示选区覆盖层 → 用户拖选 → prepareEditBase()
 *       → 编辑(画笔/箭头/文本/马赛克/旋转) → finishCapture() 写剪贴板
 */
class ScreenCapture : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString capturedImagePath READ capturedImagePath NOTIFY capturedImageChanged)
    Q_PROPERTY(QString editImagePath    READ editImagePath    NOTIFY editImageChanged)
    Q_PROPERTY(int     editImageWidth   READ editImageWidth   NOTIFY editImageChanged)
    Q_PROPERTY(int     editImageHeight  READ editImageHeight  NOTIFY editImageChanged)

  public:
    ~ScreenCapture();
    static ScreenCapture* instance();

    /* ── 截屏流程 ── */

    /// 隐藏窗口 → 延迟截屏 → captureStarted
    Q_INVOKABLE void startCapture();

    /// 快速截取（无编辑）：裁剪 + 写剪贴板
    Q_INVOKABLE void captureRegion(int x, int y, int w, int h);

    /// 取消截屏，清理所有临时文件
    Q_INVOKABLE void cancelCapture();

    /* ── 编辑流程 ── */

    /// 选区确定后，裁剪原始截图存为编辑基底
    Q_INVOKABLE void prepareEditBase(int x, int y, int w, int h);

    /// 合成基底+Canvas标注 → 写剪贴板 → 结束
    Q_INVOKABLE void finishCapture(const QString& canvasImagePath);

    /// 仅合成（不写剪贴板），结果存入 m_resultPixmap 供 saveToFile
    Q_INVOKABLE void compositeOnly(const QString& canvasImagePath);

    /// 将 m_resultPixmap 保存到本地文件
    Q_INVOKABLE bool saveToFile(const QString& filePath);

    /// 旋转 90° 顺时针（基底+Canvas 合成后旋转），更新 editImage 属性
    Q_INVOKABLE void rotateEditImage(const QString& canvasImagePath);

    /// 默认保存路径（桌面/screenshot_yyyyMMdd_HHmmss.png）
    Q_INVOKABLE QString suggestSavePath();

    /// 马赛克：对 editBase 指定区域做像素化，保存到临时文件并返回 URL
    Q_INVOKABLE QString mosaicRegion(int x, int y, int w, int h, int blockSize);

    /// 临时目录
    Q_INVOKABLE QString tempDir();

    /* ── 属性 ── */
    QString capturedImagePath() const;
    QString editImagePath()    const;
    int     editImageWidth()   const;
    int     editImageHeight()  const;

  signals:
    void captureStarted();
    void captureFinished();
    void captureCancelled();
    void capturedImageChanged();
    void editImageChanged();

  private:
    explicit ScreenCapture(QObject* parent = nullptr);
    void showMainWindow();
    void cleanupTempFiles();

    static ScreenCapture* m_instance;

    QPixmap  m_screenCapture;       // 全屏截图
    QString  m_capturedImagePath;    // file:/// URL

    QPixmap  m_editBaseImage;       // 裁剪区域 / 旋转后结果
    QPixmap  m_resultPixmap;        // 合成结果（供 saveToFile）
    QString  m_editImagePath;       // 旋转后临时图片 URL
    int      m_editImageWidth  = 0;
    int      m_editImageHeight = 0;
    int      m_mosaicCounter   = 0; // 马赛克临时文件计数
    int      m_editImgCounter  = 0; // 旋转临时文件计数
};

#endif // SCREENCAPTURE_H
