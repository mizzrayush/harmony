/*
 * MixerModel.h - QML list model wrapping effect mixer channels
 */

#ifndef HARMONY_MIXER_MODEL_H
#define HARMONY_MIXER_MODEL_H

#include <QAbstractListModel>
#include <QTimer>
#include "Mixer.h"

namespace harmony::gui
{

class MixerModel : public QAbstractListModel
{
	Q_OBJECT

public:
	enum MixerRoles {
		ChannelIndexRole = Qt::UserRole + 1,
		NameRole,
		VolumeRole,
		IsMutedRole,
		IsSoloRole,
		PeakLeftRole,
		PeakRightRole,
		ColorRole
	};

	explicit MixerModel(QObject* parent = nullptr);
	virtual ~MixerModel();

	// QAbstractItemModel interface
	int rowCount(const QModelIndex& parent = QModelIndex()) const override;
	QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
	bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole) override;
	QHash<int, QByteArray> roleNames() const override;

public slots:
	void addChannel();
	void removeChannel(int index);
	void toggleMute(int index);
	void toggleSolo(int index);

private slots:
	void updatePeaks();
	void refreshModel();

private:
	lmms::Mixer* getMixer() const;

	QTimer* m_peakTimer;
	int m_channelCount;
};

} // namespace harmony::gui

#endif // HARMONY_MIXER_MODEL_H
