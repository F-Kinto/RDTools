#include "svgiconitem.h"

#include <QFile>
#include <QPainter>
#include <QRegularExpression>
#include <QUrl>

SvgIconItem::SvgIconItem(QQuickItem* parent) : QQuickPaintedItem(parent)
{
    setAntialiasing(true);
    updateItemSize();
}

QString SvgIconItem::source() const
{
    return m_source;
}

void SvgIconItem::setSource(const QString& source)
{
    if (m_source == source)
        return;

    m_source = source;
    reloadSvg();
    emit sourceChanged();
}

QColor SvgIconItem::fillColor() const
{
    return m_fillColor;
}

void SvgIconItem::setFillColor(const QColor& color)
{
    if (m_fillColor == color)
        return;

    m_fillColor   = color;
    m_pureChanged = true;
    reloadSvg();
    emit fillColorChanged();
}

QColor SvgIconItem::strokeColor() const
{
    return m_strokeColor;
}

void SvgIconItem::setStrokeColor(const QColor& color)
{
    if (m_strokeColor == color)
        return;

    m_strokeColor = color;
    m_pureChanged = true;
    reloadSvg();
    emit strokeColorChanged();
}

QColor SvgIconItem::pathColor() const
{
    return m_pathColor;
}

void SvgIconItem::setPathColor(const QColor& color)
{
    if (m_pathColor == color)
        return;

    m_pathColor   = color;
    m_pathChanged = true;
    reloadSvg();
    emit pathColorChanged();
}

QColor SvgIconItem::pathStrokeColor() const
{
    return m_pathStrokeColor;
}

void SvgIconItem::setPathStrokeColor(const QColor& color)
{
    if (m_pathStrokeColor == color)
        return;

    m_pathStrokeColor = color;
    m_pathChanged     = true;
    reloadSvg();
    emit pathStrokeColorChanged();
}

QColor SvgIconItem::rectColor() const
{
    return m_rectColor;
}

void SvgIconItem::setRectColor(const QColor& color)
{
    if (m_rectColor == color)
        return;

    m_rectColor   = color;
    m_rectChanged = true;
    reloadSvg();
    emit rectColorChanged();
}

QColor SvgIconItem::rectStrokeColor() const
{
    return m_rectStrokeColor;
}

void SvgIconItem::setRectStrokeColor(const QColor& color)
{
    if (m_rectStrokeColor == color)
        return;

    m_rectStrokeColor = color;
    m_rectChanged     = true;
    reloadSvg();
    emit rectStrokeColorChanged();
}

QColor SvgIconItem::beginColor() const
{
    return m_beginColor;
}

void SvgIconItem::setBeginColor(const QColor& color)
{
    if (m_beginColor == color)
        return;

    m_beginColor      = color;
    m_gradientChanged = true;
    reloadSvg();
    emit beginColorChanged();
}

QColor SvgIconItem::endColor() const
{
    return m_endColor;
}

void SvgIconItem::setEndColor(const QColor& color)
{
    if (m_endColor == color)
        return;

    m_endColor        = color;
    m_gradientChanged = true;
    reloadSvg();
    emit endColorChanged();
}

qreal SvgIconItem::iconWidth() const
{
    return m_iconWidth;
}

void SvgIconItem::setIconWidth(qreal width)
{
    if (qFuzzyCompare(m_iconWidth, width))
        return;

    m_iconWidth = width;
    updateItemSize();
    emit iconWidthChanged();
}

qreal SvgIconItem::iconHeight() const
{
    return m_iconHeight;
}

void SvgIconItem::setIconHeight(qreal height)
{
    if (qFuzzyCompare(m_iconHeight, height))
        return;

    m_iconHeight = height;
    updateItemSize();
    emit iconHeightChanged();
}

qreal SvgIconItem::topPadding() const
{
    return m_topPadding;
}

void SvgIconItem::setTopPadding(qreal padding)
{
    if (qFuzzyCompare(m_topPadding, padding))
        return;

    m_topPadding = padding;
    updateItemSize();
    emit topPaddingChanged();
}

void SvgIconItem::paint(QPainter* painter)
{
    if (!m_renderer.isValid())
        return;

    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setRenderHint(QPainter::SmoothPixmapTransform, true);
    m_renderer.render(painter, QRectF(0, m_topPadding, m_iconWidth, m_iconHeight));
}

/**
 * @brief 按当前颜色设置改写 SVG 源码
 */
