import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.1
import Theme 1.0

Popup {
    id: root
    modal: true
    padding: 10
    width: 300
    height: 400

    signal timeChanged(int seconds);

    ListModel {
        id: modeModel

        ListElement {
            name: "easy"
            seconds: 300
        }
        ListElement {
            name: "hard"
            seconds: 60
        }
        ListElement {
            name: "ahh!"
            seconds: 20
        }
    }

    contentItem: Item {
        anchors.margins: 10
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: Theme.pink
        }
        ColumnLayout {
            anchors.fill: parent
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "time until glitch"
                font.family: Theme.mainFont.name
                font.pixelSize: Theme.h2
                color: Theme.alertRed
            }
            Repeater {
                Layout.alignment: Qt.AlignHCenter
                model: modeModel
                RowLayout {
                    width: parent.width * .75
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        visible: AppState.countdownTotal === seconds
                        Layout.alignment: Qt.AlignVCenter
                        text: ">"
                        font.family: Theme.mainFont.name
                        font.pixelSize: Theme.h1
                        color:  Theme.alertRed
                    }
                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: name
                        font.family: Theme.mainFont.name
                        font.pixelSize: Theme.h1
                        color:  Theme.alertRed
                    }
                    Text {
                        Layout.alignment: Qt.AlignBottom
                        text: AppState.formatTime(seconds)
                        font.family: Theme.mainFont.name
                        font.pixelSize: Theme.h2
                        color:  Theme.alertRed
                    }
                    MouseArea {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: {
                            timeChanged(seconds);
                        }
                    }
                }
            }
            Rectangle {
                Layout.alignment: Qt.AlignBottom
                height: 40
                Layout.fillWidth: true
                color: Theme.alertRed
                Text {
                    anchors.topMargin: 5
                    anchors.centerIn: parent
                    text: "ok"
                    font.family: Theme.mainFont.name
                    font.pixelSize: Theme.h1
                    color: "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.close()
                    }
                }
            }
        }
    }

    background: Rectangle {
        id: bg
        anchors.fill: parent
        color: Theme.alertRed
        layer.enabled: true
        layer.effect:
            ShaderEffect {
                property size size: Qt.size(bg.width, bg.height)
                property real clipSize: Theme.clipSize
                fragmentShader: "qrc:/shaders/clipcorners.frag"
            }
    }
}
