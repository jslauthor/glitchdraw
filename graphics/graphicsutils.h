#ifndef GRAPHICSUTILS_H
#define GRAPHICSUTILS_H

#include <QImage>
#include <QRgba64>

class GraphicsUtils
{
  
public:
  static QImage mergeImages(
      const QImage &source,
      const QImage &destination,
      int alpha_threshold
  );

};

#endif // GRAPHICSUTILS_H
