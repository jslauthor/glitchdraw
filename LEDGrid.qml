import QtQuick 2.12
import LeonardSouza 1.0
import Theme 1.0

Item {
    id: itemRoot
    clip: true
    enabled: !zoomAnimation.running

    property real margin: 5
    property real yMargin: margin + (itemRoot.height / 2 - gridHeight / 2)
    property int scaleMin: 1
    property int scaleMax: 10

    property real gridHeight: itemRoot.width * .666667

    Connections {
        target: AppState
        onZoomReset: {
            zoomAnimation.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: .8
    }

    LEDGridImage {
        id: root
        width: itemRoot.width - margin*2
        height: gridHeight - margin*2 * .677777
        x: margin
        y: yMargin
        PinchArea {
            id: pinchArea
            pinch.target: root
            anchors.fill: parent
            pinch.maximumScale: scaleMax
            pinch.minimumScale: scaleMin
            pinch.minimumX: -AppState.getOffset(itemRoot.width, root.scale) + margin
            pinch.maximumX: AppState.getOffset(itemRoot.width, root.scale) + margin
            pinch.minimumY: -AppState.getOffset(gridHeight, root.scale) + yMargin
            pinch.maximumY: AppState.getOffset(gridHeight, root.scale) + yMargin
            pinch.dragAxis: Pinch.XAndYAxis
            onPinchUpdated: function (event) {
                AppState.setMiniDisplayValue(root.x, root.y, root.width, root.height, root.scale);
                miniDisplayContainer.state = "SHOWN";
                displayTimer.restart();
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                scrollGestureEnabled: false
                onPositionChanged: {
                  if (pressed) {
                      // Begin drawing an intermediate image on top of the saved image
                      // much like Photoshop
                    AppState.drawFromCoordinates(mouseX, mouseY, width, height);
                    miniDisplayContainer.state = "HIDDEN";
                  }
                }
                onCanceled: {
                    AppState.cancelDrawing();
                }
                onReleased: {
                   // This paints the intermediate image onto the saved image (makes it permanent)
                   AppState.swapBuffer();
                }
                onPressed: {
                    AppState.updateBrush();
                    AppState.drawFromCoordinates(mouseX, mouseY, width, height);
                }
            }
        }
    }

    Text {
        visible: AppState.miniDisplayValue.scale > 1
        text: "zoom: " + String(Math.round(AppState.miniDisplayValue.scale * 100)) + "%"
        font.family: Theme.mainFont.name
        font.pixelSize: Theme.h5
        color: "#FFFFFF"
        anchors.horizontalCenter: parent.horizontalCenter
        y: 15
    }

    ParallelAnimation {
        id: zoomAnimation
        NumberAnimation {
            target: root
            property: "scale"
            duration: 850
            easing.type: Easing.InOutCirc
            to: 1
        }
        NumberAnimation { target: root; property: "x"; to: margin; duration: 850; easing.type: Easing.InOutCirc }
        NumberAnimation { target: root; property: "y"; to: yMargin; duration: 850; easing.type: Easing.InOutCirc }
        onFinished: {
            miniDisplayContainer.state = "HIDDEN";
            AppState.setMiniDisplayValue(root.x, root.y, root.width, root.height, root.scale);
        }
    }



    Timer {
        id: displayTimer
        repeat: false
        interval: 950
        onTriggered: miniDisplayContainer.state = "HIDDEN"
    }

    Item {
        id: miniDisplayContainer
        width: 150 * 1.66667
        height: 150
        x: parent.width - 270
        y: parent.height - 170
        opacity: 0
        state: "HIDDEN"
        transitions: [
            Transition {
                from: "HIDDEN"
                to: "SHOWN"
                NumberAnimation {
                    target: miniDisplayContainer
                    property: "opacity"
                    duration: 150
                    easing.type: Easing.InQuad
                    from: miniDisplayContainer.opacity
                    to: 1
                }
            },
            Transition {
                from: "SHOWN"
                to: "HIDDEN"
                NumberAnimation {
                    target: miniDisplayContainer
                    property: "opacity"
                    duration: 250
                    easing.type: Easing.InQuad
                    from: miniDisplayContainer.opacity
                    to: 0
                }
            }
        ]
        LEDGridMiniDisplay {
            anchors.fill: parent
            miniDisplayWidth: AppState.miniDisplayValue.widthPercent
            miniDisplayHeight: AppState.miniDisplayValue.heightPercent
            miniDisplayX: AppState.miniDisplayValue.xPercent
            miniDisplayY: AppState.miniDisplayValue.yPercent
        }
    }


}
