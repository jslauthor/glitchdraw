#include "glitchtimer.h"

GlitchTimer::GlitchTimer(QObject *parent) : QObject(parent)
{
}

QImage GlitchTimer::image() {
  return m_image;
}

void GlitchTimer::run(QImage &img) {
  m_image = img;
  this->restart();
}

void GlitchTimer::restart() {
  this->stop();
  m_temp_image = QImage(m_image);
  m_ranges = m_painter.generateRanges(15, m_temp_image.size().height());
  m_timerId = startTimer(16);
  m_time.restart();
  emit glitchStarted();
}

void GlitchTimer::stop() {
  if (m_timerId != -1)
    killTimer(m_timerId);
  m_timerId = -1;
}

void GlitchTimer::timerEvent(QTimerEvent * /*event*/)
{
  qreal durationProgress = m_time.elapsed() / m_duration;
  qreal percent = m_easing.valueForProgress(durationProgress);
  if (durationProgress >= 1.) {
    this->stop();
    emit glitchCompleted();
  }

  m_image = m_painter.paint(m_temp_image, m_ranges, percent, m_time.elapsed(), .25);
  emit imageChanged();
}
