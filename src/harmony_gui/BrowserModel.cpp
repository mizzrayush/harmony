/*
 * BrowserModel.cpp - QML list model for Sidebar Browser (Plugins, Samples, Projects)
 */

#include "BrowserModel.h"
#include "PluginFactory.h"
#include "ConfigManager.h"
#include <QDirIterator>
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <algorithm>

namespace harmony::gui
{

BrowserModel::BrowserModel(QObject* parent)
	: QAbstractListModel(parent)
	, m_category(0)
{
	refreshData();
}

BrowserModel::~BrowserModel()
{
}

int BrowserModel::rowCount(const QModelIndex& parent) const
{
	if (parent.isValid()) {
		return 0;
	}
	return m_filteredItems.size();
}

QVariant BrowserModel::data(const QModelIndex& index, int role) const
{
	if (!index.isValid() || index.row() >= m_filteredItems.size()) {
		return QVariant();
	}

	const auto& item = m_filteredItems[index.row()];
	switch (role) {
		case NameRole:
			return item.name;
		case DescRole:
			return item.desc;
		case IconRole:
			return item.icon;
		case TypeRole:
			return item.type;
		case PathRole:
			return item.path;
		default:
			return QVariant();
	}
}

QHash<int, QByteArray> BrowserModel::roleNames() const
{
	QHash<int, QByteArray> roles;
	roles[NameRole] = "name";
	roles[DescRole] = "desc";
	roles[IconRole] = "icon";
	roles[TypeRole] = "type";
	roles[PathRole] = "path";
	return roles;
}

void BrowserModel::setFilter(const QString& val)
{
	if (m_filter != val) {
		m_filter = val;
		emit filterChanged();

		// Apply filter to m_allItems
		beginResetModel();
		m_filteredItems.clear();
		for (const auto& item : m_allItems) {
			if (m_filter.isEmpty() || item.name.contains(m_filter, Qt::CaseInsensitive) || item.desc.contains(m_filter, Qt::CaseInsensitive)) {
				m_filteredItems.append(item);
			}
		}
		endResetModel();
	}
}

void BrowserModel::setCategory(int val)
{
	if (m_category != val) {
		m_category = val;
		emit categoryChanged();
		refreshData();
	}
}

void BrowserModel::refreshData()
{
	beginResetModel();
	m_allItems.clear();
	m_filteredItems.clear();

	if (m_category == 0) {
		loadPlugins();
	} else if (m_category == 1) {
		loadSamples();
	} else if (m_category == 2) {
		loadProjects();
	}

	// Apply filter initially
	for (const auto& item : m_allItems) {
		if (m_filter.isEmpty() || item.name.contains(m_filter, Qt::CaseInsensitive) || item.desc.contains(m_filter, Qt::CaseInsensitive)) {
			m_filteredItems.append(item);
		}
	}
	endResetModel();
}

void BrowserModel::loadPlugins()
{
	lmms::PluginFactory* factory = lmms::getPluginFactory();
	if (!factory) {
		return;
	}

	auto descs = factory->descriptors(lmms::Plugin::Type::Instrument);
	std::sort(descs.begin(), descs.end(), [](auto d1, auto d2) {
		return qstricmp(d1->displayName, d2->displayName) < 0;
	});

	for (const auto desc : descs) {
		if (desc->subPluginFeatures) {
			lmms::Plugin::Descriptor::SubPluginFeatures::KeyList subPluginKeys;
			desc->subPluginFeatures->listSubPluginKeys(desc, subPluginKeys);
			std::sort(subPluginKeys.begin(), subPluginKeys.end(), [](const auto& l, const auto& r) {
				return QString::compare(l.displayName(), r.displayName(), Qt::CaseInsensitive) < 0;
			});

			for (const auto& key : subPluginKeys) {
				BrowserItem item;
				item.name = key.displayName();
				item.desc = key.desc->subPluginFeatures ? key.description() : tr(key.desc->description);
				item.icon = "🎹";
				item.type = "plugin";
				item.path = QString::fromUtf8(key.desc->name);
				m_allItems.append(item);
			}
		} else {
			BrowserItem item;
			item.name = desc->displayName;
			item.desc = tr(desc->description);
			item.icon = "🎹";
			item.type = "plugin";
			item.path = QString::fromUtf8(desc->name);
			m_allItems.append(item);
		}
	}
}

void BrowserModel::loadSamples()
{
	lmms::ConfigManager* cfg = lmms::ConfigManager::inst();
	QStringList dirs = { cfg->factorySamplesDir(), cfg->userSamplesDir() };
	QStringList nameFilters = { "*.wav", "*.ogg", "*.mp3", "*.flac" };

	for (const auto& dirPath : dirs) {
		if (dirPath.isEmpty() || !QDir(dirPath).exists()) {
			continue;
		}

		QDirIterator it(dirPath, nameFilters, QDir::Files, QDirIterator::Subdirectories);
		while (it.hasNext()) {
			it.next();
			QFileInfo info = it.fileInfo();
			BrowserItem item;
			item.name = info.fileName();
			item.desc = QString("%1 (%2 KB)").arg(info.absoluteFilePath()).arg(info.size() / 1024);
			item.icon = "🔊";
			item.type = "sample";
			item.path = info.absoluteFilePath();
			m_allItems.append(item);
		}
	}
}

void BrowserModel::loadProjects()
{
	lmms::ConfigManager* cfg = lmms::ConfigManager::inst();
	QStringList dirs = { cfg->factoryProjectsDir(), cfg->userProjectsDir() };
	QStringList nameFilters = { "*.mmp", "*.mmpz" };

	for (const auto& dirPath : dirs) {
		if (dirPath.isEmpty() || !QDir(dirPath).exists()) {
			continue;
		}

		QDirIterator it(dirPath, nameFilters, QDir::Files, QDirIterator::Subdirectories);
		while (it.hasNext()) {
			it.next();
			QFileInfo info = it.fileInfo();
			BrowserItem item;
			item.name = info.fileName();
			item.desc = info.absoluteFilePath();
			item.icon = "💾";
			item.type = "project";
			item.path = info.absoluteFilePath();
			m_allItems.append(item);
		}
	}
}

} // namespace harmony::gui
