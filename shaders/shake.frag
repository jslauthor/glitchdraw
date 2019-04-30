#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif // GL_FRAGMENT_PRECISION_HIGH
#endif // GL_ES

uniform sampler2D source;
varying highp vec2 qt_TexCoord0;
uniform float percent;
uniform float iTime;

const int octaves = 3;

float random (vec2 st)
{
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))* 43758.5453123);
}

float noise(vec2 st)
{
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p)
{
    float value = 0.0;
    float freq = 1.13;
    float amp = 0.57;
    for (int i = 0; i < octaves; i++)
    {
        value += amp * (noise((p - vec2(1.0)) * freq));
        freq *= 1.61;
        amp *= 0.47;
    }
    return value;
}

float pat(vec2 p)
{
    float time = iTime*0.75;
    vec2 aPos = vec2(sin(time * 0.035), sin(time * 0.05)) * 3.;
    vec2 aScale = vec2(3.25);
    float a = fbm(p * aScale + aPos);
    vec2 bPos = vec2(sin(time * 0.09), sin(time * 0.11)) * 1.2;
    vec2 bScale = vec2(0.75);
    float b = fbm((p + a) * bScale + bPos);
    vec2 cPos = vec2(-0.6, -0.5) + vec2(sin(-time * 0.01), sin(time * 0.1)) * 1.9;
    vec2 cScale = vec2(1.25);
    float c = fbm((p + b) * cScale + cPos);
    return c;
}

vec2 Shake(float maxshake, float mag)
{
    float speed = 20.0*mag;
    float shakescale = maxshake * mag;

    float time = iTime*speed;			// speed of shake

    vec2 p1 = vec2(0.25,0.25);
    vec2 p2 = vec2(0.75,0.75);
    p1 += time;
    p2 += time;

    // random shake is just too violent...
    //float val1 = random(p1);
    //float val2 = random(p2);

    float val1 = pat(p1);
    float val2 = pat(p2);
    val1 = clamp(val1,0.0,1.0);
    val2 = clamp(val2,0.0,1.0);

    return vec2(val1*shakescale,val2*shakescale);
}


void main(void)
{

    float maxshake = 0.3;				// max shake amount
    float mag = percent;		// shake magnitude...

    // *temp* , We will calc shakexy once in the vertex shader...
    vec2 shakexy = Shake(maxshake,mag);

    vec2 uv = qt_TexCoord0.st;
    uv *= 1.0-(maxshake*mag);
    vec3 col = texture2D(source, uv + shakexy).xyz;
    float a = texture2D(source, uv + shakexy).a;

    gl_FragColor = vec4(col, a);
}
