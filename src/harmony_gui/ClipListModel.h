/*
 * ClipListModel.h - QML list model wrapping track clips
 */

#ifndef HARMONY_CLIP_LIST_MODEL_H
#define HARMONY_CLIP_LIST_MODEL_H

#include <QAbstractListModel>
#include "Track.h"
#include "Clip.h"

namespace harmony::gui
{

class ClipListModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(void* trackId READ trackId WRITE setTrackId NOTIFY trackIdChanged)

public:
	enum ClipRoles {
		ClipIndexRole = Qt::UserRole + 1,
		ClipNameRole,
		StartTickRole,
		LengthTicksRole,
		ClipColorRole,
		ClipPtrRole
	};

	explicit ClipListModel(QObject* parent = nullptr);
	virtual ~ClipListModel();

	void* trackId() const { return m_track; }
	void setTrackId(void* id);

	// QAbstractItemModel interface
	int rowCount(const QModelIndex& parent = QModelIndex()) const override;
	QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
	QHash<int, QByteArray> roleNames() const override;

	// QML interactions
	Q_INVOKABLE void addClip(int startTick);
	Q_INVOKABLE void deleteClip(int clipIndex);
	Q_INVOKABLE void moveClip(int clipIndex, int newStartTick);
	Q_INVOKABLE void resizeClip(int clipIndex, int newLengthTicks);

signals:
	void trackIdChanged();

private slots:
	void refreshModel();
	void onTrackDestroyed();

private:
	void connectClipSignals(lmms::Clip* clip);

	lmms::Track* m_track;
	std::vector<lmms::Clip*> m_clips;
};

} // namespace harmony::gui

#endif // HARMONY_CLIP_LIST_MODEL_H
