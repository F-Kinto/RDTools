#ifndef SVGICONITEM_H
#define SVGICONITEM_H

#include <QColor>
#include <QQuickPaintedItem>
#include <QSvgRenderer>

/**
 * @brief 可换色的 SVG 图标项（移植自 VmsTools Public/SvgIconItem）
 *
 * 把 SVG 源码读出来按需改写 fill / stroke 颜色，再交给 QSvgRenderer 绘制，
 * 因此同一份 SVG 资源可以用不同主题色渲染。
 */
class SvgIconItem : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QColor fillColor READ fillColor WRITE setFillColor NOTIFY fillColorChanged)
    Q_PROPERTY(QColor strokeColor READ strokeColor WRITE setStrokeColor NOTIFY strokeColorChanged)
    Q_PROPERTY(QColor pathColor READ pathColor WRITE setPathColor NOTIFY pathColorChanged)
    Q_PROPERTY(QColor pathStrokeColor READ pathStrokeColor WRITE setPathStrokeColor NOTIFY pathStrokeColorChanged)
    Q_PROPERTY(QColor beginColor READ beginColor WRITE setBeginColor NOTIFY beginColorChanged)
    Q_PROPERTY(QColor endColor READ endColor WRITE setEndColor NOTIFY endColorChanged)
    Q_PROPERTY(QColor rectColor READ rectColor WRITE setRectColor NOTIFY rectColorChanged)
    Q_PROPERTY(QColor rectStrokeColor READ rectStrokeColor WRITE setRectStrokeColor NOTIFY rectStrokeColorChanged)
    Q_PROPERTY(qreal iconWidth READ iconWidth WRITE setIconWidth NOTIFY iconWidthChanged)
    Q_PROPERTY(qreal iconHeight READ iconHeight WRITE setIconHeight NOTIFY iconHeightChanged)
    Q_PROPERTY(qreal topPadding READ topPadding WRITE setTopPadding NOTIFY topPaddingChanged)

  public:
    explicit SvgIconItem(QQuickItem* parent = nullptr);

    QString source() const;
    void    setSource(const QString& source);

    QColor fillColor() const;
    void   setFillColor(const QColor& color);

    QColor strokeColor() const;
    void   setStrokeColor(const QColor& color);

    QColor pathColor() const;
    void   setPathColor(const QColor& color);
    QColor pathStrokeColor() const;
    void   setPathStrokeColor(const QColor& color);

    QColor rectColor() const;
    void   setRectColor(const QColor& color);

    QColor rectStrokeColor() const;
    void   setRectStrokeColor(const QColor& color);

    QColor beginColor() const;
    void   setBeginColor(const QColor& color);

    QColor endColor() const;
    void   setEndColor(const QColor& color);

    qreal iconWidth() const;
    void  setIconWidth(qreal width);

    qreal iconHeight() const;
    void  setIconHeight(qreal height);

    qreal topPadding() const;
    void  setTopPadding(qreal padding);

    void paint(QPainter* painter) override;

  signals:
    void sourceChanged();
    void fillColorChanged();
    void strokeColorChanged();
    void pathColorChanged();
    void pathStrokeColorChanged();
    void rectColorChanged();
    void rectStrokeColorChanged();
    void beginColorChanged();
    void endColorChanged();
    void iconWidthChanged();
    void iconHeightChanged();
    void topPaddingChanged();

  private:
    void    reloadSvg();
    QString applyColors(const QString& svgContent) const;
    void    updateItemSize();

    QString m_source;
    QColor  m_fillColor       = QColor("#FFFFFE");
    QColor  m_strokeColor     = QColor("#FFFFFE");
    QColor  m_pathColor       = QColor("#FFFFFE");
    QColor  m_pathStrokeColor = QColor("#FFFFFE");
    QColor  m_rectColor       = QColor("#FFFFFE");
    QColor  m_rectStrokeColor = QColor("#FFFFFE");
    // 渐变的开始色和结束色
    QColor m_beginColor = QColor("#FFFFFE");
    QColor m_endColor   = QColor("#FFFFFE");
    qreal  m_iconWidth  = 128.0;
    qreal  m_iconHeight = 128.0;
    qreal  m_topPadding = 0.0;

    mutable bool m_pathChanged     = false;
    mutable bool m_gradientChanged = false;
    mutable bool m_pureChanged     = false;
    mutable bool m_rectChanged     = false;
    QSvgRenderer m_renderer;
};

#endif // SVGICONITEM_H
