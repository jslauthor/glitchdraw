import QtQuick 2.12
import LeonardSouza 1.0

Item {
    id: itemRoot
    clip: true

    property real margin: 5
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: .8
    }

    // This functiontakes teh difference between the scaled grid and the original
    // and provides the offset for panning around
    function getOffset(base) {
        return (root.scale * base - base) / 2;
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
            pinch.maximumScale: 5
            pinch.minimumScale: 1
            pinch.minimumX: -getOffset(itemRoot.width) + margin
            pinch.maximumX: getOffset(itemRoot.width) + margin
            pinch.minimumY: -getOffset(itemRoot.height) + margin
            pinch.maximumY: getOffset(itemRoot.height) + margin
            pinch.dragAxis: Pinch.XAndYAxis
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


}
