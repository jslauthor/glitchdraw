import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.1

Item {
    id: root
    property int value
    property int from
    property int to
    signal changed(int value)
    RowLayout {
        anchors.fill: parent
        Slider {
            id: valueSlider
            Layout.fillWidth: true
            value: root.value
            from: root.from
            to: root.to
            onValueChanged: root.changed(valueSlider.value)
        }
    }
}
