import QtQuick 2.12

Item {
    id: root
    layer.enabled: true
    clip: false

    property real miniDisplayWidth: 0
    property real miniDisplayHeight: 0
    property real miniDisplayX: 0
    property real miniDisplayY: 0

    LEDGridImage {
        anchors.fill: parent
    }
    layer.effect: ShaderEffect {
        property size rectSize: Qt.size(miniDisplayWidth, miniDisplayHeight)
        property size rectPos: Qt.size(miniDisplayX, miniDisplayY)
        property size size: Qt.size(root.width, root.height)

        blending: true
        fragmentShader: "qrc:/shaders/minidisplay.frag"
    }
}
