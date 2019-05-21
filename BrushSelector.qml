import QtQuick 2.12
import QtGraphicalEffects 1.12
import Theme 1.0
import LeonardSouza 1.0

ListView {
    id: list
    model: BrushModel {}
    currentIndex: AppState.brush.type
    orientation: ListView.Horizontal
    implicitHeight: 65
    implicitWidth: childrenRect.width
    spacing: 5
    signal itemClicked(int brush)
    delegate: Item {
        id: brushDelegate
        width: list.height
        height: list.height
        RadialBrush {
            width: 40
            height: 40
            visible: type === 0
            anchors.centerIn: parent
        }
        SquareBrush {
            width: 40
            height: 40
            visible: type === 1
            anchors.centerIn: parent
        }
        MouseArea {
            width: brushDelegate.height
            height: brushDelegate.width
            onClicked: itemClicked(type)
        }
    }
    highlight: Rectangle {
        width: list.height
        height: list.height
        color: Theme.alertRed
        Behavior on x {
            SpringAnimation {
                spring: 3
                damping: 0.2
            }
        }
        layer.enabled: true
        layer.effect:
            ShaderEffect {
                property size size: Qt.size(list.height, list.height)
                property real clipSize: Theme.clipSize
                fragmentShader: "qrc:/shaders/clipcorners.frag"
            }
    }
}
