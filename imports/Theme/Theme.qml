pragma Singleton

import QtQuick 2.8

QtObject {
    readonly property color blue: "#62C9E2"
    readonly property color mutedBlue: "#38717A"
    readonly property color darkBlue: "#22215C"
    readonly property color midBlue: "#3F75BA"
    readonly property color superBlue: "#00FFE6"
    readonly property color peach: "#F47F57"
    readonly property color alertRed: "#FF0055"
    readonly property color pink: "#FCE3EB"
    readonly property color orange: "#FFB000"

    readonly property real h6: 8;
    readonly property real h5: 11;
    readonly property real h2: 16;
    readonly property real h1: 20;
    readonly property real huge: 28;

    readonly property real clipSize: 7;

    property FontLoader mainFont: FontLoader {
        source: "qrc:/content/fonts/8-bit-pusab.ttf"
    }
}
