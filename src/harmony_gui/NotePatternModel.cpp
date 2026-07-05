/*
 * NotePatternModel.cpp - QML list model wrapping notes inside a MidiClip
 */

#include "NotePatternModel.h"
#include "InstrumentTrack.h"
#include "Volume.h"
#include <QDebug>

namespace harmony::gui
{

NotePatternModel::NotePatternModel(QObject* parent)
	: QAbstractListModel(parent)
	, m_midiClip(nullptr)
{
}

NotePatternModel::~NotePatternModel()
{
}

int NotePatternModel::rowCount(const QModelIndex& parent) const
{
	if (parent.isValid() || !m_midiClip) {
		return 0;
	}
	return static_cast<int>(m_midiClip->notes().size());
}

QVariant NotePatternModel::data(const QModelIndex& index, int role) const
{
	if (!index.isValid() || !m_midiClip) {
		return QVariant();
	}

	const auto& notes = m_midiClip->notes();
	int row = index.row();
	if (row < 0 || row >= static_cast<int>(notes.size())) {
		return QVariant();
	}

	lmms::Note* note = notes[row];
	if (!note) {
		return QVariant();
	}

	switch (role) {
		case NoteIndexRole:
			return row;
		case KeyRole:
			return note->key();
		case StartTickRole:
			return static_cast<int>(note->pos());
		case LengthTicksRole:
			return static_cast<int>(note->length());
		case VelocityRole:
			return static_cast<float>(note->getVolume()) / lmms::DefaultVolume;
		case NoteNameRole:
			return getNoteName(note->key());
		default:
			return QVariant();
	}
}

QHash<int, QByteArray> NotePatternModel::roleNames() const
{
	QHash<int, QByteArray> roles;
	roles[NoteIndexRole] = "noteIndex";
	roles[KeyRole] = "noteKey";
	roles[StartTickRole] = "startTick";
	roles[LengthTicksRole] = "lengthTicks";
	roles[VelocityRole] = "velocity";
	roles[NoteNameRole] = "noteName";
	return roles;
}

void NotePatternModel::setTrack(void* trackPtr)
{
	beginResetModel();
	m_midiClip = nullptr;

	if (trackPtr) {
		auto* track = static_cast<lmms::Track*>(trackPtr);
		auto* it = dynamic_cast<lmms::InstrumentTrack*>(track);
		if (it) {
			const auto& clips = it->getClips();
			if (clips.empty()) {
				// Automatically create first MIDI clip for the track
				auto* newClip = new lmms::MidiClip(it);
				it->addClip(newClip);
				m_midiClip = newClip;
			} else {
				m_midiClip = dynamic_cast<lmms::MidiClip*>(clips.front());
			}
		}
	}
	endResetModel();
}

void NotePatternModel::addNote(int key, int startTick, int lengthTicks, float velocity)
{
	if (!m_midiClip) {
		return;
	}

	beginInsertRows(QModelIndex(), rowCount(), rowCount());
	lmms::Note newNote(
		lmms::TimePos(lengthTicks),
		lmms::TimePos(startTick),
		key,
		static_cast<volume_t>(velocity * lmms::DefaultVolume)
	);
	m_midiClip->addNote(newNote);
	m_midiClip->rearrangeAllNotes();
	endInsertRows();

	refreshModel();
}

void NotePatternModel::removeNote(int noteIndex)
{
	if (!m_midiClip) {
		return;
	}

	const auto& notes = m_midiClip->notes();
	if (noteIndex >= 0 && noteIndex < static_cast<int>(notes.size())) {
		beginRemoveRows(QModelIndex(), noteIndex, noteIndex);
		m_midiClip->removeNote(notes[noteIndex]);
		m_midiClip->rearrangeAllNotes();
		endRemoveRows();

		refreshModel();
	}
}

void NotePatternModel::moveNote(int noteIndex, int newKey, int newStartTick)
{
	if (!m_midiClip) {
		return;
	}

	const auto& notes = m_midiClip->notes();
	if (noteIndex >= 0 && noteIndex < static_cast<int>(notes.size())) {
		lmms::Note* note = notes[noteIndex];
		note->setKey(newKey);
		note->setPos(lmms::TimePos(newStartTick));
		m_midiClip->rearrangeAllNotes();

		refreshModel();
	}
}

void NotePatternModel::resizeNote(int noteIndex, int newLengthTicks)
{
	if (!m_midiClip) {
		return;
	}

	const auto& notes = m_midiClip->notes();
	if (noteIndex >= 0 && noteIndex < static_cast<int>(notes.size())) {
		lmms::Note* note = notes[noteIndex];
		note->setLength(lmms::TimePos(newLengthTicks));
		m_midiClip->rearrangeAllNotes();

		refreshModel();
	}
}

void NotePatternModel::setNoteVelocity(int noteIndex, float velocity)
{
	if (!m_midiClip) {
		return;
	}

	const auto& notes = m_midiClip->notes();
	if (noteIndex >= 0 && noteIndex < static_cast<int>(notes.size())) {
		lmms::Note* note = notes[noteIndex];
		note->setVolume(static_cast<volume_t>(velocity * lmms::DefaultVolume));
		emit dataChanged(index(noteIndex), index(noteIndex), {VelocityRole});
	}
}

void NotePatternModel::refreshModel()
{
	beginResetModel();
	endResetModel();
}

QString NotePatternModel::getNoteName(int key) const
{
	static const char* const names[] = {
		"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
	};
	int octave = (key / 12) - 1;
	int noteInOctave = key % 12;
	return QString("%1%2").arg(names[noteInOctave]).arg(octave);
}

} // namespace harmony::gui
