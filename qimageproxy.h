#ifndef QIMAGEPROXY_H
#define QIMAGEPROXY_H

#include <QQuickItem>
#include <QtQuick/QQuickPaintedItem>
#include <QImage>
#include <QPainter>

class QImageProxy : public QQuickPaintedItem
{
  Q_OBJECT
  Q_PROPERTY(QImage image READ image WRITE setImage)

public:
  QImageProxy();

  void setImage(QImage &image);
  QImage image() const;

  void paint(QPainter *painter);

signals:

public slots:
private:
  QImage m_image;
};

#endif // QIMAGEPROXY_H
