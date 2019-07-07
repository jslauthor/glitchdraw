#include "mathutils.h"

float MathUtils::lerp(float a, float b, float f)
{
    return (a * (1.0 - f)) + (b * f);
}


qreal MathUtils::scaleRange(float value, float min1, float max1, float min2, float max2)
{
  // newValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
  return (((value - min1) * (max2 - min2)) / (max1 - min1)) + min2;
}
