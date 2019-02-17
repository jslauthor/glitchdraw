import QtQuick 2.0
import QtQuick.Layouts 1.1
import Theme 1.0


ColumnLayout {
    id: root
    property string header
    property string label
    Text {
        id: header
        text: root.header
        font.family: Theme.mainFont.name
        font.pixelSize: Theme.h6
        color: Theme.peach
    }
    Text {
        id: label
        text: root.label
        font.family: Theme.mainFont.name
        font.pixelSize: Theme.h2
        color: Theme.superBlue
    }
}
