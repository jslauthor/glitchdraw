#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif // GL_FRAGMENT_PRECISION_HIGH
#endif // GL_ES

attribute vec4 qt_Vertex;
attribute vec2 qt_MultiTexCoord0;

varying highp vec2 qt_TexCoord0;
uniform mat4 qt_Matrix;

void main()
{
    qt_TexCoord0 = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}
