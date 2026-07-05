/*
 * MixerModel.cpp - QML list model wrapping effect mixer channels
 */

#include "MixerModel.h"
#include "Engine.h"
#include <QDebug>

namespace harmony::gui
{

MixerModel::MixerModel(QObject* parent)
	: QAbstractListModel(parent)
	, m_peakTimer(new QTimer(this))
	, m_channelCount(0)
{
	m_peakTimer->setInterval(33); // ~30 FPS updates
	connect(m_peakTimer, &QTimer::timeout, this, &MixerModel::updatePeaks);
	m_peakTimer->start();

	lmms::Mixer* mixer = getMixer();
	if (mixer) {
		connect(mixer, &lmms::Mixer::dataChanged, this, &MixerModel::refreshModel);
	}
	refreshModel();
}

MixerModel::~MixerModel()
{
}

lmms::Mixer* MixerModel::getMixer() const
{
	return lmms::Engine::mixer();
}

int MixerModel::rowCount(const QModelIndex& parent) const
{
	if (parent.isValid()) {
		return 0;
	}
	return m_channelCount;
}

QVariant MixerModel::data(const QModelIndex& index, int role) const
{
	lmms::Mixer* mixer = getMixer();
	if (!mixer || index.row() >= m_channelCount) {
		return QVariant();
	}

	lmms::MixerChannel* ch = mixer->mixerChannel(index.row());
	if (!ch) {
		return QVariant();
	}

	switch (role) {
		case ChannelIndexRole:
			return ch->index();
		case NameRole:
			return ch->m_name.isEmpty() ? (ch->isMaster() ? QStringLiteral("Master") : QString("FX %1").arg(ch->index())) : ch->m_name;
		case VolumeRole:
			return ch->m_volumeModel.value();
		case IsMutedRole:
			return ch->m_muteModel.value();
		case IsSoloRole:
			return ch->m_soloModel.value();
		case PeakLeftRole:
			return ch->m_peakLeft;
		case PeakRightRole:
			return ch->m_peakRight;
		case ColorRole:
			return ch->color().has_value() ? ch->color().value().name() : "#7f39fb";
		default:
			return QVariant();
	}
}

bool MixerModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
	lmms::Mixer* mixer = getMixer();
	if (!mixer || index.row() >= m_channelCount) {
		return false;
	}

	lmms::MixerChannel* ch = mixer->mixerChannel(index.row());
	if (!ch) {
		return false;
	}

	bool changed = false;
	if (role == VolumeRole) {
		float vol = value.toFloat();
		if (ch->m_volumeModel.value() != vol) {
			ch->m_volumeModel.setValue(vol);
			changed = true;
		}
	} else if (role == IsMutedRole) {
		bool muted = value.toBool();
		if (ch->m_muteModel.value() != muted) {
			ch->m_muteModel.setValue(muted);
			changed = true;
		}
	} else if (role == IsSoloRole) {
		bool solo = value.toBool();
		if (ch->m_soloModel.value() != solo) {
			ch->m_soloModel.setValue(solo);
			changed = true;
		}
	} else if (role == NameRole) {
		QString name = value.toString();
		if (ch->m_name != name) {
			ch->m_name = name;
			changed = true;
		}
	}

	if (changed) {
		emit dataChanged(index, index, {role});
		return true;
	}
	return false;
}

QHash<int, QByteArray> MixerModel::roleNames() const
{
	QHash<int, QByteArray> roles;
	roles[ChannelIndexRole] = "channelIndex";
	roles[NameRole] = "channelName";
	roles[VolumeRole] = "channelVolume";
	roles[IsMutedRole] = "isMuted";
	roles[IsSoloRole] = "isSolo";
	roles[PeakLeftRole] = "peakLeft";
	roles[PeakRightRole] = "peakRight";
	roles[ColorRole] = "channelColor";
	return roles;
}

void MixerModel::addChannel()
{
	lmms::Mixer* mixer = getMixer();
	if (mixer) {
		mixer->createChannel();
		refreshModel();
	}
}

void MixerModel::removeChannel(int index)
{
	lmms::Mixer* mixer = getMixer();
	if (mixer && index > 0 && index < m_channelCount) {
		mixer->deleteChannel(index);
		refreshModel();
	}
}

void MixerModel::toggleMute(int index)
{
	lmms::Mixer* mixer = getMixer();
	if (mixer && index >= 0 && index < m_channelCount) {
		lmms::MixerChannel* ch = mixer->mixerChannel(index);
		ch->m_muteModel.setValue(!ch->m_muteModel.value());
		emit dataChanged(this->index(index), this->index(index), {IsMutedRole});
	}
}

void MixerModel::toggleSolo(int index)
{
	lmms::Mixer* mixer = getMixer();
	if (mixer && index >= 0 && index < m_channelCount) {
		lmms::MixerChannel* ch = mixer->mixerChannel(index);
		ch->m_soloModel.setValue(!ch->m_soloModel.value());
		emit dataChanged(this->index(index), this->index(index), {IsSoloRole});
	}
}

void MixerModel::updatePeaks()
{
	if (m_channelCount > 0) {
		emit dataChanged(index(0), index(m_channelCount - 1), {PeakLeftRole, PeakRightRole});
	}
}

void MixerModel::refreshModel()
{
	lmms::Mixer* mixer = getMixer();
	int newCount = mixer ? mixer->numChannels() : 0;

	if (newCount != m_channelCount) {
		beginResetModel();
		m_channelCount = newCount;
		endResetModel();
	}
}

} // namespace harmony::gui
