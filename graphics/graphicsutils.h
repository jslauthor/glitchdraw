#ifndef GRAPHICSUTILS_H
#define GRAPHICSUTILS_H

#include <QImage>
#include <QRgba64>
#include <QEasingCurve>

class GraphicsUtils
{
  
public:
  static QImage mergeImages(
      const QImage &source,
      const QImage &destination,
      int alpha_threshold
  );

  static qreal getGlitchAmountForCountdown(float);

private:
  static const QEasingCurve m_easing;

};

#endif // GRAPHICSUTILS_H
