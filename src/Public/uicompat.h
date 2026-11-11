#ifndef UICOMPAT_H
#define UICOMPAT_H

#include <QColor>
#include <QObject>
#include <QString>

/**
 * @brief 主题色单例（对应 VmsTools 的 ThemeColorStyle）
 *
 * 颜色取自 ThemeColor.css，供搬运过来的 Flu 系列控件直接使用。
 * 注册方式为上下文属性，QML 里可裸用 ThemeColorStyle.xxx。
 */
class ThemeColorStyle : public QObject {
    Q_OBJECT
    // ===== 主界面相关 =====
    Q_PROPERTY(QColor privacy_color READ privacy_color CONSTANT)
    Q_PROPERTY(QColor privacy_error_color READ privacy_error_color CONSTANT)
    Q_PROPERTY(QColor privacy_text_color READ privacy_text_color CONSTANT)
    Q_PROPERTY(QColor privacy_rect_color READ privacy_rect_color CONSTANT)
    Q_PROPERTY(QColor tab_text_nor_color READ tab_text_nor_color CONSTANT)
    Q_PROPERTY(QColor tab_text_checked_color READ tab_text_checked_color CONSTANT)
    Q_PROPERTY(QColor dialog_bg_color READ dialog_bg_color CONSTANT)
    Q_PROPERTY(QColor workspace_checked_begin_color READ workspace_checked_begin_color CONSTANT)
    Q_PROPERTY(QColor workspace_checked_end_color READ workspace_checked_end_color CONSTANT)
    Q_PROPERTY(QColor workspace_begin_color READ workspace_begin_color CONSTANT)
    Q_PROPERTY(QColor workspace_end_color READ workspace_end_color CONSTANT)

    // ===== 文本颜色 =====
    Q_PROPERTY(QColor title_text_nor_color READ title_text_nor_color CONSTANT)
    Q_PROPERTY(QColor text_nor_color READ text_nor_color CONSTANT)
    Q_PROPERTY(QColor placeholder_text_color READ placeholder_text_color CONSTANT)
    Q_PROPERTY(QColor okBtn_text_color READ okBtn_text_color CONSTANT)
    Q_PROPERTY(QColor cancelBtn_text_color READ cancelBtn_text_color CONSTANT)
    Q_PROPERTY(QColor cancelBtn_text_nor_color READ cancelBtn_text_nor_color CONSTANT)
    Q_PROPERTY(QColor text_disable_color READ text_disable_color CONSTANT)

    // ===== 按钮背景颜色 =====
    Q_PROPERTY(QColor bg_disable_color READ bg_disable_color CONSTANT)
    Q_PROPERTY(QColor okBtn_bg_color READ okBtn_bg_color CONSTANT)
    Q_PROPERTY(QColor cancelBtn_bg_color READ cancelBtn_bg_color CONSTANT)
    Q_PROPERTY(QColor cancelBtn_bg_nor_color READ cancelBtn_bg_nor_color CONSTANT)
    Q_PROPERTY(QColor deleteBtn_bg_color READ deleteBtn_bg_color CONSTANT)
    Q_PROPERTY(QColor button_hover_bg_color READ button_hover_bg_color CONSTANT)
    Q_PROPERTY(QColor button_disable_bg_color READ button_disable_bg_color CONSTANT)
    Q_PROPERTY(QColor radioBtn_checked_color READ radioBtn_checked_color CONSTANT)
    Q_PROPERTY(QColor radioBtn_nor_color READ radioBtn_nor_color CONSTANT)
    Q_PROPERTY(QColor radioBtn_disable_color READ radioBtn_disable_color CONSTANT)

    // ===== 边框颜色 =====
    Q_PROPERTY(QColor border_nor_color READ border_nor_color CONSTANT)
    Q_PROPERTY(QColor border_checked_color READ border_checked_color CONSTANT)
    Q_PROPERTY(QColor border_error_color READ border_error_color CONSTANT)

    // ===== 功能按钮颜色 =====
    Q_PROPERTY(QColor tool_button_nor_color READ tool_button_nor_color CONSTANT)
    Q_PROPERTY(QColor tool_button_press_color READ tool_button_press_color CONSTANT)
    Q_PROPERTY(QColor tool_button_hover_color READ tool_button_hover_color CONSTANT)
    Q_PROPERTY(QColor tool_button_active_color READ tool_button_active_color CONSTANT)
    Q_PROPERTY(QColor tool_button_disable_color READ tool_button_disable_color CONSTANT)

