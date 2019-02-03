import QtQuick 2.0

Rectangle {
    id: root
    Item {
        id: layerRoot
        layer.enabled: true
        width: root.width
        height: root.height
        layer.effect:
            ShaderEffect {
                property real h: root.height
                fragmentShader: "
                    #ifdef GL_ES
                        #ifdef GL_FRAGMENT_PRECISION_HIGH
                            precision highp float;
                        #else
                            precision mediump float;
                        #endif // GL_FRAGMENT_PRECISION_HIGH
                    #endif // GL_ES

                    uniform highp float h;
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
                        highp float hue = (qt_TexCoord0.y * h) / h;
                        highp vec3 hsb = vec3(hue, 1, 1);
                        highp vec3 color = hsb2rgb(hsb);
                        gl_FragColor = vec4(color,1.0);
                    }"
            }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPositionChanged: {
                if (pressed) {
                    AppState.setHueFromCoordinates(mouseY, height)
                }
            }
        }
    }
    Rectangle {
        id: indicator
        x: -5
        y: (root.height * AppState.hue) - (indicator.height / 2)
        width: root.width + 10
        height: 10
        color: "transparent"
        border.color: "white"
        border.width: 1
        radius: 5
    }
}

