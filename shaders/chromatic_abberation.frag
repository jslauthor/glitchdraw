#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif // GL_FRAGMENT_PRECISION_HIGH
#endif // GL_ES

uniform sampler2D source;
varying highp vec2 qt_TexCoord0;

uniform float strength;
uniform float turbulence;
uniform float time;

void main(void)
{
    vec2 uv = qt_TexCoord0;

    float turbulenceFactor = mix(0., turbulence, abs(sin(time)));

    vec2 d = abs((uv - 0.5) * (strength + turbulenceFactor));
    d = pow(d, vec2(2.0, 2.0));

    vec4 r = texture2D(source, uv - d * 0.003);
    vec4 g = texture2D(source, uv);
    vec4 b = texture2D(source, uv + d * 0.003);
    float a = texture2D(source, qt_TexCoord0.st).a;

    gl_FragColor = vec4(r.r, g.g, b.b, a);
}
