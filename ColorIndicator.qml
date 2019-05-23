import QtQuick 2.0
import QtQuick.Layouts 1.1
import Theme 1.0

ColumnLayout {
    id: root
    spacing: 5
    Header {
        label: "color"
    }

    Item {
        id: indicator
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
        layer.enabled: true
        layer.effect:
            ShaderEffect {
                property size size: Qt.size(indicator.width, indicator.height)
                property real clipSize: Theme.clipSize
                fragmentShader: "qrc:/shaders/clipcorners.frag"
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
