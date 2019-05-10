import QtQuick 2.12
import LeonardSouza 1.0

Item {
    id: itemRoot
    clip: true

    property real margin: 5
    property real scale: 1
    property real miniDisplayWidth: 0
    property real miniDisplayHeight: 0
    property real miniDisplayX: 0
    property real miniDisplayY: 0
    property int scaleMin: 1
    property int scaleMax: 5

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: .8
    }

    QImageProxy {
        id: root
        image: AppState.image
        layer.enabled: true
        width: itemRoot.width - margin*2
        height: itemRoot.height - margin*2
        x: margin
        y: margin
        layer.effect: ShaderEffect {
            property size size: Qt.size(root.width, root.height)
            property real frequency: 64
            property real uScale: 5
            property real uYrot: 0
            blending: true
            fragmentShader: "qrc:/shaders/led.frag"
        }
        PinchArea {
            pinch.target: root
            anchors.fill: parent
            pinch.maximumScale: scaleMax
            pinch.minimumScale: scaleMin
            pinch.minimumX: -AppState.getOffset(itemRoot.width, root.scale) + margin
            pinch.maximumX: AppState.getOffset(itemRoot.width, root.scale) + margin
            pinch.minimumY: -AppState.getOffset(itemRoot.height, root.scale) + margin
            pinch.maximumY: AppState.getOffset(itemRoot.height, root.scale) + margin
            pinch.dragAxis: Pinch.XAndYAxis
            onPinchUpdated: function (event) {
                AppState.setMiniDisplayValue(root.x, root.y, root.width, root.height, root.scale);
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                scrollGestureEnabled: false
                onPositionChanged: {
                  if (pressed) {
                      // Begin drawing an intermediate image on top of the saved image
                      // much like Photoshop
                    AppState.drawFromCoordinates(mouseX, mouseY, width, height)
                  }
                }
                onPressedChanged: {
                    if (!pressed) {
                        // This paints the intermediate image onto the saved image (makes it permanent)
                        AppState.swapBuffer();
                    } else {
                        AppState.updateBrush();
                    }
                }
            }
        }
    }

    Rectangle {
        width: 200
        height: 200
        x: parent.width / 2
        y: parent.height/ 2
        border.color: "white"
        color: "transparent"
        Rectangle {
            color: "white"
            width: AppState.miniDisplayValue.widthPercent * 200
            height: AppState.miniDisplayValue.heightPercent * 200
            x: AppState.miniDisplayValue.xPercent * 200
            y: AppState.miniDisplayValue.yPercent * 200
        }
    }

}
