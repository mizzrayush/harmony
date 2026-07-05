/*
 * InstrumentControlModel.cpp - QML controller for active instrument shaping parameters
 */

#include "InstrumentControlModel.h"
#include <QDebug>

namespace harmony::gui
{

InstrumentControlModel::InstrumentControlModel(QObject* parent)
	: QObject(parent)
	, m_instrumentTrack(nullptr)
{
}

InstrumentControlModel::~InstrumentControlModel()
{
}

void InstrumentControlModel::setTrack(void* trackPtr)
{
	m_instrumentTrack = nullptr;
	if (trackPtr) {
		auto* track = static_cast<lmms::Track*>(trackPtr);
		auto* it = dynamic_cast<lmms::InstrumentTrack*>(track);
		if (it) {
			m_instrumentTrack = it;
		}
	}

	emit volumeAttackChanged();
	emit volumeDecayChanged();
	emit volumeSustainChanged();
	emit volumeReleaseChanged();
	emit filterCutoffChanged();
	emit filterResonanceChanged();
	emit filterEnabledChanged();
}

float InstrumentControlModel::volumeAttack() const
{
	if (!m_instrumentTrack || !m_instrumentTrack->soundShaping()) {
		return 0.0f;
	}
	return m_instrumentTrack->soundShaping()->getVolumeParameters().getAttackModel().value();
}

float InstrumentControlModel::volumeDecay() const
{
	if (!m_instrumentTrack || !m_instrumentTrack->soundShaping()) {
		return 0.0f;
	}
	return m_instrumentTrack->soundShaping()->getVolumeParameters().getDecayModel().value();
}

float InstrumentControlModel::volumeSustain() const
{
	if (!m_instrumentTrack || !m_instrumentTrack->soundShaping()) {
		return 0.0f;
	}
	return m_instrumentTrack->soundShaping()->getVolumeParameters().getSustainModel().value();
}

float InstrumentControlModel::volumeRelease() const
{
	if (!m_instrumentTrack || !m_instrumentTrack->soundShaping()) {
		return 0.0f;
	}
	return m_instrumentTrack->soundShaping()->getVolumeParameters().getReleaseModel().value();
}

float InstrumentControlModel::filterCutoff() const
{
	if (!m_instrumentTrack || !m_instrumentTrack->soundShaping()) {
		return 0.0f;
	}
	return m_instrumentTrack->soundShaping()->getFilterCutModel().value();
}

float InstrumentControlModel::filterResonance() const
{
	if (!m_instrumentTrack || !m_instrumentTrack->soundShaping()) {
		return 0.0f;
	}
	return m_instrumentTrack->soundShaping()->getFilterResModel().value();
}

bool InstrumentControlModel::filterEnabled() const
{
	if (!m_instrumentTrack || !m_instrumentTrack->soundShaping()) {
		return false;
	}
	return m_instrumentTrack->soundShaping()->getFilterEnabledModel().value();
}

void InstrumentControlModel::setVolumeAttack(float val)
{
	if (m_instrumentTrack && m_instrumentTrack->soundShaping()) {
		auto& params = m_instrumentTrack->soundShaping()->getVolumeParameters();
		const_cast<lmms::FloatModel&>(params.getAttackModel()).setValue(val);
		emit volumeAttackChanged();
	}
}

void InstrumentControlModel::setVolumeDecay(float val)
{
	if (m_instrumentTrack && m_instrumentTrack->soundShaping()) {
		auto& params = m_instrumentTrack->soundShaping()->getVolumeParameters();
		const_cast<lmms::FloatModel&>(params.getDecayModel()).setValue(val);
		emit volumeDecayChanged();
	}
}

void InstrumentControlModel::setVolumeSustain(float val)
{
	if (m_instrumentTrack && m_instrumentTrack->soundShaping()) {
		auto& params = m_instrumentTrack->soundShaping()->getVolumeParameters();
		const_cast<lmms::FloatModel&>(params.getSustainModel()).setValue(val);
		emit volumeSustainChanged();
	}
}

void InstrumentControlModel::setVolumeRelease(float val)
{
	if (m_instrumentTrack && m_instrumentTrack->soundShaping()) {
		auto& params = m_instrumentTrack->soundShaping()->getVolumeParameters();
		const_cast<lmms::FloatModel&>(params.getReleaseModel()).setValue(val);
		emit volumeReleaseChanged();
	}
}

void InstrumentControlModel::setFilterCutoff(float val)
{
	if (m_instrumentTrack && m_instrumentTrack->soundShaping()) {
		m_instrumentTrack->soundShaping()->getFilterCutModel().setValue(val);
		emit filterCutoffChanged();
	}
}

void InstrumentControlModel::setFilterResonance(float val)
{
	if (m_instrumentTrack && m_instrumentTrack->soundShaping()) {
		m_instrumentTrack->soundShaping()->getFilterResModel().setValue(val);
		emit filterResonanceChanged();
	}
}

void InstrumentControlModel::setFilterEnabled(bool val)
{
	if (m_instrumentTrack && m_instrumentTrack->soundShaping()) {
		m_instrumentTrack->soundShaping()->getFilterEnabledModel().setValue(val);
		emit filterEnabledChanged();
	}
}

} // namespace harmony::gui
