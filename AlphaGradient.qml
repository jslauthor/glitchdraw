import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
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
    LinearGradient {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent"}
            GradientStop { position: 1.0; color: AppState.colorOpaque }
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPressed: {
            AppState.setOpacityFromCoordinates(mouseY, height)
        }
        onPositionChanged: {
            if (pressed) {
                AppState.setOpacityFromCoordinates(mouseY, height)
            }
        }
    }
    Rectangle {
        id: indicator
        x: -5
        y: (root.height * AppState.opacity) - (indicator.height / 2)
        width: root.width + 10
        height: 10
        color: "transparent"
        border.color: "white"
        border.width: 1
        radius: 5
    }
}

