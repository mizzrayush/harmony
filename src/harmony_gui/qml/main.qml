import QtQuick
import QtQuick.Controls
import Harmony

ApplicationWindow {
    id: root
    width: 1280
    height: 720
    visible: true
    title: qsTr("Project Harmony - LMMS next-gen frontend")

    // Global models accessed by subpanels
    TrackListModel {
        id: globalTrackListModel
    }

    MixerModel {
        id: globalMixerModel
    }

    // Modern Dark Theme Palette
    readonly property color colorBg: "#121214"
    readonly property color colorPanel: "#1a1a1e"
    readonly property color colorPanelLight: "#242429"
    readonly property color colorBorder: "#2d2d35"
    readonly property color colorAccent: "#7f39fb"
    readonly property color colorAccentHover: "#9b60ff"
    readonly property color colorText: "#f5f6fa"
    readonly property color colorTextMuted: "#a4b0be"

    background: Rectangle {
        color: root.colorBg
    }

    // Top Navigation Header
    header: Toolbar {
        id: mainToolbar
        height: 55
    }

    // Main workspace area with collapsible sidebar browser
    SplitView {
        id: mainSplitView
        anchors.fill: parent
        orientation: Qt.Horizontal

        // Left Panel: Sidebar Browser (collapsible)
        SidebarBrowser {
            id: sidebarBrowser
            SplitView.preferredWidth: 250
            SplitView.minimumWidth: 200
            SplitView.maximumWidth: 400
        }

        // Right Panel: Split Timeline and Editors
        SplitView {
            orientation: Qt.Vertical
            SplitView.fillWidth: true

            // Timeline / Arrangement Editor
            TimelineWorkspace {
                id: timelineWorkspace
                SplitView.preferredHeight: 350
                SplitView.minimumHeight: 150
                SplitView.fillHeight: true
            }

            // Bottom drawer: Piano Roll, Mixer, etc.
            BottomPanel {
                id: bottomPanel
                SplitView.preferredHeight: 250
                SplitView.minimumHeight: 150
            }
        }
    }
}
