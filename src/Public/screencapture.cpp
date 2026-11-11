#include "screencapture.h"

#include <QClipboard>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QPainter>
#include <QScreen>
#include <QStandardPaths>
#include <QTimer>
#include <QTransform>
#include <QUrl>
#include <QWindow>

ScreenCapture* ScreenCapture::m_instance = nullptr;

ScreenCapture::ScreenCapture(QObject* parent) : QObject(parent) {}

ScreenCapture::~ScreenCapture()
{
    cleanupTempFiles();
}

ScreenCapture* ScreenCapture::instance()
{
    if (!m_instance)
        m_instance = new ScreenCapture();
    return m_instance;
}

/* ── 属性 ── */

QString ScreenCapture::capturedImagePath() const { return m_capturedImagePath; }
QString ScreenCapture::editImagePath()    const { return m_editImagePath; }
int     ScreenCapture::editImageWidth()   const { return m_editImageWidth; }
int     ScreenCapture::editImageHeight()  const { return m_editImageHeight; }

QString ScreenCapture::tempDir()
{
    return QDir::tempPath();
}

QString ScreenCapture::suggestSavePath()
{
    const QString desktop =
        QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    const QString ts = QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss");
    return desktop + QStringLiteral("/screenshot_%1.png").arg(ts);
}

/* ── 临时文件 ── */

void ScreenCapture::cleanupTempFiles()
{
    const QString tmp = QDir::tempPath();
    QFile::remove(tmp + QStringLiteral("/rdtools_screencapture.png"));
    QFile::remove(tmp + QStringLiteral("/rdtools_canvas_overlay.png"));
    // 清理旋转/马赛克临时文件（带编号模式）
    QDir tmpDir(tmp);
    const QStringList patterns =
        QStringList() << QStringLiteral("rdtools_edit_image_*.png")
                      << QStringLiteral("rdtools_mosaic_*.png");
    const QStringList tempFiles = tmpDir.entryList(patterns, QDir::Files);
    for (const auto& f : tempFiles)
        QFile::remove(tmp + QLatin1Char('/') + f);
    m_mosaicCounter  = 0;
    m_editImgCounter = 0;
}

/* ── 截屏流程 ── */

void ScreenCapture::startCapture()
{
    for (auto* w : QGuiApplication::topLevelWindows()) {
        if (w->isVisible()
            && w->objectName() != QStringLiteral("screencaptureOverlay"))
            w->hide();
    }

    QTimer::singleShot(200, [this]() {
        QScreen* screen = QGuiApplication::primaryScreen();
        if (!screen) {
            emit captureCancelled();
            showMainWindow();
            return;
        }

        m_screenCapture = screen->grabWindow(0);
        if (m_screenCapture.isNull()) {
            emit captureCancelled();
            showMainWindow();
            return;
        }

        const QString tempPath =
            QDir::tempPath() + QStringLiteral("/rdtools_screencapture.png");
        m_screenCapture.save(tempPath, "PNG");
        m_capturedImagePath = QUrl::fromLocalFile(tempPath).toString();
        emit capturedImageChanged();

        m_editBaseImage = QPixmap();
        m_editImagePath = QString();
        m_editImageWidth  = 0;
        m_editImageHeight = 0;
        emit editImageChanged();

        emit captureStarted();
    });
}

void ScreenCapture::captureRegion(int x, int y, int w, int h)
{
    if (m_screenCapture.isNull() || w <= 0 || h <= 0) {
        cancelCapture();
        return;
    }

    const qreal dpr = m_screenCapture.devicePixelRatioF();
    const QRect region(qRound(x * dpr), qRound(y * dpr),
                       qRound(w * dpr), qRound(h * dpr));
    QPixmap cropped = m_screenCapture.copy(region);

    QGuiApplication::clipboard()->setPixmap(cropped);
    m_resultPixmap = cropped;

    cleanupTempFiles();
    m_screenCapture   = QPixmap();
    m_capturedImagePath = QString();
    emit capturedImageChanged();

    showMainWindow();
    emit captureFinished();
}

void ScreenCapture::cancelCapture()
{
    cleanupTempFiles();
    m_screenCapture     = QPixmap();
    m_capturedImagePath = QString();
    m_editBaseImage     = QPixmap();
    m_resultPixmap      = QPixmap();
    m_editImagePath     = QString();
    m_editImageWidth    = 0;
    m_editImageHeight   = 0;
    emit capturedImageChanged();
    emit editImageChanged();

    showMainWindow();
    // 延迟发射信号，给主窗口渲染时间，避免 overlay 先消失导致的短暂黑屏
    QTimer::singleShot(100, this, [this]() { emit captureCancelled(); });
}

/* ── 编辑流程 ── */

void ScreenCapture::prepareEditBase(int x, int y, int w, int h)
{
    if (m_screenCapture.isNull() || w <= 0 || h <= 0)
        return;

    const qreal dpr = m_screenCapture.devicePixelRatioF();
    const QRect region(qRound(x * dpr), qRound(y * dpr),
                       qRound(w * dpr), qRound(h * dpr));
    m_editBaseImage = m_screenCapture.copy(region);
}

