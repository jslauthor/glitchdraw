#include <utility>

#include "appstate.h"

AppState::AppState(QObject *parent, RenderThread *thread) : QObject(parent) {
  m_color = QColor();
  m_color.setHsvF(m_hue, m_saturation, m_lightness, m_opacity);

  m_image = QImage(LED_WIDTH, LED_HEIGHT, QImage::Format_ARGB32_Premultiplied);
  m_image.fill(Qt::transparent);

  m_glitch_timer = new GlitchTimer(this);
  connect(m_glitch_timer, &GlitchTimer::glitchStarted, this, &AppState::onGlitchStarted);
  connect(m_glitch_timer, &GlitchTimer::glitchCompleted, this, &AppState::onGlitchCompleted);
  connect(m_glitch_timer, &GlitchTimer::imageChanged, this, &AppState::onImageChanged);

  m_timer = new QTimer(this);
  connect(m_timer, &QTimer::timeout, this, &AppState::updateCountdown);
  restartCountdown();

  m_renderThread = thread;
  swapBuffer();

  m_renderThread->render(m_image);
  updateBrush();
}

AppState::~AppState() {
  delete m_renderThread;
  m_timer->stop();
  delete m_timer;
  delete m_glitch_timer;
}

void AppState::setHue(qreal hue) {
  // comparing doubles in c++ is weird
  if (fabs(hue - m_hue) >= std::numeric_limits<double>::epsilon()) {
    m_hue = hue;
    emit hueChanged();
  }
}

qreal AppState::hue() const {
  return m_hue;
}

void AppState::setColor(QColor &color) {
  if (color != m_color) {
    m_color = color;
    emit colorChanged();
    emit hueChanged();
  }
}

QColor AppState::color() const {
  return m_color;
}

// Return the opaque color
QColor AppState::colorOpaque() const {
  QColor newColor = QColor(m_color);
  newColor.setAlphaF(1.);
  return newColor;
}

void AppState::cancelDrawing() {
  m_image = QImage(m_image_source);
  swapBuffer();
  emit imageChanged();
  m_renderThread->render(m_image);
}

void AppState::swapBuffer() {
  m_image_source = QImage(m_image);
  m_image_layer = QImage(m_image);
  m_image_layer.fill(QColor(0, 0, 0, 0));
  m_touchPointFlags.fill(false);

// Useful for saving an image
//  QImageWriter writer("/images/layer.png", "PNG");
//  qInfo("%d", writer.write(m_image_layer));
//  QString boop(writer.errorString());
//  qInfo(boop.toLatin1());
}

void AppState::updateBrush() {
  QImage qpix(m_brush.size, m_brush.size, QImage::Format_ARGB32_Premultiplied);
  qpix.fill(Qt::transparent);
  QPainter paint;
  paint.begin(&qpix);
  switch (m_brush.type) {
    case Brush::circle: {
      QRadialGradient gradient(m_brush.size/2., m_brush.size/2., m_brush.size);
      gradient.setColorAt(0, m_color);
      gradient.setColorAt(m_brush.hardness/2., m_color);
      QColor newColor(m_color);
      newColor.setAlphaF(0.);
      gradient.setColorAt(.51, newColor);
      QBrush brush(gradient);
      paint.setBrush(brush);
      paint.fillRect(0, 0, m_brush.size, m_brush.size, brush);
      break;
    }
    case Brush::square: {
      paint.fillRect(0, 0, m_brush.size, m_brush.size, m_color);
      break;
    }
    default:
      break;
  }
  paint.end();
  m_brush_source = qpix;
}

void AppState::drawFromCoordinates(double x, double y, double width, double height) {

  restartCountdown();
  QPoint point(
    qRound(qBound(0., x / width, 1.) * LED_WIDTH),
    qRound(qBound(0., y / height, 1.) * LED_HEIGHT)
  );

  int flagIndex = qBound(0, (point.x() + point.y()) + (point.y() * LED_WIDTH), LED_TOTAL_POINTS - 1);
  if (m_touchPointFlags.at(flagIndex)) {
    // since our layer does draw not the same coordinate twice, skip drawing.
    return;
  }

  m_touchPointFlags.at(flagIndex) = true;

  //TODO: Make color selector circle bobble big on drag like Procreate
  //TODO: Add cool circle thingie to HSBSpectrum (https://www.shadertoy.com/view/ltBXRc)
  // TODO: Remove decay in glitch shader?

  // Create a new layer and paint onto it
  // This technique is unlikely to work for large images :/
  QImage new_layer(m_image_layer.size(), QImage::Format_ARGB32_Premultiplied);
  new_layer.fill(Qt::transparent);
  QPainter paint;
  paint.begin(&new_layer);
  int half_brush_size = m_brush.size/2;

  paint.drawImage(point.x()-half_brush_size, point.y()-half_brush_size, m_brush_source);
  paint.end();

  // Merge the new layer and do not allow it to go above alpha threhold (acts like photoshop)
  m_image_layer = GraphicsUtils::mergeImages(m_image_layer, new_layer, m_color.alpha());

  // Paint m_image_layer onto copied m_image_source
  // and update m_image
  QImage original(m_image_source);
  paint.begin(&original);
  if (m_draw_mode == DrawMode::erase) {
    paint.setCompositionMode(QPainter::CompositionMode_DestinationOut);
  }
  paint.drawImage(m_image_layer.rect(), m_image_layer);
  paint.end();
  m_image = original;

  emit imageChanged();
  m_renderThread->render(m_image);
}

