import QtQuick 2.12
import QtGraphicalEffects 1.12
import Theme 1.0

ListView {
    id: list
    model: BrushModel {}
    orientation: ListView.Horizontal
    implicitHeight: 85
    implicitWidth: childrenRect.width
    spacing: 20
    delegate: Item {
        id: brushDelegate
        width: 85
        height: 85
        Rectangle {
            visible: brushDelegate.ListView.isCurrentItem
            width: list.height
            height: list.height
            color: Theme.blue
        }
        RadialGradient {
            width: AppState.brush.size
            height: AppState.brush.size
            visible: type === 'circle'
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
            visible: type === 'square'
            anchors.centerIn: parent
            color: "#FFFFFF"
        }
    }
}
