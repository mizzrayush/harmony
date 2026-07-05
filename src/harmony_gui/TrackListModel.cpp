/*
 * TrackListModel.cpp - QML list model wrapping active song tracks
 */

#include "TrackListModel.h"
#include "Engine.h"
#include "InstrumentTrack.h"
#include <QDebug>

namespace harmony::gui
{

TrackListModel::TrackListModel(QObject* parent)
	: QAbstractListModel(parent)
{
	lmms::Song* song = getSong();
	if (song) {
		connect(song, &lmms::Song::trackAdded, this, &TrackListModel::onTrackAdded);
		connect(song, &lmms::Song::trackRemoved, this, &TrackListModel::onTrackRemoved);
		connect(song, &lmms::Song::trackMoved, this, &TrackListModel::onTrackMoved);
		connect(song, &lmms::Song::projectLoaded, this, &TrackListModel::refreshModel);
	}
	refreshModel();
}

TrackListModel::~TrackListModel()
{
}

lmms::Song* TrackListModel::getSong() const
{
	return lmms::Engine::getSong();
}

int TrackListModel::rowCount(const QModelIndex& parent) const
{
	if (parent.isValid()) {
		return 0;
	}
	return m_tracks.size();
}

QVariant TrackListModel::data(const QModelIndex& index, int role) const
{
	if (!index.isValid() || index.row() >= m_tracks.size()) {
		return QVariant();
	}

	lmms::Track* track = m_tracks[index.row()];
	if (!track) {
		return QVariant();
	}

	switch (role) {
		case TrackIdRole:
			return QVariant::fromValue(static_cast<void*>(track));
		case NameRole:
			return track->name();
		case TypeRole:
			return static_cast<int>(track->type());
		case IsMutedRole:
			return track->isMuted();
		case IsSoloRole:
			return track->isSolo();
		case ColorRole:
			return track->color().has_value() ? track->color().value().name() : "#7f39fb";
		case ClipCountRole:
			return static_cast<int>(track->getClips().size());
		default:
			return QVariant();
	}
}

bool TrackListModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
	if (!index.isValid() || index.row() >= m_tracks.size()) {
		return false;
	}

	lmms::Track* track = m_tracks[index.row()];
	if (!track) {
		return false;
	}

	bool changed = false;
	if (role == NameRole) {
		QString name = value.toString();
		if (track->name() != name) {
			track->setName(name);
			changed = true;
		}
	} else if (role == IsMutedRole) {
		bool muted = value.toBool();
		if (track->isMuted() != muted) {
			track->setMuted(muted);
			changed = true;
		}
	} else if (role == IsSoloRole) {
		bool solo = value.toBool();
		if (track->isSolo() != solo) {
			if (solo) {
				track->toggleSolo();
			} else {
				track->toggleSolo(); // toggles back
			}
			changed = true;
		}
	}

	if (changed) {
		emit dataChanged(index, index, {role});
		return true;
	}
	return false;
}

QHash<int, QByteArray> TrackListModel::roleNames() const
{
	QHash<int, QByteArray> roles;
	roles[TrackIdRole] = "trackId";
	roles[NameRole] = "trackName";
	roles[TypeRole] = "trackType";
	roles[IsMutedRole] = "isMuted";
	roles[IsSoloRole] = "isSolo";
	roles[ColorRole] = "trackColor";
	roles[ClipCountRole] = "clipCount";
	return roles;
}

void TrackListModel::addInstrumentTrack(const QString& pluginName)
{
	lmms::Song* song = getSong();
	if (!song) {
		return;
	}

	auto track = lmms::Track::create(lmms::Track::Type::Instrument, song);
	if (track) {
		auto it = dynamic_cast<lmms::InstrumentTrack*>(track);
		if (it) {
			it->loadInstrument(pluginName);
			it->setName(pluginName);
		}
		song->addTrack(track);
	}
}

void TrackListModel::deleteTrack(int index)
{
	lmms::Song* song = getSong();
	if (!song || index >= m_tracks.size()) {
		return;
	}

	lmms::Track* track = m_tracks[index];
	song->removeTrack(track);
	delete track;
}

void TrackListModel::toggleMute(int index)
{
	if (index >= 0 && index < m_tracks.size()) {
		lmms::Track* track = m_tracks[index];
		track->setMuted(!track->isMuted());
		emit dataChanged(this->index(index), this->index(index), {IsMutedRole});
	}
}

void TrackListModel::toggleSolo(int index)
{
	if (index >= 0 && index < m_tracks.size()) {
		lmms::Track* track = m_tracks[index];
		track->toggleSolo();
		emit dataChanged(this->index(index), this->index(index), {IsSoloRole});
	}
}

void TrackListModel::onTrackAdded(lmms::Track* track)
{
	Q_UNUSED(track);
	refreshModel();
}

void TrackListModel::onTrackRemoved()
{
	refreshModel();
}

void TrackListModel::onTrackMoved()
{
	refreshModel();
}

void TrackListModel::refreshModel()
{
	beginResetModel();
	for (auto* track : m_tracks) {
		if (track) {
			disconnect(track, nullptr, this, nullptr);
		}
	}
	m_tracks.clear();

	lmms::Song* song = getSong();
	if (song) {
		for (auto* track : song->tracks()) {
			m_tracks.append(track);
			connectTrackSignals(track);
		}
	}
	endResetModel();
}

void TrackListModel::connectTrackSignals(lmms::Track* track)
{
	if (!track) {
		return;
	}
	connect(track, &lmms::Track::nameChanged, this, [this, track]() {
		int index = m_tracks.indexOf(track);
		if (index != -1) {
			emit dataChanged(this->index(index), this->index(index), {NameRole});
		}
	});
	connect(track, &lmms::Track::colorChanged, this, [this, track]() {
		int index = m_tracks.indexOf(track);
		if (index != -1) {
			emit dataChanged(this->index(index), this->index(index), {ColorRole});
		}
	});
}

} // namespace harmony::gui
