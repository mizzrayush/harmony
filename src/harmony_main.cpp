/*
 * harmony_main.cpp - Entry point for Project Harmony QML Frontend
 */

#include "lmmsconfig.h"
#include "lmmsversion.h"

#include <QApplication>
#include <QDebug>
#include <QFileInfo>
#include <QLocale>
#include <QTimer>
#include <QTranslator>
#include <QFile>
#include <QTextStream>
#include <QDateTime>

#ifdef LMMS_BUILD_WIN32
#include <windows.h>
#endif

#include "ConfigManager.h"
#include "Engine.h"
#include "NotePlayHandle.h"
#include "harmony_gui/HarmonyApp.h"

// File message handler for debugging QML/C++ at runtime
void harmonyMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
	QFile logFile("harmony_log.txt");
	if (logFile.open(QIODevice::WriteOnly | QIODevice::Append)) {
		QTextStream stream(&logFile);
		switch (type) {
		case QtDebugMsg: stream << "DEBUG: "; break;
		case QtInfoMsg: stream << "INFO: "; break;
		case QtWarningMsg: stream << "WARNING: "; break;
		case QtCriticalMsg: stream << "CRITICAL: "; break;
		case QtFatalMsg: stream << "FATAL: "; break;
		}
		stream << QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz")
		       << " [" << (context.file ? context.file : "") << ":" << context.line << "] " << msg << "\n";
	}
#ifdef LMMS_BUILD_WIN32
	OutputDebugStringW(reinterpret_cast<const wchar_t*>(msg.utf16()));
#endif
}

int main(int argc, char** argv)
{
	// Force initialization of QML resources (avoids linker stripping)
	Q_INIT_RESOURCE(harmony_qml);

	// Install file logger first
	qInstallMessageHandler(harmonyMessageHandler);

	using namespace lmms;

	// Initialize memory managers
	NotePlayHandleManager::init();

	// Initialize RNG
	srand(time(nullptr));

	// High DPI support
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

	// Create QApplication (required for styling and native widgets if embedded)
	QApplication app(argc, argv);
	app.setApplicationName("Harmony");
	app.setApplicationVersion(LMMS_VERSION);
	app.setOrganizationName("HarmonyDAW");

	// Initialize LMMS Config Manager
	ConfigManager::inst()->loadConfigFile("");

	// Initialize LMMS Audio Engine
	qDebug() << "Initializing LMMS Audio Engine...";
	Engine::init(false);

	// Initialize project with default template
	Engine::getSong()->createNewProject();

	// Initialize Harmony QML Application lifecycle manager
	qDebug() << "Launching Harmony QML Application...";
	harmony::gui::HarmonyApp harmonyApp;
	harmonyApp.init();

	return app.exec();
}