    // ===== 列表颜色 =====
    Q_PROPERTY(QColor list_bg_select_color READ list_bg_select_color CONSTANT)
    Q_PROPERTY(QColor data_bg_select_color READ data_bg_select_color CONSTANT)
    Q_PROPERTY(QColor list_bg_hover_color READ list_bg_hover_color CONSTANT)
    Q_PROPERTY(QColor list_bg_disable_color READ list_bg_disable_color CONSTANT)
    Q_PROPERTY(QColor list_bg_nor_color READ list_bg_nor_color CONSTANT)
    Q_PROPERTY(QColor list_text_nor_color READ list_text_nor_color CONSTANT)
    Q_PROPERTY(QColor list_text_hover_color READ list_text_hover_color CONSTANT)
    Q_PROPERTY(QColor list_text_select_color READ list_text_select_color CONSTANT)
    Q_PROPERTY(QColor data_text_select_color READ data_text_select_color CONSTANT)
    Q_PROPERTY(QColor list_text_disable_color READ list_text_disable_color CONSTANT)

    // ===== 云台控制颜色 =====
    Q_PROPERTY(QColor ptz_nor_bg_color READ ptz_nor_bg_color CONSTANT)
    Q_PROPERTY(QColor ptz_hover_bg_color READ ptz_hover_bg_color CONSTANT)
    Q_PROPERTY(QColor ptz_press_bg_color READ ptz_press_bg_color CONSTANT)

  public:
    explicit ThemeColorStyle(QObject* parent = nullptr) : QObject(parent) {}

    QColor privacy_color() const { return QColor("#E5F5FF"); }
    QColor privacy_error_color() const { return QColor("#FF4A4A"); }
    QColor privacy_text_color() const { return QColor("#0099FF"); }
    QColor privacy_rect_color() const { return QColor("#F5F7FA"); }
    QColor tab_text_nor_color() const { return QColor("#989EA6"); }
    QColor tab_text_checked_color() const { return QColor("#0099FF"); }
    QColor dialog_bg_color() const { return QColor("#EDEFF2"); }
    QColor workspace_checked_begin_color() const { return QColor("#66C2FF"); }
    QColor workspace_checked_end_color() const { return QColor("#0099FF"); }
    QColor workspace_begin_color() const { return QColor("#C1D1DC"); }
    QColor workspace_end_color() const { return QColor("#7C92A0"); }

    QColor title_text_nor_color() const { return QColor("#1D1F21"); }
    QColor text_nor_color() const { return QColor("#6D7682"); }
    QColor placeholder_text_color() const { return QColor("#989EA6"); }
    QColor okBtn_text_color() const { return QColor("#FFFFFF"); }
    QColor cancelBtn_text_color() const { return QColor("#6D7682"); }
    QColor cancelBtn_text_nor_color() const { return QColor("#6D7682"); }
    QColor text_disable_color() const { return QColor("#C6C9CC"); }

    QColor bg_disable_color() const { return QColor("#F6F6F6"); }
    QColor okBtn_bg_color() const { return QColor("#0099FF"); }
    QColor cancelBtn_bg_color() const { return QColor("#FFFFFF"); }
    QColor cancelBtn_bg_nor_color() const { return QColor("#FFFFFF"); }
    QColor deleteBtn_bg_color() const { return QColor("#FF4A4A"); }
    QColor button_hover_bg_color() const { return QColor("#E5F5FF"); }
    QColor button_disable_bg_color() const { return QColor("#F6F6F6"); }
    QColor radioBtn_checked_color() const { return QColor("#0099FF"); }
    QColor radioBtn_nor_color() const { return QColor("#FFFFFF"); }
    QColor radioBtn_disable_color() const { return QColor("#F5F7FA"); }

    QColor border_nor_color() const { return QColor("#CAD2DD"); }
    QColor border_checked_color() const { return QColor("#0099FF"); }
    QColor border_error_color() const { return QColor("#FF4A4A"); }

    QColor tool_button_nor_color() const { return QColor("#6D7682"); }
    QColor tool_button_press_color() const { return QColor("#989EA6"); }
    QColor tool_button_hover_color() const { return QColor("#1D1F21"); }
    QColor tool_button_active_color() const { return QColor("#0099FF"); }
    QColor tool_button_disable_color() const { return QColor("#C6C9CC"); }

    QColor list_bg_select_color() const { return QColor("#E5F5FF"); }
    QColor data_bg_select_color() const { return QColor("#0099FF"); }
    QColor list_bg_hover_color() const { return QColor("#E5F5FF"); }
    QColor list_bg_disable_color() const { return QColor("#F6F6F6"); }
    QColor list_bg_nor_color() const { return QColor("#FFFFFF"); }
    QColor list_text_nor_color() const { return QColor("#6D7682"); }
    QColor list_text_hover_color() const { return QColor("#6D7682"); }
    QColor list_text_select_color() const { return QColor("#0099FF"); }
    QColor data_text_select_color() const { return QColor("#FFFFFF"); }
    QColor list_text_disable_color() const { return QColor("#C6C9CC"); }

