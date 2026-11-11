#include "systemtools.h"

#include <QProcess>

#ifdef Q_OS_WIN
#include <Windows.h>
#include <Shellapi.h>
#endif

SystemTools* SystemTools::m_instance = nullptr;

SystemTools::SystemTools(QObject* parent) : QObject(parent)
{
    // 检测系统版本：Win7 = 6.1, Win8 = 6.2, Win8.1 = 6.3, Win10+ = 10.0
#ifdef Q_OS_WIN
    auto version = QSysInfo::windowsVersion();
    m_isWin7OrLower = (version <= QSysInfo::WV_6_3); // Win8.1 及以下走旧路径
#else
    m_isWin7OrLower = false;
#endif
}

SystemTools::~SystemTools() {}

SystemTools* SystemTools::instance()
{
    if (!m_instance)
        m_instance = new SystemTools();
    return m_instance;
}

void SystemTools::openSystemInfo()
{
#ifdef Q_OS_WIN
    if (m_isWin7OrLower) {
        // Win7/Win8/Win8.1：打开"系统属性"控制面板
        QProcess::startDetached(QStringLiteral("control"), {QStringLiteral("sysdm.cpl")});
    } else {
        // Win10+：使用 ms-settings 协议直接打开"设置→系统→关于"
        // ShellExecuteW 支持 ms-settings: URI scheme
        SHELLEXECUTEINFOW sei = {};
        sei.cbSize = sizeof(sei);
        sei.fMask  = SEE_MASK_NOASYNC;
        sei.lpVerb = L"open";
        sei.lpFile = L"ms-settings:about";
        sei.nShow  = SW_SHOWNORMAL;
        ShellExecuteExW(&sei);
    }
#endif
}

void SystemTools::openDeviceManager()
{
#ifdef Q_OS_WIN
    QProcess::startDetached(QStringLiteral("mmc"), {QStringLiteral("devmgmt.msc")});
#endif
}

void SystemTools::openTaskManagerPerformance()
{
#ifdef Q_OS_WIN
    // 启动任务管理器
    QProcess::startDetached(QStringLiteral("taskmgr"), {});

    // 同时打开性能监视器（perfmon.exe），提供更详细的性能图表
    // perfmon 在 Win7+ 均可用，直接定位到性能视图
    QProcess::startDetached(QStringLiteral("perfmon"), {QStringLiteral("/res")});
#endif
}
