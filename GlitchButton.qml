import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import Theme 1.0

Button {
    id: root
    property color backgroundColor: "#888"
    property string label: "A button"
    style: ButtonStyle {
        background: Item {
            Rectangle {
                width: 6
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                anchors.topMargin: 6
                color: backgroundColor

            }
            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                color: backgroundColor
            }
            Rectangle {
                width: 6
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                anchors.topMargin: 6
                color: backgroundColor
                anchors.right: parent.right
            }
        }
        label: RowLayout {

            Image {
                Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
                source: "images/skull.svg"
                antialiasing: true
                Layout.margins: 10
                Layout.rightMargin: 5
            }

            Text {
                Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
                text: root.label
                color: "#FFFFFF"
                font.family: Theme.mainFont.name
                font.pixelSize: Theme.h2
                Layout.margins: 10
                Layout.leftMargin: 0
            }
        }
    }
}
