#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif // GL_FRAGMENT_PRECISION_HIGH
#endif // GL_ES

varying highp vec2 qt_TexCoord0;
uniform highp sampler2D source;
uniform highp float qt_Opacity;

uniform vec2 rectSize;
uniform vec2 rectPos;
uniform vec2 size;

float borderSize = .01;

// return 1 if v inside the box, return 0 otherwise
float insideRect(vec2 v, vec2 bottomLeft, vec2 topRight) {
    vec2 s = step(bottomLeft, v) - step(topRight, v);
    return s.x * s.y;
}

void main(void)
{
    vec2 st = qt_TexCoord0;
    vec2 pos = st * size;

    vec2 rSize = rectSize * size;
    vec2 rPos = rectPos * size;
    vec2 bottomLeft = vec2(rPos.x, rPos.y + rSize.y);
    vec2 topRight = vec2(rPos.x + rSize.x, rPos.y);

    vec4 color = texture2D(source, st) * qt_Opacity;

    if (insideRect(pos, bottomLeft, topRight) == 0.) {
        gl_FragColor = mix(vec4(1., 1., 1., 1.) * qt_Opacity, color, .75);
        return;
    }

    gl_FragColor = color;
}
