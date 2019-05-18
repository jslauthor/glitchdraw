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
            name: "ahhh"
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

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 15
                Text {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    text: "mode"
                    font.family: Theme.mainFont.name
                    font.pixelSize: Theme.h5
                    color:  Theme.orange
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                }
                Text {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
                    text: "minutes"
                    font.family: Theme.mainFont.name
                    font.pixelSize: Theme.h5
                    color:  Theme.orange
                    Layout.fillWidth: true
                    Layout.leftMargin: 36
                }
            }

            Repeater {
                Layout.alignment: Qt.AlignHCenter
                model: modeModel
                Item {
                    id: repeated
                    width: childrenRect.width
                    height: childrenRect.height
                    Layout.alignment: Qt.AlignHCenter
                    MouseArea {
                        width: text.width
                        height: text.height
                        onClicked: {
                            timeChanged(seconds);
                        }
                    }
                    Text {
                        id: caret
                        visible: Number(AppState.countdownTotal) == Number(seconds)
                        text: ">"
                        font.family: Theme.mainFont.name
                        font.pixelSize: Theme.h2
                        color:  Theme.alertRed
                        x: text.x - caret.width - 5
                        y: text.y + 11
                    }
                    RowLayout {
                        id: text
                        height: 45
                        spacing: 15
                        Text {
                            text: name
                            font.family: Theme.mainFont.name
                            font.pixelSize: Theme.huge
                            color:  Theme.alertRed
                            Layout.fillWidth: true
                        }
                        Text {
                            Layout.alignment: Qt.AlignBottom
                            text: AppState.formatPopupLabel(seconds, "mm:ss")
                            font.family: Theme.mainFont.name
                            font.pixelSize: Theme.h2
                            color:  Theme.alertRed
                            Layout.fillWidth: true
                            Layout.bottomMargin: 3
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
