/*
 * PlaybackController.cpp - QML controller bridge for LMMS transport controls
 */

#include "PlaybackController.h"
#include "Engine.h"
#include "Song.h"
#include "TimePos.h"
#include <QDebug>

namespace harmony::gui
{

PlaybackController::PlaybackController(QObject* parent)
	: QObject(parent)
	, m_updateTimer(new QTimer(this))
	, m_lastTicks(-1)
{
	m_updateTimer->setInterval(30); // ~33 FPS updates
	connect(m_updateTimer, &QTimer::timeout, this, &PlaybackController::updatePosition);

	// Connect to backend Song signals once song is loaded/changed
	lmms::Song* song = getSong();
	if (song) {
		connect(song, &lmms::Song::playbackStateChanged, this, &PlaybackController::onPlaybackStateChanged);
		connect(song, &lmms::Song::stopped, this, &PlaybackController::onPlaybackStateChanged);
		connect(song, &lmms::Song::tempoChanged, this, &PlaybackController::onTempoChanged);
	}
}

PlaybackController::~PlaybackController()
{
}

lmms::Song* PlaybackController::getSong() const
{
	return lmms::Engine::getSong();
}

bool PlaybackController::isPlaying() const
{
	lmms::Song* song = getSong();
	return song ? song->isPlaying() : false;
}

bool PlaybackController::isPaused() const
{
	lmms::Song* song = getSong();
	return song ? song->isPaused() : false;
}

int PlaybackController::tempo() const
{
	lmms::Song* song = getSong();
	return song ? song->getTempo() : 120;
}

void PlaybackController::setTempo(int bpm)
{
	lmms::Song* song = getSong();
	if (song && bpm != song->getTempo()) {
		song->tempoModel().setValue(bpm);
	}
}

QString PlaybackController::timePosition() const
{
	lmms::Song* song = getSong();
	if (!song) {
		return QStringLiteral("001.01.000");
	}

	lmms::TimePos pos = song->getPlayPos();
	lmms::TimeSig sig(song->getTimeSigModel());

	int bar = pos.getBar() + 1;
	int beat = pos.getBeatWithinBar(sig) + 1;
	int ticks = pos.getTickWithinBeat(sig);

	return QString("%1 . %2 . %3")
		.arg(bar, 3, 10, QChar('0'))
		.arg(beat, 2, 10, QChar('0'))
		.arg(ticks, 3, 10, QChar('0'));
}

int PlaybackController::timePosTicks() const
{
	lmms::Song* song = getSong();
	return song ? song->getPlayPos().getTicks() : 0;
}

void PlaybackController::setTimePosTicks(int ticks)
{
	lmms::Song* song = getSong();
	if (song) {
		song->setPlayPos(ticks);
		emit timePositionChanged();
	}
}

void PlaybackController::play()
{
	lmms::Song* song = getSong();
	if (song) {
		song->playSong();
	}
}

void PlaybackController::pause()
{
	lmms::Song* song = getSong();
	if (song) {
		song->togglePause();
	}
}

void PlaybackController::stop()
{
	lmms::Song* song = getSong();
	if (song) {
		song->stop();
	}
}

void PlaybackController::togglePause()
{
	lmms::Song* song = getSong();
	if (song) {
		song->togglePause();
	}
}

void PlaybackController::onPlaybackStateChanged()
{
	if (isPlaying()) {
		m_updateTimer->start();
	} else {
		m_updateTimer->stop();
	}
	emit playbackStateChanged();
	updatePosition();
}

void PlaybackController::onTempoChanged()
{
	emit tempoChanged();
}

void PlaybackController::updatePosition()
{
	int current = timePosTicks();
	if (current != m_lastTicks) {
		m_lastTicks = current;
		emit timePositionChanged();
	}
}

} // namespace harmony::gui