    QColor ptz_nor_bg_color() const { return QColor("#F5F7FA"); }
    QColor ptz_hover_bg_color() const { return QColor("#DFE2E5"); }
    QColor ptz_press_bg_color() const { return QColor("#59BDFF"); }
};

/**
 * @brief 配置管理器占位实现（对应 VmsTools 的 ConfigureManager）
 *
 * Flu 控件只用到 isRTLLayout 等少量属性，RDTools 没有对应业务，
 * 这里给出稳定的默认值，保证控件可以正常渲染。
 */
class ConfigureManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isRTLLayout READ isRTLLayout CONSTANT)
    Q_PROPERTY(int pageType READ pageType CONSTANT)
    Q_PROPERTY(bool closeButtonEvent READ closeButtonEvent WRITE setCloseButtonEvent NOTIFY closeButtonEventChanged)
    Q_PROPERTY(bool exitNoRemind READ exitNoRemind WRITE setExitNoRemind NOTIFY exitNoRemindChanged)
    Q_PROPERTY(QString topTeamId READ topTeamId CONSTANT)
    Q_PROPERTY(QString topTeamName READ topTeamName CONSTANT)
    Q_PROPERTY(QString userAccount READ userAccount CONSTANT)
    Q_PROPERTY(QString userPasswd READ userPasswd CONSTANT)

  public:
    static ConfigureManager* instance()
    {
        static ConfigureManager obj;
        return &obj;
    }

    explicit ConfigureManager(QObject* parent = nullptr) : QObject(parent) {}

    // 从右到左布局：项目只支持从左到右
    bool isRTLLayout() const { return false; }
    int  pageType() const { return 0; }

    bool closeButtonEvent() const { return m_closeButtonEvent; }
    void setCloseButtonEvent(bool v)
    {
        if (m_closeButtonEvent == v)
            return;
        m_closeButtonEvent = v;
        emit closeButtonEventChanged();
    }

    bool exitNoRemind() const { return m_exitNoRemind; }
    void setExitNoRemind(bool v)
    {
        if (m_exitNoRemind == v)
            return;
        m_exitNoRemind = v;
        emit exitNoRemindChanged();
    }

    QString topTeamId() const { return QString(); }
    QString topTeamName() const { return QString(); }
    QString userAccount() const { return QString(); }
    QString userPasswd() const { return QString(); }

    Q_INVOKABLE QString getProgramLogoUrl() const { return QString(); }

  signals:
    void closeButtonEventChanged();
    void exitNoRemindChanged();

  private:
    bool m_closeButtonEvent = false;
    bool m_exitNoRemind     = false;
};

/**
 * @brief 提示信息配色（对应 VmsTools 的 InfoInterface）
 */
class InfoInterface : public QObject {
    Q_OBJECT
    Q_PROPERTY(QColor titleTextColor READ titleTextColor CONSTANT)
    Q_PROPERTY(QColor contentTextColor READ contentTextColor CONSTANT)
    Q_PROPERTY(QColor infoBgColor READ infoBgColor CONSTANT)
    Q_PROPERTY(QColor successBgColor READ successBgColor CONSTANT)
    Q_PROPERTY(QColor warningBgColor READ warningBgColor CONSTANT)
    Q_PROPERTY(QColor errorBgColor READ errorBgColor CONSTANT)
    Q_PROPERTY(int pointSize READ pointSize CONSTANT)

  public:
    static InfoInterface* instance()
    {
        static InfoInterface obj;
        return &obj;
    }

    explicit InfoInterface(QObject* parent = nullptr) : QObject(parent) {}

    QColor titleTextColor() const { return QColor("#1D1F21"); }
    QColor contentTextColor() const { return QColor("#6D7682"); }
    QColor infoBgColor() const { return QColor("#E5F5FF"); }
    QColor successBgColor() const { return QColor("#E8F8EE"); }
    QColor warningBgColor() const { return QColor("#FFF6E5"); }
    QColor errorBgColor() const { return QColor("#FFECEC"); }
    int    pointSize() const { return 10; }
};

/**
 * @brief 全局状态占位实现（对应 VmsTools 的 InformationNotifier）
 */
class InformationNotifier : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool appQuitting READ appQuitting CONSTANT)
    Q_PROPERTY(bool isLogin READ isLogin CONSTANT)

  public:
    static InformationNotifier* instance()
    {
        static InformationNotifier obj;
        return &obj;
    }

    explicit InformationNotifier(QObject* parent = nullptr) : QObject(parent) {}

    bool appQuitting() const { return false; }
    bool isLogin() const { return false; }
};

#endif // UICOMPAT_H
