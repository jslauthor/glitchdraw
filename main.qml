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
    // a number to process
    property real time: 0
    // An easing interpolated percentage to drive glitchiness
    property real countdownProgress: 0
    property real shakeMax: 0

    function getRndInteger(min, max) {
      return Math.floor(Math.random() * (max - min) ) + min;
    }

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
            countdownProgress = Math.round(AppState.getCountProgress() * 1000) / 1000;
            shakeMax = countdownProgress * 40;
        }
    }

    Timer {
        interval: 24
        running: true
        repeat: true
        onTriggered: {
            // No need to let the count run on and on
            time = time >= 500 ? 0 : time + 1;
        }
    }

    SettingsPopup {
        id: settingsPopup
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        onTimeChanged: {
            AppState.setCountdownTotal(seconds)
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
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: flickableContent.height
                    flickableDirection: Flickable.VerticalFlick
                    ColumnLayout {
                        id: flickableContent
                        Layout.fillWidth: true
                        spacing: -10
                        ColumnLayout {
                            Layout.minimumWidth: 300
                            Layout.fillWidth: true
                            Layout.margins: 10
                            spacing: 5
                            RowLayout {
                                Layout.fillWidth: true
                                Item {
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.minimumWidth: 40
                                    Layout.minimumHeight: 40
                                    Image {
                                        Layout.alignment: Qt.AlignVCenter
                                        id: webflowLogo
                                        source: "images/webflow.svg"
                                        antialiasing: true
                                        fillMode: Image.PreserveAspectFit
                                        width: 40
                                        anchors.centerIn: parent
                                    }
                                    ColorOverlay {
                                        anchors.centerIn: parent
                                        source: webflowLogo
                                        color: "white"
                                        width: webflowLogo.width
                                        height: webflowLogo.height
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "glitch draw"
                                    font.family: Theme.mainFont.name
                                    font.pixelSize: Theme.h1
                                    Layout.leftMargin: 20
                                    color: "white"
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: 200
                                ColumnLayout {
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignTop
                                    Header {
                                        text: "brushes"
                                    }
                                    RowLayout {
                                        BrushSelector {
                                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                            onItemClicked: AppState.setBrushType(brush);
                                        }
                                    }
                                }


                                ColumnLayout {
                                    Layout.minimumWidth: 75
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignTop
                                    Layout.leftMargin: 10
                                    Header {
                                        text: "erase: " + String(AppState.drawMode === 0 ? "off" : "on")
                                    }
                                    GlitchButton {
                                        Layout.minimumWidth: 65
                                        Layout.minimumHeight: 65
                                        Layout.alignment: Qt.AlignCenter
                                        imageSource: "images/eraser.svg"
                                        backgroundColor: Theme.darkBlue
                                        toggleEnabled: true
                                        toggled: AppState.drawMode === 1
                                        flashBackground: true
                                        onClicked: AppState.drawMode === 0 ? AppState.setDrawMode(1) : AppState.setDrawMode(0)
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignTop
                                    Layout.leftMargin: 10
                                    Header {
                                        text: "settings"
                                    }
                                    Item {
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        Layout.minimumWidth: 60
                                        Layout.minimumHeight: 60
                                        Rectangle {
                                            color: "transparent"
                                            anchors.fill: parent
                                        }

                                        Image {
                                            Layout.alignment: Qt.AlignVCenter
                                            id: settingsButton
                                            source: "images/settings.svg"
                                            antialiasing: true
                                            width: 60
                                            height: 60
                                            anchors.centerIn: parent
                                        }
                                        ColorOverlay {
                                            anchors.centerIn: parent
                                            source: settingsButton
                                            color: Theme.alertRed
                                            width: settingsButton.width
                                            height: settingsButton.height
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked:  settingsPopup.open()
                                        }
                                    }
                                }
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
                            spacing: -8
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
                                RowLayout {
                                    id: countdownText
                                    Layout.topMargin: 10
                                    spacing: -5
                                    transform: Translate {
                                        x: countdownProgress * getRndInteger(-shakeMax, shakeMax)
                                        y: countdownProgress * getRndInteger(-shakeMax, shakeMax)
                                    }

                                    Text {
                                        font.family: Theme.mainFont.name
                                        font.pixelSize: 40
                                        color: Theme.superBlue
                                        text: AppState.countdownLabel
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignBottom
                                        font.family: Theme.mainFont.name
                                        font.pixelSize: 12
                                        color: Theme.superBlue
                                        text: AppState.countdownMsLabel
                                        Layout.bottomMargin: 8
                                    }
                                    layer.enabled: true
                                }
                            }
                        }

                        RowLayout {
                            GlitchButton {
                                Layout.margins: 5
                                Layout.bottomMargin: 10
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignCenter
                                backgroundColor: Theme.alertRed
                                onClicked: AppState.clearCanvas()
                                label: "CLEAR"
                            }

                            Item {
                                id: zoomContainer
                                property real targetWidth: 130
                                Layout.topMargin: 5
                                Layout.rightMargin: 5
                                Layout.bottomMargin: 10
                                Layout.fillHeight: true
                                Layout.minimumWidth: targetWidth
                                Layout.alignment: Qt.AlignTop
                                property bool stateVisible: AppState.miniDisplayValue.scale > 1

                                states: [
                                    State { when: zoomContainer.stateVisible;
                                        PropertyChanges {
                                            target: zoomContainer;
                                            opacity: 1.0
                                        }
                                        PropertyChanges {
                                            target: zoomContainer;
                                            Layout.minimumWidth: targetWidth
                                        }
                                    },
                                    State { when: !zoomContainer.stateVisible;
                                        PropertyChanges {
                                            target: zoomContainer;
                                            opacity: 0.0
                                        }
                                        PropertyChanges {
                                            target: zoomContainer;
                                            Layout.minimumWidth: 0
                                        }
                                    }
                                ]
                                transitions: [ Transition {
                                    ParallelAnimation {
                                        NumberAnimation { property: "opacity"; duration: 250 }
                                        NumberAnimation { property: "Layout.minimumWidth"; easing.type: Easing.InOutBack; duration: 250 }
                                    }
                                }]

                                ZoomButton {
                                    anchors.fill: parent
                                    backgroundColor: Theme.alertRed
                                    onClicked: AppState.resetZoom();
                                }
                            }
                        }
                    }
                }



                Item {
                    Layout.fillHeight: true
                    Layout.minimumWidth: ledGrid.height
                    Layout.alignment: Qt.AlignRight
                    clip: true

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

                    Text {
                        visible: countdownProgress >= .01
                        text: "Draw on me before time runs out!"
                        anchors.centerIn: parent
                        font.family: Theme.mainFont.name
                        font.pixelSize: Theme.h5
                        color: "#FFFFFF"
                        SequentialAnimation on opacity {
                            running: true
                            loops: Animation.Infinite
                            NumberAnimation { to: 1; easing.type: Easing.InOutCubic; duration: 400; }
                            NumberAnimation { to: 0; easing.type: Easing.InOutCubic; duration: 400; }
                            NumberAnimation { to: 1; easing.type: Easing.InOutCubic; duration: 400; }
                        }
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
                            width: (AppState.brush.size * 7.5) * AppState.miniDisplayValue.scale
                            height: (AppState.brush.size * 7.5) * AppState.miniDisplayValue.scale
                            visible: AppState.brush.type === 0
                        }
                        SquareBrush {
                            anchors.centerIn: parent
                            width: (AppState.brush.size * 7.5) * AppState.miniDisplayValue.scale
                            height: (AppState.brush.size * 7.5) * AppState.miniDisplayValue.scale
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
                    anchors.margins: 20
                    Item {
                        Layout.minimumWidth: 40
                        Layout.fillHeight: true
                        Rectangle {
                            color: "transparent"
                            anchors.fill: parent
                        }

                        Image {
                            Layout.alignment: Qt.AlignVCenter
                            id: backButton
                            source: "images/back.svg"
                            antialiasing: true
                            width: 40
                            height: 40
                            anchors.centerIn: parent
                        }
                        ColorOverlay {
                            anchors.centerIn: parent
                            source: backButton
                            color: "white"
                            width: backButton.width
                            height: backButton.height
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: stackView.pop()
                        }
                    }

                    Item {
                        z: 1
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 5
                        HSBSpectrum {
                            enabled: AppState.drawMode === 0
                            anchors.fill: parent
                        }

                        Rectangle {
                            visible: AppState.drawMode === 1
                            color: "black"
                            opacity: .4
                            anchors.fill: parent
                            MouseArea {
                                anchors.fill: parent
                                onClicked: AppState.setDrawMode(0)
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: AppState.drawMode === 1
                            spacing: 15
                            Image {
                                Layout.alignment: Qt.AlignCenter
                                source: "images/eraser.svg"
                                antialiasing: true
                                fillMode: Image.PreserveAspectFit
                                width: 40
                                opacity: .75
                            }
                            Header {
                                Layout.alignment: Qt.AlignCenter
                                label: "Tap to turn erase mode off."
                            }
                        }


                    }

                    AlphaGradient {
                        z: 0
                        Layout.minimumWidth: 75
                        Layout.fillHeight: true
                        Layout.leftMargin: 15
                    }

                    Item {
                        z: 0
                        Layout.minimumWidth: 75
                        Layout.fillHeight: true
                        Layout.leftMargin: 15
                        HueGradient {
                            enabled: AppState.drawMode === 0
                            anchors.fill: parent
                        }

                        Rectangle {
                            visible: AppState.drawMode === 1
                            color: "black"
                            opacity: .4
                            anchors.fill: parent
                            MouseArea {
                                anchors.fill: parent
                                onClicked: AppState.setDrawMode(0)
                            }
                        }

                        Image {
                            visible: AppState.drawMode === 1
                            source: "images/eraser.svg"
                            antialiasing: true
                            fillMode: Image.PreserveAspectFit
                            width: 40
                            anchors.centerIn: parent
                            opacity: .75
                        }
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
