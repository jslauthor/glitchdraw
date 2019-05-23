import QtQuick 2.5

Rectangle {
    id: root
    Item {
        id: layerRoot
        layer.enabled: true
        width: root.width
        height: root.height
        layer.effect: ShaderEffect {
            property real w: root.width
            property real h: root.height
            property real hue: AppState.hue
            fragmentShader: "
                #ifdef GL_ES
                    #ifdef GL_FRAGMENT_PRECISION_HIGH
                        precision highp float;
                    #else
                        precision mediump float;
                    #endif // GL_FRAGMENT_PRECISION_HIGH
                #endif // GL_ES

                uniform highp float w;
                uniform highp float h;
                uniform highp float hue;
                varying highp vec2 qt_TexCoord0;

                //  Function from Iñigo Quiles (dude's a genius)
                //  https://www.shadertoy.com/view/MsS3Wc
                vec3 hsb2rgb(in vec3 c) {
                    highp vec3 mult = vec3(0.0,4.0,2.0);
                    highp vec3 rgb = clamp(abs(mod(c.x*6.0+mult,
                                             6.0)-3.0)-1.0,
                                     0.0,
                                     1.0 );
                    rgb = rgb*rgb*(3.0-2.0*rgb);
                    highp vec3 defaultV = vec3(1.0);
                    return c.z * mix( defaultV, rgb, c.y);
                }

                void main() {
                    highp float saturation = (qt_TexCoord0.x * w) / w;
                    highp float brightness = ((1.0 - qt_TexCoord0.y) * h) / h;
                    highp vec3 hsb = vec3(hue, saturation, brightness);
                    highp vec3 color = hsb2rgb(hsb);
                    gl_FragColor = vec4(color,1.0);
                }"
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPositionChanged: {
                if (pressed) {
                    AppState.setColorFromCoordinates(mouseX, mouseY, width, height)
                }
            }
        }
    }
    Rectangle {
        visible: enabled
        x: (root.width * AppState.saturationF) - 15
        y: (root.height * (1 - AppState.lightnessF)) - 15
        width: 30
        height: 30
        color: AppState.color
        border.color: "white"
        border.width: 3
        radius: 15
    }
}
