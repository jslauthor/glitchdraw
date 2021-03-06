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
uniform float uScale; // For imperfect, isotropic anti-aliasing in
uniform float uYrot;  // absence of dFdx() and dFdy() functions
uniform float frequency; // Needed globally for lame version of aastep()

float aastep(float threshold, float value) {
  float afwidth = frequency * .005 / uScale / cos(uYrot);
  return smoothstep(threshold - afwidth, threshold + afwidth, value);
}

void main() {
  vec2 st = qt_TexCoord0; // OMG 0..1 COORDINATES SMH
  vec4 tex = texture2D(source, st);

  vec2 nearest = 2.0 * fract(frequency * st) - 1.0;
  float dist = length(nearest);
  float radius = 0.5;
  vec3 dots = tex.a > 0. ? tex.xyz : vec3(.2, .2, .2);
  float step = aastep(radius, dist);
  vec3 fragcolor = mix(dots, vec3(0.0, 0.0, 0.0), step);
  gl_FragColor = vec4(fragcolor, step == 1.0 ? 0.0 : step) * qt_Opacity;
}
