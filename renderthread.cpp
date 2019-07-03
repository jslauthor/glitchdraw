#include <utility>

#include "renderthread.h"

RenderThread::RenderThread(QObject *parent) : QThread(parent)
{
  this->m_image = QImage();
  rgb_matrix::RGBMatrix::Options defaults;
  defaults.hardware_mapping = "regular";  // or e.g. "adafruit-hat"
  defaults.chain_length = 3;
  defaults.parallel = 2;
  defaults.brightness = 65;
  //    defaults.show_refresh_rate = true;
  rgb_matrix::RuntimeOptions runtime;
  runtime.drop_privileges = -1; // Need this otherwise the touchscreen doesn't work
  runtime.gpio_slowdown = 2;
  m_canvas = rgb_matrix::CreateMatrixFromOptions(defaults, runtime);
  if (m_canvas == nullptr) {
    qInfo("could not create matrix");
  }
}


RenderThread::~RenderThread()
{
  lock.lockForWrite();
  delete &m_image;
  m_canvas->Clear();
  delete m_canvas;
  lock.unlock();

  wait();
}

void RenderThread::render(QImage &image) {
  lock.lockForWrite();
  this->m_image = image;
  if (!isRunning()) {
    start(HighestPriority);
  }
  lock.unlock();
}

void RenderThread::run()
{
  forever {
    lock.lockForRead();
    QImage image = m_image;
    for (int y = 0; y < LED_HEIGHT; y++) {
      const QRgb *s = reinterpret_cast<const QRgb*>(image.constScanLine(y));
      const QRgb *end = s + LED_WIDTH;
      int x = 0;
      while (s < end) {
        m_canvas->SetPixel(x, y, qRed(*s), qGreen(*s), qBlue(*s));
        s++;
        x++;
      }
    }
    lock.unlock();
  }
}
