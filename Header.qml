import QtQuick 2.0
import Theme 1.0

Text {
    property string label
    id: root
    text: root.label
    font.family: Theme.mainFont.name
    font.pixelSize: Theme.h6
    color: Theme.peach
}
