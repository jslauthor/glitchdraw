#ifndef APPSTATE_H
#define APPSTATE_H

#include <QObject>
#include <QColor>
#include <QVector3D>
#include <QImage>
#include <QPainter>
#include <cmath>
#include <QRadialGradient>
#include <QBrush>
#include <QImageWriter>
#include <QPoint>
#include <QDebug>

#include "graphics/graphicsutils.h"
#include "renderthread.h"

class AppState : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
  Q_PROPERTY(QColor colorOpaque READ colorOpaque NOTIFY colorChanged)
  Q_PROPERTY(qreal hue READ hue WRITE setHue NOTIFY hueChanged)
  Q_PROPERTY(qreal saturationF READ saturationF WRITE setSaturationF NOTIFY colorChanged)
  Q_PROPERTY(qreal lightnessF READ lightnessF WRITE setLightnessF NOTIFY colorChanged)
  Q_PROPERTY(qreal opacity READ opacity WRITE setOpacity NOTIFY opacityChanged)
  Q_PROPERTY(QImage image READ image NOTIFY imageChanged)

public:
  explicit AppState(QObject *parent = nullptr, RenderThread *thread = nullptr);
  ~AppState() override;

  Q_INVOKABLE void setColorFromCoordinates(double x, double y, double width, double height);
  Q_INVOKABLE void setHueFromCoordinates(double y, double height);
  Q_INVOKABLE void setOpacityFromCoordinates(double y, double height);
  Q_INVOKABLE void drawFromCoordinates(double x, double y, double width, double height);

  // This clears the image_layer and saves the image_source to m_image
  Q_INVOKABLE void swapBuffer();

  void setColor(QColor &color);
  QColor color() const;
  QColor colorOpaque() const;

  void setHue(qreal hue);
  qreal hue() const;

  void setSaturationF(qreal saturation);
  qreal saturationF() const;

  void setLightnessF(qreal lightness);
  qreal lightnessF() const;

  void setOpacity(qreal opacity);
  qreal opacity() const;

  QImage image() const;

signals:
  void hueChanged();
  void colorChanged();
  void opacityChanged();
  void imageChanged();

public slots:
private:
  qreal m_hue = 0.58;
  qreal m_saturation = 0.75;
  qreal m_lightness = 0.75;
  qreal m_opacity = 0.5;
  QColor m_color;
  QImage m_image;
  QImage m_image_layer;
  QImage m_image_source;
  QPoint *m_last_point;
  RenderThread *m_renderThread;
};

#endif // APPSTATE_H
