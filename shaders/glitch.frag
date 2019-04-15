#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif // GL_FRAGMENT_PRECISION_HIGH
#endif // GL_ES

uniform float iTime;

// Modified https://www.shadertoy.com/view/Xt3XzH

// A simple implementation of sine waves along a given, unnormalized velocity

const float TAU = 6.2831852;
const float PI = 0.5 * TAU; // This is a political statement

const float octaves = 8.0;
const vec2 globalVelocity = vec2(25.0, 50.0);

// Hash without Sine by Dave Hoskins
// https://www.shadertoy.com/view/4djSRW
float hash11(float p)
{
    const float HASHSCALE1 = .1031;
        vec3 p3  = fract(vec3(p) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float getAmplitude(float octave)
{
    return 1.0 / pow(2.0, octave);
}

float getWavelength(float octave)
{
        const float maximumWavelength = 50.0;

    float wavelength = TAU * maximumWavelength / pow(2.0, octave);

    // Make it aperiodic with a random factor
    wavelength *= 0.75 + 0.5 * hash11(1.337 * octave);

    return wavelength;
}

float getSpeed(float octave)
{
    const float speedScaleFactor = 2.0;

    // Smallest waves travel twice as fast as given velocity,
    // largest waves travel half as fast
    const vec2 speedRange = vec2(5.0, 0.1);

    // Map octave to speed range
    float speed = speedScaleFactor * mix(speedRange.x, speedRange.y, octave / (max(1.0, octaves - 1.0)));

    // Add some randomness
    speed *= hash11(1.337 * octave);

    return speed;
}

float getShift(vec2 position, vec2 velocity, float percent)
{
    float magnitude = length(velocity);
    vec2 direction = (magnitude > 1e-5) ? velocity / magnitude : vec2(0.0);

    float height = 0.0;

    for (float octave = 0.0; octave < octaves; octave += 1.0)
    {
        float amplitude = getAmplitude(octave);
        float wavelength = getWavelength(octave);
        float speed = magnitude * getSpeed(octave);
        float frequency = TAU / wavelength;
        float randomPhaseOffset = hash11(1.337 * octave) * TAU;
        float phase = speed * frequency + randomPhaseOffset;
        float theta = dot(-direction, position);

        height += amplitude * sin(theta * frequency + (percent * 100.) * phase);
    }

    return height;
}

// I take zero credit for any of the below code. I modified it to suit my needs in Qt, but
// all the credit goes to tdhooper on shadertoy: https://www.shadertoy.com/view/XtyXzW

uniform sampler2D source;
varying highp vec2 qt_TexCoord0;
varying float yCoord;

uniform vec2 iResolution;
uniform float glitchScale;
uniform float percent;

highp float time;
highp vec2 coord;

float round(float n) {
    return floor(n + .5);
}

vec2 round(vec2 n) {
    return floor(n + .5);
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

struct GlitchSeed {
    vec2 seed;
    float prob;
};

GlitchSeed glitchSeed(vec2 p, float speed) {
    float seedTime = floor(time * speed);
    vec2 seed = vec2(
        1. + mod(seedTime / 100., 100.),
        1. + mod(seedTime, 100.)
    ) / 100.;
    seed += p;

    float position_percent = coord.y / iResolution.y;
    float margin_percent = mix(percent, percent + .05, rand(seed));
    float prob = 0.;
    if (position_percent <= margin_percent && percent != 0.) {
        prob = mix(.4, 1., rand(seed));
    }

    return GlitchSeed(seed, prob);
}

float shouldApply(GlitchSeed seed) {
    return round(
        mix(
            mix(rand(seed.seed), 1., seed.prob - .5),
            0.,
            (1. - seed.prob) * .5
        )
    );
}

vec2 glitchCoord(vec2 p, vec2 gridSize) {
        vec2 coord = floor(p / gridSize) * gridSize;;
    coord += (gridSize / 2.);
    return coord;
}

float isInBlock(vec2 pos, vec4 block) {
    vec2 a = sign(pos - block.xy);
    vec2 b = sign(block.zw - pos);
    return min(sign(a.x + a.y + b.x + b.y - 3.), 0.);
}

vec2 moveDiff(vec2 pos, vec4 swapA, vec4 swapB) {
    vec2 diff = swapB.xy - swapA.xy;
    return diff * isInBlock(pos, swapA);
}

vec4 swapCoords(vec2 seed, vec2 groupSize, vec2 subGrid, vec2 blockSize) {
    vec2 rand2 = vec2(rand(seed), rand(seed+.1));
    vec2 range = subGrid - (blockSize - 1.);
    vec2 coord = floor(rand2 * range) / subGrid;
    vec2 bottomLeft = coord * groupSize;
    vec2 realBlockSize = (groupSize / subGrid) * blockSize;
    vec2 topRight = bottomLeft + realBlockSize;
    topRight -= groupSize / 2.;
    bottomLeft -= groupSize / 2.;
    return vec4(bottomLeft, topRight);
}

void swapBlocks(inout vec2 xy, vec2 groupSize, vec2 subGrid, vec2 blockSize, vec2 seed, float apply) {

    vec2 groupOffset = glitchCoord(xy, groupSize);
    vec2 pos = xy - groupOffset;

    vec2 seedA = seed * groupOffset;
    vec2 seedB = seed * (groupOffset + .1);

    vec4 swapA = swapCoords(seedA, groupSize, subGrid, blockSize);
    vec4 swapB = swapCoords(seedB, groupSize, subGrid, blockSize);

    vec2 newPos = pos;
    newPos += moveDiff(pos, swapA, swapB) * apply;
    newPos += moveDiff(pos, swapB, swapA) * apply;
    pos = newPos;

    xy = pos + groupOffset;
}


void glitchSwap(inout vec2 p) {

    vec2 pp = p;

    float scale = glitchScale;
    float speed = 5.;

    vec2 groupSize;
    vec2 subGrid;
    vec2 blockSize;
    GlitchSeed seed;
    float apply;

    groupSize = vec2(.6) * scale;
    subGrid = vec2(2);
    blockSize = vec2(1);

    seed = glitchSeed(glitchCoord(p, groupSize), speed);
    apply = shouldApply(seed);
    swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

    groupSize = vec2(.8) * scale;
    subGrid = vec2(3);
    blockSize = vec2(1);

    seed = glitchSeed(glitchCoord(p, groupSize), speed);
    apply = shouldApply(seed);
    swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

    groupSize = vec2(.2) * scale;
    subGrid = vec2(6);
    blockSize = vec2(1);

    seed = glitchSeed(glitchCoord(p, groupSize), speed);
    float apply2 = shouldApply(seed);
    swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 1.), apply * apply2);
    swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 2.), apply * apply2);
    swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 3.), apply * apply2);
    swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 4.), apply * apply2);
    swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 5.), apply * apply2);

    groupSize = vec2(1.2, .2) * scale;
    subGrid = vec2(9,2);
    blockSize = vec2(3,1);

    seed = glitchSeed(glitchCoord(p, groupSize), speed);
    apply = shouldApply(seed);
    swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);
}