void AppState::setColorFromCoordinates(double x, double y, double width, double height) {
  // Matches algorithm in glsl shader in HSBSpectrum
  setSaturationF(qBound(0., x / width, 1.));
  setLightnessF(qBound(0., 1 - (y / height), 1.));
  QColor newColor = QColor();
  newColor.setHsvF(hue(), m_saturation, m_lightness, m_opacity);
  setColor(newColor);
  updateBrush();
}

void AppState::setHueFromCoordinates(double y, double height) {
  // Matches algorithm in glsl shader in HueGradient
  qreal hue = qBound(0., y / height, 1.);
  QColor newColor = QColor();
  newColor.setHsvF(hue, m_saturation, m_lightness, m_opacity);
  setColor(newColor);
  setHue(hue);
  updateBrush();
}

void AppState::setOpacityFromCoordinates(double y, double height) {
  setOpacity(qBound(0., y / height, 1.));
  QColor newColor = QColor();
  newColor.setHsvF(m_hue, m_saturation, m_lightness, m_opacity);
  setColor(newColor);
  updateBrush();
}

void AppState::setSaturationF(qreal saturation) {
  m_saturation = saturation;
}

qreal AppState::saturationF() const {
  return m_saturation;
}

void AppState::setLightnessF(qreal lightness) {
  m_lightness = lightness;
}

qreal AppState::lightnessF() const {
  return m_lightness;
}

void AppState::setOpacity(qreal opacity) {
  if (fabs(opacity - m_opacity) >= std::numeric_limits<double>::epsilon()) {
    m_opacity = opacity;
    emit opacityChanged();
  }
}

qreal AppState::opacity() const {
  return m_opacity;
}

QImage AppState::image() const {
  return m_image;
}

void AppState::setBrush(const BrushAnatomy& brush) {
  m_brush = brush;
  emit brushChanged();
}

BrushAnatomy AppState::brush() const {
  return m_brush;
}

void AppState::setBrushSize(int size) {
  m_brush.size = size;
  emit brushChanged();
}

void AppState::setBrushHardness(qreal hardness) {
  m_brush.hardness = hardness;
  emit brushChanged();
}

void AppState::setBrushType(int type) {
  // totally lame that we can't use the native enum from QML
  switch(type) {
    case 0:
      m_brush.type = Brush::circle;
      break;
    case 1:
      m_brush.type = Brush::square;
      break;
    default:
      break;
  }

  emit brushChanged();
}

void AppState::setDrawMode(int type) {
  QColor newColor = QColor();
  // totally lame that we can't use the native enum from QML
  switch(type) {
    case 0:
      m_draw_mode = DrawMode::Modes::paint;
      m_hue = m_last_hue;
      m_saturation = m_last_saturation;
      m_lightness = m_last_lightness;
      newColor.setHsvF(m_last_hue, m_last_saturation, m_last_lightness, m_opacity);
      setColor(newColor);
      break;
    case 1:
      m_draw_mode = DrawMode::Modes::erase;
      m_last_hue = m_hue;
      m_last_saturation = m_saturation;
      m_last_lightness = m_lightness;
      m_hue = 0.;
      m_saturation = 0.;
      m_lightness = 0.;
      newColor.setHsvF(m_hue, m_saturation, m_lightness, m_opacity);
      setColor(newColor);
      break;
    default:
      break;
  }

  emit drawModeChanged();
}
DrawMode::Modes AppState::drawMode() const {
  return m_draw_mode;
}

void AppState::clearCanvas() {
  m_image.fill(Qt::transparent);
  swapBuffer();
  emit imageChanged();
  restartCountdown();
  m_renderThread->render(m_image);
}

QString AppState::formatPopupLabel(int seconds, const QString& format) const {
  QTime time = QTime(0,0,0,0);
  return time.addSecs(seconds).toString(format);
}

