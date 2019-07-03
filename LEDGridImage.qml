import QtQuick 2.12
import LeonardSouza 1.0

QImageProxy {
    id: root
    image: AppState.image
    layer.enabled: true

    layer.effect: ShaderEffect {
        property size size: Qt.size(root.width, root.height)
        property real frequency: 96
        property real uScale: 5
        property real uYrot: 0
        blending: true
        fragmentShader: "qrc:/shaders/led.frag"
    }
}
