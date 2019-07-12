import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.11
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

    Connections {
        target: AppState
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

    // This Item creates the CRT effect
    Item {
      anchors.fill: parent
      enabled: !AppState.isGlitching
      Image {
          anchors.fill: parent
          source: "images/app_bg.jpg"
          antialiasing: true
      }

      RowLayout {
          anchors.fill: parent
          ColumnLayout {
              id: flickableContent
              Layout.fillWidth: true
              Layout.fillHeight: true
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
                  Layout.fillWidth: true
                  Layout.maximumWidth: 300
                  Item {
                      id: brushSizePreviewContainer
                      property bool stateVisible: false
                      Layout.fillHeight: true
                      Layout.minimumWidth: 300
                      Layout.rightMargin: 0
                      states: [
                          State { when: brushSizePreviewContainer.stateVisible;
                              PropertyChanges {
                                  target: brushSizePreviewContainer;
                                  opacity: 1.0
                              }
                              PropertyChanges {
                                  target: brushSizePreviewContainer;
                                  Layout.minimumWidth: 300
                              }
                              PropertyChanges {
                                  target: brushSizePreviewContainer;
                                  Layout.rightMargin: 20
                              }
                          },
                          State { when: !brushSizePreviewContainer.stateVisible;
                              PropertyChanges {
                                  target: brushSizePreviewContainer;
                                  opacity: 0.0
                              }
                              PropertyChanges {
                                  target: brushSizePreviewContainer;
                                  Layout.minimumWidth: 0
                              }
                              PropertyChanges {
                                  target: brushSizePreviewContainer;
                                  Layout.rightMargin: 0
                              }
                          }
                      ]
                      transitions: [ Transition {
                          ParallelAnimation {
                              NumberAnimation { property: "opacity"; duration: 250 }
                              NumberAnimation { property: "Layout.minimumWidth"; easing.type: Easing.InOutBack; duration: 250 }
                              NumberAnimation { property: "Layout.rightMargin"; easing.type: Easing.InOutBack; duration: 250 }
                          }
                      }]

                      Item {
                          id: brushSizePreview
                          width: 200
                          height: 100
                          anchors.centerIn: parent
                          Connections {
                              target: AppState
                              onBrushChanged: {
                                  brushSizePreviewContainer.stateVisible = true
                                  brushTimer.restart()
                              }
                          }

                          Timer {
                              id: brushTimer
                              repeat: false
                              interval: 2000
                              onTriggered: brushSizePreviewContainer.stateVisible = false
                          }

                          LEDPanelGraphic {
                             anchors.centerIn: parent
                             anchors.fill: parent
                          }
                          RadialBrush {
                              selectedColor: AppState.colorOpaque
                              anchors.centerIn: parent
                              width: AppState.brush.size * 1.45
                              height: AppState.brush.size * 1.45
                              visible: AppState.brush.type === 0
                          }
                          SquareBrush {
                              color: AppState.colorOpaque
                              anchors.centerIn: parent
                              width: AppState.brush.size * 1.45
                              height: AppState.brush.size * 1.45
                              visible: AppState.brush.type === 1
                          }
                      }
                  }

                  ColorIndicator {}
              }

              RowLayout {
                  Layout.margins: 10
                  ColumnLayout {
                      id: countdownContainer
                      Layout.alignment: Qt.AlignTop
                      Layout.maximumWidth: 200
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
                  ColumnLayout {
                      Layout.alignment: Qt.AlignTop
                      Header {
                          label: "clear panel"
                      }
                      RowLayout {
                          GlitchButton {
                              Layout.margins: 5
                              Layout.bottomMargin: 10
                              Layout.fillWidth: true
                              Layout.fillHeight: true
                              Layout.alignment: Qt.AlignCenter
                              backgroundColor: Theme.alertRed
                              onClicked: AppState.clearCanvas()
                          }
                      }
                  }

              }


          }



          Item {
              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.minimumWidth: 500
              RowLayout {
                  anchors.fill: parent
                  anchors.rightMargin: 30
                  anchors.topMargin: 10
                  anchors.bottomMargin: 10

                  Item {
                      z: 1
                      Layout.fillWidth: true
                      Layout.fillHeight: true
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
                      Layout.minimumWidth: 70
                      Layout.fillHeight: true
                      Layout.leftMargin: 10
                  }

                  Item {
                      z: 0
                      Layout.minimumWidth: 70
                      Layout.fillHeight: true
                      Layout.leftMargin: 10
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

      GlitchWarning {
          width: (parent.height * 1.7777) * .5
          height: (parent.width * .5625) * .5
          opacity: countdownProgress >= .01 && !AppState.isGlitching ? 1 : 0
          anchors.centerIn: parent
      }

      layer.enabled: true
      layer.effect: ShaderEffect {
          property real strength: countdownProgress * 0.02
          property real time: rootWindow.time
          property size size: Qt.size(rootWindow.width, rootWindow.height)
          blending: true
          fragmentShader: "qrc:/shaders/crt.frag"
      }
    }



}