QString SvgIconItem::applyColors(const QString& svgContent) const
{
    QString content = svgContent;

    if (m_gradientChanged) {
        static const QRegularExpression stopColorStartRegex(QStringLiteral("<stop\\s+([^>]*?)stop-color\\s*=\\s*\"(?!none)([^\"]*)\""),
                                                            QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch         match1 = stopColorStartRegex.match(content);
        if (match1.hasMatch())
            content.replace(stopColorStartRegex, QStringLiteral("<stop \\1stop-color=\"%1\"").arg(m_beginColor.name(QColor::HexRgb)));

        static const QRegularExpression stopColorEndRegex(
            QStringLiteral("<stop\\s+offset\\s*=\\s*\"1(00%)?\"\\s+([^>]*?)stop-color\\s*=\\s*\"(?!none)([^\"]*)\""),
            QRegularExpression::CaseInsensitiveOption);

        QRegularExpressionMatch match2 = stopColorEndRegex.match(content);
        if (match2.hasMatch())
            content.replace(stopColorEndRegex, QStringLiteral("<stop offset=\"1\" stop-color=\"%1\"").arg(m_endColor.name(QColor::HexRgb)));

        m_gradientChanged = false;
    }

    if (m_pureChanged) {
        static const QRegularExpression fillRegex(QStringLiteral("fill\\s*=\\s*\"(?!none)([^\"]*)\""), QRegularExpression::CaseInsensitiveOption);
        if (fillRegex.match(content).hasMatch())
            content.replace(fillRegex, QStringLiteral("fill=\"%1\"").arg(m_fillColor.name(QColor::HexRgb)));

        static const QRegularExpression strokeRegex(QStringLiteral("stroke\\s*=\\s*\"(?!none)([^\"]*)\""), QRegularExpression::CaseInsensitiveOption);
        if (strokeRegex.match(content).hasMatch())
            content.replace(strokeRegex, QStringLiteral("stroke=\"%1\"").arg(m_strokeColor.name(QColor::HexRgb)));

        m_pureChanged = false;
    }

    if (m_pathChanged) {
        static const QRegularExpression pathFillRegex(QStringLiteral("<path\\s+([^>]*?)fill\\s*=\\s*\"(?!none)([^\"]*)\""),
                                                      QRegularExpression::CaseInsensitiveOption);
        if (pathFillRegex.match(content).hasMatch())
            content.replace(pathFillRegex, QStringLiteral("<path \\1fill=\"%1\"").arg(m_pathColor.name(QColor::HexRgb)));

        static const QRegularExpression pathStrokeRegex(QStringLiteral("<path\\s+([^>]*?)stroke\\s*=\\s*\"(?!none)([^\"]*)\""),
                                                        QRegularExpression::CaseInsensitiveOption);
        if (pathStrokeRegex.match(content).hasMatch())
            content.replace(pathStrokeRegex, QStringLiteral("<path \\1stroke=\"%1\"").arg(m_pathStrokeColor.name(QColor::HexRgb)));

        m_pathChanged = false;
    }

    if (m_rectChanged) {
        static const QRegularExpression rectFillRegex(QStringLiteral("<rect\\s+([^>]*?)fill\\s*=\\s*\"(?!none)([^\"]*)\""),
                                                      QRegularExpression::CaseInsensitiveOption);
        if (rectFillRegex.match(content).hasMatch())
            content.replace(rectFillRegex, QStringLiteral("<rect \\1fill=\"%1\"").arg(m_rectColor.name(QColor::HexRgb)));

        static const QRegularExpression rectStrokeRegex(QStringLiteral("<rect\\s+([^>]*?)stroke\\s*=\\s*\"(?!none)([^\"]*)\""),
                                                        QRegularExpression::CaseInsensitiveOption);
        if (rectStrokeRegex.match(content).hasMatch())
            content.replace(rectStrokeRegex, QStringLiteral("<rect \\1stroke=\"%1\"").arg(m_rectStrokeColor.name(QColor::HexRgb)));

        m_rectChanged = false;
    }
    return content;
}

void SvgIconItem::reloadSvg()
{
    if (m_source.isEmpty()) {
        m_renderer.load(QByteArray());
        update();
        return;
    }

    QString filePath = m_source;
    // qrc:/xxx 需要转成 :/xxx 才能用 QFile 读取
    if (filePath.startsWith("qrc:/"))
        filePath = ":" + filePath.mid(4);

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_renderer.load(QByteArray());
        update();
        return;
    }

    const QString    svgContent = QString::fromUtf8(file.readAll());
    const QByteArray coloredSvg = applyColors(svgContent).toUtf8();
    m_renderer.load(coloredSvg);
    update();
}

void SvgIconItem::updateItemSize()
{
    setImplicitWidth(m_iconWidth);
    setImplicitHeight(m_iconHeight + m_topPadding);
    update();
}
