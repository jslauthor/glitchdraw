#include "qimageproxy.h"

QImageProxy::QImageProxy() = default;

void QImageProxy::setImage(QImage &image) {
  m_image = image;
  update();
}

QImage QImageProxy::image() const {
  return m_image;
}

void QImageProxy::paint(QPainter *painter) {
  painter->drawImage(QRect(0, 0, width(), height()), m_image);
}
