#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QJSEngine>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <QTextStream>
#include <QUrl>

#include "Public/qmlsupport.h"
#include "Public/screentools.h"
#include "Public/systemtools.h"
#include "Public/screencapture.h"
#include "Public/svgiconitem.h"
#include "Public/uicompat.h"

#include <Windows.h>

// 把单例对象注册成 QML 类型（模块 RDTools.Public 1.0）
template <typename T>
static void registerSingleton(const char* uri, int major, int minor, const char* name)
{
    qmlRegisterSingletonType<T>(
        uri, major, minor, name, [](QQmlEngine* qmlEngine, QJSEngine*) -> QObject* {
            T* obj = T::instance();
            qmlEngine->setObjectOwnership(obj, QQmlEngine::CppOwnership);
            return obj;
        });
}

// 进程级 Per-Monitor DPI 感知：不设置的话，修改系统缩放比后启动读到的
// 可能是修改之前的 DPI，界面尺寸会按错误的缩放比计算
static void setDPIAwareness()
{
    HMODULE hShCore = GetModuleHandleA("shcore.dll");
    if (!hShCore) {
        hShCore = LoadLibraryA("shcore.dll");
        if (!hShCore)
            return;
    }

    typedef HRESULT(WINAPI * SetProcessDpiAwarenessProc)(int);
    auto pSetProcessDpiAwareness =
        (SetProcessDpiAwarenessProc)GetProcAddress(hShCore, "SetProcessDpiAwareness");
    if (pSetProcessDpiAwareness)
        pSetProcessDpiAwareness(2 /* PROCESS_PER_MONITOR_DPI_AWARE */);
}

// 窗口程序没有控制台，把 QML/C++ 的日志写到可执行文件同级的 rdtools.log
static void fileMessageHandler(QtMsgType type, const QMessageLogContext&, const QString& msg)
{
    QFile f(QCoreApplication::applicationDirPath() + "/rdtools.log");
    if (!f.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
        return;
    QTextStream(&f) << qPrintable(msg) << "\n";
}

int main(int argc, char* argv[])
{
    // 高 DPI 相关设置必须在 QGuiApplication 构造前完成
    setDPIAwareness();
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("RDTools");
    app.setApplicationName("RDTools");

    qInstallMessageHandler(fileMessageHandler);

    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    // FluentUI 模块随程序部署在可执行文件同级的 FluentUI 目录下
    engine.addImportPath(QCoreApplication::applicationDirPath());
    // 搬运过来的 Flu 控件以 QML 模块形式放在 qrc:/Component/<模块> 下
    engine.addImportPath(QStringLiteral("qrc:/"));

    // ===== 分辨率 / DPI 适配（RDTools.Public 与 Flu 控件的 ScreenTools 模块均指向同一实例）=====
    registerSingleton<ScreenTools>("ScreenTools", 1, 0, "ScreenTools");
    registerSingleton<ScreenTools>("RDTools.Public", 1, 0, "ScreenTools");

    // ===== 系统工具集（系统信息、COM 端口、性能监控等）=====
    registerSingleton<SystemTools>("RDTools.Public", 1, 0, "SystemTools");

    // ===== 截屏工具（截屏、区域裁剪、剪贴板写入）=====
    registerSingleton<ScreenCapture>("RDTools.Public", 1, 0, "ScreenCapture");

    // ===== Flu 控件依赖的配置 / 提示信息单例 =====
    registerSingleton<ConfigureManager>("ConfigureManager", 1, 0, "ConfigureManager");
    registerSingleton<InfoInterface>("InfoInterface", 1, 0, "InfoInterface");
    registerSingleton<InformationNotifier>("InformationNotifier", 1, 0, "InformationNotifier");
    // 主题色 / 图标字典以上下文属性提供，Flu 控件里可直接裸用 ThemeColorStyle.xxx、CommonImageStyle.xxx
    engine.rootContext()->setContextProperty("ThemeColorStyle", new ThemeColorStyle(&app));
    engine.rootContext()->setContextProperty("CommonImageStyle", CommonImageStyle::instance());

    // 控件用到的枚举（import VMS.Enum 1.0 后用 VmsEnum.XxxEnum.Yyy）
    registerSingleton<VmsEnum>("VMS.Enum", 1, 0, "VmsEnum");
    // SVG 换色图标项（FluCustomSvg 内部使用）
    qmlRegisterType<SvgIconItem>("SvgIconItem", 1, 0, "SvgIconItem");

    // 控件里存在 import 但实际未使用到的模块，注册为空模块避免加载失败
    qmlRegisterModule("TranslatorManager", 1, 0);

    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    engine.load(url);
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
