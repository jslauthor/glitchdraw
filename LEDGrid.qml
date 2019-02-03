import QtQuick 2.0
import LeonardSouza 1.0

QImageProxy {
    id: root
    image: AppState.image
    layer.enabled: true
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
            AppState.drawFromCoordinates(mouseX, mouseY, width, height)
          }
        }
        onPressedChanged: {
            if (!pressed) {
                AppState.swapBuffer();
            }
        }
    }
}
