import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import LeonardSouza 1.0

Window {
    visible: true
    width: 800
    height: 480
    title: qsTr("Retro LEDoodler")
    color: "#2a2d29"

    StackView {
        id: stackView
        initialItem: drawingInterface
        anchors.fill: parent

        Component {
            id: drawingInterface
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    Layout.fillHeight: true
                    ColorIndicator {
                        width: 75
                        height: 75
                        MouseArea {
                            anchors.fill: parent
                            onClicked: stackView.push(colorSelector)
                        }
                    }
                }

                LEDGrid {
                    id: ledGrid
                    Layout.fillHeight: true
                    Layout.minimumWidth: ledGrid.height
                }
            }

        }

        Component {
            id: colorSelector
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Item {
                        Layout.alignment: Qt.AlignTop
                        Layout.minimumWidth: 30
                        Layout.maximumWidth: 30
                        Layout.minimumHeight: 30
                        Layout.maximumHeight: 30
                        Image {
                            id: backButton
                            source: "images/back.svg"
                            antialiasing: true

                            MouseArea {
                                anchors.fill: parent
                                onClicked: stackView.pop()
                            }

                            anchors.fill: parent
                        }
                        ColorOverlay {
                            anchors.fill: parent
                            source: backButton
                            color: "#FF888888"
                        }
                    }
                    HSBSpectrum {
                        z: 1
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 5
                    }
                    AlphaGradient {
                        z: 0
                        Layout.minimumWidth: 50
                        Layout.fillHeight: true
                        Layout.leftMargin: 15
                    }
                    HueGradient {
                        z: 0
                        Layout.minimumWidth: 50
                        Layout.fillHeight: true
                        Layout.leftMargin: 15
                    }
                }
            }

        }
    }


}
