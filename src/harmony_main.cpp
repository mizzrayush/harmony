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

#include "ConfigManager.h"
#include "Engine.h"
#include "NotePlayHandle.h"
#include "harmony_gui/HarmonyApp.h"

int main(int argc, char** argv)
{
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

	// Initialize Harmony QML Application lifecycle manager
	qDebug() << "Launching Harmony QML Application...";
	harmony::gui::HarmonyApp harmonyApp;
	harmonyApp.init();

	return app.exec();
}
