/*
 * HarmonyApp.cpp - QML Application manager for Project Harmony
 */

#include "HarmonyApp.h"
#include "PlaybackController.h"
#include "BrowserModel.h"
#include "TrackListModel.h"
#include "MixerModel.h"
#include "NotePatternModel.h"
#include "InstrumentControlModel.h"
#include "ClipListModel.h"
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
	// Register Harmony bridge types for QML
	qmlRegisterType<harmony::gui::PlaybackController>("Harmony", 1, 0, "PlaybackController");
	qmlRegisterType<harmony::gui::BrowserModel>("Harmony", 1, 0, "BrowserModel");
	qmlRegisterType<harmony::gui::TrackListModel>("Harmony", 1, 0, "TrackListModel");
	qmlRegisterType<harmony::gui::MixerModel>("Harmony", 1, 0, "MixerModel");
	qmlRegisterType<harmony::gui::NotePatternModel>("Harmony", 1, 0, "NotePatternModel");
	qmlRegisterType<harmony::gui::InstrumentControlModel>("Harmony", 1, 0, "InstrumentControlModel");
	qmlRegisterType<harmony::gui::ClipListModel>("Harmony", 1, 0, "ClipListModel");

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
