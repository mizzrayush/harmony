/*
 * BrowserModel.h - QML list model for Sidebar Browser (Plugins, Samples, Projects)
 */

#ifndef HARMONY_BROWSER_MODEL_H
#define HARMONY_BROWSER_MODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QString>

namespace harmony::gui
{

class BrowserModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
	Q_PROPERTY(int category READ category WRITE setCategory NOTIFY categoryChanged)

public:
	enum BrowserRoles {
		NameRole = Qt::UserRole + 1,
		DescRole,
		IconRole,
		TypeRole,
		PathRole
	};

	struct BrowserItem {
		QString name;
		QString desc;
		QString icon;
		QString type; // "plugin", "sample", "project"
		QString path; // file path or plugin internal name
	};

	explicit BrowserModel(QObject* parent = nullptr);
	virtual ~BrowserModel();

	// QAbstractItemModel interface
	int rowCount(const QModelIndex& parent = QModelIndex()) const override;
	QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
	QHash<int, QByteArray> roleNames() const override;

	QString filter() const { return m_filter; }
	void setFilter(const QString& val);

	int category() const { return m_category; }
	void setCategory(int val);

signals:
	void filterChanged();
	void categoryChanged();

private:
	void refreshData();
	void loadPlugins();
	void loadSamples();
	void loadProjects();

	QList<BrowserItem> m_allItems;
	QList<BrowserItem> m_filteredItems;
	QString m_filter;
	int m_category; // 0: Plugins, 1: Samples, 2: Projects
};

} // namespace harmony::gui

#endif // HARMONY_BROWSER_MODEL_H
