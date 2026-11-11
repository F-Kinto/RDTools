#ifndef SYSTEMTOOLS_H
#define SYSTEMTOOLS_H

#include <QObject>
#include <QStringList>

/**
 * @brief 系统工具集（单例，注册给 QML 使用）
 *
 * 提供系统信息查看、COM 端口枚举、性能监控等 Q_INVOKABLE 接口，
 * 供 QML 按钮点击时调用。所有功能支持 Win7 及以上系统。
 */
class SystemTools : public QObject {
    Q_OBJECT

  public:
    ~SystemTools();

    static SystemTools* instance();

    /**
     * @brief 打开 Windows"设置→系统信息"页面
     *
     * Win10+ 使用 ms-settings:about 协议直接打开"关于"页；
     * Win7/8 回退到 control sysdm.cpl 打开"系统属性"对话框。
     */
    Q_INVOKABLE void openSystemInfo();

    /**
     * @brief 打开 Windows 设备管理器
     *
     * Win7+ 均可用 devmgmt.msc 打开设备管理器。
     */
    Q_INVOKABLE void openDeviceManager();

    /**
     * @brief 打开任务管理器并切换到"性能"标签
     *
     * Win7 启动经典 taskmgr.exe（保留上次标签页状态）；
     * Win8+ 启动新版 taskmgr.exe。
     * 同时以 ShellExecute 打开 perfmon.exe（性能监视器），
     * 提供更详细的性能图表。
     */
    Q_INVOKABLE void openTaskManagerPerformance();

  private:
    explicit SystemTools(QObject* parent = nullptr);

    static SystemTools* m_instance;

    bool m_isWin7OrLower = false;
};

#endif // SYSTEMTOOLS_H
