/*
 * HarmonyApp.h - QML Application manager for Project Harmony
 */

#ifndef HARMONY_GUI_HARMONY_APP_H
#define HARMONY_GUI_HARMONY_APP_H

#include <QObject>
#include <QQmlApplicationEngine>

namespace harmony::gui
{

class HarmonyApp : public QObject
{
	Q_OBJECT
public:
	explicit HarmonyApp(QObject* parent = nullptr);
	virtual ~HarmonyApp() override;

	void init();

private:
	QQmlApplicationEngine m_engine;
};

} // namespace harmony::gui

#endif // HARMONY_GUI_HARMONY_APP_H
