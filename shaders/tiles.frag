#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif // GL_FRAGMENT_PRECISION_HIGH
#endif // GL_ES

const highp float size = 10.;
const highp vec4 GRID_DIMS = vec4(size);
const highp vec4 COL_EVEN = vec4(.4, .4, .4, 1.0);
const highp vec4 COL_ODD = vec4(.2, 0.2, 0.2, 1.0);

void main() {
    vec4 m = mod(gl_FragCoord, 2.0 * GRID_DIMS);
    if (m.x < GRID_DIMS.x && m.y < GRID_DIMS.y ||
        m.x >= GRID_DIMS.x && m.y >= GRID_DIMS.y)
        gl_FragColor = COL_EVEN;
    else
        gl_FragColor = COL_ODD;
}
