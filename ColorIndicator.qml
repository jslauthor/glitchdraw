import QtQuick 2.0

Item {
    id: root
    Item {
        id: layerBackground
        layer.enabled: true
        width: root.width
        height: root.height
        layer.effect:
            ShaderEffect {
                fragmentShader: "qrc:/shaders/tiles.frag"
            }
    }
    Rectangle {
        anchors.fill: parent
        color: AppState.color
    }
}
