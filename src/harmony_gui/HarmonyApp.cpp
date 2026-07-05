/*
 * HarmonyApp.cpp - QML Application manager for Project Harmony
 */

#include "HarmonyApp.h"
#include <QQmlContext>
#include <QCoreApplication>
#include <QDebug>
#include <QUrl>

namespace harmony::gui
{

HarmonyApp::HarmonyApp(QObject* parent)
	: QObject(parent)
{
}

HarmonyApp::~HarmonyApp()
{
}

void HarmonyApp::init()
{
	// Expose useful global objects to QML context if needed later
	// QQmlContext* context = m_engine.rootContext();

	// Load main QML from resources
	const QUrl url(QStringLiteral("qrc:/qml/main.qml"));

	QObject::connect(&m_engine, &QQmlApplicationEngine::objectCreated,
		QCoreApplication::instance(), [url](QObject *obj, const QUrl &objUrl) {
			if (!obj && url == objUrl) {
				qCritical() << "Error: Failed to load QML root component (main.qml)";
				QCoreApplication::exit(-1);
			} else {
				qDebug() << "Harmony QML main window successfully created.";
			}
		}, Qt::QueuedConnection);

	m_engine.load(url);
}

} // namespace harmony::gui
