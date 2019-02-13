import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.1
import Theme 1.0

Item {
    id: root
    property int value
    property int from
    property int to
    signal changed(int value)
    RowLayout {
        anchors.fill: parent

        Text {
            id: hello
            text: qsTr("text")
            font.family: Theme.mainFont.name
        }

        Slider {
            id: valueSlider
            Layout.fillWidth: true
            value: root.value
            from: root.from
            to: root.to
            onValueChanged: root.changed(valueSlider.value)
            background: Item {
                x: valueSlider.leftPadding
                y: valueSlider.topPadding + valueSlider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 4
                width: valueSlider.availableWidth
                height: implicitHeight
                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: Theme.mutedBlue

                    Rectangle {
                        width: valueSlider.visualPosition * parent.width
                        height: parent.height
                        color: Theme.blue
                        radius: 2
                    }
                }
                Rectangle {
                    x: parent.height
                    y: parent.height
                    width: parent.width
                    height: parent.height
                    color: Theme.darkBlue
                }
            }
            handle: ColumnLayout {
                x: valueSlider.leftPadding + valueSlider.visualPosition * (valueSlider.availableWidth - width)
                y: valueSlider.topPadding + valueSlider.availableHeight / 2 - height / 2
                implicitWidth: 18
                implicitHeight: 26
                spacing: 0
                Rectangle {
                    height: 3
                    width: 10
                    color: Theme.superBlue
                    Layout.alignment: Qt.AlignCenter
                }
                Rectangle {
                    height: 20
                    width: parent.width
                    color: Theme.superBlue
                }
                Rectangle {
                    height: 3
                    width: 10
                    color: Theme.superBlue
                    Layout.alignment: Qt.AlignCenter
                }
            }
        }
    }
}
