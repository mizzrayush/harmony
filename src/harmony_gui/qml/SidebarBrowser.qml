import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: browserRoot
    color: root.colorPanel
    
    // Right border separator
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: root.colorBorder
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        anchors.margins: 12

        // Search Bar Container
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: root.colorPanelLight
            border.color: root.colorBorder
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Text {
                    text: "🔍"
                    color: root.colorTextMuted
                    font.pixelSize: 12
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Search library...")
                    placeholderTextColor: root.colorTextMuted
                    color: root.colorText
                    font.pixelSize: 12
                    background: null
                    verticalAlignment: TextInput.AlignVCenter
                }
            }
        }

        // Category Selectors
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            
            property int activeTab: 0

            Repeater {
                model: ["Plugins", "Samples", "Projects"]
                delegate: Button {
                    id: tabBtn
                    Layout.fillWidth: true
                    implicitHeight: 26
                    
                    background: Rectangle {
                        color: parent.parent.activeTab === index ? root.colorAccent : "transparent"
                        radius: 4
                        border.color: parent.parent.activeTab === index ? "transparent" : root.colorBorder
                        border.width: 1
                    }

                    contentItem: Text {
                        text: modelData
                        color: parent.parent.activeTab === index ? root.colorText : root.colorTextMuted
                        font.pixelSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: parent.activeTab = index
                }
            }
        }

        // Browser Library List
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: libraryList
                anchors.fill: parent
                spacing: 2
                
                // Dynamic Model selection based on category tabs
                model: {
                    if (searchField.text !== "") {
                        return filteredModel;
                    }
                    if (browserRoot.children[0].children[1].activeTab === 0) return pluginModel;
                    if (browserRoot.children[0].children[1].activeTab === 1) return sampleModel;
                    return projectModel;
                }

                delegate: ItemDelegate {
                    id: itemDelegate
                    width: libraryList.width
                    height: 36
                    
                    background: Rectangle {
                        color: itemDelegate.hovered ? root.colorPanelLight : "transparent"
                        radius: 4
                    }

                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 10

                        Text {
                            text: model.icon
                            font.pixelSize: 14
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                text: model.name
                                color: root.colorText
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: model.desc
                                color: root.colorTextMuted
                                font.pixelSize: 9
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }

    // Static Mock Models
    ListModel {
        id: pluginModel
        ListElement { name: "TripleOscillator"; desc: "3-Oscillator Subtractive Synth"; icon: "🎹" }
        ListElement { name: "ZynAddSubFX"; desc: "Advanced Additive/Subtractive Synth"; icon: "🌀" }
        ListElement { name: "VeSTige"; desc: "VSTi Host Plugin"; icon: "🎛️" }
        ListElement { name: "Kicker"; desc: "Kick Drum Synthesizer"; icon: "🥁" }
        ListElement { name: "BitInvader"; desc: "Wavetable Synthesizer"; icon: "⚡" }
        ListElement { name: "Monstr"; desc: "3-Oscillator Stereo Synth"; icon: "👾" }
    }

    ListModel {
        id: sampleModel
        ListElement { name: "Kick_Deep.wav"; desc: "Drum One-Shot (124 KB)"; icon: "🔊" }
        ListElement { name: "Snare_Tight.wav"; desc: "Drum One-Shot (98 KB)"; icon: "🔊" }
        ListElement { name: "Hihat_Closed.wav"; desc: "Drum One-Shot (45 KB)"; icon: "🔊" }
        ListElement { name: "Synth_Arp_120.wav"; desc: "Melodic Loop (1.2 MB)"; icon: "🎵" }
        ListElement { name: "Vocal_Chop.wav"; desc: "Vocal Slice (320 KB)"; icon: "🎤" }
        ListElement { name: "Bass_Growl.wav"; desc: "Wavetable Bass (480 KB)"; icon: "🎸" }
    }

    ListModel {
        id: projectModel
        ListElement { name: "Midnight_Session.mmpz"; desc: "Saved 2 hrs ago"; icon: "💾" }
        ListElement { name: "Lofi_Vibes_Demo.mmpz"; desc: "Saved 3 days ago"; icon: "💾" }
        ListElement { name: "Heavy_Dubstep_Drop.mmp"; desc: "Saved 1 week ago"; icon: "💾" }
    }

    // Mock search filtering logic
    ListModel {
        id: filteredModel
        ListElement { name: "TripleOscillator"; desc: "Subtractive Synth Match"; icon: "🎹" }
        ListElement { name: "Kick_Deep.wav"; desc: "Drum One-Shot Match"; icon: "🔊" }
    }
}
