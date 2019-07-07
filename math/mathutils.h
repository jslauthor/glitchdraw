#ifndef MATHUTILS_H
#define MATHUTILS_H

#include <QtGlobal>

class MathUtils {

public:
  static float lerp(float a, float b, float f);
  static qreal scaleRange(float value, float min1, float max1, float min2, float max2);
};

#endif // MATHUTILS_H
