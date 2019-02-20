#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif // GL_FRAGMENT_PRECISION_HIGH
#endif // GL_ES

uniform highp sampler2D source;
varying highp vec2 qt_TexCoord0;
uniform vec2 size;
uniform float clipSize;

void main(void)
{
    vec2 st = qt_TexCoord0;
    float x = st.x * size.x;
    float y = st.y * size.y;

    if ((x < clipSize || x > size.x - clipSize) && (y < clipSize || y > size.y - clipSize)) {
        gl_FragColor = vec4(0.,0.,0.,0.);
    } else {
        gl_FragColor = texture2D(source, qt_TexCoord0.st);
    }

}
