#ifndef QMLSUPPORT_H
#define QMLSUPPORT_H

#include <QFile>
#include <QQmlPropertyMap>
#include <QRegularExpression>
#include <QString>

/**
 * @brief 图标资源字典（对应 VmsTools 的 CommonImageStyle）
 *
 * 直接解析 CommonImage.css / CommonPngImage.css 里的 name:"qrc:/..." 定义，
 * 以动态属性形式暴露给 QML（CommonImageStyle.min_img 等）。
 */
class CommonImageStyle : public QQmlPropertyMap {
    Q_OBJECT

  public:
    static CommonImageStyle* instance()
    {
        static CommonImageStyle obj;
        return &obj;
    }

    explicit CommonImageStyle(QObject* parent = nullptr) : QQmlPropertyMap(parent)
    {
        loadStyleSheet(QStringLiteral(":/style/CommonImage.css"));
        loadStyleSheet(QStringLiteral(":/style/CommonPngImage.css"));
    }

  private:
    // CSS 里一行形如：min_img:"qrc:/svgSource/image/svgSource/min_img.svg";/*注释*/
    void loadStyleSheet(const QString& filePath)
    {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
            return;

        const QString           content = QString::fromUtf8(file.readAll());
        static QRegularExpression regex(QStringLiteral("([A-Za-z_][A-Za-z0-9_]*)\\s*:\\s*\"([^\"]*)\"\\s*;"));
        QRegularExpressionMatchIterator it = regex.globalMatch(content);
        while (it.hasNext()) {
            const QRegularExpressionMatch match = it.next();
            insert(match.captured(1), match.captured(2));
        }
    }
};

/**
 * @brief 控件使用的枚举集合（对应 VmsTools 的 VmsEnum，模块 VMS.Enum）
 *
 * 这里没有原始业务枚举，只需要保证 QML 里 VmsEnum.XxxEnum.Yyy 能取到稳定整数，
 * 因此用属性字典实现，取值顺序与原工程保持一致。
 */
class VmsEnum : public QQmlPropertyMap {
    Q_OBJECT

  public:
    static VmsEnum* instance()
    {
        static VmsEnum obj;
        return &obj;
    }

    explicit VmsEnum(QObject* parent = nullptr) : QQmlPropertyMap(parent)
    {
        insert(QStringLiteral("SvgColorTypeEnum"),
               makeGroup({{"PureColor", 0}, {"BorderPathColor", 1}, {"GradientColor", 2}, {"RectPathColor", 3}}));
        insert(QStringLiteral("LableColorTypeEnum"), makeGroup({{"TextStyle", 0}, {"BackgroundStyle", 1}}));
        insert(QStringLiteral("LableTypeEnum"), makeGroup({{"LabelOnly", 0}, {"AddLable", 1}, {"CloseLable", 2}}));
        insert(QStringLiteral("DirectionTypeEnum"), makeGroup({{"Up", 0}, {"Down", 1}, {"Left", 2}, {"Right", 3}}));
        insert(QStringLiteral("StatusEnum"),
               makeGroup({{"Ready", 0}, {"Processing", 1}, {"Success", 2}, {"Failed", 3}, {"Exception", 4}}));
        insert(QStringLiteral("CloudRequestResult"), makeGroup({{"eRequestFail", 0}, {"eRequestSuccess", 1}}));
        insert(QStringLiteral("LoginType"), makeGroup({{"eNotLogin", 0}, {"eLogin", 1}}));
        insert(QStringLiteral("TipToastType"), makeGroup({{"eRequestFrequently", 0}}));
        insert(QStringLiteral("TableSortTypeEnum"),
               makeGroup({{"SortDefault", 0},
                          {"SortIDAsc", 1},
                          {"SortIDDesc", 2},
                          {"SortNameAsc", 3},
                          {"SortNameDesc", 4},
                          {"SortStatusAsc", 5},
                          {"SortStatusDesc", 6},
                          {"SortDepartAsc", 7},
                          {"SortDepartDesc", 8},
                          {"SortFaceAsc", 9},
                          {"SortFaceDesc", 10}}));
        insert(QStringLiteral("PageOperate"),
               makeGroup({{"DeviceManagementEnum", 0},
                          {"LANDeviceEnum", 1},
                          {"RealtimePreviewEnum", 2},
                          {"VideoPlaybackEnum", 3},
                          {"CloudPlaybackEnum", 4},
                          {"LocalRecordingEnum", 5},
                          {"MessageCenterEnum", 6},
                          {"WorkbenchEnum", 7},
                          {"TeamManagementEnum", 8},
                          {"VipWebViewManagerEnum", 9}}));
    }

  private:
    QVariant makeGroup(const QList<QPair<QString, int>>& values)
    {
        QQmlPropertyMap* group = new QQmlPropertyMap(this);
        for (const auto& pair : values)
            group->insert(pair.first, pair.second);
        return QVariant::fromValue(static_cast<QObject*>(group));
    }
};

#endif // QMLSUPPORT_H
