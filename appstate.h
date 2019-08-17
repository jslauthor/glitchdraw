#ifndef APPSTATE_H
#define APPSTATE_H

#define LED_HEIGHT_SCALE_FACTOR 0.9488627100244351
#define LED_WIDTH_SCALE_FACTOR 1.053893244444444
#define LED_TOTAL_POINTS LED_WIDTH * LED_HEIGHT

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
#include <array>
#include <chrono>
#include <QTouchEvent>
#include <QList>

#include "glitchtimer.h"
#include "graphics/graphicsutils.h"
#include "math/mathutils.h"
#include "renderthread.h"

struct MiniDisplay {
  Q_GADGET

  double m_widthPercent;
  double m_heightPercent;
  double m_xPercent;
  double m_yPercent;
  double m_scale;
  Q_PROPERTY(double widthPercent MEMBER m_widthPercent)
  Q_PROPERTY(double heightPercent MEMBER m_heightPercent)
  Q_PROPERTY(double xPercent MEMBER m_xPercent)
  Q_PROPERTY(double yPercent MEMBER m_yPercent)
  Q_PROPERTY(double scale MEMBER m_scale)

public:
  MiniDisplay(double w = 0., double h = 0., double x = 0., double y = 0., double s = 1.):
    m_widthPercent(w), m_heightPercent(h), m_xPercent(x), m_yPercent(y), m_scale(s) {}
};
Q_DECLARE_METATYPE(MiniDisplay);

namespace Brush {
  Q_NAMESPACE
  enum Brushes {
    circle=0,
    square=1
  };
  Q_ENUMS(Brushes)
}

namespace DrawMode {
  Q_NAMESPACE
  enum Modes {
    paint=0,
    erase=1
  };
  Q_ENUMS(Modes)
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
  qreal hardness = 1.;
  int size = 2;
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
  Q_PROPERTY(MiniDisplay miniDisplayValue READ miniDisplayValue NOTIFY miniDisplayValueChanged)
  Q_PROPERTY(DrawMode::Modes drawMode READ drawMode WRITE setDrawMode NOTIFY drawModeChanged)
  Q_PROPERTY(bool isGlitching READ isGlitching NOTIFY isGlitchingChanged)

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
  Q_INVOKABLE QString formatPopupLabel(int seconds, const QString& format) const;
  Q_INVOKABLE QColor getInvertedLightness(const QColor& color);

  // This clears the image_layer and saves the image_source to m_image
  Q_INVOKABLE void swapBuffer();
  Q_INVOKABLE void cancelDrawing();

  // This creates a new brush to use for painting
  Q_INVOKABLE void updateBrush();

  Q_INVOKABLE void resetZoom();

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

  Q_INVOKABLE qreal getOffset(qreal base, qreal scale);
  Q_INVOKABLE void setMiniDisplayValue(double x, double y, double width, double height, double scale);
  MiniDisplay miniDisplayValue();

  Q_INVOKABLE void setDrawMode(int type);
  DrawMode::Modes drawMode() const;

  bool isGlitching() const;

  void drawPoint(const QTouchEvent::TouchPoint& point, int width, int height);

signals:
  void hueChanged();
  void colorChanged();
  void opacityChanged();
  void imageChanged();
  void brushChanged();
  void countdownChanged();
  void glitchImminent();
  void isGlitchingChanged();
  void countdownTotalChanged();
  void miniDisplayValueChanged();
  void zoomReset();
  void drawModeChanged();

public slots:
  void updateCountdown();
  void onGlitchStarted();
  void onGlitchCompleted();
  void onImageChanged(QImage);

protected:
  bool eventFilter(QObject *obj, QEvent *event) override;

private:
  const QString ledTouchscreenId = QString("Multi touch   Multi touch overlay device");
  std::array<bool, LED_WIDTH * LED_HEIGHT> m_touchPointFlags;

  qreal m_hue = 0.58;
  qreal m_saturation = 0.75;
  qreal m_lightness = 0.75;
  qreal m_last_hue = 0.58;
  qreal m_last_saturation = 0.75;
  qreal m_last_lightness = 0.75;
  qreal m_opacity = 1.;
  QColor m_color;
  QImage m_image;
  QImage m_image_layer;
  QImage m_image_source;
  QImage m_brush_source;
  BrushAnatomy m_brush;
  DrawMode::Modes m_draw_mode = DrawMode::Modes::paint;
  QElapsedTimer m_elapsedTimer;
  int m_countdownTotal = 300;
  int m_countdown = m_countdownTotal;
  MiniDisplay m_miniDisplayValue;
  bool m_isGlitching = false;
  // Pointers
  QTimer *m_timer;
  RenderThread *m_renderThread;
  GlitchTimer *m_glitch_timer;
};

#endif // APPSTATE_H
