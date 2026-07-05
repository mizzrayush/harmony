/*
 * NotePatternModel.h - QML list model wrapping notes inside a MidiClip
 */

#ifndef HARMONY_NOTE_PATTERN_MODEL_H
#define HARMONY_NOTE_PATTERN_MODEL_H

#include <QAbstractListModel>
#include "MidiClip.h"
#include "Note.h"

namespace harmony::gui
{

class NotePatternModel : public QAbstractListModel
{
	Q_OBJECT

public:
	enum NoteRoles {
		NoteIndexRole = Qt::UserRole + 1,
		KeyRole,
		StartTickRole,
		LengthTicksRole,
		VelocityRole,
		NoteNameRole
	};

	explicit NotePatternModel(QObject* parent = nullptr);
	virtual ~NotePatternModel();

	// QAbstractItemModel interface
	int rowCount(const QModelIndex& parent = QModelIndex()) const override;
	QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
	QHash<int, QByteArray> roleNames() const override;

	Q_INVOKABLE void setTrack(void* trackPtr);
	Q_INVOKABLE void addNote(int key, int startTick, int lengthTicks, float velocity);
	Q_INVOKABLE void removeNote(int noteIndex);
	Q_INVOKABLE void moveNote(int noteIndex, int newKey, int newStartTick);
	Q_INVOKABLE void resizeNote(int noteIndex, int newLengthTicks);
	Q_INVOKABLE void setNoteVelocity(int noteIndex, float velocity);

private:
	void refreshModel();
	QString getNoteName(int key) const;

	lmms::MidiClip* m_midiClip;
};

} // namespace harmony::gui

#endif // HARMONY_NOTE_PATTERN_MODEL_H
