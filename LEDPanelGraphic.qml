import QtQuick 2.0
import QtQuick.Layouts 1.1

Item {
   clip: true
   Rectangle {
       anchors.fill: parent
       anchors.centerIn: parent
       color: "black"
       opacity: .65
       GridLayout {
          id: pixelGrid
          columns: 96
          rows: 64
          anchors.fill: parent
          layer.enabled: true
          rowSpacing: 1
          columnSpacing: 1
          Repeater {
              model: pixelGrid.columns * pixelGrid.rows
              Rectangle {
                  color: "white"
                  width: 1
                  height: 1
                  radius: width * .5
                  opacity: .65
              }
          }
       }
   }
   Rectangle {
       anchors.fill: parent
       anchors.leftMargin: -5
       anchors.rightMargin: -5
       anchors.topMargin:  -15
       anchors.bottomMargin: -15
       color: "transparent"
       border.width: 20
       border.color: "black"
   }
}