QString AppState::formatTime(int seconds, const QString& format) const {
  QTime time = QTime(0,0,0,0);
  return time.addSecs(seconds).addMSecs(1000 - m_elapsedTimer.elapsed()).toString(format);
}

QString AppState::countdownLabel() const {
  return formatTime(m_countdown - 1, "m:ss");
}

QString AppState::countdownMsLabel() const {
  return formatTime(m_countdown, ".z");
}

qreal AppState::getCountProgress() {
  float percent =
      1. - static_cast<float>((m_countdown - 1) * 1000 + 1000 - m_elapsedTimer.elapsed())
      / static_cast<float>(m_countdownTotal * 1000);
  return std::max(GraphicsUtils::getGlitchAmountForCountdown(percent), 0.);
}

void AppState::restartCountdown() {
  m_countdown = m_countdownTotal;
  m_timer->start(24);
  m_elapsedTimer.restart();
  emit countdownChanged();
}

void AppState::updateCountdown() {
  if (m_elapsedTimer.elapsed() >= 1000) {
    m_countdown--;
    m_elapsedTimer.restart();
  }

  if (m_countdown <= 0) {
    emit glitchImminent();
    m_timer->stop();
    m_glitch_timer->run(m_image);
  }
  emit countdownChanged();
}

bool AppState::isGlitching() const {
  return m_isGlitching;
}

void AppState::onGlitchStarted() {
  m_isGlitching = true;
  emit isGlitchingChanged();
}

void AppState::onGlitchCompleted() {
  swapBuffer();
  restartCountdown();

  m_isGlitching = false;
  emit isGlitchingChanged();
}

void AppState::onImageChanged(QImage image) {
  m_image = QImage(std::move(image));
  emit imageChanged();
  m_renderThread->render(m_image);
}


void AppState::setCountdownTotal(int total) {
  m_countdownTotal = total;
  restartCountdown();
  emit countdownTotalChanged();
}

int AppState::countdownTotal() const {
  return m_countdownTotal;
}

qreal AppState::getOffset(qreal base, qreal scale) {
  return (scale * base - base) / 2.;
}

void AppState::setMiniDisplayValue(double x, double y, double width, double height, double scale) {
  qreal rootX = getOffset(width, scale) - x;
  qreal rootY = getOffset(height, scale) - y;

  m_miniDisplayValue = MiniDisplay(
    (width / scale) / width,
    (height / scale) / height,
    std::max(0., (rootX / scale) / width),
    std::max(0., (rootY / scale) / height),
    scale
  );

  emit miniDisplayValueChanged();
}

MiniDisplay AppState::miniDisplayValue() {
  return m_miniDisplayValue;
}

void AppState::resetZoom() {
  emit zoomReset();
}

void AppState::drawPoint(const QTouchEvent::TouchPoint &point, int width, int height)
{
  // What's up with all these magic numbers? 20 and -12 are the amount of offset
  // required to scale the bezel to the LED screens based on their differing aspect ratios
  const auto x = MathUtils::scaleRange(point.pos().x(), 20., width - 20, 0., width);
  const auto y = MathUtils::scaleRange(point.pos().y(), -12., height + 12., 12., height - 12.);
  drawFromCoordinates(x, y, width, height);
}

bool AppState::eventFilter(QObject *obj, QEvent *event)
{

  if (event->type() == QEvent::TouchBegin || event->type() == QEvent::TouchUpdate || event->type() == QEvent::TouchEnd) {
    auto *touchEvent = dynamic_cast<QTouchEvent *>(event);

    if (touchEvent->device()->name() == ledTouchscreenId) {
      switch (event->type()) {
        case QEvent::TouchBegin: {
          updateBrush();
          for (const auto& point : touchEvent->touchPoints()) {
            drawPoint(point, touchEvent->window()->width(), touchEvent->window()->height());
          }
          break;
        }
        case QEvent::TouchUpdate: {
          auto newTime = std::chrono::high_resolution_clock::now();
          std::chrono::duration<double> elapsed = newTime - lastDurationForEventFilter;
          // throttle the input since it comes in at 450hz and kills the pi
          if (elapsed.count() >= 0.02) {
            for (const auto& point : touchEvent->touchPoints()) {
              lastDurationForEventFilter = newTime;
              drawPoint(point, touchEvent->window()->width(), touchEvent->window()->height());
            }
          }
          break;
        }
        case QEvent::TouchEnd:
          swapBuffer();
          break;
      }
      return true; // do not propagate event
    }
  }

  return QObject::eventFilter(obj, event);
}
