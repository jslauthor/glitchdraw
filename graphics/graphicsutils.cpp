#include "graphicsutils.h"
#include <QDebug>

QImage GraphicsUtils::mergeImages(const QImage &source, const QImage &destination, int alpha_threshold)
{
  if (source.width() != destination.width() || source.height() != destination.height()) {
    qErrnoWarning("Source and Destination images must match in size");
  }

  QImage mergedImage(source);

  for (int i = 0; i < mergedImage.height(); i++) {
      QRgb *s = reinterpret_cast<QRgb*>(mergedImage.scanLine(i));
      QRgb *end = s + mergedImage.width();

      // We expect this length to be the same since we check up top
      const QRgb *d = reinterpret_cast<const QRgb*>(destination.constScanLine(i));

      while (s < end) {
        // Handy way to check hex value!
        // qDebug() << "Value : " << hex << *s;
        int alpha = qAlpha(*s);
        if (alpha < alpha_threshold && qAlpha(*d) > alpha) {
          *s = qRgba(qRed(*d), qGreen(*d), qBlue(*d), qAlpha(*d));
        }
        s++;
        d++;
      }
  }

  return mergedImage;
}
