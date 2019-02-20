import QtQuick 2.12
import QtGraphicalEffects 1.12
import Theme 1.0
import LeonardSouza 1.0

ListView {
    id: list
    model: BrushModel {}
    currentIndex: AppState.brush.type
    orientation: ListView.Horizontal
    implicitHeight: 75
    implicitWidth: childrenRect.width
    spacing: 20
    signal itemClicked(int brush)
    delegate: Item {
        id: brushDelegate
        width: list.height
        height: list.height
        RadialGradient {
            width: AppState.brush.size
            height: AppState.brush.size
            visible: type === 0
            anchors.centerIn: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#FFFFFF" }
                GradientStop { position: Math.min(AppState.brush.hardness / 2, .49); color: "#FFFFFF" }
                GradientStop { position: 0.5; color: "#00000000" }
            }
        }
        Rectangle {
            width: AppState.brush.size
            height: AppState.brush.size
            visible: type === 1
            anchors.centerIn: parent
            color: "#FFFFFF"
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
        color: Theme.midBlue
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
