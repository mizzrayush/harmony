/*
 * PlaybackController.h - QML controller bridge for LMMS transport controls
 */

#ifndef HARMONY_PLAYBACK_CONTROLLER_H
#define HARMONY_PLAYBACK_CONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QString>
#include "Song.h"

namespace harmony::gui
{

class PlaybackController : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playbackStateChanged)
	Q_PROPERTY(bool isPaused READ isPaused NOTIFY playbackStateChanged)
	Q_PROPERTY(int tempo READ tempo WRITE setTempo NOTIFY tempoChanged)
	Q_PROPERTY(QString timePosition READ timePosition NOTIFY timePositionChanged)
	Q_PROPERTY(int timePosTicks READ timePosTicks WRITE setTimePosTicks NOTIFY timePositionChanged)
	Q_PROPERTY(QString projectFileName READ projectFileName NOTIFY projectFileChanged)

public:
	explicit PlaybackController(QObject* parent = nullptr);
	virtual ~PlaybackController();

	bool isPlaying() const;
	bool isPaused() const;
	int tempo() const;
	void setTempo(int bpm);

	QString timePosition() const;
	int timePosTicks() const;
	void setTimePosTicks(int ticks);
	QString projectFileName() const;

	Q_INVOKABLE void createNewProject();
	Q_INVOKABLE void loadProject(const QString &filename);
	Q_INVOKABLE bool saveProject();
	Q_INVOKABLE bool saveProjectAs(const QString &filename);

public slots:
	void play();
	void pause();
	void stop();
	void togglePause();

signals:
	void playbackStateChanged();
	void tempoChanged();
	void timePositionChanged();
	void projectFileChanged();

private slots:
	void onPlaybackStateChanged();
	void onTempoChanged();
	void updatePosition();

private:
	lmms::Song* getSong() const;

	QTimer* m_updateTimer;
	int m_lastTicks;
};

} // namespace harmony::gui

#endif // HARMONY_PLAYBACK_CONTROLLER_H
