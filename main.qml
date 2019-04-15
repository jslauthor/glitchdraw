import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import LeonardSouza 1.0
import Theme 1.0

Window {
    id: rootWindow
    visible: true
    width: 800
    height: 480
    title: qsTr("Glitch Paint")

    // Holds a time factor (count) so that sin() has
    // a number process
    property real time: 0
    // An easing interpolated percentage to drive glitchiness
    property real countdownProgress: 0

    Image {
        anchors.fill: parent
        source: "images/app_bg.jpg"
        antialiasing: true
    }

    Connections {
        target: AppState
        onGlitchImminent: {
            // This will only work with one nested screen
            // Not the best idea for a full on production app :P
            if (stackView.depth !== 1) {
                stackView.pop();
            }
        }
        onCountdownChanged: {
            countdownProgress = Math.round(AppState.getCountProgress() * 100) / 100;
        }
    }

    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            // No need to let the count run on and on
            time = time >= 500 ? 0 : time + 1;
        }
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
                    Layout.alignment: Qt.AlignBottom
                    spacing: -10
                    ColumnLayout {
                        Layout.margins: 10
                        spacing: 5
                        Header {
                            text: "brushes"
                        }
                        BrushSelector {
                            onItemClicked: AppState.setBrushType(brush);
                        }
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
                    RowLayout {
                        Layout.margins: 10
                        Layout.maximumWidth: 80
                        spacing: 0
                        ColorIndicator {
                            Layout.alignment: Qt.AlignLeft
                            Layout.maximumWidth: 95
                            MouseArea {
                                width:  parent.width
                                height: parent.height
                                onClicked: stackView.push(colorSelector)
                            }
                        }
                        ColumnLayout {
                            id: countdownContainer
                            Layout.alignment: Qt.AlignTop
                            Header {
                                label: "glitch countdown"
                            }
                            Text {
                                Layout.topMargin: 10
                                font.family: Theme.mainFont.name
                                font.pixelSize: 40
                                color: Theme.superBlue
                                text: AppState.countdownLabel
                            }
                        }
                    }


                    GlitchButton {
                        Layout.topMargin: 5
                        Layout.alignment: Qt.AlignCenter
                        backgroundColor: Theme.alertRed
                        onClicked: AppState.clearCanvas()
                        label: "CLEAR ALL"
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.minimumWidth: ledGrid.height
                    Layout.alignment: Qt.AlignRight

                    Connections {
                        target: AppState
                        onBrushChanged: {
                            brushContainer.state = "SHOWN"
                            brushTimer.restart()
                        }
                    }

                    Timer {
                        id: brushTimer
                        repeat: false
                        interval: 500
                        onTriggered: brushContainer.state = "HIDDEN"
                    }

                    LEDGrid {
                        id: ledGrid
                        anchors.fill: parent
                    }
                    Item {
                        id: brushContainer
                        anchors.centerIn: parent
                        opacity: 0
                        state: "HIDDEN"
                        transitions: [
                            Transition {
                                from: "HIDDEN"
                                to: "SHOWN"
                                NumberAnimation {
                                    target: brushContainer
                                    property: "opacity"
                                    duration: 250
                                    easing.type: Easing.InCurve
                                    from: 0
                                    to: .9
                                }
                            },
                            Transition {
                                from: "SHOWN"
                                to: "HIDDEN"
                                NumberAnimation {
                                    target: brushContainer
                                    property: "opacity"
                                    duration: 250
                                    easing.type: Easing.OutCurve
                                    from: .9
                                    to: 0
                                }
                            }
                        ]
                        RadialBrush {
                            anchors.centerIn: parent
                            width: AppState.brush.size * 7.5
                            height: AppState.brush.size * 7.5
                            visible: AppState.brush.type === 0
                        }
                        SquareBrush {
                            anchors.centerIn: parent
                            width: AppState.brush.size * 7.5
                            height: AppState.brush.size * 7.5
                            visible: AppState.brush.type === 1
                        }
                    }


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
                        Layout.alignment: Qt.AlignVCenter
                        Layout.minimumWidth: 30
                        Layout.maximumWidth: 30
                        Layout.minimumHeight: 30
                        Layout.maximumHeight: 30
                        Image {
                            id: backButton
                            source: "images/back.svg"
                            antialiasing: true
                            anchors.fill: parent
                        }
                        ColorOverlay {
                            anchors.fill: parent
                            source: backButton
                            color: "white"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: stackView.pop()
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

        layer.enabled: true
        layer.effect: ShaderEffect {
            property real strength: 2 + (countdownProgress * 7)
            property real turbulence: countdownProgress * 8
            property real time: rootWindow.time
            blending: true
            fragmentShader: "qrc:/shaders/chromatic_abberation.frag"
        }
    }

}
