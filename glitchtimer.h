#ifndef GLITCHTIMER_H
#define GLITCHTIMER_H

#include <QObject>
#include <QImage>
#include <QTimer>
#include <QDebug>
#include <QTimerEvent>
#include <QTime>
#include <QEasingCurve>

#include "glitchpainter.h"

class GlitchTimer : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QImage image READ image NOTIFY imageChanged)
  Q_PROPERTY(QImage image READ image NOTIFY glitchStarted);
  Q_PROPERTY(QImage image READ image NOTIFY glitchCompleted)

public:
  explicit GlitchTimer(QObject *parent = nullptr);

  QImage image();
  void run(QImage &img);

signals:
  void imageChanged(QImage);
  void glitchStarted();
  void glitchCompleted();

public slots:

private:
  GlitchPainter m_painter;
  QImage m_image;
  QImage m_temp_image;
  qreal m_duration = 500;
  QTime m_time;
  int m_timerId = -1;
  QEasingCurve m_easing = QEasingCurve(QEasingCurve::OutInElastic);

protected:
  void restart();
  void stop();
  void timerEvent(QTimerEvent *event) override;

};

#endif // GLITCHTIMER_H
