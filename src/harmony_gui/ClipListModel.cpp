/*
 * ClipListModel.cpp - QML list model wrapping track clips
 */

#include "ClipListModel.h"
#include <QDebug>

namespace harmony::gui
{

ClipListModel::ClipListModel(QObject* parent)
	: QAbstractListModel(parent)
	, m_track(nullptr)
{
}

ClipListModel::~ClipListModel()
{
	setTrackId(nullptr);
}

void ClipListModel::setTrackId(void* id)
{
	lmms::Track* track = static_cast<lmms::Track*>(id);
	if (m_track != track) {
		if (m_track) {
			disconnect(m_track, nullptr, this, nullptr);
		}
		m_track = track;
		if (m_track) {
			connect(m_track, &lmms::Track::destroyedTrack, this, &ClipListModel::onTrackDestroyed);
			connect(m_track, &lmms::Track::clipAdded, this, &ClipListModel::refreshModel);
		}
		emit trackIdChanged();
		refreshModel();
	}
}

int ClipListModel::rowCount(const QModelIndex& parent) const
{
	if (parent.isValid() || !m_track) {
		return 0;
	}
	return static_cast<int>(m_clips.size());
}

QVariant ClipListModel::data(const QModelIndex& index, int role) const
{
	if (!index.isValid() || !m_track || index.row() >= static_cast<int>(m_clips.size())) {
		return QVariant();
	}

	lmms::Clip* clip = m_clips[index.row()];
	if (!clip) {
		return QVariant();
	}

	switch (role) {
		case ClipIndexRole:
			return index.row();
		case ClipNameRole:
			return clip->name();
		case StartTickRole:
			return clip->startPosition().getTicks();
		case LengthTicksRole:
			return clip->length().getTicks();
		case ClipColorRole:
			return clip->color().has_value() ? clip->color().value().name() : "#7f39fb";
		case ClipPtrRole:
			return QVariant::fromValue(static_cast<void*>(clip));
		default:
			return QVariant();
	}
}

QHash<int, QByteArray> ClipListModel::roleNames() const
{
	QHash<int, QByteArray> roles;
	roles[ClipIndexRole] = "clipIndex";
	roles[ClipNameRole] = "clipName";
	roles[StartTickRole] = "startTick";
	roles[LengthTicksRole] = "lengthTicks";
	roles[ClipColorRole] = "clipColor";
	roles[ClipPtrRole] = "clipPtr";
	return roles;
}

void ClipListModel::addClip(int startTick)
{
	if (!m_track) {
		return;
	}
	lmms::TimePos pos(startTick);
	lmms::Clip* clip = m_track->createClip(pos);
	if (clip) {
		clip->changeLength(lmms::TimePos(lmms::TimePos::ticksPerBar()));
		refreshModel();
	}
}

void ClipListModel::deleteClip(int clipIndex)
{
	if (!m_track || clipIndex < 0 || clipIndex >= static_cast<int>(m_clips.size())) {
		return;
	}
	lmms::Clip* clip = m_clips[clipIndex];
	delete clip; // destructor automatically handles removal from track and cleanup
}

void ClipListModel::moveClip(int clipIndex, int newStartTick)
{
	if (!m_track || clipIndex < 0 || clipIndex >= static_cast<int>(m_clips.size())) {
		return;
	}
	m_clips[clipIndex]->movePosition(lmms::TimePos(newStartTick));
}

void ClipListModel::resizeClip(int clipIndex, int newLengthTicks)
{
	if (!m_track || clipIndex < 0 || clipIndex >= static_cast<int>(m_clips.size())) {
		return;
	}
	if (newLengthTicks < 1) {
		newLengthTicks = 1;
	}
	m_clips[clipIndex]->changeLength(lmms::TimePos(newLengthTicks));
}

void ClipListModel::refreshModel()
{
	beginResetModel();
	for (auto* clip : m_clips) {
		if (clip) {
			disconnect(clip, nullptr, this, nullptr);
		}
	}
	m_clips.clear();

	if (m_track) {
		const auto& clips = m_track->getClips();
		m_clips.assign(clips.begin(), clips.end());

		for (auto* clip : m_clips) {
			connectClipSignals(clip);
		}
	}
	endResetModel();
}

void ClipListModel::onTrackDestroyed()
{
	m_track = nullptr;
	emit trackIdChanged();
	refreshModel();
}

void ClipListModel::connectClipSignals(lmms::Clip* clip)
{
	if (!clip) {
		return;
	}
	connect(clip, &lmms::Clip::positionChanged, this, &ClipListModel::refreshModel);
	connect(clip, &lmms::Clip::lengthChanged, this, &ClipListModel::refreshModel);
	connect(clip, &lmms::Clip::colorChanged, this, &ClipListModel::refreshModel);
	connect(clip, &lmms::Clip::destroyedClip, this, &ClipListModel::refreshModel, Qt::QueuedConnection);
}

} // namespace harmony::gui
