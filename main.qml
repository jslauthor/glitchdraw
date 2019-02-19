import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import LeonardSouza 1.0
import Theme 1.0

Window {
    visible: true
    width: 800
    height: 480
    title: qsTr("Retro LEDoodler")

    Image {
        anchors.fill: parent
        source: "images/app_bg.jpg"
        antialiasing: true
    }

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
                    BrushSelector {
                        Layout.margins: 10
                        onItemClicked: AppState.setBrushType(brush);
                    }
                    ConfigSlider {
                        id: brushSizeConfig
                        Layout.margins: 10
                        Layout.fillWidth: true
                        value: AppState.brush.size
                        from: 1
                        to: 64
                        stepSize: 1
                        header: "size"
                        label: AppState.brush.size + " pts"
                        onChanged: AppState.setBrushSize(value)

                        Binding { target: brushSizeConfig; property: "value"; value: AppState.brush.size }
                        Binding { target: AppState; property: "brush.size"; value: brushSizeConfig.value }
                    }
                    ConfigSlider {
                        id: brushHardnessConfig
                        Layout.margins: 10
                        Layout.fillWidth: true
                        value: AppState.brush.hardness
                        from: 0
                        to: 1
                        header: "hardness"
                        label: Math.round(AppState.brush.hardness * 100) + "%"
                        onChanged: AppState.setBrushHardness(value)

                        Binding { target: brushHardnessConfig; property: "value"; value: AppState.brush.hardness }
                        Binding { target: AppState; property: "brush.hardness"; value: brushHardnessConfig.value }
                    }
                    ColorIndicator {
                        Layout.margins: 10
                        MouseArea {
                            width:  parent.width
                            height: parent.height
                            onClicked: stackView.push(colorSelector)
                        }
                    }
                    GlitchButton {
                        backgroundColor: Theme.alertRed
                        onClicked: AppState.clearCanvas()
                        label: "CLEAR ALL"
                        Layout.alignment: Qt.AlignCenter
                    }
                }

                LEDGrid {
                    id: ledGrid
                    Layout.fillHeight: true
                    Layout.minimumWidth: ledGrid.height
                    Layout.alignment: Qt.AlignRight
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