void staticNoise(inout vec2 p, vec2 groupSize, float grainSize, float contrast) {
    GlitchSeed seedA = glitchSeed(glitchCoord(p, groupSize), 5.);
    seedA.prob *= .5;
    if (shouldApply(seedA) == 1.) {
        GlitchSeed seedB = glitchSeed(glitchCoord(p, vec2(grainSize)), 5.);
        vec2 offset = vec2(rand(seedB.seed), rand(seedB.seed + .1));
        offset = round(offset * 2. - 1.);
        offset *= contrast;
        p += offset;
    }
}

void glitchStatic(inout vec2 p) {

    // Static
    //staticNoise(p, vec2(.25, .25/2.) * glitchScale, .005, 5.);

    // 8-bit
    staticNoise(p, vec2(.5, .25/2.) * glitchScale, .2 * glitchScale, 2.);
}

void glitchColor(vec2 p, inout vec3 color) {
    vec2 groupSize = vec2(.75,.125) * glitchScale;
    vec2 subGrid = vec2(0,6);
    float speed = 5.;
    GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
    seed.prob *= .3;
    if (shouldApply(seed) == 1.) {
        vec2 co = mod(p, groupSize) / groupSize;
        co *= subGrid;
        float a = max(co.x, co.y);
        color.rgb *= vec3(
          min(floor(mod(a - 0., 3.)), 1.),
            min(floor(mod(a - 1., 3.)), 1.),
            min(floor(mod(a - 2., 3.)), 1.)
        );

//        color *= min(floor(mod(a, 2.)), 1.) * 10.;
    }
}

void freezeTime(vec2 p, inout float time, vec2 groupSize, float speed) {
    GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
//    seed.prob *= .5;
    if (shouldApply(seed) == 1.) {
        float frozenTime = floor(time * speed) / speed;
        time = frozenTime;
    }
}

void glitchTime(vec2 p, inout float time) {
   freezeTime(p, time, vec2(.5) * glitchScale, 2.);
}

void main()
{
    time = iTime;
    time /= 3.;
    time = mod(time, 1.);

    coord = iResolution * qt_TexCoord0;
    vec2 p = qt_TexCoord0;

    vec2 velocity = vec2(length(globalVelocity), 10.0);
    float shiftAmount = getShift(vec2(coord.y, 0.0), velocity, percent);
    p.x += .25 * shiftAmount;

    glitchSwap(p);
    glitchTime(p, time);
    glitchStatic(p);
    vec3 color = texture2D(source, p).rgb;
    float alpha = texture2D(source, p).a;
    glitchColor(p, color);

    gl_FragColor = vec4(color * mix(.25, 1., rand(p)), alpha);
}
