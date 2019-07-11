import QtQuick 2.0
import LeonardSouza 1.0
import QtQuick.Layouts 1.1
import QtQuick.Shapes 1.11
import Theme 1.0
import QtGraphicalEffects 1.12

Item {

    LEDPanelGraphic {
       anchors.fill: parent
       anchors.centerIn: parent
    }

    ColumnLayout {
      anchors.fill: parent
      Text {
          Layout.topMargin: 10
          Layout.maximumWidth: parent.width * .75
          Layout.alignment: Qt.AlignHCenter
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
          text: "Draw on the LED panel before time runs out!"
          font.family: Theme.mainFont.name
          font.pixelSize: Theme.h2
          color: "#FFFFFF"
          SequentialAnimation on opacity {
              running: true
              loops: Animation.Infinite
              NumberAnimation { to: 1; easing.type: Easing.InOutCubic; duration: 400; }
              NumberAnimation { to: 0; easing.type: Easing.InOutCubic; duration: 400; }
              NumberAnimation { to: 1; easing.type: Easing.InOutCubic; duration: 400; }
          }
      }
      Item {
          id: handCursorAnimation
          Layout.alignment: Qt.AlignHCenter
          height: 100
          width: 100
          property int duration: 2000;
          Item {
              x: -7
              y: -3
              Image {
                  id: handCursor
                  source: "images/hand_cursor.svg"
                  antialiasing: true
                  x: 0
                  y: 100
                  opacity: 0
              }
          }
          Shape {
              id: handShape
              width: parent.width
              height: parent.height
              opacity: 0
              ShapePath {
                  strokeColor: "white"
                  strokeWidth: 4
                  fillColor: "transparent"
                  capStyle: ShapePath.RoundCap

                  property int joinStyleIndex: 0

                  property variant styles: [
                      ShapePath.BevelJoin,
                      ShapePath.MiterJoin,
                      ShapePath.RoundJoin
                  ]

                  joinStyle: styles[joinStyleIndex]

                  startX: 0
                  startY: 100
                  PathLine { id: handPath; x: 0; y: 100 }
              }
          }
          // This is some diiiiiiirty animation :P
          SequentialAnimation {
              running: true
              loops: Animation.Infinite
              NumberAnimation { target: handCursor; property: "opacity"; from: 0; to: 1; easing.type: Easing.InCirc; duration: 300; }
              NumberAnimation { target: handCursor; property: "scale"; to: 1.5; easing.type: Easing.InOutBack; duration: 100; }
              NumberAnimation { target: handCursor; property: "scale"; to: .8; easing.type: Easing.InOutBack; duration: 100; }
              NumberAnimation { target: handCursor; property: "scale"; to: 1; easing.type: Easing.InOutBack; duration: 100; }
              ParallelAnimation {
                  SequentialAnimation {
                      NumberAnimation { target: handCursor; property: "x"; to: 100; easing.type: Easing.InOutBack; duration: handCursorAnimation.duration; }
                      PauseAnimation { duration: 400; }
                      NumberAnimation { target: handCursor; property: "x"; to: 0; easing.type: Easing.OutCirc; duration: 250; }
                  }
                  SequentialAnimation {
                      NumberAnimation { target: handCursor; property: "y"; to: 0; easing.type: Easing.InOutBack; duration: handCursorAnimation.duration; }
                      PauseAnimation { duration: 400; }
                      NumberAnimation { target: handCursor; property: "y"; to: 100; easing.type: Easing.OutCirc; duration: 250; }
                  }
                  SequentialAnimation {
                      PauseAnimation { duration: 550 }
                      NumberAnimation { target: handShape; property: "opacity"; from: 0; to: 1; easing.type: Easing.InCirc; duration: 250; }
                      PauseAnimation { duration: 600 }
                      NumberAnimation { targets: [handShape, handCursor]; property: "opacity"; from: 1; to: 0; easing.type: Easing.InCirc; duration: 250; }
                  }
                  SequentialAnimation {
                      NumberAnimation { target: handPath; property: "x"; to: 100; easing.type: Easing.InOutBack; duration: handCursorAnimation.duration; }
                      PauseAnimation { duration: 400; }
                      NumberAnimation { target: handPath; property: "x"; to: 0; easing.type: Easing.OutCirc; duration: 250; }
                  }
                  SequentialAnimation {
                      NumberAnimation { target: handPath; property: "y"; to: 0; easing.type: Easing.InOutBack; duration: handCursorAnimation.duration; }
                      PauseAnimation { duration: 400; }
                      NumberAnimation { target: handPath; property: "y"; to: 100; easing.type: Easing.OutCirc; duration: 250; }
                  }
              }
          }
       }
    }

}
