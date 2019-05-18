import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import Theme 1.0

Button {
    id: root

    property color backgroundColor: "#888"
    property string label: ""
    property string imageSource: "images/skull.svg"

    style: ButtonStyle {
        background: Rectangle {
            id: bg
            anchors.fill: parent
            color: backgroundColor
            layer.enabled: true
            layer.effect:
                ShaderEffect {
                    property size size: Qt.size(bg.width, bg.height)
                    property real clipSize: Theme.clipSize
                    fragmentShader: "qrc:/shaders/clipcorners.frag"
                }
        }
        label: RowLayout {
            RowLayout {

                Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
                Layout.margins: 10
                Layout.fillWidth: true

                Image {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    source: root.imageSource
                    antialiasing: true
                    Layout.rightMargin: 5
                }

                Text {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: root.label
                    color: "#FFFFFF"
                    font.family: Theme.mainFont.name
                    font.pixelSize: Theme.h2
                    Layout.leftMargin: 0
                    Layout.topMargin: 1
                }
            }

        }
    }
}
