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
#include <QLineF>
#include <QPointF>
#include <QTimer>
#include <QDateTime>
#include <QTime>
#include <QDebug>
#include <QElapsedTimer>

#include "glitchtimer.h"
#include "graphics/graphicsutils.h"
#include "renderthread.h"

namespace Brush {
  Q_NAMESPACE
  enum Brushes {
    circle=0,
    square=1
  };
  Q_ENUMS(Brushes)
}

// Data for the brush
class BrushAnatomy: public QObject {
  Q_GADGET
  Q_PROPERTY(Brush::Brushes type MEMBER type);
  Q_PROPERTY(qreal hardness MEMBER hardness);
  Q_PROPERTY(int size MEMBER size);
public:
  BrushAnatomy() = default;
  BrushAnatomy(const BrushAnatomy &copy) {
    type = copy.type;
    hardness = copy.hardness;
    size = copy.size;
  }
  BrushAnatomy& operator= (const BrushAnatomy &copy) {
    type = copy.type;
    hardness = copy.hardness;
    size = copy.size;
    return *this;
  }
  ~BrushAnatomy() override = default;
  Brush::Brushes type = Brush::Brushes::circle;
  qreal hardness = .5;
  int size = 10;
};
Q_DECLARE_METATYPE(BrushAnatomy);

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
  Q_PROPERTY(BrushAnatomy brush READ brush WRITE setBrush NOTIFY brushChanged)
  Q_PROPERTY(QString countdownLabel READ countdownLabel NOTIFY countdownChanged)
  Q_PROPERTY(QString countdownMsLabel READ countdownMsLabel NOTIFY countdownChanged)
  Q_PROPERTY(int countdownTotal READ countdownTotal WRITE setCountdownTotal NOTIFY countdownTotalChanged)

public:
  explicit AppState(QObject *parent = nullptr, RenderThread *thread = nullptr);
  ~AppState() override;

  Q_INVOKABLE void setColorFromCoordinates(double x, double y, double width, double height);
  Q_INVOKABLE void setHueFromCoordinates(double y, double height);
  Q_INVOKABLE void setOpacityFromCoordinates(double y, double height);
  Q_INVOKABLE void drawFromCoordinates(double x, double y, double width, double height);
  Q_INVOKABLE void setBrushType(int type);
  Q_INVOKABLE void setBrushSize(int size);
  Q_INVOKABLE void setBrushHardness(qreal hardness);
  Q_INVOKABLE void clearCanvas();
  Q_INVOKABLE qreal getCountProgress();
  Q_INVOKABLE QString formatTime(int seconds, const QString& format) const;

  // This clears the image_layer and saves the image_source to m_image
  Q_INVOKABLE void swapBuffer();

  // This creates a new brush to use for painting
  Q_INVOKABLE void updateBrush();

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
  QString countdownLabel() const;
  QString countdownMsLabel() const;

  void setBrush(const BrushAnatomy& brush);
  BrushAnatomy brush() const;

  Q_INVOKABLE void setCountdownTotal(int total);
  int countdownTotal() const;

  void restartCountdown();

signals:
  void hueChanged();
  void colorChanged();
  void opacityChanged();
  void imageChanged();
  void brushChanged();
  void countdownChanged();
  void glitchImminent();
  void countdownTotalChanged();

public slots:
  void updateCountdown();
  void onGlitchStarted();
  void onGlitchCompleted();
  void onImageChanged(QImage);

private:
  qreal m_hue = 0.58;
  qreal m_saturation = 0.75;
  qreal m_lightness = 0.75;
  qreal m_opacity = 0.5;
  QColor m_color;
  QImage m_image;
  QImage m_image_layer;
  QImage m_image_source;
  QImage m_brush_source;
  BrushAnatomy m_brush;
  QElapsedTimer m_elapsedTimer;
  int m_countdownTotal = 300;
  int m_countdown = m_countdownTotal;
  // Pointers
  QTimer *m_timer;
  QPoint *m_last_point;
  RenderThread *m_renderThread;
  GlitchTimer *m_glitch_timer;
};

#endif // APPSTATE_H
