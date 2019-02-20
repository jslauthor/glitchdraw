import QtQuick 2.0
import QtQuick.Layouts 1.1
import Theme 1.0

ColumnLayout {
    id: root
    property string header
    property string label
    Header {
        label: root.header
    }

    Text {
        id: label
        text: root.label
        font.family: Theme.mainFont.name
        font.pixelSize: Theme.h2
        color: Theme.superBlue
    }
}
