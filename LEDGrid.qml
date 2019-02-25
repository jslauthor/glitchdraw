import QtQuick 2.0
import LeonardSouza 1.0

Item {
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: .8
    }

    QImageProxy {
        id: root
        image: AppState.image
        layer.enabled: true
        anchors.fill: parent
        anchors.margins: 5
        layer.effect: ShaderEffect {
            property size size: Qt.size(root.width, root.height)
            property real frequency: 64
            property real uScale: 5
            property real uYrot: 0
            blending: true
            fragmentShader: "qrc:/shaders/led.frag"
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPositionChanged: {
              if (pressed) {
                  // Begin drawing a intermediate image on top of the saved image
                  // much like Photoshop
                AppState.drawFromCoordinates(mouseX, mouseY, width, height)
              }
            }
            onPressedChanged: {
                if (!pressed) {
                    // This paints the intermediate image onto the saved image (makes it permanent)
                    AppState.swapBuffer();
                } else {
                    AppState.updateBrush();
                }
            }
        }
    }


}
