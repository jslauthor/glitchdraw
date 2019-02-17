import QtQuick 2.0
import QtQuick.Layouts 1.1
import Theme 1.0

ColumnLayout {
    id: root
    Text {
        id: header
        text: "color"
        font.family: Theme.mainFont.name
        font.pixelSize: Theme.h6
        color: Theme.peach
    }
    Item {
        width: 75
        height: 75
        Item {
            id: layerBackground
            layer.enabled: true
            anchors.fill: parent
            layer.effect:
                ShaderEffect {
                    fragmentShader: "qrc:/shaders/tiles.frag"
                }
        }
        Rectangle {
            anchors.fill: parent
            color: AppState.color
        }
        Rectangle {
            anchors.fill: parent
            color: AppState.colorOpaque
            rotation: 45
            transform: [
                Translate { y: 16 },
                Scale {xScale: 2; yScale: 2}
            ]
        }
        clip: true
    }
    RowLayout {
        spacing: 20
        SectionLabel {
            header: "opacity"
            label: Math.round(AppState.opacity * 100) + "%"
        }
        SectionLabel {
            header: "hex"
            label: String(AppState.colorOpaque).toUpperCase()
        }

    }
}
