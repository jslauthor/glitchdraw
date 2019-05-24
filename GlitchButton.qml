import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import LeonardSouza 1.0
import Theme 1.0

Button {
    id: root

    property color backgroundColor: "#888"
    property string label: ""
    property string imageSource: "images/skull.svg"
    property bool flashBackground: false
    property bool toggleEnabled: false
    property bool toggled: true

    style: ButtonStyle {
        background: Rectangle {
            id: bg
            state: "ON"
            anchors.fill: parent
            color: backgroundColor
            layer.enabled: true
            layer.effect:
                ShaderEffect {
                    property size size: Qt.size(bg.width, bg.height)
                    property real clipSize: Theme.clipSize
                    fragmentShader: "qrc:/shaders/clipcorners.frag"
                }

            states: [
                State {
                    name: "ON"
                    when: toggled
                    PropertyChanges { target: bg; opacity: 1.; color: backgroundColor}
                },
                State {
                    name: "OFF"
                    when: !toggled
                    PropertyChanges { target: bg; opacity: 0.; color: Qt.lighter(backgroundColor, 1.5)}
                }
            ]

            transitions: [
                Transition {
                    from: "ON"
                    to: "OFF"
                    ParallelAnimation {
                        ColorAnimation { target: bg; duration: 100 }
                        PropertyAnimation { target: bg; properties: "opacity"; duration: 100 }
                    }
                },
                Transition {
                    from: "OFF"
                    to: "ON"
                    ParallelAnimation {
                        ColorAnimation { target: bg; duration: 100 }
                        PropertyAnimation { target: bg; properties: "opacity"; duration: 100 }
                    }
                }
            ]


            Connections {
                target: root
                onClicked: pressAnimation.running = true
            }

            SequentialAnimation  {
                id: pressAnimation
                loops: 1
                ColorAnimation {
                    target: bg
                    property: "color"
                    from: backgroundColor
                    to: Qt.lighter(backgroundColor, 1.5)
                    duration: 75
                }
                ColorAnimation {
                    target: bg
                    property: "color"
                    to: backgroundColor
                    from: Qt.lighter(backgroundColor, 1.5)
                    duration: 75
                }
            }
        }
        label: RowLayout {
            RowLayout {

                Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
                Layout.margins: 10
                Layout.fillWidth: true

                Image {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    source: root.imageSource
                    antialiasing: true
                }

                Text {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: root.label
                    color: "#FFFFFF"
                    font.family: Theme.mainFont.name
                    font.pixelSize: Theme.h2
                    Layout.leftMargin: 5
                    Layout.topMargin: 1
                    visible: root.label.length != 0
                }
            }

        }
    }



}
