import QtQuick 2.12
import LeonardSouza 1.0

Item {
    id: itemRoot
    clip: true

    property real margin: 5
    property int scaleMin: 1
    property int scaleMax: 5

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: .8
    }

    LEDGridImage {
        id: root
        width: itemRoot.width - margin*2
        height: itemRoot.height - margin*2
        x: margin
        y: margin
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

    LEDGridMiniDisplay {
        width: 200
        height: 200
        x: parent.width / 2
        y: parent.height/ 2
        clip:false
        miniDisplayWidth: AppState.miniDisplayValue.widthPercent
        miniDisplayHeight: AppState.miniDisplayValue.heightPercent
        miniDisplayX: AppState.miniDisplayValue.xPercent
        miniDisplayY: AppState.miniDisplayValue.yPercent
    }
}
