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
uniform float iTime;
uniform vec4 circleColor;

mat2 rotate2d(float angle){
    return mat2(cos(angle),-sin(angle),
                sin(angle),cos(angle));
}

float variation(vec2 v1, vec2 v2, float strength, float speed) {
        return sin(
        dot(normalize(v1), normalize(v2)) * strength + iTime * speed
    ) / 100.0;
}

vec4 paintCircle (vec2 uv, vec2 center, float rad, float width, vec4 bgColor, vec4 color) {

    vec2 diff = center-uv;
    float len = length(diff);

    len += variation(diff, vec2(0.0, 1.0), 2.5, 1.5);
    len -= variation(diff, vec2(1.0, 0.0), 2.5, 1.5);

    float circle = smoothstep(rad-width, rad, len) - smoothstep(rad, rad+width, len);
    return mix(bgColor, vec4(circle) * color, circle);
}

void main()
{
    vec2 uv = qt_TexCoord0;
    vec4 color;
    float radius = 0.35;
    vec2 center = vec2(0.5);

    vec4 bgColor = texture2D(source, uv).rgba;

    //paint soft circle
    color = paintCircle(uv, center, radius, 0.1, bgColor, circleColor);

    //paint thin circle
    color += paintCircle(uv, center, radius, 0.01, bgColor, circleColor);

    gl_FragColor = color * qt_Opacity;
}


