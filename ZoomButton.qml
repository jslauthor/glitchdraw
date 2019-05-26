import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import LeonardSouza 1.0
import Theme 1.0

Button {
    id: root

    property color backgroundColor: "#888"
    property string imageSource: "images/skull.svg"

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

                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.margins: 5
                Layout.fillWidth: true

                Item {
                   Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                   Layout.minimumWidth: 30
                   Layout.minimumHeight: 30
                   Image {
                       id: upRight
                       source: "images/minimize_up_right.svg"
                       antialiasing: true
                       anchors.bottom: parent.bottom
                       anchors.left: parent.left

                       ParallelAnimation {
                           running: true
                           loops: Animation.Infinite
                           SequentialAnimation {
                               NumberAnimation { target: upRight; property: "anchors.leftMargin"; to: 0; easing.type: Easing.InOutBack; }
                               NumberAnimation { target: upRight; property: "anchors.leftMargin"; to: 3; easing.type: Easing.InOutBack; }
                               NumberAnimation { target: upRight; property: "anchors.leftMargin"; to: 0; easing.type: Easing.InOutBack; }
                           }
                           SequentialAnimation {
                               NumberAnimation { target: upRight; property: "anchors.bottomMargin"; to: 0; easing.type: Easing.InOutBack; }
                               NumberAnimation { target: upRight; property: "anchors.bottomMargin"; to: 3; easing.type: Easing.InOutBack; }
                               NumberAnimation { target: upRight; property: "anchors.bottomMargin"; to: 0; easing.type: Easing.InOutBack; }
                           }
                       }
                   }
                   Image {
                       id: bottomLeft
                       source: "images/minimize_down_left.svg"
                       antialiasing: true
                       anchors.top: parent.top
                       anchors.right: parent.right

                       ParallelAnimation {
                           running: true
                           loops: Animation.Infinite
                           SequentialAnimation {
                               NumberAnimation { target: bottomLeft; property: "anchors.rightMargin"; to: 0; easing.type: Easing.InOutBack; }
                               NumberAnimation { target: bottomLeft; property: "anchors.rightMargin"; to: 3; easing.type: Easing.InOutBack; }
                               NumberAnimation { target: bottomLeft; property: "anchors.rightMargin"; to: 0; easing.type: Easing.InOutBack; }
                           }
                           SequentialAnimation {
                               NumberAnimation { target: bottomLeft; property: "anchors.topMargin"; to: 0; easing.type: Easing.InOutBack; }
                               NumberAnimation { target: bottomLeft; property: "anchors.topMargin"; to: 3; easing.type: Easing.InOutBack; }
                               NumberAnimation { target: bottomLeft; property: "anchors.topMargin"; to: 0; easing.type: Easing.InOutBack; }
                           }
                       }
                   }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: -5
                    Text {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        text: "reset"
                        color: "#FFFFFF"
                        font.family: Theme.mainFont.name
                        font.pixelSize: Theme.h5
                    }
                    Text {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.minimumWidth: 60
                        text: "zoom"
                        color: "#FFFFFF"
                        font.family: Theme.mainFont.name
                        font.pixelSize: Theme.h2
                    }
                }
            }

        }
    }



}