void ScreenCapture::compositeOnly(const QString& canvasImagePath)
{
    if (m_editBaseImage.isNull())
        return;

    QPixmap result = m_editBaseImage;

    if (!canvasImagePath.isEmpty()) {
        QPixmap canvasImg;
        QString localPath = canvasImagePath;
        if (localPath.startsWith(QStringLiteral("file:")))
            localPath = QUrl(localPath).toLocalFile();
        if (canvasImg.load(localPath)) {
            if (canvasImg.size() != result.size()) {
                canvasImg = canvasImg.scaled(result.size(),
                    Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
            }
            QPainter painter(&result);
            painter.setCompositionMode(QPainter::CompositionMode_SourceOver);
            painter.drawPixmap(0, 0, canvasImg);
            painter.end();
        }
    }

    m_resultPixmap = result;
}

void ScreenCapture::finishCapture(const QString& canvasImagePath)
{
    compositeOnly(canvasImagePath);

    if (!m_resultPixmap.isNull())
        QGuiApplication::clipboard()->setPixmap(m_resultPixmap);

    cleanupTempFiles();
    m_screenCapture     = QPixmap();
    m_capturedImagePath = QString();
    m_editBaseImage     = QPixmap();
    m_editImagePath     = QString();
    m_editImageWidth    = 0;
    m_editImageHeight   = 0;
    emit capturedImageChanged();
    emit editImageChanged();

    showMainWindow();
    // 延迟发射信号，给主窗口渲染时间，避免 overlay 先消失导致的短暂黑屏
    QTimer::singleShot(100, this, [this]() { emit captureFinished(); });
}

bool ScreenCapture::saveToFile(const QString& filePath)
{
    if (m_resultPixmap.isNull())
        return false;

    QString localPath = filePath;
    if (localPath.startsWith(QStringLiteral("file:")))
        localPath = QUrl(localPath).toLocalFile();

    return m_resultPixmap.save(localPath, "PNG");
}

void ScreenCapture::rotateEditImage(const QString& canvasImagePath)
{
    compositeOnly(canvasImagePath);

    if (m_resultPixmap.isNull())
        return;

    // 顺时针 90°
    QTransform transform;
    transform.rotate(90);
    QPixmap rotated = m_resultPixmap.transformed(transform);

    // 清理上一次旋转临时文件，用递增编号确保 QML Image 刷新
    const QString tmp = QDir::tempPath();
    {
        QDir tmpDir(tmp);
        const QStringList oldFiles = tmpDir.entryList(
            QStringList() << QStringLiteral("rdtools_edit_image_*.png"),
            QDir::Files);
        for (const auto& f : oldFiles)
            QFile::remove(tmp + QLatin1Char('/') + f);
    }

    const QString tempPath =
        tmp + QStringLiteral("/rdtools_edit_image_%1.png").arg(++m_editImgCounter);
    rotated.save(tempPath, "PNG");

    m_editBaseImage = rotated;
    m_editImagePath = QUrl::fromLocalFile(tempPath).toString();
    const qreal dpr = rotated.devicePixelRatioF();
    m_editImageWidth  = qRound(rotated.width()  / (dpr > 0 ? dpr : 1.0));
    m_editImageHeight = qRound(rotated.height() / (dpr > 0 ? dpr : 1.0));

    emit editImageChanged();
}

QString ScreenCapture::mosaicRegion(int x, int y, int w, int h, int blockSize)
{
    if (m_editBaseImage.isNull() || w <= 0 || h <= 0 || blockSize < 2)
        return QString();

    const qreal dpr = m_editBaseImage.devicePixelRatioF();
    const QRect region(qRound(x * dpr), qRound(y * dpr),
                       qRound(w * dpr), qRound(h * dpr));
    QPixmap crop = m_editBaseImage.copy(region);
    if (crop.isNull())
        return QString();

    // 像素化：缩小再放大
    const int bs = qMax(2, qRound(blockSize * dpr));
    const int smallW = qMax(1, crop.width()  / bs);
    const int smallH = qMax(1, crop.height() / bs);

    QPixmap small = crop.scaled(smallW, smallH,
        Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    QPixmap pixelated = small.scaled(crop.width(), crop.height(),
        Qt::IgnoreAspectRatio, Qt::FastTransformation);

    // 保存到临时文件
    const QString tempPath =
        QDir::tempPath() + QStringLiteral("/rdtools_mosaic_%1.png").arg(++m_mosaicCounter);
    pixelated.save(tempPath, "PNG");

    return QUrl::fromLocalFile(tempPath).toString();
}

/* ── 内部 ── */

void ScreenCapture::showMainWindow()
{
    for (auto* w : QGuiApplication::topLevelWindows()) {
        if (!w->isVisible()
            && w->objectName() != QStringLiteral("screencaptureOverlay"))
            w->show();
    }
}
