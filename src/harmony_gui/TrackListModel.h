/*
 * TrackListModel.h - QML list model wrapping active song tracks
 */

#ifndef HARMONY_TRACK_LIST_MODEL_H
#define HARMONY_TRACK_LIST_MODEL_H

#include <QAbstractListModel>
#include "Song.h"
#include "Track.h"

namespace harmony::gui
{

class TrackListModel : public QAbstractListModel
{
	Q_OBJECT

public:
	enum TrackRoles {
		TrackIdRole = Qt::UserRole + 1,
		NameRole,
		TypeRole,
		IsMutedRole,
		IsSoloRole,
		ColorRole,
		ClipCountRole
	};

	explicit TrackListModel(QObject* parent = nullptr);
	virtual ~TrackListModel();

	// QAbstractItemModel interface
	int rowCount(const QModelIndex& parent = QModelIndex()) const override;
	QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
	bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole) override;
	QHash<int, QByteArray> roleNames() const override;

public slots:
	void addInstrumentTrack(const QString& pluginName);
	void deleteTrack(int index);
	void toggleMute(int index);
	void toggleSolo(int index);

private slots:
	void onTrackAdded(lmms::Track* track);
	void onTrackRemoved();
	void onTrackMoved();
	void refreshModel();

private:
	lmms::Song* getSong() const;
	void connectTrackSignals(lmms::Track* track);

	QList<lmms::Track*> m_tracks;
};

} // namespace harmony::gui

#endif // HARMONY_TRACK_LIST_MODEL_H
