/*
 * InstrumentControlModel.h - QML controller for active instrument shaping parameters
 */

#ifndef HARMONY_INSTRUMENT_CONTROL_MODEL_H
#define HARMONY_INSTRUMENT_CONTROL_MODEL_H

#include <QObject>
#include "InstrumentTrack.h"

namespace harmony::gui
{

class InstrumentControlModel : public QObject
{
	Q_OBJECT
	Q_PROPERTY(float volumeAttack READ volumeAttack WRITE setVolumeAttack NOTIFY volumeAttackChanged)
	Q_PROPERTY(float volumeDecay READ volumeDecay WRITE setVolumeDecay NOTIFY volumeDecayChanged)
	Q_PROPERTY(float volumeSustain READ volumeSustain WRITE setVolumeSustain NOTIFY volumeSustainChanged)
	Q_PROPERTY(float volumeRelease READ volumeRelease WRITE setVolumeRelease NOTIFY volumeReleaseChanged)

	Q_PROPERTY(float filterCutoff READ filterCutoff WRITE setFilterCutoff NOTIFY filterCutoffChanged)
	Q_PROPERTY(float filterResonance READ filterResonance WRITE setFilterResonance NOTIFY filterResonanceChanged)
	Q_PROPERTY(bool filterEnabled READ filterEnabled WRITE setFilterEnabled NOTIFY filterEnabledChanged)

public:
	explicit InstrumentControlModel(QObject* parent = nullptr);
	virtual ~InstrumentControlModel();

	Q_INVOKABLE void setTrack(void* trackPtr);

	// Getters
	float volumeAttack() const;
	float volumeDecay() const;
	float volumeSustain() const;
	float volumeRelease() const;

	float filterCutoff() const;
	float filterResonance() const;
	bool filterEnabled() const;

	// Setters
	void setVolumeAttack(float val);
	void setVolumeDecay(float val);
	void setVolumeSustain(float val);
	void setVolumeRelease(float val);

	void setFilterCutoff(float val);
	void setFilterResonance(float val);
	void setFilterEnabled(bool val);

signals:
	void volumeAttackChanged();
	void volumeDecayChanged();
	void volumeSustainChanged();
	void volumeReleaseChanged();

	void filterCutoffChanged();
	void filterResonanceChanged();
	void filterEnabledChanged();

private:
	lmms::InstrumentTrack* m_instrumentTrack;
};

} // namespace harmony::gui

#endif // HARMONY_INSTRUMENT_CONTROL_MODEL_H
